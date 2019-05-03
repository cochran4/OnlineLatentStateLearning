function ScatterPlot(x1,x2,xlbl,ylbl)

% Add in colors
Colors

% Plot trend line
hold on
p = polyfit(x1,x2,1);
xi = linspace(min(x1),max(x1),1000);
yi = polyval(p,xi);
plot(xi,yi,'-','LineWidth',3,'Color',clr(7,:))

% Plot points
plot( x1, x2,   'ko','MarkerFaceColor',clr(2,:),'MarkerSize',12)

PrettyFig(ylbl,[],[],[])
xlabel(xlbl,'FontWeight','bold')
set(gca,'FontSize',30)
legend( {['Trend line ',sprintf('(R=%0.2f)',corr(x1,x2))]} ,'Location','northoutside','Orientation','horizontal') 
legend boxoff

% Add in correlation values
set(gcf,'Position',[50 50 800 600])
