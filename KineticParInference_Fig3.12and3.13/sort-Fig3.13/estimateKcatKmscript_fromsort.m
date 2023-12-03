% Define the experimental data

t = [0; 67.5000;  117.5000;  155.0000;  415.0000];

%reaction curves predicted from droplet sorting:
%wtP91:
%P = (10^(-4)).* [0.07; 0.0930;    0.1866;    0.2748;    0.4911];
%I211E
%P = (10^(-4)).* [0.07; 0.0818;    0.1475;    0.1956;    0.3538];
%I211R
%P = (10^(-4)).* [0.07; 0.2610;    0.4665;    0.6699;    0.7130];
%I211WL214V
P = (10^(-4)).* [0.07;  0.7130;    0.7130;    0.7130;      0.7130];


%Parameters specific to the assay:
E_init = 0.0125 * 10^-6;  % Initial enzyme concentration;
S_init = 71.3 * 10^-6;  % Initial substrate concentration 

% Estimate k2 and k_1
[k2_estimate, k_1_estimate] = estimate_kinetic_parameters(t, P, S_init, E_init, S_init);

kcat_estimate = k2_estimate/60
Km_estimate = (k_1_estimate+k2_estimate)/((10^8)*60)

% Display the estimated parameters
disp("Estimated k2: " + k2_estimate);
disp("Estimated k_1: " + k_1_estimate);
disp("Estimated kcat: " + kcat_estimate);
disp("Estimated Km: " + Km_estimate);
disp("Estimated kcat/Km: " + kcat_estimate/Km_estimate);

