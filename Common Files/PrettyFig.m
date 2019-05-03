function PrettyFig(lbl,ysze,xsze,xtck)

% Pretty Figure
set(gcf,'Color',[1 1 1])
xlabel('t','FontWeight','bold','FontSize',24)
set(gca,'YGrid','off')
set(gca,'FontSize',22)
set(gca,'FontName','Arial')
set(gca,'Box','off')
set(gca,'LineWidth',2)
if ~isempty(xtck)
    set(gca,'XTick',xtck)
end
set(gca,'XAxisLocation','bottom')
legend('boxoff')
ylabel(lbl,'FontWeight','bold','FontSize',24)
if ~isempty(ysze)
    set(gca,'YLim',ysze)
end
if ~isempty(xsze)
    set(gca,'XLim',xsze)
end