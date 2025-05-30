% Main script for running GPE simulations using the TSSP method
% 
% This script loads a configuration file and runs BEC simulations using the
% Time-Splitting Spectral method. Multiple production configurations are
% available for different physical scenarios.

% Clear workspace and command window
clc;
clear;

fprintf('=== GPE-TSSP Simulation Suite ===\n\n');

try
    % Add path to source code directory
    addpath('src');

    % Get helper function handles
    helpers = utils();

    % Configuration selection
    % You can change this line to use different configuration files:
    % Available options:
    %   'config/default_config.json'           - General 2D harmonic trap
    %   'config/harmonic_1d.json'              - 1D harmonic trap
    %   'config/harmonic_2d.json'              - 2D anisotropic harmonic trap  
    %   'config/harmonic_3d.json'              - 3D fully anisotropic trap
    %   'config/optical_lattice_1d.json'       - 1D optical lattice
    %   'config/optical_lattice_2d.json'       - 2D optical lattice
    %   'config/double_well.json'              - Double-well potential
    %   'config/ground_state_calculation.json' - Ground state optimization
    %   'config/strong_nonlinearity.json'      - Thomas-Fermi regime
    
    config_file = 'config/harmonic_3d.json';  % <-- Change this line to use different configs
    
    % Load configuration using helper
    fprintf('Loading configuration: %s\n', config_file);
    config = helpers.load_config(config_file);
    
    % Display configuration information
    if isfield(config, 'description')
        fprintf('Configuration: %s\n', config.description);
    end
    
    fprintf('\nSimulation Parameters:\n');
    fprintf('  Dimension: %dD\n', config.simulation.dimension);
    fprintf('  Mode: %s\n', config.simulation.mode);
    fprintf('  Potential: %s\n', config.potential.type);
    fprintf('  Grid: %dx%dx%d\n', config.grid.Nx, config.grid.Ny, config.grid.Nz);
    fprintf('  Domain: %.1fx%.1fx%.1f\n', config.grid.Lx, config.grid.Ly, config.grid.Lz);
    fprintf('  Time step: %.6f\n', config.simulation.dt);
    fprintf('  Total time: %.2f\n', config.simulation.T);
    fprintf('  Interaction strength (κ): %.2f\n', config.parameters.kappa);
    
    if config.visualization.animate
        fprintf('  Animation: Enabled\n');
    else
        fprintf('  Animation: Disabled\n');
    end
    fprintf('\n');

    % Initialize grid, parameters, and initial wave function
    fprintf('Initializing simulation...\n');
    [x, y, z, kx, ky, kz, dx, dy, dz, params, psi0] = initialization(config, helpers);

    % Calculate the potential
    fprintf('Calculating potential...\n');
    V = potentials(x, y, z, config);

    % Select simulation mode
    results = []; % Initialize results
    psi_final = []; % Initialize final psi

    if strcmpi(config.simulation.mode, 'evolution')
        fprintf('Starting time evolution simulation...\n');
        [psi_final, results] = tssp_solver(psi0, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z, helpers);
        fprintf('✅ Time evolution completed successfully.\n');

    elseif strcmpi(config.simulation.mode, 'ground_state')
        fprintf('Calculating ground state using %s method...\n', config.ground_state.method);
        [psi_final, results] = ground_state(psi0, V, kx, ky, kz, dx, dy, dz, params, config, helpers);
        fprintf('✅ Ground state calculation completed successfully.\n');

    else
        error('Unknown simulation mode specified in config: %s', config.simulation.mode);
    end

    % Display simulation results summary
    fprintf('\nSimulation Summary:\n');
    density = abs(psi_final).^2;
    total_norm = sum(density(:)) * dx * dy * dz;
    max_density = max(density(:));
    fprintf('  Final norm: %.8f\n', total_norm);
    fprintf('  Max density: %.6f\n', max_density);
    
    if isfield(results, 'time') && ~isempty(results.time)
        fprintf('  Time points saved: %d\n', length(results.time));
    end

    % Visualize results
    fprintf('Generating visualizations...\n');
    visualizations(x, y, z, psi_final, results, config);
    fprintf('✅ Visualization completed.\n');

    fprintf('\n🎉 Simulation finished successfully!\n');
    fprintf('\nTo run a different configuration, edit the config_file variable in main.m\n');
    fprintf('Available configurations are listed in config/README.md\n');

    % Clean up path
    rmpath('src');

catch ME
    fprintf('\n❌ An error occurred during simulation\n');
    fprintf('Error message: %s\n', ME.message);
    fprintf('Error identifier: %s\n', ME.identifier);
    
    if ~isempty(ME.stack)
        fprintf('\nStack trace:\n');
        for i = 1:min(3, length(ME.stack))  % Show only first 3 stack entries
            fprintf('  File: %s\n', ME.stack(i).file);
            fprintf('  Function: %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            if i < min(3, length(ME.stack))
                fprintf('  ↓\n');
            end
        end
        if length(ME.stack) > 3
            fprintf('  ... (%d more entries)\n', length(ME.stack) - 3);
        end
    end
    
    fprintf('\nTroubleshooting tips:\n');
    fprintf('  • Check your configuration file syntax\n');
    fprintf('  • Verify all parameters are within valid ranges\n');
    fprintf('  • Try reducing dt or increasing grid resolution for stability\n');
    fprintf('  • See config/README.md for parameter guidelines\n');
    
    % Clean up path even if error occurs
    if exist('src', 'dir') % Check if src exists before trying to remove path
         if contains(path, fullfile(pwd, 'src')) % Check if it's actually on the path
            rmpath('src');
            fprintf('\nCleaned up paths after error.\n');
         end
    end
end

disp('Main script finished.'); 