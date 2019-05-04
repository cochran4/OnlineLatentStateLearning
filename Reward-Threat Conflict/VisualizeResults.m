function VisualizeResults
% Visualize results for approach-avoidance task
close all

% Load colors
Colors

%--------------------------------------------------------------------------
% Show contigencies for the task
%--------------------------------------------------------------------------

% Reward probability
figure(2000)
PrettyFig('',[0 1],[0 152],[0 75 150])
hold on
plot([0,50,51,100,101,150],[0.8,0.8,0.2,0.2,0.8,0.8],'Color',clr(1,:),'LineWidth', 4)
plot([0,50,51,100,101,150],[0.2,0.2,0.8,0.8,0.2,0.2],'Color',clr(2,:),'LineWidth', 4)
plot([0,50,51,100,101,150],[0.5,0.5,0.5,0.5,0.5,0.5],'Color',clr(3,:),'LineWidth', 4)
ylabel('Reward probability','FontWeight','bold','FontSize',32)
patch( [50.5;50.5; 75.5; 75.5],        [-10; 10; 10; -10], clr(1,:),'FaceAlpha',0.1,'EdgeColor','none')
patch( [100.5;100.5;150.5;150.5], [-10; 10; 10; -10], clr(1,:),'FaceAlpha',0.1,'EdgeColor','none')
set(gcf,'Position',[50 50 600 500])
print('Truth_Reward','-dpng','-r300')


% Threat probability
figure(2001)
PrettyFig('',[0 1],[0 152],[0 75 150])
hold on
plot([0,75,76,150],[0.2,0.2,0.8,0.8],'Color',clr(1,:),'LineWidth', 4)
plot([0,75,76,150],[0.8,0.8,0.2,0.2],'Color',clr(2,:),'LineWidth', 4)
plot([0,75,76,150],[0.5,0.5,0.5,0.5],'Color',clr(3,:),'LineWidth', 4)
ylabel('Threat probability','FontWeight','bold','FontSize',32)
patch( [50.5;50.5; 75.5; 75.5],        [-10; 10; 10; -10], clr(1,:),'FaceAlpha',0.1,'EdgeColor','none')
patch( [100.5;100.5;150.5;150.5], [-10; 10; 10; -10], clr(1,:),'FaceAlpha',0.1,'EdgeColor','none')
set(gcf,'Position',[50 50 600 500])
print('Truth_Threat','-dpng','-r300')


% Threat probability with legend
legend({'Arm 1','Arm 2','Arm 3'},'Location','southoutside','Orientation','horizontal')
legend boxoff
print('Truth_Legend','-dpng','-r300')

%--------------------------------------------------------------------------
% Load Data

lst = {'Analysis_RescorlaWagner','Analysis_LatentState','Analysis_Gershman2017',...
      'Analysis_Hybrid','Analysis_fRLDecay'};
clear param0

for i=1:length(lst)
   % Load data
   load(lst{i}) 
   
   % Save AIC, number of parameters, and parameters
   ML{i}      = log( L0 );
   nPar{i}    = (size(param,2)-1);
   param00{i} = param;
end

%--------------------------------------------------------------------------

% Build bar graphs
figure(6)
ax1 = axes('Position',[0 0 1 1.1],'Visible','off');
ax2 = axes('Position',[0.17 .15 .79 .79]);
nm  = 2;

PrettyFig('',[-3 17],[0.3 ((nm+1)*3.3+0.5)],[])
set(gca,'FontSize',27)
set(gca,'XAxisLocation','origin')
xlabel('')
ylabel('Mean \Delta loglikelihood','FontSize',26,'FontName','Arial','FontWeight','bold')

