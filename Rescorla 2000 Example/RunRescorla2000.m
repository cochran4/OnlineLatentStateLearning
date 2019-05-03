function RunRescorla2000
% Visualize results from Rescorla (2000)

% Close figures
close all

% Approach
% Run example
RunExample('Rescorla2000',{'LatentState','Hybrid','RescorlaWagner','fRLDecay','InfiniteMixture','LatentCauseRW','LatentCauseRW_alpha1'},1,{1,2})

% Load data
load('Results_Rescorla2000')

% Color scheme
Colors
clr    = [ ones(1,3)*0.15; clr];

% Model names
mdlnmes = {'Latent-state','Hybrid','Rescorla-Wagner','fRL-Decay','Infinite-mixture','Latent-cause RW','Latent-cause RW (\alpha=1)'};

% Associative strength at the end of stage 2
for l=1:length(mdlnmes)
    for k=1:2
        figure(k+3 + l*10)
        title(mdlnmes{l})
        PrettyFig('',[-0.5 0.75],[0.5,2.5],[]) 
        set(gca,'XTick',[])
        h1 = sum( MU{l,k}([501,509],1),  2); h1 = h1(2)-h1(1);
        h2 = sum( MU{l,k}([501,509],2), 2); h2 = h2(2)-h2(1);
        ylabel('\Delta Associative strength','FontWeight','bold','FontSize',32)
        tol = 0.02;
        patch( [0;0;1;1]+0.5, [0; h1+tol*sign(h1); h1+tol*sign(h1); 0], clr(2,:),'FaceAlpha',0.75,'EdgeColor','none')
        hold on
        patch( [0;0;1;1]+1.5, [0; h2+tol*sign(h2); h2+tol*sign(h2); 0], clr(3,:),'FaceAlpha',0.75,'EdgeColor','none')
        legend({'A','B'},'Location','southeast')
        legend boxoff
        if k==2 && l==2, legend off, end
        set(gca,'TickDir','out');
        set(gcf,'Position',[50 50 600 500])
        print(['AssociativeStrength',num2str(k),num2str(l)],'-dpng','-r300')
        
    end
end


for k=[1,5,6,7]
    figure(6013+k)
    title(mdlnmes{k})
    symb = {'-','--','--'};
    for j=[1,2]
          PrettyFig('',[0 1],[490 509.5],[495,500,505])
          ylabel('Beliefs','FontWeight','bold','FontSize',32)
          hold on
          plot( LSB{k,2}(:,j),symb{j},'LineWidth',4,'Color','k')
          plot( LSB{k,2}(:,3),symb{3},'LineWidth',4,'Color','k')
          if j==1, patch( [501.5,501.5,0,0]',[-1,1,1,-1]',clr(1,:),'FaceAlpha',0.1,'EdgeColor','none'), end
          plot( LSB{k,2}(:,j),symb{j},'LineWidth',4,'Color','k')
    end
    set(gcf,'Position',[50 50 600 500])
    print(['Beliefs',num2str(k)],'-dpng','-r300')
end