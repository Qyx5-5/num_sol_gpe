function [psi_gs, results_gs] = ground_state(psi0, V, kx, ky, kz, dx, dy, dz, params, config, helpers)
% Calculates the ground state wave function using the method specified in config.
% Uses helper functions passed in the 'helpers' struct.
%
% Args:
%     psi0: Initial wave function guess.
%     V: Potential energy array.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: Structure containing parameters (epsilon, kappa_d, etc.).
%     config: Configuration structure (specifies method in config.ground_state.method).
%     helpers: A struct containing function handles to utility functions.
%
% Returns:
%     psi_gs: The calculated ground state wave function.
%     results_gs: Structure containing convergence results (e.g., energy vs. iteration).

method = lower(config.ground_state.method);

switch method
    case 'imaginary_time'
        % Pass helpers to local function
        [psi_gs, results_gs] = imaginary_time_evolution_local(psi0, V, kx, ky, kz, dx, dy, dz, params, config, helpers);
    case 'direct_minimization'
        % Pass helpers to local function
        [psi_gs, results_gs] = direct_minimization_local(psi0, V, kx, ky, kz, dx, dy, dz, params, config, helpers);
    otherwise
        error('Unknown ground state method: %s', method);
end

end

% --- Local Ground State Calculation Functions ---

function [psi, results] = imaginary_time_evolution_local(psi, V, kx, ky, kz, dx, dy, dz, params, config, helpers)
% Calculates the ground state using imaginary time evolution.
% (Local version, uses helpers)

% Get parameters
dt_imag = config.ground_state.dt_imag;
tolerance = config.ground_state.tolerance;
max_iter = config.ground_state.max_iter;
epsilon = params.epsilon;
kappa_d = params.kappa_d;
dimension = config.simulation.dimension;

% Initialize variables for convergence check
old_energy = Inf;
converged = false;
iter = 0;

% Initialize results structure
results = struct();
results.energy = zeros(1, max_iter);
results.iteration = zeros(1, max_iter);

% Main imaginary time evolution loop
while ~converged && iter < max_iter
    iter = iter + 1;

    % Perform one TSSP step with imaginary time dt -> -1i*dt_imag
    % Re-implement step logic here, cannot call tssp_solver's local steps
    
    % 1. Potential half-step (imaginary time)
    psi = psi .* exp(-(dt_imag/2) / epsilon * (V + kappa_d * abs(psi).^2));
    
    % 2. Kinetic full-step (imaginary time)
    switch dimension
        case 1
            psi_hat = fft(psi);
            K = kx.^2;
            psi = ifft(exp(-epsilon * dt_imag * K / 2) .* psi_hat);
        case 2
            psi_hat = fft2(psi);
            [KX, KY] = meshgrid(kx, ky);
            K = KX.^2 + KY.^2;
            psi = ifft2(exp(-epsilon * dt_imag * K / 2) .* psi_hat);
        case 3
            psi_hat = fftn(psi);
            [KX, KY, KZ] = meshgrid(kx, ky, kz);
            K = KX.^2 + KY.^2 + KZ.^2;
            psi = ifftn(exp(-epsilon * dt_imag * K / 2) .* psi_hat);
    end
    
    % 3. Potential half-step (imaginary time)
    psi = psi .* exp(-(dt_imag/2) / epsilon * (V + kappa_d * abs(psi).^2));

    % Normalize wave function (using helper)
    psi = helpers.normalize_wavefunction(psi, dx, dy, dz, config);

    % Calculate energy (using helper)
    energy = helpers.calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);

    % Check convergence (relative change)
    if iter > 1 && abs(old_energy) > eps % Avoid division by zero/NaN
        if abs(energy - old_energy) / abs(old_energy) < tolerance
            converged = true;
        end
    elseif iter > 1 && abs(energy - old_energy) < tolerance % Fallback for zero energy
         converged = true;
    end

    % Update for next iteration
    old_energy = energy;

    % Store results
    results.energy(iter) = energy;
    results.iteration(iter) = iter;

    % Display progress
    if mod(iter, 50) == 0
        fprintf('GS Iter %d: Energy = %.8f\n', iter, energy);
    end
end

% Trim results arrays
results.energy = results.energy(1:iter);
results.iteration = results.iteration(1:iter);