% Get differences
ix   = {1:150,1:50,51:100,101:150};
wdth = 1; 
for i=1:4
    for j=1:nm
        hold on
        h1 = mean( sum( ML{j+1}(ix{i},:)-ML{1}(ix{i},:) , 1), 2 );
        patch( [0;0;1;1]*wdth+0.5+(j-1)*wdth+(i-1)*(wdth*nm+0.2), [0; h1; h1; 0], ...
            clr(j+1,:),'FaceAlpha',1,'EdgeColor','none')
    end
    if i==1
        %patch( [0.3 0.3 wdth*nm+0.6 wdth*nm+0.6], [-500; 1200; 1200; -500], ...
        %     clr(1,:),'FaceAlpha',0.2,'EdgeColor','none')
    end
    for j=1:nm
        hold on
        h1 = mean( sum( ML{j+1}(ix{i},:)-ML{1}(ix{i},:) , 1), 2 );
        se = std( sum( ML{j+1}(ix{i},:)-ML{1}(ix{i},:) , 1), [],  2 )/sqrt( size(ML{j+1},2) );
        
        
        patch( [0;0;1;1]*wdth+0.5+(j-1)*wdth+(i-1)*(wdth*nm+0.2), [0; h1; h1; 0], ...
            clr(j+1,:),'FaceAlpha',1,'EdgeColor','none')    
        errorbar(1+(j-1)*wdth+(i-1)*(nm*wdth+0.2),h1,se,'k','LineWidth',1.5)
        if i==1
            disp([lst{j+1} ' - ',lst{1}])
            n = size(ML{1},2);
            AIC   = 2*(nPar{j+1}-nPar{1})-2*sum( ML{j+1}-ML{1},1);
            BIC   = log(150)*(nPar{j+1}-nPar{1})-2*sum( ML{j+1}-ML{1},1);
            hAIC  = mean(AIC, 2 );
            seAIC = std(AIC,[],2 )/sqrt(n);
            hBIC  = mean(BIC, 2 );
            seBIC = std(BIC,[],2 )/sqrt(n);
            sprintf('Mean AIC: %0.3f (%0.3f-%0.3f)',hAIC,hAIC-seAIC*tinv(0.975,n-1),hAIC+seAIC*tinv(0.975,n-1))
            sprintf('Mean BIC: %0.3f (%0.3f-%0.3f)',hBIC,hBIC-seBIC*tinv(0.975,n-1),hBIC+seBIC*tinv(0.975,n-1))
        end
    end
end


legend({'Our model','Gershman (2017)'},...
    'Location','northeast','FontSize',17)
legend boxoff
set(gca,'XTick',[])
axes(ax1)
text(0.54,0.04,'Trials',   'HorizontalAlignment','center','FontName','Arial','FontSize',24,'FontWeight','bold')
text(0.27,0.11,'All',   'HorizontalAlignment','center','FontName','Arial','FontSize',24)
text(0.46,0.11,'1-50',  'HorizontalAlignment','center','FontName','Arial','FontSize',24)
text(0.645,0.11,'51-100', 'HorizontalAlignment','center','FontName','Arial','FontSize',24)
text(0.834,0.11,'101-150','HorizontalAlignment','center','FontName','Arial','FontSize',24)
set(gcf,'Position',[50 50 1200 600])
print('AllComparison','-dpng','-r300')


% Comparison between rescorla-wagner and other models
for i=4:5
    disp([lst{i} ' - ',lst{1}])
    n = size(ML{1},2);
    AIC   = 2*(nPar{i}-nPar{1})-2*sum( ML{i}-ML{1},1);
    BIC   = log(150)*(nPar{i}-nPar{1})-2*sum( ML{i}-ML{1},1);
    hAIC  = mean(AIC, 2 );
    seAIC = std(AIC,[],2 )/sqrt(n);
    hBIC  = mean(BIC, 2 );
    seBIC = std(BIC,[],2 )/sqrt(n);
    sprintf('Mean AIC: %0.3f (%0.3f-%0.3f)',hAIC,hAIC-seAIC*tinv(0.975,n-1),hAIC+seAIC*tinv(0.975,n-1))
    sprintf('Mean BIC: %0.3f (%0.3f-%0.3f)',hBIC,hBIC-seBIC*tinv(0.975,n-1),hBIC+seBIC*tinv(0.975,n-1))
end


