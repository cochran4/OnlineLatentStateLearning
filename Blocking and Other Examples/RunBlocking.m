function RunBlocking
% Run and visualize results for blocking example

% Close open figures
close all

% Models
mdls  = {'LatentState','Hybrid','RescorlaWagner',...
        'fRLDecay','InfiniteMixture','Gershman2017',...
        'Gershman2017_alpha1','Redish2007'};

% Examples
expls = {'Blocking','Overexpectation','Conditioned Inhibition','Backwards Blocking'};

% Run examples
par = PatientParameters;
RunExample('Blocking',mdls,1,expls,par)

% Load data
load('Results_Blocking')

% Initialize information for plots
mdlnme = {'LS','HB','RW',...
          'FD','IM','GM',...
          'GM1','RD'};
lgdlbl = {{'A','B','C/D'},{'A','B'},{'A','B'},{'A','B'}};
cnum   = [3,2,2,2];

% Get colors
Colors 
clr    = [ ones(1,3)*0.15; clr];
xtck   = {[10,20,30,40],[30,60,90],[50,100,150,200],[10,20,30,40]};

for l=1:4
    for k=1:length(mdls)
        figure(k+3+l*(length(mdls)+1))
        xLim = [-0.55,0.55]*(k==1 && k~=8) + ...
               [-0.55,1.15]*(k~=1 && k~=8) + ...
               [-0.55,1.15]*(k==8);
        PrettyFig('',xLim,[0.5 size(V{k,l},1)+2*0.5],xtck{l})
        for j=1:cnum(l)
            %title(mdlnme{k},'FontSize',32)
            hold on
            plot(V{k,l}(:,j),'Color',clr(j+1,:),'LineWidth',4) 
        end
        ylabel('Associative strength','FontWeight','bold','FontSize',24)
        set(gcf,'Position',[50 50 600 500])
        print(['AssociativeStrength',mdlnme{k},num2str(l)],'-dpng','-r300')
        
        if k==length(mdls)
            legend(lgdlbl{l},'FontName','Arial','FontSize',32,'Location','eastoutside','Orientation','vertical')
            legend boxoff
            print(['Legend',mdlnme{k},num2str(l)],'-dpng','-r300')
        end
    end
end
disp([])      