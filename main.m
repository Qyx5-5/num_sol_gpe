% Main script for running GPE simulations using the TSSP method.

% Clear workspace and command window
clc;
clear;

try
    % Add paths to source code directories
    addpath('src/core', 'src/utils', 'src/potentials', 'src/ground_state', 'src/visualizations');
    
    % Load configuration from JSON file
    config = load_config('config/default_config.json');
    
    % Initialize grid, parameters, and wave function
    [x, y, z, kx, ky, kz, dx, dy, dz, params] = initialize_grid(config);
    psi = initialize_wavefunction(x, y, z, dx, dy, dz, config);
    
    % Get the potential function based on config
    potential_func = str2func(config.potential.type);
    V = potential_func(x, y, z, config.potential.parameters);
    
    % Run the simulation or calculate ground state
    if strcmp(config.simulation.mode, 'evolution')
        % Run time evolution using TSSP solver
        [psi, results] = tssp_solver(psi, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z);
    elseif strcmp(config.simulation.mode, 'ground_state')
        % Calculate ground state using specified method
        [psi, results] = feval(str2func(config.ground_state.method), psi, V, kx, ky, kz, dx, dy, dz, params, config);
        % results = {}; % You might want to store some results from ground state calculation
    end
    
    % Visualize results based on configuration
    if config.visualization.plot_density
        if config.simulation.dimension == 1
            plot_density_1d(x, psi, results, config);
        elseif config.simulation.dimension == 2
            plot_density_2d(x, y, psi, results, config);
        elseif config.simulation.dimension == 3
            plot_density_3d(x, y, z, psi, results, config);
        end
    end
    
    if config.visualization.plot_widths
        plot_condensate_widths(results, config);
    end
    
    if config.visualization.animate
        animate_simulation(results, config);
    end
    
    % Remove paths to source code directories
    rmpath('src/core', 'src/utils', 'src/potentials', 'src/ground_state', 'src/visualizations');

catch ME
    fprintf('An error occurred:\n');
    fprintf('%s\n', ME.message);
    for i = 1:length(ME.stack)
        fprintf('  In %s at line %d\n', ME.stack(i).name, ME.stack(i).line);
    end
end 