function RunSpontaneousRecovery
% Run spontaneous recovery example

% Close previous images
close all

% Run example
mdls  = {'LatentState','Hybrid','RescorlaWagner',...
         'fRLDecay','InfiniteMixture','Gershman2017',...
         'Gershman2017_alpha1','Redish2007'};
par   = PatientParameters;
RunExample('SpontaneousRecovery',mdls,1,{1,200},par)

% Load data
load('Results_SpontaneousRecovery')

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
    rectangle('Position',[40.2 -0.1 19.6 0.2],'FaceColor',[1 1 1],'EdgeColor',[1 1 1])        
    PrettyFig('',[-1/2 1/2]+(l~=1)*0.5,[0 70+1],[0 20 40 60 70])
    for j=1:2
        %title(mdlnme{l})
        ylabel('Associative strength','FontWeight','bold','FontSize',24)
        hold on
        plot(1:40,MU{l,j}(1:40,:,1),'-','Color',clr(j+1,:),'LineWidth', 4,'MarkerSize',12)
        plot(20+(41:par.ntrials),MU{l,j}(41:end,:,1),'-','Color',clr(j+1,:),'LineWidth', 4,'MarkerSize',12,'MarkerFaceColor',1*ones(1,3))
        plot(40,MU{l,j}(40,:,1),'x','Color',clr(j+1,:),'LineWidth', 4,'MarkerSize',12)
        plot(20+41,MU{l,j}(41,:,1),'x','Color',clr(j+1,:),'LineWidth', 4,'MarkerSize',12,'MarkerFaceColor',1*ones(1,3))
    end
    set(gca,'XTick',[0 20 40 60 70])
    set(gca,'XTickLabel',[0 20 40 0 10])
    set(gca,'XAxisLocation','bottom')
    set(gcf,'Position',[50 50 600 500])
    print(['AS_SponRec_',mdlnme{l}],'-dpng','-r300')

    if l==length(mdlnme)
        legend({'1','200'},'Location','southoutside','Orientation','vertical')
        legend boxoff
        print('Legend','-dpng','-r300')
    end

    
    %---------------------------------------------
    % Beliefs
    if any( l==[1,5,6,7,8] )
        figure(6 + l*100+2)
        PrettyFig('',[0 1],[0 81+1],[0 20 40 60 70])
        %title(mdlnme{l})
        ylabel('Beliefs','FontWeight','bold','FontSize',24)
        
        % Most likely state
        rectangle('Position',[40.2 -0.1 19.6 0.2],'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
        for j=1:2
            hold on
            ix1     = mean(LSB{l,j}(:,:,1));
           [~,ix1] = sort(ix1,'descend');    
            plot( 1:40,mean(LSB{l,j}(2:41,ix1(1)),3),symb{1},'LineWidth',4,'Color',clr(j+1,:))
            plot( 40,mean(LSB{l,j}(41,ix1(1)),3),'x','LineWidth',4,'Color',clr(j+1,:),'MarkerSize',12)            
            plot( 20+(41:par.ntrials),mean(LSB{l,j}(42:end,ix1(1)),3),symb{1},'LineWidth',4,'Color',clr(j+1,:))
            plot( 20+41,mean(LSB{l,j}(42,ix1(1)),3),'x','LineWidth',4,'Color',clr(j+1,:),'MarkerSize',12)
        end
        set(gca,'XTick',[0 20 40 60 70])
        set(gca,'XTickLabel',[0 20 40 0 10])
        set(gcf,'Position',[50 50 600 500])
        print(['Beliefs_SponRec_',mdlnme{l}],'-dpng','-r300')
    end        
end


