function RunRenewal
% Run renewal example

% Close previous images
close all

% Run example
mdls  = {'LatentState','Hybrid','RescorlaWagner',...
         'fRLDecay','InfiniteMixture','Gershman2017',...
         'Gershman2017_alpha1','Redish2007'};
par   = PatientParameters;
RunExample('Renewal',mdls,1,{1,2},par)

% Load data
load('Results_Renewal')

% Colors and symbols
Colors
clr    = [ ones(1,3)*0.15; clr];
symb   = {'-','--','^'};

% Shortened model names for figure file names
mdlnme = {'LS','HB','RW',...
          'FD','IM','GM',...
          'GM1','RD'};
              
for l=1:length(mdls)    
    %------------------------------------------------
    % Expectations
    figure(6 + l*100+1)
    
    
    for j=1:2
        PrettyFig('',[-1/2 1/2]+(l~=1)*0.5,[0 51],[0 10 20 30 40 50 60])
        ylabel('Expected reward','FontWeight','bold','FontSize',24)
        hold on
        plot( MU{l,j}(:,:,1),'-','Color',clr(j+1,:),'LineWidth', 4,'MarkerSize',12,'MarkerFaceColor',1*ones(1,3))
    end

    set(gca,'XAxisLocation','bottom')
    set(gcf,'Position',[50 50 600 500])
    print(['Expectations_Renewal_',mdlnme{l}],'-dpng','-r300')

    if l==length(mdlnme)
        legend({'No context change','Context change'},'Location','southoutside','Orientation','horizontal')
        legend boxoff
        print('Legend','-dpng','-r300')
    end

    
    %---------------------------------------------
    % Beliefs
    if any( l==[1,5,6,7,8] )
        figure(6 + l*100+2)
        PrettyFig('',[0 1],[0 51],[0 10 20 30 40 50 60])
        %title(mdlnme{l})
        ylabel('Beliefs','FontWeight','bold','FontSize',24)
        
        % Most likely state
        for j=1:2
            hold on
           ix1     = mean(LSB{l,j}(:,:,1));
           [~,ix1] = sort(ix1,'descend');    
            plot( mean(LSB{l,j}(:,ix1(1)),3),symb{1},'LineWidth',4,'Color',clr(j+1,:))
        end
        set(gca,'XAxisLocation','bottom')
        set(gcf,'Position',[50 50 600 500])
        print(['Beliefs_Renewal_',mdlnme{l}],'-dpng','-r300')
    end        
end


