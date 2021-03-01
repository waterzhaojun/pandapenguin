function loco = GetLocoState(expt, loco, varargin)
% Determine locomotive state using a Hidden Markov Model
IP = inputParser;
addRequired( IP, 'expt', @isstruct )
addRequired( IP, 'loco', @isstruct )
addParameter( IP, 'Nstate', 2, @isnumeric ) % Nstate = 2; % still/minor running, major running
addParameter( IP, 'loadDir', 'D:\MATLAB\LevyLab\', @ischar )
addParameter( IP, 'show', false, @islogical )
parse( IP, expt, loco, varargin{:} ); 
Nstate = IP.Results.Nstate;
show = IP.Results.show;
loadDir = IP.Results.loadDir;
%Nexpt = numel(loco);

% Load master HMM
loadPath = sprintf('%sLocoHMM_%istate.mat', loadDir, Nstate);
if exist(loadPath, 'file')
    fprintf('\nLoading %s', loadPath);
    load(loadPath, 'speedRange', 'transEst', 'transGuess', 'emitEst', 'emitGuessPDF', 'Nemit', 'stateName') % 'speedInt', 
else
    error('%s does not exist!', loadPath);
end

% Discretize speed data (matlab can't handle continuous HMM) and pool across experiments/runs
%speedRange = 0:speedInt:40; 

for r = 1:numel(loco)
    % Discretize the data
    loco(r).speedDiscrete = imquantize( vertcat( loco(r).speedDown ), speedRange ); % Down  speedDiscreteExpt 
    % Fit individual speed data sets to the HMM trained from the pooled data
    loco(r).state = hmmviterbi( imquantize( vertcat( loco(r).speed ), speedRange )', transEst, emitEst )';
    loco(r).stateDown = hmmviterbi( loco(r).speedDiscrete', transEst, emitEst )'; 
    %loco(r).stateDown = max(reshape( loco(r).state, [], expt.Nplane ), [], 2); %down sample for volume scan using modal state within the scan
    loco(r).stateBinary = false( size(loco(r).stateDown, 1), Nstate );
    for n = 1:Nstate
        loco(r).stateBinary(:,n) = loco(r).stateDown == n; 
    end      
end


% Compare the estimated model parameters to the guess
if show
    close all;
    figure('Units','normalized','OuterPosition',[0.5,0,0.5,1]);   
    subplot(3,1,1); plot( emitGuessPDF', '--' ); hold on; 
    plot( emitEst' ); 
    speedLevelTicks = 1:50:Nemit;
    set(gca,'Xtick',speedLevelTicks, 'XtickLabel', speedRange( speedLevelTicks ) );
    xlabel('Speed'); ylabel('Emission Probability Density');
    %xlim([0,20]);
    
    subplot(3,1,2); imagesc( transGuess); axis square; title('Guessed Transition Probabilities'); set(gca,'Xtick',1:Nstate, 'XtickLabel',stateName,'Ytick',1:Nstate, 'YtickLabel',stateName);
    text(1,1, sprintf('%2.4f',transGuess(1,1)), 'color','k', 'HorizontalAlignment','center' );
    text(2,1, sprintf('%2.4f',transGuess(2,1)), 'color','w', 'HorizontalAlignment','center' );
    text(1,2, sprintf('%2.4f',transGuess(1,2)), 'color','w', 'HorizontalAlignment','center' );
    text(2,2, sprintf('%2.4f',transGuess(2,2)), 'color','k', 'HorizontalAlignment','center' );
    
    subplot(3,1,3); imagesc( transEst); axis square; title('Estimated Transition Probabilities'); set(gca,'Xtick',1:Nstate, 'XtickLabel',stateName,'Ytick',1:Nstate, 'YtickLabel',stateName);
    text(1,1, sprintf('%2.4f',transEst(1,1)), 'color','k', 'HorizontalAlignment','center' );
    text(2,1, sprintf('%2.4f',transEst(2,1)), 'color','w', 'HorizontalAlignment','center' );
    text(1,2, sprintf('%2.4f',transEst(1,2)), 'color','w', 'HorizontalAlignment','center' );
    text(2,2, sprintf('%2.4f',transEst(2,2)), 'color','k', 'HorizontalAlignment','center' );
    colormap('gray'); 
    impixelinfo;
    
    figure('Units','normalized','OuterPosition',[0,0,0.5,1])
    subplot(2,1,1);
    yyaxis left; 
    plot( vertcat(loco.speed) ); %plot( loco(r).speed ); 
    ylabel('Speed'); xlabel('Frame');
    yyaxis right; 
    plot( vertcat(loco.state) -1, 'color',[1,0,0,0.3] ); %plot( loco(r).state -1, 'color',[1,0,0,0.4] );  % , 'LineStyle','--'
    set(gca,'Ytick',0:Nstate-1, 'box','off');
    ylim([0,Nstate-1+0.2]);
    ylabel('Locomotive State');
    xlim([-Inf,Inf]);
    
    subplot(2,1,2);
    yyaxis left; 
    plot( vertcat(loco.speedDown) ); %plot( loco(r).speed ); 
    ylabel('Downsampled Speed'); xlabel('Frame');
    yyaxis right; 
    plot( vertcat(loco.stateDown) -1, 'color',[1,0,0,0.3] ); %plot( loco(r).state -1, 'color',[1,0,0,0.4] );  % , 'LineStyle','--'
    set(gca,'Ytick',0:Nstate-1, 'box','off');
    ylim([0,Nstate-1+0.2]);
    ylabel('Downsampled Locomotive State');
    xlim([-Inf,Inf]);
    %{
    for r = 1:numel(loco)
        yyaxis left; 
        plot( vertcat(loco.speed) ); %plot( loco(r).speed ); 
        ylabel('Downsampled Speed'); xlabel('Frame');

        yyaxis right; 
        plot( vertcat(loco.state) -1, 'color',[1,0,0,0.4] ); %plot( loco(r).state -1, 'color',[1,0,0,0.4] );  % , 'LineStyle','--'
        set(gca,'Ytick',0:Nstate-1, 'box','off');
        ylim([0,Nstate-1+0.2]);
        ylabel('Locomotive State');
        xlim([-Inf,Inf]);
        pause; cla;
    end
    %}
end
end

%{
close all; clearvars sp;
figure('WindowState','maximized');
for r = 1 % find(~cellfun(@isempty, {loco.quad}))
    sp(1) = subplot(4,1,1); plot( loco(r).speedDown ); ylabel('Downsampled Speed'); ylim([0,30]); box off;
    sp(2) = subplot(4,1,2); plot( loco(r).speedDiscrete ); ylabel('Discretized Speed'); ylim([0,30]); box off;
    sp(3) = subplot(4,1,3); plot( loco(r).state ); ylabel('Locomotive State'); ylim([1,Nstate]); box off;
    sp(4) = subplot(4,1,4); plot( loco(r).stateBinary(:,2) ); ylabel('Run State'); ylim([0,1]); box off;
    linkaxes(sp,'x');
    %pause; cla;
end
%}
