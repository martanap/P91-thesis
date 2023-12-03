function [k2, k_1] = estimate_kinetic_parameters(t, P, S, E_init, S_init)
    % Define the enzyme kinetics model
    % enz_kin_inh = @(t, y, k1, k_1, k2, k3, k_3) [(-k1*y(1)*y(2) + k_1*y(3) + k2*y(3));  % dEdt
    %                                             (-k1*y(1)*y(2) + k_1*y(3) - k3*y(3)*y(2) + k_3*y(5));  % dSdt
    %                                             (k1*y(1)*y(2) - k_1*y(3) - k2*y(3) + k_3*y(5) - k3*y(3)*y(2));  % dCdt
    %                                             (k2*y(3));  % dPdt
    %                                             (k3*y(3)*y(2) - k_3*y(5))];  % dCIdt

    
% Define the objective function with weighted sum of squared differences
    objective = @(params) sum(((P - simulate_reaction(params(1), params(2), t, E_init, S_init))./P).^2);
   
    
    % Set up pattern search options
    options = optimoptions('patternsearch');
    options.Display = 'iter';  % Display iteration information
    options.MaxIterations = 200000;  % Maximum number of iterations
    options.UseCompletePoll = true;  % Use complete poll step
    options.CompleteSearch = 'on';  % Perform complete search

    % Set lower and upper bounds for the parameters
    lb = [0.05, 10^3];  % Lower bounds for k2 and k_1
    ub = [500, 10^7];  % Upper bounds for k2 and k_1

    % Perform parameter estimation using pattern search
    initial_guess = [30, 1.7997e+05];  % Initial guess for k2 and k_1
    optimal_params = patternsearch(objective, initial_guess, [], [], [], [], lb, ub, [], options);
   

% Extract the estimated parameters
    k2 = optimal_params(1);
    k_1 = optimal_params(2);
end

function P = simulate_reaction(k2, k_1, t, E_init, S_init)
    % Calculate rate constants (in min^-1)
    k1 = (10^8)*60;  % min^-1
    k3 = (10^8)*60;  % min^-1
    Ks = 500*10^-6;
    k3_prime = k3 * Ks;  % k_3 * S_initial

    % Set initial conditions
    y0 = [E_init; S_init; 0; 0; 0];

    % Solve the IVP
    options = odeset('RelTol', 1e-13);
    [~, y] = ode23s(@(t, y) enz_kin_inh(t, y, k1, k_1, k2, k3, k3_prime), t, y0, options);

    % Extract the product concentration
    P = y(:, 4);
end
