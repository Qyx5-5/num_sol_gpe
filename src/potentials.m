function V = potentials(x, y, z, config, t)
% Calculates the potential energy array based on the configuration.
%
% Args:
%     x, y, z: Spatial coordinate arrays (can be vectors or meshes).
%              For 1D, provide x.
%              For 2D, provide x, y.
%              For 3D, provide x, y, z.
%     config: A structure containing the full simulation configuration.
%             config.potential.type: String specifying the potential type.
%             config.potential.parameters: Structure with potential-specific parameters.
%     t: Current time (optional, required for time-dependent potentials like rotating_trap).
%
% Returns:
%     V: The potential energy array.

potential_type = config.potential.type;
params = config.potential.parameters;

% Pass time if needed by the potential
if nargin < 5
    t = 0; % Default time if not provided
end

% Add dimension info to params for all potential functions
params.dimension = config.simulation.dimension;

switch lower(potential_type)
    case 'harmonic'
        V = harmonic_local(x, y, z, params);
    case 'optical_lattice'
        V = optical_lattice_local(x, y, z, params);
    case 'double_well'
        V = double_well_local(x, y, z, params);
    case 'anharmonic'
        V = anharmonic_local(x, y, z, params);
    case 'rotating_trap'
        % Rotating trap needs time
        if nargin < 5
            error('Time variable "t" is required for rotating_trap potential.');
        end
        params.t = t; % Add time to params
        V = rotating_trap_local(x, y, z, params);
    case 'disordered'
        V = disordered_local(x, y, z, params);
    case 'box'
        V = box_local(x, y, z, params);
    otherwise
        error('Unknown potential type: %s', potential_type);
end

end

% --- Local Potential Functions ---

function V = harmonic_local(x, y, z, params)
% Harmonic potential (merged from harmonic.m and harmonic_trap.m).

% Determine dimension based on input arrays
dim = params.dimension;

% Parameter validation (from harmonic_trap.m) - only check for needed dimensions
if dim > 1 && ~isfield(params, 'gamma_y')
    error('Missing parameter gamma_y for 2D/3D harmonic potential.');
end
if dim > 2 && ~isfield(params, 'gamma_z')
    error('Missing parameter gamma_z for 3D harmonic potential.');
end
if dim > 1 && isfield(params, 'gamma_y') && params.gamma_y < 0
    error('Invalid parameter: gamma_y must be non-negative.');
end
if dim > 2 && isfield(params, 'gamma_z') && params.gamma_z < 0
    error('Invalid parameter: gamma_z must be non-negative.');
end

% Calculate potential based on dimension
if dim == 1 % 1D
    V = 0.5 * x.^2;
elseif dim == 2 % 2D
    gamma_y = params.gamma_y;
    [X, Y] = meshgrid(x, y);
    V = 0.5 * (X.^2 + gamma_y^2 * Y.^2);
else % 3D
    gamma_y = params.gamma_y;
    gamma_z = params.gamma_z;
    [X, Y, Z] = meshgrid(x, y, z);
    V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
end
end

function V = optical_lattice_local(x, y, z, params)
% Optical lattice potential.

V0 = params.V0;
kL = params.kL;
include_harmonic = isfield(params, 'include_harmonic') && params.include_harmonic;

% Determine dimension based on input arrays
dim = params.dimension;

if dim == 1 % 1D
    V = V0 * sin(kL * x).^2;
    if include_harmonic
        % Add 1D harmonic potential (assuming base frequency 1)
        V = V + 0.5 * x.^2;
    end
elseif dim == 2 % 2D
    [X, Y] = meshgrid(x, y);
    V = V0 * (sin(kL * X).^2 + sin(kL * Y).^2);
    if include_harmonic
        gamma_y = params.gamma_y; % Required if harmonic
        V = V + 0.5 * (X.^2 + gamma_y^2 * Y.^2);
    end
else % 3D
    [X, Y, Z] = meshgrid(x, y, z);
    V = V0 * (sin(kL * X).^2 + sin(kL * Y).^2 + sin(kL * Z).^2);
    if include_harmonic
        gamma_y = params.gamma_y; % Required if harmonic
        gamma_z = params.gamma_z; % Required if harmonic
        V = V + 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    end
end
end

function V = double_well_local(x, y, z, params)
% Double-well potential.

if ~isfield(params, 'method')
    error('Must specify double-well method: ''gaussian_barrier'' or ''quartic''');
end

% Determine dimension based on input arrays
dim = params.dimension;

