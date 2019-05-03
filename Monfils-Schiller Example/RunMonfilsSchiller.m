function RunMonfilsSchiller

% Close previous images
close all

% Run example
sp = 1;
for i=1:150
    tmp{i} = i*sp;
end
par = PatientParameters;
RunExample('MonfilsSchiller',{'LatentState','Gershman2017','Gershman2017_alpha1'},1,tmp,par)

% Load data
load('Results_MonfilsSchiller')

% Colors and symbols
Colors
clr    = [ ones(1,3)*0.15; clr];
symb   = {'-','--','^'};

% Shortened model name
mdlnme = {'LS','GM','GM1'};

% Indices of point of interest
ix = [100,5,1];

% Linewidth
lw = 4;
ms = 8;

% Visualize
for l=1:3

    figure(800+l)
    for j=1:size(V,2)        
        AS0(3,j) = MU{l,j}(end,1,1); % Associative strength at start of test trial
    end
    PrettyFig('',[-1/3 0]+(l~=1)*1/3,[0 151],[0 50 100 150])
    hold on
    xlabel([])
    plot( sp*(0:size(V,2)-1)',AS0(3,:)','-', 'Color',clr(2,:),'LineWidth', lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))

    ylabel('Associative strength, testing','FontWeight','bold','FontSize',24)
    set(gca,'XAxisLocation','bottom')
    set(gca,'YAxisLocation','left')
    xlabel('Time delay after retrieval','FontWeight','bold','FontSize',24)
    set(gcf,'Position',[50 50 600 500])
    print(['RetrievalTime_',mdlnme{l}],'-dpng','-r300')
    
    %------------------------------------------------
    % Associative strengths
    figure(6 + l*100+1)
    %title(mdlnme{l})
    for j=3:-1:1
        PrettyFig('',[-1/2 1/2]+(l~=1)*0.5,[0 25],[4 24])
        hold on
        plot( (1:3),MU{l,ix(j)}(1:3,1,1) ,'-','Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
    end
    xlabel([])
    for j=1:3
        plot( 4,MU{l,ix(j)}(4,1,1),       'x','Color',clr(j+1,:),'LineWidth', lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
        plot( 5:24-1,MU{l,ix(j)}(5:24-1,1,1) ,'-','Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
        plot( 24,MU{l,ix(j)}(24,1,1) ,'x','Color',clr(j+1,:),'LineWidth', lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
    end
    ylabel('Associative strength','FontWeight','bold','FontSize',24)
    set(gca,'XAxisLocation','bottom')
    set(gca,'XTickLabel',{'Retrieval','Test'});
    set(gcf,'Position',[50 50 600 500])
    print(['Expectations_',mdlnme{l}],'-dpng','-r300')
    if l==2
        set(gca,'XLim',[23.5,24.5])
        set(gca,'YLim',[0,0.003])
        for j=1:3
            plot( 24,MU{l,ix(j)}(24,1,1) ,'x','Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
        end
        set(gcf,'Position',[50 50 350 500])
        print(['Inset_',mdlnme{l}],'-dpng','-r300')
        legend({num2str(ix(3)),num2str(ix(2)),num2str(ix(1))},'Location','southoutside','Orientation','horizontal')
        legend boxoff
        set(gcf,'Position',[50 50 350 500])
        print(['LegendInset',num2str(l)],'-dpng','-r300')
    end
    %---------------------------------------------
    % Beliefs
    figure(6 + l*100+2)
    PrettyFig('',[0 1],[0 25],[4 24])
    xlabel([])
    %title(mdlnme{l})
    ylabel('Beliefs','FontWeight','bold','FontSize',24)
    symb0 = {'x','o'};
    for j=1:3
        for k=1:1
            hold on
            plot( 1:3,LSB{l,ix(j)}(1:3,k), symb{k},'Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
            plot( 4,LSB{l,ix(j)}(4,k),     symb0{k},'Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
            plot( 5:24-1,LSB{l,ix(j)}(5:24-1,k) ,symb{k},'Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))
            plot( 24,LSB{l,ix(j)}(24,k) ,symb0{k},'Color',clr(j+1,:),'LineWidth',lw,'MarkerSize',ms,'MarkerFaceColor',1*ones(1,3))            
        end
    end
    set(gca,'XTickLabel',{'Retrieval','Test'});
    set(gcf,'Position',[50 50 600 500])
    print(['Beliefs_',mdlnme{l}],'-dpng','-r300')
    
end

