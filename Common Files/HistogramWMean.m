function HistogramWMean(x)
% Plot histogram with mean and confidence intervals

% Get colors
Colors

% Estimate mean change with confidence intervals
n                    = length( x );
se                   = std(  x )/sqrt(n);
t                    = tinv(0.975,n-1);
tmp(1)               = mean( x );
tmp(2)               = tmp(1) - se*t;
tmp(3)               = tmp(1) + se*t; 

% Plot change in geometric mean
plot( tmp(1)*ones(1,2), [0 100], '-','Color',clr(7,:),'LineWidth',3)
hold on
histogram( x, 10,'FaceColor',clr(2,:) )  
plot( tmp(1)*ones(1,2), [0 100], '-','Color',clr(7,:),'LineWidth',3)
plot( tmp(2)*ones(1,2), [0 100], '-','Color',clr(7,:),'LineWidth',1)
plot( tmp(3)*ones(1,2), [0 100], '-','Color',clr(7,:),'LineWidth',1)
patch([tmp(2) tmp(2) tmp(3) tmp(3)],[0 50 50 0],clr(7,:),'FaceAlpha',0.2,'EdgeColor','none')

% Add in legend
legend({['Participant average = ', sprintf('%0.3f (%0.3f-%0.3f)',tmp(1),tmp(2),tmp(3))]},'Location','northoutside','FontSize',26)
legend boxoff