if ~converged
    warning('Ground state (imaginary time) did not converge within %d iterations. Final energy change: %.3e', max_iter, abs(energy - results.energy(max(1,iter-1))));
end
fprintf('Ground state (imaginary time) finished in %d iterations. Final Energy = %.8f\n', iter, energy);

end

function [psi, results] = direct_minimization_local(psi, V, kx, ky, kz, dx, dy, dz, params, config, helpers)
% Calculates the ground state using direct energy minimization.
% (Local version, uses helpers)

% Get parameters
tolerance = config.ground_state.tolerance;
max_iter = config.ground_state.max_iter;
alpha = config.ground_state.minimization_step;

% Initialize variables for convergence check
old_energy = Inf;
converged = false;
iter = 0;

% Initialize results structure
results = struct();
results.energy = zeros(1, max_iter);
results.iteration = zeros(1, max_iter);

% Main minimization loop
while ~converged && iter < max_iter
    iter = iter + 1;

    % Calculate current energy (using helper)
    energy = helpers.calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);

    % Calculate energy gradient (using local function below)
    grad = calculate_energy_gradient_local(psi, V, kx, ky, kz, params, config);

    % Update wave function using gradient descent
    psi = psi - alpha * grad;

    % Normalize wave function (using helper)
    psi = helpers.normalize_wavefunction(psi, dx, dy, dz, config);

    % Check convergence (relative change)
    if iter > 1 && abs(old_energy) > eps % Avoid division by zero/NaN
        if abs(energy - old_energy) / abs(old_energy) < tolerance
            converged = true;
        end
     elseif iter > 1 && abs(energy - old_energy) < tolerance % Fallback for zero energy
         converged = true;
    end

    % Update for next iteration
    old_energy = energy;

    % Store results
    results.energy(iter) = energy;
    results.iteration(iter) = iter;

    % Display progress
    if mod(iter, 50) == 0 
        fprintf('GS Iter %d: Energy = %.8f\n', iter, energy);
    end
end

% Trim results arrays
results.energy = results.energy(1:iter);
results.iteration = results.iteration(1:iter);

if ~converged
     warning('Ground state (direct minimization) did not converge within %d iterations. Final energy change: %.3e', max_iter, abs(energy - results.energy(max(1,iter-1))));
end
fprintf('Ground state (direct minimization) finished in %d iterations. Final Energy = %.8f\n', iter, energy);

end

% --- Local Gradient Calculation Function ---

function grad = calculate_energy_gradient_local(psi, V, kx, ky, kz, params, config)
% Calculates the gradient of the energy functional (H*psi).
% (Local version for direct_minimization)

epsilon = params.epsilon;
kappa_d = params.kappa_d;
dimension = config.simulation.dimension;

% Calculate kinetic term gradient part: -epsilon^2/2 * laplacian(psi)
switch dimension
    case 1
        psi_hat = fft(psi);
        K = kx.^2;
        laplacian_psi = ifft(K .* psi_hat);
        grad_kin_term = -epsilon^2/2 * laplacian_psi;
    case 2
        psi_hat = fft2(psi);
        [KX, KY] = meshgrid(kx, ky);
        K = KX.^2 + KY.^2;
        laplacian_psi = ifft2(K .* psi_hat);
        grad_kin_term = -epsilon^2/2 * laplacian_psi;
    case 3
        psi_hat = fftn(psi);
        [KX, KY, KZ] = meshgrid(kx, ky, kz);
        K = KX.^2 + KY.^2 + KZ.^2;
        laplacian_psi = ifftn(K .* psi_hat);
        grad_kin_term = -epsilon^2/2 * laplacian_psi;
    otherwise
         error('Invalid dimension: %d', dimension);
end

% Assemble gradient: H*psi = (-epsilon^2/2 * laplacian + V + kappa_d*|psi|^2) * psi
grad = grad_kin_term + (V .* psi) + (kappa_d * abs(psi).^2 .* psi);
grad = real(grad); % Gradient should be real if H is Hermitian and psi is appropriately defined

end

% --- Removed Local Utility/Step Functions --- 
% (normalize_wavefunction_local, calculate_energy_local, 
%  apply_potential_step_local, apply_kinetic_step_local are removed) 