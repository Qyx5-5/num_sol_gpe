function [psi, results] = imaginary_time_evolution(psi, V, kx, ky, kz, dx, dy, dz, params, config)
% Calculates the ground state using imaginary time evolution.
%
% Args:
%     psi: Initial wave function guess.
%     V: Potential energy array.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: Structure containing parameters.
%     config: Configuration structure.
%
% Returns:
%     psi: The calculated ground state wave function.

% Get parameters
dt = config.ground_state.dt_imag;
tolerance = config.ground_state.tolerance;
max_iter = 1000; % Maximum number of iterations

% Initialize variables for convergence check
old_energy = Inf;
converged = false;
iter = 0;

% Initialize results structure
results.energy = [];
results.iterations = [];

% Main imaginary time evolution loop
while ~converged && iter < max_iter
    % Store old wave function
    psi_old = psi;
    
    % Perform one TSSP step with imaginary time (dt -> -i*dt)
    psi = apply_potential_step(psi, V, -1i*dt, params);
    psi = apply_kinetic_step(psi, kx, ky, kz, -1i*dt, params, config.simulation.dimension);
    psi = apply_potential_step(psi, V, -1i*dt, params);
    
    % Normalize wave function
    psi = normalize_wavefunction(psi, dx, dy, dz, config);
    
    % Calculate energy
    energy = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);
    
    % Check convergence
    if abs(energy - old_energy) < tolerance
        converged = true;
    end
    
    % Update for next iteration
    old_energy = energy;
    iter = iter + 1;
    
    % Store results
    results.energy(end+1) = energy;
    results.iterations(end+1) = iter;
    
    % Display progress
    if mod(iter, 10) == 0
        fprintf('Iteration %d: Energy = %.6f\n', iter, energy);
    end
end

if ~converged
    warning('Ground state calculation did not converge within %d iterations', max_iter);
end

end 