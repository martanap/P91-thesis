%Experimental conditions (in M)
E_init = 0.0125 * 10^-6;
S_init = 71.3 * 10^-6;
time1 = [60, 110, 145, 405]; % Set beginning of the screen for each timespan
time2 = [75, 125, 165, 425]; % Set end of the screen for each timespan
sort_thresh=10*10^-6 %M

i=1;

P_ratio = [0.168525009,	0.169787916,	0.159791393,	0.392207493;
0.148295169,	0.119036777,	0.08724103,	0.286796949;
0.473054484,	0.372574272,	0.368753459,	0.078128859;
1.291094322,  0, 0, 0;  %I211WL214V - completed in 1st timepoint
0.210125338,	0.338601035,	0.384214119,	0.242866699;]

% Define the mean times between time1 and time2 for each timespan
mean_times = (time1 + time2) / 2;  % Update with the desired mean times
inferred_curves = zeros(height(P_ratio), length(time1));
inferred_curves(:, 1) = P_ratio(:, 1);

for j = 2:length(time1)
    inferred_curves(:, j) = inferred_curves(:, j-1) + P_ratio(:, j);
end

% Define the scaling factor
desired_max_value = S_init;
current_max_value = max(max(inferred_curves));  % Find the current maximum value in plateau_curves
scaling_factor = desired_max_value / current_max_value;

% Scale the plateau_curves
plateau_curves = inferred_curves * scaling_factor;

variant_names = {'wtP91', 'I211E', 'I211R', 'I211WL214V', 'I211W'};

colors = lines(5);


figure;
hold on;
for i = 1:length(variant_names)

    scatter(0, 0, 50, 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
end
for i = 1:length(variant_names)

    plot([0, mean_times], [0, plateau_curves(i, :)], 'Color', colors(i, :));
    scatter(mean_times, plateau_curves(i, :), 50, 'o', 'MarkerFaceColor', colors(i, :), 'MarkerEdgeColor', colors(i, :));
end
hold off;
xlabel('Time (min)');
ylabel('Product Formation');
legend(variant_names, 'Location', 'best');
set(gca, 'FontSize', 14); % Set font size for axis labels and tick labels
set(gcf,'position',[100,100,400,400])


