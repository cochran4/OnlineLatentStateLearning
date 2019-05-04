function VisualizeResultsByModel(mdlname)
% Visualize results for a specific model
close all

% Load data
load(['Analysis_',mdlname])

cd(['./',mdlname])


% Shift (may want to change if using dual screens)
shft = [50 50];

% Load colors
Colors

%--------------------------------------------------------------------------
% Calculate arm choice frequencies
for j=1:1
    figure(j+1560)
    for i=1:3
        hold on
        plot( squeeze( mean( dta0.arm==i , 1)' )*100,'Color',clr(i,:),'LineWidth',3.5)    
    end
    PrettyFig('Choice, %',[0,100],[0 151],[])
    set(gca,'FontSize',30)
    set(gcf,'Position',[shft 700 600])
    print('Choice','-dpng','-r300')
    legend( {'Arm 1','Arm 2','Arm 3'} ,'Location','southoutside','Orientation','horizontal') 
    legend boxoff
    print('Legend','-dpng','-r300')
end


%--------------------------------------------------------------------------
% Calculate arm choice probabilities
MU  = reshape(MU,150,1,3,[]);
for j=1:1
    figure(j+560)
    for i=1:3
        hold on
        plot( squeeze( mean( MU(:,j,i,:) , 4) ),'Color',clr(i,:),'LineWidth',3.5)    
    end
    PrettyFig('Associative strength',[-0.26,0.26],[0 151],[])
    set(gca,'YTick',[-0.3,-0.2,-0.1,0,0.1,0.2,0.3])
    set(gca,'FontSize',30)
    set(gcf,'Position',[shft 700 600])
    print(['AS_',mdlname],'-dpng','-r300')
end

%-------------------------------
% Plot latent-state beliefs
if contains(mdlname,'Latent') || contains(mdlname,'Gershman2017')
    figure(3+560)
    for i=1:3
        hold on
        plot( squeeze( mean( lsb(:,i,:), 3) ),'Color',clr(i,:),'LineWidth',3.5)    
    end
    PrettyFig('Beliefs',[0,1],[0 151],[])
    
    set(gca,'FontSize',30)
    set(gcf,'Position',[shft 700 600])
    print(['Beliefs_',mdlname],'-dpng','-r300')
    legend( {'State 1','State 2','State 3'} ,'Location','southoutside','Orientation','horizontal')
    legend boxoff
    print('Beliefs_Legend','-dpng','-r300')
end

%--------------------------------------------------------------------------
% Labels for various models
lbl{1} = 'Soft max';
if strcmp(Approach,'RescorlaWagner') 
    lbl{2} = 'Learning rate alpha';
elseif strcmp(Approach,'Hybrid')
    lbl{2}  = 'Learning rate \kappa';
    lbl{3}  = 'Learning rate \eta';
elseif strcmp(Approach,'fRLDecay')
    lbl{2}  = 'Learning rate \eta';
    lbl{3}  = 'Decay rate d';
else
    lbl{2}  = 'Learning rate \alpha';
    lbl{3}  = 'Latent-state transitions \gamma';
    lbl{4}  = 'Initial stard deviation \sigma_0';
end
lbl{end+1}  = 'Threat weighting';
lbl{end+1}  = 'Mean likelihood';

% Loop through parameters
for i=1:size(param,2)
    
    figure(i)
    
    % Plot histograms of parameters
    HistogramWMean(param(:,i))

    % More formatting
    PrettyFig('Persons, count',[0 50],[],[])
    xlabel(lbl{i},'FontWeight','bold')
    set(gca,'FontSize',30)
    set(gcf,'Position',[shft 800 600])
    print(['HistParam_',mdlname,num2str(i)],'-dpng','-r300')
    
end    
    