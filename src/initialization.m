function [x, y, z, kx, ky, kz, dx, dy, dz, params, psi0] = initialization(config, helpers)
% Initializes the spatial grid, wave number arrays, and initial wave function.
% Uses helper functions passed in the 'helpers' struct.
%
% Args:
%     config: A structure containing simulation configuration parameters.
%     helpers: A struct containing function handles to utility functions.
%
% Returns:
%     x, y, z:  Spatial coordinate arrays.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: A structure containing derived physical parameters (epsilon, kappa_d, etc.).
%     psi0: The normalized initial wave function.

% --- Initialize Grid (from original initialize_grid.m) ---
Nx = config.grid.Nx;
Ny = config.grid.Ny;
Nz = config.grid.Nz;
Lx = config.grid.Lx;
Ly = config.grid.Ly;
Lz = config.grid.Lz;
epsilon = config.parameters.epsilon;
kappa = config.parameters.kappa;
gamma_y = config.parameters.gamma_y;
gamma_z = config.parameters.gamma_z;

% Calculate grid spacing
dx = Lx / Nx;
dy = Ly / Ny;
dz = Lz / Nz;

% Construct spatial coordinate arrays
x = dx * (-Nx/2:Nx/2-1);
y = dy * (-Ny/2:Ny/2-1);
z = dz * (-Nz/2:Nz/2-1);

% Construct wave number arrays
kx = (2 * pi / Lx) * [0:Nx/2-1, -Nx/2:-1];
ky = (2 * pi / Ly) * [0:Ny/2-1, -Ny/2:-1];
kz = (2 * pi / Lz) * [0:Nz/2-1, -Nz/2:-1];

% Calculate dimension-dependent interaction parameter using helper function handle
kappa_d = helpers.calculate_kappa_d(kappa, config.simulation.dimension, epsilon, gamma_y, gamma_z);

% Store derived parameters in a structure
params = struct('epsilon', epsilon, 'kappa', kappa, 'kappa_d', kappa_d, 'gamma_y', gamma_y, 'gamma_z', gamma_z);

% --- Initialize Wave Function (calls local function, passing helpers) ---
psi0 = initialize_wavefunction_local(x, y, z, dx, dy, dz, config, params, helpers);

end

% --- Local Initialization Functions ---

function psi = initialize_wavefunction_local(x, y, z, dx, dy, dz, config, params, helpers)
% Initializes the wave function based on the configuration.
% (Local version, uses helpers for normalization)

% Get initial condition type and parameters
init_type = config.initial_condition.type;
params_init = config.initial_condition.parameters; % Avoid collision with params output

% Determine dimension based on input arrays
dim = 1;
if ~isempty(y)
    dim = 2;
end
if ~isempty(z)
    dim = 3;
end

% Initialize wave function based on type
switch lower(init_type)
    case 'gaussian'
        % Gaussian initial condition
        sigma_x = params_init.sigma_x;
        if isfield(params_init, 'sigma_y')
            sigma_y = params_init.sigma_y;
        else
            sigma_y = sigma_x;
        end
        if isfield(params_init, 'sigma_z')
            sigma_z = params_init.sigma_z;
        else
            sigma_z = sigma_x;
        end

        if dim == 1 % 1D
            psi = exp(-x.^2 / (2 * sigma_x^2));
        elseif dim == 2 % 2D
            [X, Y] = meshgrid(x, y);
            psi = exp(-X.^2 / (2 * sigma_x^2) - Y.^2 / (2 * sigma_y^2));
        else % 3D
            [X, Y, Z] = meshgrid(x, y, z);
            psi = exp(-X.^2 / (2 * sigma_x^2) - Y.^2 / (2 * sigma_y^2) - Z.^2 / (2 * sigma_z^2));
        end

    case 'thomas_fermi'
        % Thomas-Fermi initial condition (approximation)
        warning('Thomas-Fermi requires potential V, implementing basic version. Ensure potential exists and is passed if needed elsewhere.');
        V_tf = 0; % Simplified placeholder - requires potential V for real use
        mu = 0.5; % Placeholder chemical potential - should be determined properly
        kappa_d = params.kappa_d; % Use kappa_d from passed params struct
        
        psi_squared = (mu - V_tf) / kappa_d;
        psi_squared(psi_squared < 0) = 0; % Density must be non-negative
        psi = sqrt(psi_squared);
        
    case 'custom'
        % Custom initial condition
        error('Custom initial condition not implemented yet.');
        
    otherwise
        error('Invalid initial condition type: %s', init_type);
end

% Normalize the wave function using helper function handle
psi = helpers.normalize_wavefunction(psi, dx, dy, dz, config);

end 