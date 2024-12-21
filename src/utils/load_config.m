function config = load_config(config_file)
% Loads the configuration from a JSON file and sets default values.
%
% Args:
%     config_file: The path to the JSON configuration file.
%
% Returns:
%     config: A structure containing the configuration parameters.

% Read the JSON file
config = jsondecode(fileread(config_file));

% Set default values if parameters are not specified in the JSON file

% Simulation parameters
if ~isfield(config, 'simulation') || ~isfield(config.simulation, 'dimension')
    config.simulation.dimension = 2; % Default to 2D
end
if ~isfield(config, 'simulation') || ~isfield(config.simulation, 'dt')
    config.simulation.dt = 0.001;
end
if ~isfield(config, 'simulation') || ~isfield(config.simulation, 'T')
    config.simulation.T = 10;
end
if ~isfield(config, 'simulation') || ~isfield(config.simulation, 'Nt')
    config.simulation.Nt = ceil(config.simulation.T / config.simulation.dt);
end
if ~isfield(config, 'simulation') || ~isfield(config.simulation, 'save_every')
    config.simulation.save_every = 100;
end
if ~isfield(config, 'simulation') || ~isfield(config.simulation, 'mode')
    config.simulation.mode = 'evolution';
end

% Grid parameters
if ~isfield(config, 'grid') || ~isfield(config.grid, 'Nx')
    config.grid.Nx = 128;
end
if ~isfield(config, 'grid') || ~isfield(config.grid, 'Ny')
    config.grid.Ny = 128;
end
if ~isfield(config, 'grid') || ~isfield(config.grid, 'Nz')
    config.grid.Nz = 1;
end
if ~isfield(config, 'grid') || ~isfield(config.grid, 'Lx')
    config.grid.Lx = 10;
end
if ~isfield(config, 'grid') || ~isfield(config.grid, 'Ly')
    config.grid.Ly = 10;
end
if ~isfield(config, 'grid') || ~isfield(config.grid, 'Lz')
    config.grid.Lz = 1;
end

% Physical parameters
if ~isfield(config, 'parameters') || ~isfield(config.parameters, 'epsilon')
    config.parameters.epsilon = 0.01;
end
if ~isfield(config, 'parameters') || ~isfield(config.parameters, 'kappa')
    config.parameters.kappa = 1;
end
if ~isfield(config, 'parameters') || ~isfield(config.parameters, 'gamma_y')
    config.parameters.gamma_y = 1;
end
if ~isfield(config, 'parameters') || ~isfield(config.parameters, 'gamma_z')
    config.parameters.gamma_z = 1;
end

% Potential parameters
if ~isfield(config, 'potential') || ~isfield(config.potential, 'type')
    config.potential.type = 'harmonic';
end
if ~isfield(config, 'potential') || ~isfield(config.potential, 'parameters')
    config.potential.parameters = struct();
end

% Initial condition parameters
if ~isfield(config, 'initial_condition') || ~isfield(config.initial_condition, 'type')
    config.initial_condition.type = 'gaussian';
end
if ~isfield(config, 'initial_condition') || ~isfield(config.initial_condition, 'parameters')
    config.initial_condition.parameters = struct();
end

% Ground state parameters
if ~isfield(config, 'ground_state') || ~isfield(config.ground_state, 'method')
    config.ground_state.method = 'imaginary_time';
end
if ~isfield(config, 'ground_state') || ~isfield(config.ground_state, 'dt_imag')
    config.ground_state.dt_imag = 0.01;
end
if ~isfield(config, 'ground_state') || ~isfield(config.ground_state, 'tolerance')
    config.ground_state.tolerance = 1e-8;
end

% Visualization parameters
if ~isfield(config, 'visualization') || ~isfield(config.visualization, 'plot_density')
    config.visualization.plot_density = true;
end
if ~isfield(config, 'visualization') || ~isfield(config.visualization, 'plot_widths')
    config.visualization.plot_widths = true;
end
if ~isfield(config, 'visualization') || ~isfield(config.visualization, 'animate')
    config.visualization.animate = false;
end

end 