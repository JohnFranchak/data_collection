function setUnitView(unit, trial_num)
if (strcmp(get(1, 'Visible'),'on'))
    set(1, 'Visible', 'on');
    clf(1);
    set(1, 'Toolbar', 'none');
    set(1, 'MenuBar', 'none');
    t = text(0.1,0.5,sprintf('%04.2f', unit));
    set(t, 'FontSize', 120);
    set(t, 'Color', [0 1 0]);
    tt = text(0.01,0.9,sprintf('Trial # %03d', trial_num));
    set(tt, 'FontSize', 60);
    set(tt, 'Color', [0 0 1]);
    a = get(1, 'CurrentAxes');
    set(a, 'XTickLabel', '');
    set(a, 'YTickLabel', '');
    set(a, 'XTick', []);
    set(a, 'YTick', []);
    set(a, 'XColor', [1 1 1]);
    set(a, 'YColor', [1 1 1]);
end;
