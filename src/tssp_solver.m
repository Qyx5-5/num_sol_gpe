function [psi, results] = tssp_solver(psi, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z, helpers)
% Runs the time evolution using the TSSP method.
% Uses helper functions passed in the 'helpers' struct.
%
% Args:
%     psi: The initial wave function.
%     V: The potential energy array.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: A structure containing parameters like epsilon and kappa_d.
%     config: A structure containing simulation configuration parameters.
%     x, y, z: Spatial coordinate arrays.
%     helpers: A struct containing function handles to utility functions.
%
% Returns:
%     psi: The final wave function after time evolution.
%     results: A structure containing results at saved time steps.

% Extract parameters from config
dt = config.simulation.dt;
Nt = config.simulation.Nt;
save_every = config.simulation.save_every;
dimension = config.simulation.dimension;

% Initialize results structure
results = struct();
num_saves = ceil(Nt/save_every);
results.time = zeros(1, num_saves);
results.density = cell(1, num_saves);
results.sigma_x = zeros(1, num_saves);
results.sigma_y = zeros(1, num_saves);
results.sigma_z = zeros(1, num_saves);
results.energy = zeros(1, num_saves);

% Check if dimensions of psi and V match
if ~isequal(size(psi), size(V))
    error('Dimensions of psi and V do not match.');
end

% Check if kx, ky, kz are provided for dimensions > 1
if config.simulation.dimension > 1 && (isempty(kx) || isempty(ky))
    error('Wave number arrays kx and ky are required for 2D simulations.');
end
if config.simulation.dimension > 2 && isempty(kz)
    error('Wave number array kz is required for 3D simulations.');
end

% Time evolution loop
for n = 1:Nt
    % Perform one TSSP step
    psi = tssp_step_local(psi, V, kx, ky, kz, dt, params, config);
    
    % Save results at specified intervals
    if mod(n, save_every) == 0
        % Calculate density
        rho = abs(psi).^2;
        
        % Calculate condensate widths and energy if requested
        if isfield(config.visualization, 'calculate_observables') && config.visualization.calculate_observables
            [sigma_x, sigma_y, sigma_z] = helpers.calculate_condensate_widths(psi, x, y, z, dx, dy, dz, dimension);
            energy = helpers.calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);
        else
            sigma_x = NaN;
            sigma_y = NaN;
            sigma_z = NaN;
            energy = NaN;
        end
        
        % Store results
        idx = n/save_every;
        results.time(idx) = n * dt;
        results.density{idx} = rho;
        results.sigma_x(idx) = sigma_x;
        results.sigma_y(idx) = sigma_y;
        results.sigma_z(idx) = sigma_z;
        results.energy(idx) = energy;
        
        % Display progress
        fprintf('Time step: %d/%d (t = %f)\n', n, Nt, n * dt);
    end
end

end

% --- Local Functions ---

function psi = tssp_step_local(psi, V, kx, ky, kz, dt, params, config)
% Performs a single TSSP step (potential, kinetic, potential).
% Uses local potential and kinetic step functions.

% Apply potential step (half step)
psi = apply_potential_step_local(psi, V, dt/2, params); % Half dt

% Apply kinetic step (full step)
psi = apply_kinetic_step_local(psi, kx, ky, kz, dt, params, config.simulation.dimension);

% Apply potential step again (half step)
psi = apply_potential_step_local(psi, V, dt/2, params); % Half dt

end

function psi = apply_potential_step_local(psi, V, dt_half, params)
% Applies the potential evolution step of the TSSP method.
% (Local version)

kappa = params.kappa;
epsilon = params.epsilon;

% Apply potential and nonlinear evolution
psi = psi .* exp(-1i * dt_half / epsilon * (V + kappa * abs(psi).^2)); % Note: dt_half used here

end

function psi = apply_kinetic_step_local(psi, kx, ky, kz, dt, params, dimension)
% Applies the kinetic evolution step of the TSSP method.
% (Local version)

epsilon = params.epsilon;

% Apply kinetic evolution in Fourier space
switch dimension
    case 1
        psi_hat = fft(psi);
        K = kx.^2;
        psi = ifft(exp(-1i * epsilon * dt * K / 2) .* psi_hat); % Corrected exponent: (-i*epsilon*k^2*dt/2)

    case 2
        psi_hat = fft2(psi);
        [KX, KY] = meshgrid(kx, ky);
        K = KX.^2 + KY.^2;
        psi = ifft2(exp(-1i * epsilon * dt * K / 2) .* psi_hat); % Corrected exponent: (-i*epsilon*k^2*dt/2)

    case 3
        psi_hat = fftn(psi);
        [KX, KY, KZ] = meshgrid(kx, ky, kz);
        K = KX.^2 + KY.^2 + KZ.^2;
        psi = ifftn(exp(-1i * epsilon * dt * K / 2) .* psi_hat); % Corrected exponent: (-i*epsilon*k^2*dt/2)
end

end 