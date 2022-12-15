create_figure('grand average');

colormap('default');
cmap = colormap;

for i = 1:34
    hold on;
    plot(table2array(signal_m_TEST{3,2}(i,:))', 'LineWidth', 1, 'color', cmap(round(i*1.5),:));
end
set(gcf, 'position', [360   108   306   590]);
set(gca, 'TickDir', 'out', 'linewidth', 1.5, 'xtick', [0 25:125:525], 'XTickLabel', [-1 0 5 10 15 20], 'ylim', [-3 2]);
% 'xtick', [0 75:125:600], 'XTickLabel',[-3 0:5:20]


%% 
create_figure('grand average');
hold on;

%plot(mean(signal_m{6,2})', 'LineWidth', 2, 'color', 'k');
wani_plot_shading(1:numel(mean(table2array(signal_m_TEST{3,2}))), mean(table2array(signal_m_TEST{3,1})), ste(table2array(signal_m_TEST{3,1})), 'color', 'k', 'color_shade', [.8 .8 .8]);

set(gcf, 'position', [360   477   306   221]);
set(gca, 'TickDir', 'out', 'TickLength', [.02 .02], 'linewidth', 1.5, 'xtick', [25:125:525], 'XTickLabel', [ 0, 5, 10, 15, 20], 'ylim', [-.5 .5]);

%% each temp

close all;



temp = {'48', '49', '50'};
% for 
% signal_m_TEST{i,j}(:,end)=[];
% you can change this value
j = 2; % high cue
x = 1:524;
create_figure('shading');
cols = [0.3333    0.6588    1.0000
    0         0         0
    0.7608    0.3020         0];
for i = 1:3
    hold on;
    plot(x, mean(table2array(signal_m_TEST{i,:})), 'color', cols(i,:), 'linewidth', 2);
end

set(gcf, 'position', [50   126   661   324]);
set(gca, 'ylim', [-.3 1], 'linewidth', 1.5, 'TickDir', 'out', 'TickLength', [.02 .02], 'Xtick', (0:3:24)*25);
set(gca, 'XTickLabel', get(gca, 'XTick')./25-3);
h = legend('48 C', '49 C', '50 C'); 
set(h, 'fontsize', 15, 'box', 'off', 'Location', 'northeastoutside');
xlabel('Time (seconds)');
ylabel('Grand average amplitude');



%%

x = 1:524;
create_figure('shading');
cols = [0.9922    0.8314    0.6196
    0.9373    0.3961    0.2824
    0.6000         0         0];
for i = [25:125:525]% (3:5:24)*25
    line([i i], [-.4 1], 'col', [.8 .8 .8], 'linewidth', 1);
end
for i = 1:3
    hold on;
    wani_plot_shading(x, mean(table2array(cat(1,signal_m_TEST{i,:}))), ste(table2array(cat(1,signal_m_TEST{i,:}))), 'color', cols(i,:), 'alpha', .2);
end
set(gcf, 'position', [50   126   549   324]);
set(gca, 'ylim', [-.3 .5], 'linewidth', 1.5, 'TickDir', 'out', 'TickLength', [.02 .02], 'xtick', [25:125:525], 'XTickLabel', [ 0, 5, 10, 15, 20], 'ytick', -.2:.2:1);
set(gca, 'fontSize', 25);
savename = fullfile(figdir, 'Temp_all_grandavg_full.pdf');
pagesetup(gcf);
saveas(gcf, savename);
pagesetup(gcf);
saveas(gcf, savename);
