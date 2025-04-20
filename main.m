% Main script for running GPE simulations using the TSSP method (Simplified Structure).

% Clear workspace and command window
clc;
clear;

try
    % Add path to source code directory
    addpath('src');

    % Get helper function handles
    helpers = utils();

    % Load configuration using helper
    config = helpers.load_config('config/default_config.json');

    % Initialize grid, parameters, and initial wave function
    % Pass helpers struct to initialization
    [x, y, z, kx, ky, kz, dx, dy, dz, params, psi0] = initialization(config, helpers);

    % Calculate the potential (assumed time-independent based on this main script structure)
    % The potentials function handles type selection internally.
    V = potentials(x, y, z, config); % Pass t=0 implicitly by omitting the arg

    % Select simulation mode
    results = []; % Initialize results
    psi_final = []; % Initialize final psi

    if strcmpi(config.simulation.mode, 'evolution')
        fprintf('Starting time evolution...\n');
        % Pass helpers struct to solver
        [psi_final, results] = tssp_solver(psi0, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z, helpers);
        fprintf('Time evolution finished.\n');

    elseif strcmpi(config.simulation.mode, 'ground_state')
        fprintf('Calculating ground state...\n');
        % Pass helpers struct to ground state function
        [psi_final, results] = ground_state(psi0, V, kx, ky, kz, dx, dy, dz, params, config, helpers);
        % Note: results structure from ground_state might differ from evolution results
        fprintf('Ground state calculation finished.\n');

    else
        error('Unknown simulation mode specified in config: %s', config.simulation.mode);
    end

    % Visualize results (pass final wave function and results struct)
    fprintf('Visualizing results...\n');
    visualizations(x, y, z, psi_final, results, config); % Use consolidated visualization
    fprintf('Visualization finished.\n');

    % Clean up path
    rmpath('src');

catch ME
    fprintf('\n--- An error occurred ---\n');
    fprintf('Error message: %s\n', ME.message);
    fprintf('Error identifier: %s\n', ME.identifier);
    disp('Stack trace:');
    for i = 1:length(ME.stack)
        fprintf('  File: %s\n  Name: %s\n  Line: %d\n', ME.stack(i).file, ME.stack(i).name, ME.stack(i).line);
        fprintf('------------------------\n');
    end
    
    % Clean up path even if error occurs
    if exist('src', 'dir') % Check if src exists before trying to remove path
         if contains(path, fullfile(pwd, 'src')) % Check if it's actually on the path
            rmpath('src');
            fprintf('Removed src from path after error.\n');
         end
    end
end

disp('Main script finished.'); 