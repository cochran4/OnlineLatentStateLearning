function RunWilsonBoumphreyPearce
% Visualize results from Wilson, Boumphrey, Pearce example

% Close current figures
close all

% Models
mdls  = {'LatentState','Hybrid','RescorlaWagner',...
         'fRLDecay','InfiniteMixture','Gershman2017',...
         'Gershman2017_alpha1','Redish2007'};

% Run example
par = PatientParameters;
RunExample('WilsonBoumphreyPearce',mdls,1,{'C','E'},par)

% Load data
load('Results_WilsonBoumphreyPearce')

% Schedules
groupE = [repmat([1,2],1,5),repmat([1,3],1,20),repmat(4,1,10)];
groupC = [repmat([1,2],1,25),repmat(4,1,10)];
possibleOutcomes = [1,1,1; 0,1,1; 0,1,0; 1,1,0];


% Get color scheme
Colors

%-------------------------------------------------------------------------
% Plot Schedule
figure(1)
PrettyFig('',[0.5 3.5],[0 61],[30,60])
for t=1:60
    title('Group E Schedule')
    hold on
    for j=1:3
        tmp  = possibleOutcomes(groupE(t),j);
        clr0 = clr(j,:)*tmp + [1,1,1]*(1-tmp);
        patch([t-0.5; t-0.5; t+0.5; t+0.5],[j-0.5; j+0.5; j+0.5; j-0.5],clr0,'FaceAlpha',0.75,'EdgeColor','none')
    end
    set(gca,'YTIck',[1,2,3],'YTickLabel',{'Food','Light','Tone'});
end
set(gcf,'Position',[50 50 600 500])
print('GroupE_Schedule','-dpng','-r300')

figure(2)
PrettyFig('',[0.5 3.5],[0 61],[30,60])
for t=1:60
    title('Group C Schedule')
    hold on
    for j=1:3
        tmp  = possibleOutcomes(groupC(t),j);
        clr0 = clr(j,:)*tmp + [1,1,1]*(1-tmp);
        patch([t-0.5; t-0.5; t+0.5; t+0.5],[j-0.5; j+0.5; j+0.5; j-0.5],clr0,'FaceAlpha',0.75,'EdgeColor','none')
    end
    set(gca,'YTIck',[1,2,3],'YTickLabel',{'Food','Light','Tone'});
end
set(gcf,'Position',[50 50 600 500])
print('GroupC_Schedule','-dpng','-r300')
%-------------------------------------------------------------------------
% Shortened model names
mdlnme  = {'LS','HB','RW',...
           'FD','IM','GM',...
           'GM1','RD'};

% Visualize
for k=1:length(mdls)
    figure(6 + 100+k)
    PrettyFig('',[-1/2 1/2]*(k==1 || k==1) + [0 1]*(k~=1 && k~=1),[45.5 61],[50,60])
    ylabel('Associative strength','FontWeight','bold','FontSize',24)
    %title(mdlnme{k}) 
    symb = {'-','-'};
    hold on
    plot( V{k,1}(1:end-1,1,1),symb{1},'Color',clr(2,:)*1,   'LineWidth',4,'MarkerSize',8)
    plot( V{k,2}(1:end-1,1,1),symb{2},'Color',clr(2,:)*0.4,'LineWidth',4,'MarkerSize',8)
    
    set(gcf,'Position',[50 50 600 500])
    print(['Prediction_Error_',mdlnme{k}],'-dpng','-r300')
end
legend({'Group C, Cue A','Group E, Cue A'},'Location','southeastoutside','Orientation','vertical')
legend boxoff
print('Legend','-dpng','-r300')

legend({'Group C','Group E'},'Location','southeastoutside','Orientation','vertical')
legend boxoff
print('Legend2','-dpng','-r300')

  disp([])      
        
for k=intersect([1,5,6,7,8],1:length(mdls))
    figure(6013+k)
    %title(mdlnme{k})
    symb = {'-','--'}; 
    ix1     = mean(LSB{k,1});
    ix2     = mean(LSB{k,2});
    [~,ix1] = sort(ix1,'descend');
    [~,ix2] = sort(ix2,'descend');
    
    for j=1:2
          PrettyFig('',[0 1],[45.5 61],[50,60])
          ylabel('Beliefs','FontWeight','bold','FontSize',24)
          hold on
          plot( LSB{k,1}(:,ix1(j)),symb{j},'LineWidth',4,'Color',clr(2,:)*1)
          plot( LSB{k,2}(:,ix2(j)),symb{j},'LineWidth',4,'Color',clr(2,:)*0.4)
    end
    set(gcf,'Position',[50 50 600 500])
    print(['Beliefs_',mdlnme{k}],'-dpng','-r300')
end
