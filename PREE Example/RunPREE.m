function RunPREE
% Run and visualize results for blocking example

% Close open figures
close all

% Models
mdls  = {'LatentState','Hybrid','RescorlaWagner',...
         'fRLDecay','InfiniteMixture','Gershman2017',...
         'Gershman2017_alpha1','Redish2007'};

% Run examples
par = PatientParameters;
RunExample('PREE',mdls,1,{1,2,3,4},par)

% Load data
load('Results_PREE')

% Shortened model names for figure file names
mdlnme = {'LS','HB','RW',...
          'FD','IM','GM',...
          'GM1','RD'};

% Legend labels
lgdlbl = {{'Partial','Continuous'},{'Partial','Continuous'}};

% Get colors
Colors 
clr    = [ ones(1,3)*0.15; clr];
xtck   = {[10,20,30],[10,20,30,40,50]};

for l=1:2
    for k=1:length(mdls)
        figure(k+3+l*(length(mdls)+1))
        xLim = [-0.55,0.55]*(k==1 && k~=8) + ...
               [-0.05,1.05]*(k~=1 && k~=8) + ...
               [-0.05,1.05]*(k==8);
        PrettyFig('',xLim,[0.5 size(MU{k,l*2},1)+2*0.5],xtck{l})
        for j=1:2
            %title(mdlnme{k},'FontSize',32)
            hold on
            plot(MU{k,2*(l-1)+j}(:,1),'Color',clr(j+1,:),'LineWidth',4) 
        end
        ylabel('Associative strength','FontWeight','bold','FontSize',24)
        set(gcf,'Position',[50 50 600 500])
        print(['AssociativeStrength_',mdlnme{k},num2str(l)],'-dpng','-r300')
        
        if k==length(mdls)
            legend(lgdlbl{l},'FontName','Arial','FontSize',24,'Location','eastoutside','Orientation','horizontal')
            legend boxoff
            print(['Legend_',mdlnme{k},num2str(l)],'-dpng','-r300')
        end
    end
end

for l=1:2
    for k=intersect([1,5,6,7,8],1:length(mdls))
        figure(6013+k+l*(length(mdls)+1))
        %title(mdlnme{k})
        symb = {'-','--'}; 
        ix1     = mean(LSB{k,2*(l-1)+1});
        ix2     = mean(LSB{k,2*(l-1)+2});
        [~,ix1] = sort(ix1,'descend');
        [~,ix2] = sort(ix2,'descend');

        for j=1:1
              PrettyFig('',[0 1],[0.5 size(MU{k,l*2},1)+2*0.5],[10,20,30,40,50])
              ylabel('Beliefs','FontWeight','bold','FontSize',24)
              hold on
              plot( LSB{k,2*(l-1)+1}(:,ix1(j)),symb{j},'LineWidth',4,'Color',clr(3,:)*1)
              plot( LSB{k,2*(l-1)+2}(:,ix2(j)),symb{j},'LineWidth',4,'Color',clr(3,:)*0.4)
        end
        set(gcf,'Position',[50 50 600 500])
        print(['Beliefs_',mdlnme{k},num2str(l)],'-dpng','-r300')
    end
end