if dim == 1 % 1D
    if strcmpi(params.method, 'gaussian_barrier')
        V0 = params.V0;
        sigma = params.sigma;
        % Combine harmonic with Gaussian barrier along x
        V = 0.5 * x.^2 + V0 * exp(-x.^2 / sigma^2);
    elseif strcmpi(params.method, 'quartic')
        A = params.A;
        B = params.B;
        V = A * x.^4 - B * x.^2;
    else
        error('Invalid double-well method: %s', params.method);
    end
elseif dim == 2 % 2D
    gamma_y = params.gamma_y;
    [X, Y] = meshgrid(x, y);
    % Base harmonic potential
    V_harm = 0.5 * (X.^2 + gamma_y^2 * Y.^2);
    if strcmpi(params.method, 'gaussian_barrier')
        V0 = params.V0;
        sigma = params.sigma;
        % Add barrier along x
        V = V_harm + V0 * exp(-X.^2 / sigma^2);
    elseif strcmpi(params.method, 'quartic')
        A = params.A;
        B = params.B;
        % Apply quartic along x, harmonic along y
        V = A * X.^4 - B * X.^2 + 0.5 * gamma_y^2 * Y.^2;
    else
        error('Invalid double-well method: %s', params.method);
    end
else % 3D
    gamma_y = params.gamma_y;
    gamma_z = params.gamma_z;
    [X, Y, Z] = meshgrid(x, y, z);
    % Base harmonic potential
    V_harm = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    if strcmpi(params.method, 'gaussian_barrier')
        V0 = params.V0;
        sigma = params.sigma;
        % Add barrier along x
        V = V_harm + V0 * exp(-X.^2 / sigma^2);
    elseif strcmpi(params.method, 'quartic')
        A = params.A;
        B = params.B;
        % Apply quartic along x, harmonic along y and z
        V = A * X.^4 - B * X.^2 + 0.5 * (gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    else
        error('Invalid double-well method: %s', params.method);
    end
end
end

function V = anharmonic_local(x, y, z, params)
% Anharmonic potential (harmonic + quartic terms).

lambda = params.lambda;

% Determine dimension based on input arrays
dim = params.dimension;

if dim == 1 % 1D
    V = 0.5 * x.^2 + lambda * x.^4;
elseif dim == 2 % 2D
    gamma_y = params.gamma_y;
    [X, Y] = meshgrid(x, y);
    V = 0.5 * (X.^2 + gamma_y^2 * Y.^2) + lambda * (X.^4 + Y.^4);
else % 3D
    gamma_y = params.gamma_y;
    gamma_z = params.gamma_z;
    [X, Y, Z] = meshgrid(x, y, z);
    V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2) + ...
        lambda * (X.^4 + Y.^4 + Z.^4);
end
end

function V = rotating_trap_local(x, y, z, params)
% Rotating trap potential with optional stirring beam (2D only).

if ~isempty(z)
    error('Rotating trap is implemented in 2D only');
end

% Extract parameters
omega_x = params.omega_x; % Note: Uses omega_x/y, not gamma_y
omega_y = params.omega_y;
Ws = params.Ws;
Vs = params.Vs;
r0 = params.r0;
omega_s = params.omega_s;
t = params.t;

% Create 2D grid
[X, Y] = meshgrid(x, y);

% Calculate stirring beam position
rs_t = [r0 * cos(omega_s * t), r0 * sin(omega_s * t)];

% Calculate harmonic trap and stirring potential
V_harmonic = 0.5 * (omega_x^2 * X.^2 + omega_y^2 * Y.^2);
V_stirring = Ws * exp(-4 * ((X - rs_t(1)).^2 + (Y - rs_t(2)).^2) / Vs^2);

% Total potential
V = V_harmonic + V_stirring;
end

function V = disordered_local(x, y, z, params)
% Disordered potential with optional harmonic trap.

% Set random seed for reproducibility
if isfield(params, 'seed')
    rng(params.seed);
else
    rng('shuffle'); % Ensure different disorder each time if no seed
end

V0 = params.V0;
lc = params.correlation_length;
include_harmonic = isfield(params, 'include_harmonic') && params.include_harmonic;

% Get dimension from params
dim = params.dimension;
Nx = length(x);
if dim >= 2
    Ny = length(y);
end
if dim >= 3
    Nz = length(z);
end

