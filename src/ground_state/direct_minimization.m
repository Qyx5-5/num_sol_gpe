function psi = direct_minimization(psi, V, kx, ky, kz, dx, dy, dz, params, config)
% Calculates the ground state using direct energy minimization.
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
tolerance = config.ground_state.tolerance;
max_iter = 1000;
alpha = 0.1; % Step size for gradient descent

% Initialize variables for convergence check
old_energy = Inf;
converged = false;
iter = 0;

% Main minimization loop
while ~converged && iter < max_iter
    % Calculate current energy
    energy = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);
    
    % Calculate energy gradient
    grad = calculate_energy_gradient(psi, V, kx, ky, kz, dx, dy, dz, params, config);
    
    % Update wave function using gradient descent
    psi = psi - alpha * grad;
    
    % Normalize wave function
    psi = normalize_wavefunction(psi, dx, dy, dz, config);
    
    % Check convergence
    if abs(energy - old_energy) < tolerance
        converged = true;
    end
    
    % Update for next iteration
    old_energy = energy;
    iter = iter + 1;
    
    % Display progress
    if mod(iter, 10) == 0
        fprintf('Iteration %d: Energy = %.6f\n', iter, energy);
    end
end

if ~converged
    warning('Ground state calculation did not converge within %d iterations', max_iter);
end

end

function grad = calculate_energy_gradient(psi, V, kx, ky, kz, dx, dy, dz, params, config)
% Calculates the gradient of the energy functional.
%
% Returns:
%     grad: Gradient of the energy functional.

epsilon = params.epsilon;
kappa_d = params.kappa_d;
dimension = config.simulation.dimension;

% Calculate kinetic term
switch dimension
    case 1
        psi_hat = fft(psi);
        K = kx.^2;
        grad_kin = -epsilon/2 * ifft(K .* psi_hat);
        
    case 2
        psi_hat = fft2(psi);
        [KX, KY] = meshgrid(kx, ky);
        K = KX.^2 + KY.^2;
        grad_kin = -epsilon/2 * ifft2(K .* psi_hat);
        
    case 3
        psi_hat = fftn(psi);
        [KX, KY, KZ] = meshgrid(kx, ky, kz);
        K = KX.^2 + KY.^2 + KZ.^2;
        grad_kin = -epsilon/2 * ifftn(K .* psi_hat);
end

% Calculate potential and interaction terms
grad_pot = V .* psi;
grad_int = kappa_d * abs(psi).^2 .* psi;

% Total gradient
grad = grad_kin + grad_pot + grad_int;

end 