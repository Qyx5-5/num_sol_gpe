function helpers = utils()
% Returns a struct of function handles to utility functions.

helpers = struct();
helpers.load_config = @load_config;
helpers.normalize_wavefunction = @normalize_wavefunction;
helpers.calculate_condensate_widths = @calculate_condensate_widths;
helpers.calculate_energy = @calculate_energy;
helpers.calculate_kappa_d = @calculate_kappa_d;

end

% --- Subfunctions (Utility Implementations) ---

function config = load_config(config_file)
% Loads the configuration from a JSON file and sets default values.
% (Subfunction version)

% Read the JSON file
config = jsondecode(fileread(config_file));

% --- Set default values --- 
% (Code from original load_config.m)
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

% Ground state parameters - Add defaults needed by ground_state.m
if ~isfield(config, 'ground_state')
     config.ground_state = struct();
end
if ~isfield(config.ground_state, 'method')
    config.ground_state.method = 'imaginary_time';
end
if ~isfield(config.ground_state, 'dt_imag')
    config.ground_state.dt_imag = 0.01;
end
if ~isfield(config.ground_state, 'tolerance')
    config.ground_state.tolerance = 1e-8;
end
if ~isfield(config.ground_state, 'max_iter') % Added default
    config.ground_state.max_iter = 10000; 
end
if ~isfield(config.ground_state, 'minimization_step') % Added default
    config.ground_state.minimization_step = 0.01; 
end

% Visualization parameters
if ~isfield(config, 'visualization')
    config.visualization = struct();
end
if ~isfield(config.visualization, 'plot_density')
    config.visualization.plot_density = true;
end
if ~isfield(config.visualization, 'plot_widths')
    config.visualization.plot_widths = true;
end
if ~isfield(config.visualization, 'animate')
    config.visualization.animate = false;
end
if ~isfield(config.visualization, 'calculate_observables') % Added default
    config.visualization.calculate_observables = true;
end

end

function psi = normalize_wavefunction(psi, dx, dy, dz, config)
% Normalizes the wave function such that the integral of |psi|^2 is 1.
% (Subfunction version)

dimension = config.simulation.dimension;

% Check for NaN or Inf in psi before normalization
if any(isnan(psi(:))) || any(isinf(psi(:)))
    warning('Wavefunction contains NaN or Inf during normalization.');
    psi(:) = 0; % Reset to prevent further issues
end

switch dimension
    case 1
        norm_val = sum(abs(psi).^2) * dx;
    case 2
        norm_val = sum(sum(abs(psi).^2)) * dx * dy;
    case 3
        norm_val = sum(sum(sum(abs(psi).^2))) * dx * dy * dz;
    otherwise
        error('Invalid dimension: %d', dimension);
end

if norm_val <= 0 || isnan(norm_val) || isinf(norm_val)
   warning('Wavefunction norm is zero, negative, NaN or Inf (%.3e). Resetting normalization factor.', norm_val);
   norm_factor = 1;
else
   norm_factor = sqrt(norm_val);
end

psi = psi / norm_factor;

end

function [sigma_x, sigma_y, sigma_z] = calculate_condensate_widths(psi, x, y, z, dx, dy, dz, dimension)
% Calculates the condensate widths (sigma_x, sigma_y, sigma_z).
% (Subfunction version)

rho = abs(psi).^2;

% Initialize outputs
sigma_x = NaN; sigma_y = NaN; sigma_z = NaN;