if dim == 1 % 1D
    % Generate random potential with correlation length lc
    xi = randn(1, Nx);
    % Apply Gaussian smoothing (require Image Processing Toolbox or alternative)
    try
        xi = smoothdata(xi, 'gaussian', round(lc/mean(diff(x))));
    catch ME
        warning(ME.identifier, 'smoothdata (Statistics and Machine Learning Toolbox) or alternative needed for 1D disorder smoothing. Using raw noise. Error: %s', ME.message);
    end
    V_disorder = V0 * xi;

    V = V_disorder;
    if include_harmonic
        V = V + 0.5 * x.^2;
    end

elseif dim == 2 % 2D
    [X, Y] = meshgrid(x, y);
    % Generate 2D random potential
    xi = randn(Ny, Nx);
    % Apply 2D Gaussian smoothing (requires Image Processing Toolbox)
    try
        sigma_smooth = lc / mean(diff(x)); % Estimate sigma in grid units
        xi = imgaussfilt(xi, sigma_smooth);
    catch ME
        warning(ME.identifier, 'imgaussfilt (Image Processing Toolbox) needed for 2D disorder smoothing. Using raw noise. Error: %s', ME.message);
    end
    V_disorder = V0 * xi;

    V = V_disorder;
    if include_harmonic
        gamma_y = params.gamma_y;
        V = V + 0.5 * (X.^2 + gamma_y^2 * Y.^2);
    end

else % 3D
    [X, Y, Z] = meshgrid(x, y, z);
    % Generate 3D random potential
    xi = randn(Ny, Nx, Nz);
    % Apply 3D Gaussian smoothing (requires Image Processing Toolbox)
    try
        sigma_smooth = lc / mean(diff(x)); % Estimate sigma in grid units
        % smooth3 is deprecated, use imgaussfilt3 if available, otherwise basic filtering
        if exist('imgaussfilt3', 'file')
            xi = imgaussfilt3(xi, sigma_smooth);
        else
            warning('potentials:smooth3Deprecated', 'imgaussfilt3 (Image Processing Toolbox) recommended for 3D disorder smoothing. Using raw noise.');
            % Basic smoothing could be added here if needed
        end
    catch ME
        warning(ME.identifier, 'Smoothing function needed for 3D disorder. Using raw noise. Error: %s', ME.message);
    end
    V_disorder = V0 * xi;

    V = V_disorder;
    if include_harmonic
        gamma_y = params.gamma_y;
        gamma_z = params.gamma_z;
        V = V + 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    end
end
end

function V = box_local(x, y, z, params)
% Box potential with hard or smoothed walls.

V0 = params.V0;
smoothing = isfield(params, 'smoothing') && params.smoothing > 0;

if smoothing
    if ~isfield(params, 'smoothing_width')
        error('Parameter "smoothing_width" required for smoothed box potential.');
    end
    w = params.smoothing_width; % Smoothing width
end

% Determine dimension based on input arrays
dim = params.dimension;

if dim == 1 % 1D
    Lx = params.Lx;
    if smoothing
        % Use tanh for smooth transition
        V = V0 * 0.5 * (1 + tanh((abs(x) - Lx/2) / w));
    else
        V = zeros(size(x));
        V(abs(x) >= Lx/2) = V0;
    end

elseif dim == 2 % 2D
    [X, Y] = meshgrid(x, y);
    Lx = params.Lx;
    Ly = params.Ly;

    if smoothing
        Vx = V0 * 0.5 * (1 + tanh((abs(X) - Lx/2) / w));
        Vy = V0 * 0.5 * (1 + tanh((abs(Y) - Ly/2) / w));
        % Combine walls: take the maximum potential value
        V = max(Vx, Vy);
        % Alternative: V = Vx + Vy - Vx.*Vy/V0; % Smoother corner approx
    else
        V = zeros(size(X));
        V(abs(X) >= Lx/2 | abs(Y) >= Ly/2) = V0;
    end

else % 3D
    [X, Y, Z] = meshgrid(x, y, z);
    Lx = params.Lx;
    Ly = params.Ly;
    Lz = params.Lz;

    if smoothing
        Vx = V0 * 0.5 * (1 + tanh((abs(X) - Lx/2) / w));
        Vy = V0 * 0.5 * (1 + tanh((abs(Y) - Ly/2) / w));
        Vz = V0 * 0.5 * (1 + tanh((abs(Z) - Lz/2) / w));
        % Combine walls: take the maximum potential value
        V = max(max(Vx, Vy), Vz);
    else
        V = zeros(size(X));
        V(abs(X) >= Lx/2 | abs(Y) >= Ly/2 | abs(Z) >= Lz/2) = V0;
    end
end
end 