function [x, y, z, kx, ky, kz, dx, dy, dz, params] = initialize_grid(config)
% Initializes the spatial grid and wave number arrays.
%
% Args:
%     config: A structure containing simulation configuration parameters.
%
% Returns:
%     x, y, z:  Spatial coordinate arrays.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: A structure containing derived parameters.

% Extract parameters from config
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

% Calculate dimension-dependent interaction parameter
kappa_d = calculate_kappa_d(kappa, config.simulation.dimension, epsilon, gamma_y, gamma_z);

% Store derived parameters in a structure
params = struct('epsilon', epsilon, 'kappa_d', kappa_d, 'gamma_y', gamma_y, 'gamma_z', gamma_z);

end 