switch dimension
    case 1
        total_mass = sum(rho) * dx;
        if total_mass < eps 
             warning('Near-zero mass detected during width calculation (1D).'); return; 
        end
        x_mean = sum(x .* rho) * dx / total_mass;
        sigma_x = sqrt(sum((x - x_mean).^2 .* rho) * dx / total_mass);

    case 2
        [X, Y] = meshgrid(x, y);
        total_mass = sum(rho, 'all') * dx * dy;
        if total_mass < eps
             warning('Near-zero mass detected during width calculation (2D).'); return; 
        end
        x_mean = sum(X .* rho, 'all') * dx * dy / total_mass;
        y_mean = sum(Y .* rho, 'all') * dx * dy / total_mass;
        sigma_x = sqrt(sum((X - x_mean).^2 .* rho, 'all') * dx * dy / total_mass);
        sigma_y = sqrt(sum((Y - y_mean).^2 .* rho, 'all') * dx * dy / total_mass);

    case 3
        [X, Y, Z] = meshgrid(x, y, z);
        total_mass = sum(rho, 'all') * dx * dy * dz;
        if total_mass < eps
             warning('Near-zero mass detected during width calculation (3D).'); return; 
        end
        x_mean = sum(X .* rho, 'all') * dx * dy * dz / total_mass;
        y_mean = sum(Y .* rho, 'all') * dx * dy * dz / total_mass;
        z_mean = sum(Z .* rho, 'all') * dx * dy * dz / total_mass;
        sigma_x = sqrt(sum((X - x_mean).^2 .* rho, 'all') * dx * dy * dz / total_mass);
        sigma_y = sqrt(sum((Y - y_mean).^2 .* rho, 'all') * dx * dy * dz / total_mass);
        sigma_z = sqrt(sum((Z - z_mean).^2 .* rho, 'all') * dx * dy * dz / total_mass);
    otherwise
        error('Invalid dimension: %d', dimension);
end

end

function E = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config)
% Calculates the total energy of the system.
% (Subfunction version)

% Get parameters
epsilon = params.epsilon;
kappa_d = params.kappa_d;
dimension = config.simulation.dimension;
Nx = length(kx);
Ny = length(ky);
Nz = length(kz);

% Check for NaN/Inf in inputs
if any(isnan(psi(:))) || any(isinf(psi(:)))
    warning('NaN/Inf detected in psi during energy calculation.');
    E = Inf; return;
end
if any(isnan(V(:))) || any(isinf(V(:)))
     warning('NaN/Inf detected in V during energy calculation.');
    E = Inf; return;
end

% Calculate kinetic energy using FFT definition consistent with TSSP steps
switch dimension
    case 1
        psi_hat = fft(psi);
        K = kx.^2;
        E_kin = epsilon^2/2 * real(sum(K .* abs(psi_hat).^2)) / Nx; % FFT Normalization
        dV = dx;
    case 2
        psi_hat = fft2(psi);
        [KX, KY] = meshgrid(kx, ky);
        K = KX.^2 + KY.^2;
        E_kin = epsilon^2/2 * real(sum(K .* abs(psi_hat).^2, 'all')) / (Nx*Ny); % FFT Normalization
        dV = dx * dy;
    case 3
        psi_hat = fftn(psi);
        [KX, KY, KZ] = meshgrid(kx, ky, kz);
        K = KX.^2 + KY.^2 + KZ.^2;
        E_kin = epsilon^2/2 * real(sum(K .* abs(psi_hat).^2, 'all')) / (Nx*Ny*Nz); % FFT Normalization
        dV = dx * dy * dz;
    otherwise
        error('Invalid dimension specified: %d', dimension);
end

% Calculate potential energy
E_pot = sum(V .* abs(psi).^2, 'all') * dV;

% Calculate interaction energy
E_int = kappa_d/2 * sum(abs(psi).^4, 'all') * dV;

% Total energy
E = E_kin + E_pot + E_int;

% Check if energy calculation resulted in NaN/Inf
if isnan(E) || isinf(E)
    warning('Energy calculation resulted in NaN or Inf.');
    E = Inf; % Return Inf to handle convergence checks
end

end

function kappa_d = calculate_kappa_d(kappa, dimension, epsilon, gamma_y, gamma_z)
% Calculates the dimension-dependent interaction parameter kappa_d.
% (Subfunction version)

switch dimension
    case 1
        kappa_d = kappa;
    case 2
        if ~exist('gamma_y', 'var') || isempty(gamma_y) || gamma_y < 0
            error('gamma_y parameter needed and must be non-negative for 2D kappa_d calculation');
        end
        kappa_d = kappa * sqrt(gamma_y) / (2 * pi * epsilon);
    case 3
        if ~exist('gamma_y', 'var') || isempty(gamma_y) || gamma_y < 0 || ...
           ~exist('gamma_z', 'var') || isempty(gamma_z) || gamma_z < 0
            error('gamma_y and gamma_z parameters needed and must be non-negative for 3D kappa_d calculation');
        end
        kappa_d = kappa * sqrt(gamma_y * gamma_z) / (4 * pi * epsilon^2);
    otherwise
        error('Invalid dimension: %d', dimension);
end

end 