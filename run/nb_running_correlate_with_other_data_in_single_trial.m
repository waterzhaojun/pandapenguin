
% This notebook is to analyse running and related data responses


%% Setting part =============================================
googleSheetID = '19teR3WvTd_yE2m-cNahoUNnIvrzK6--tCTM4YZ6pwbQ'; % <== This is where the data sheet is.
preBoutSec = 3;  %<=========== Analyse 3s before start of the bout.
postBoutSec = 5; %<=========== Analyse 5s after the start of the bout.
root = 'C:\Users\Levylab\jun\Drew_bout\';  %<=============  Where you want to save the analyzed data
lists = [110]%110,128,189];  %<============== which data sheet lines do you want to analyze.

plotIndividual = false;

%% Code part. Don't change code below =======================
explist = load_exp(googleSheetID);
for expi = lists
    animal = explist(expi).animal;
    date = explist(expi).date;
    run = str2num(explist(expi).run);
    runtask = explist(expi).running_task;
    bvtask = explist(expi).bv_task;
    alignmenttask = explist(expi).alignment_task;
    group = explist(expi).situation;
    boutNum = str2num(explist(expi).bouts_num);
    scanmode = explist(expi).scanmode;
    
    if strcmp(runtask, 'Done') && strcmp(bvtask, 'Done') && (boutNum > 0) && strcmp(group, 'baseline') && strcmp(scanmode, '2D')%&& strcmp(alignmenttask, 'Done') 
        disp(['find ', animal, ' ', date, ' run', num2str(run), ' finished treatment']); 
        report_root = [root, animal, '_', date, '_run', num2str(run),'\'];
        if exist(report_root, 'dir')
           rmdir(report_root, 's');
        end
        
        
%         runresultfile = sbxPath(animal, date, run, 'running');
%         copyfile([runresultfile.folder,'\response.pdf'], [report_root, 'running bout.pdf']);

        runoridatapath = sbxPath(animal, date, run, 'running');
        runoridata=load(runoridatapath.result);
        runoridata = runoridata.result;
        rundata = extractRunningData(animal, date, run, preBoutSec, postBoutSec);
        bvdata = extractBvData(animal, date, run);
        df = runningCorrelationAnalysis(...
            rundata, {bvdata}, ...
            {'bv_'}, ...
            {{'diameter'}}...
        );
    
        % add filter here =========
        df = df(strcmp({df.bv_tissue}, 'pia'));
        df = df(strcmp({df.bv_type}, 'artery'));
        df = df(strcmp({df.bv_position}, 'horizontal'));
        if length(df) == 0
            continue
        end
        
        
        disp('Got some data =========================================');
        mkdir(report_root);
        alen = length(runoridata.array_treated);
        arate = runoridata.scanrate;
        timecourseLength = length(df(1).runningcorArray);
        longtimecourseLength = length(runoridata.array_treated);
        boutID = unique({df.runningboutID});
        boutIDnumpart = [];
        for boutIDi = 1:length(boutID)
            tmp = strsplit(boutID{boutIDi}, 'bout');
            boutIDnumpart = [boutIDnumpart, str2num(tmp{2})];
        end
        [~,boutIDsortIdx] = sort(boutIDnumpart);
        boutID = {boutID{boutIDsortIdx}};
            
        if plotIndividual
            c = 4;
            r = ceil(length(boutID)/c) + 2 + 1;
            %c = length(boutID);
            figure('Position', [10 10 400*c 600*1.2*r]);
            tiledlayout(r,c)
            % Plot multiple timecourse. =====================
            for i = 1:length(boutID)
                theboutID = boutID{i};
                subdf = df(strcmp({df.runningboutID}, theboutID));
                subbvmx = reshape([subdf.bv_diameter_bout_timecourse_realvalue], timecourseLength, []);

                nexttile %vFor treated data=====================================
                yyaxis left
                plot(subbvmx);
    %             bvresponse_legend = {};
    %             % format the legend text
    %             for tmplegendi = 1:length(subdf)
    %                 bvresponse_legend{tmplegendi} = [subdf(tmplegendi).bv_id, ' (', subdf(tmplegendi).bv_tissue, ' ', subdf(tmplegendi).bv_type,')'];
    %             end
    %             bvresponse_legend{length(bvresponse_legend)+1} = ['running'];
                ylabel('diameter (um)');
                ylim([min(10, min(subbvmx, [], 'all')), max(40, max(subbvmx, [], 'all'))]);

                yyaxis right
                bar(subdf(1).runningcorArray, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                xticks(1:arate:timecourseLength);
                xticklabels(-preBoutSec:1:postBoutSec);
                xlabel('time course (sec)');
                ylabel('speed (m/s)');
                ylim([0, max(0.1, max(subdf(1).runningcorArray))]);
                title(strrep(subdf(1).runningboutID, '_', '\_'));
    %             legend(bvresponse_legend, 'location', 'southoutside', 'orientation', 'horizontal');

            end
        end
        
        % plot whole time course ==================================
        if plotIndividual
            nexttile([2,c]);
        else
            figure('Position', [10 10 2000 1500]);
        end
        yyaxis left
        bvWholeTimeCourseMx = reshape([bvdata.diameter], [], length(bvdata));
%         newcolors = [0.83 0.14 0.14
%             1.00 0.54 0.00
%             0.47 0.25 0.80
%             0.25 0.80 0.54];
%         colororder(newcolors);
        plot(bvWholeTimeCourseMx);
        ylabel('diameter (um)');
        ylim([min(10, min(bvWholeTimeCourseMx, [], 'all')), max(40, max(bvWholeTimeCourseMx, [], 'all'))]);
        
        yyaxis right
        %bar(runoridata.array_treated);
        plot_running_realfs(runoridata);
        xticks(1:arate*60:longtimecourseLength);
        xticklabels(0:1:floor(longtimecourseLength/arate/60));
        xlabel('time course (min)');
        ylabel('speed (cm/s)');
        
        bvlong_legend = {};
        % format the legend text
        for tmplegendi = 1:length(bvdata)
            bvlong_legend{tmplegendi} = [bvdata(tmplegendi).id, ' (', bvdata(tmplegendi).tissue, ' ', bvdata(tmplegendi).type,')'];
        end
        bvlong_legend{length(bvlong_legend)+1} = ['running'];
        legend(bvlong_legend, 'location', 'southoutside', 'orientation', 'horizontal');
        
%         show table ===============================
%         nexttile([1,c]);
%         rundataAnaFields = {'duration', 'speed', 'distance', 'maxspeed', 'maxspeed_delay', 'acceleration'};
%         
%         T = struct2table(rundata);
%         T = T(:,rundataAnaFields);
%         uitable('Data',T{:,:}, ...
%             'ColumnName',rundataAnaFields,...
%             'ColumnFormat',{'char','numeric', 'numeric','numeric','numeric','numeric','numeric'},...
%             'RowName', []...%T.Properties.RowNames
%         );
%         %T = table(Age,Height,Weight,'RowNames',LastName);
%         uitable('Data',T{:,:}, 'ColumnName',T.Properties.VariableNames,...
%             'RowName',T.Properties.RowNames,'Position',[0, 0, 1,1/r]);
        exportgraphics(gcf,[report_root, 'correlation response.pdf']);%,'ContentType','vector')
        save([report_root, 'corr_data.mat'], 'df');
        %close;
    end
    
    
end


