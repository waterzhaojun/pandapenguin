function res = correlation_table_running_bv(explist)
% This function is to produce a struct table containing all correlation
% info.
% explist element should be cell containing animal, date, run.
% I am planning to use diameter_running_corAnalysis to replace this
% function. 

res = struct();
p=0;
for i = 1:size(explist,1)
    df = get_bout_idx(explist{i,1},explist{i,2},explist{i,3});
    
    bvpaths = bvfiles(explist{i,1},explist{i,2},explist{i,3});
    bvpaths = bvpaths.layerfolderpath;
    
    for j = 1:length(bvpaths)
        bvresultfile = [bvpaths{j}, 'result.mat'];
    	bv = load(bvresultfile);
        bv = bv.result;
        bvscanrate = bv.scanrate;
        for k = 1:length(bv.roi)
            roi = bv.roi{k};
            for m = 1:length(df) % check each bout.
                try
                    res(p+1).animal = explist{i,1};
                    res(p+1).date = explist{i,2};
                    res(p+1).run = explist{i,3};
                    res(p+1).runboutidx = m;
                    res(p+1).runstartidx = df(m).startidx;
                    res(p+1).rundirection = df(m).direction;
                    res(p+1).runscanrate = df(m).scanrate;

                    res(p+1).bvresultfile = bvresultfile;
                    res(p+1).bvroiidx = k;
                    res(p+1).bvscanrate = bvscanrate;
                    res(p+1).bvstartidx = translateIdx(res(p+1).runstartidx, ...
                        res(p+1).runscanrate,...
                        res(p+1).bvscanrate);
                    res(p+1).bvtype = roi.type;
                    res(p+1).bvtissue = roi.tissue;
                    res(p+1).bvposition = roi.position;

                    p = p+1;
                catch
                    disp(['error: ',explist{i,1},'-',explist{i,2},'-run',num2str(explist{i,3})]);
                end
            end
        end
    end
    
end


end