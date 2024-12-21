function psi = tssp_step(psi, V, kx, ky, kz, dt, params, config)
% Performs a single TSSP step (potential, kinetic, potential).
%
% Args:
%     psi: The wave function.
%     V: The potential energy array.
%     kx, ky, kz: Wave number arrays.
%     dt: The time step.
%     params: A structure containing parameters like epsilon and kappa_d.
%     config: A structure containing simulation configuration parameters.
%
% Returns:
%     psi: The updated wave function after one TSSP step.

% Apply potential step
psi = apply_potential_step(psi, V, dt, params);

% Apply kinetic step
psi = apply_kinetic_step(psi, kx, ky, kz, dt, params, config.simulation.dimension);

% Apply potential step again
psi = apply_potential_step(psi, V, dt, params);

end 