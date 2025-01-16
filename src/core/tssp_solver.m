function [psi, results] = tssp_solver(psi, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z)
% Runs the time evolution using the TSSP method.
%
% Args:
%     psi: The initial wave function.
%     V: The potential energy array.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: A structure containing parameters like epsilon and kappa_d.
%     config: A structure containing simulation configuration parameters.
%     x, y, z: Spatial coordinate arrays.
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
results.time = zeros(1, ceil(Nt/save_every));
results.density = cell(1, ceil(Nt/save_every));
results.sigma_x = zeros(1, ceil(Nt/save_every));
results.sigma_y = zeros(1, ceil(Nt/save_every));
results.sigma_z = zeros(1, ceil(Nt/save_every));
results.energy = zeros(1, ceil(Nt/save_every));

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
    psi = tssp_step(psi, V, kx, ky, kz, dt, params, config);
    
    % Save results at specified intervals
    if mod(n, save_every) == 0
        % Calculate density
        rho = abs(psi).^2;
        
        % Calculate condensate widths and energy if requested
        if isfield(config.visualization, 'calculate_observables') && config.visualization.calculate_observables
            [sigma_x, sigma_y, sigma_z] = calculate_condensate_widths(psi, x, y, z, dx, dy, dz, dimension);
            energy = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);
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