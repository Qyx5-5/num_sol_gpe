function psi = apply_potential_step(psi, V, dt, params)
% Applies the potential evolution step of the TSSP method.
%
% Args:
%     psi: Wave function.
%     V: Potential energy array.
%     dt: Time step.
%     params: Structure containing parameters.
%
% Returns:
%     psi: Updated wave function.

kappa_d = params.kappa_d;
epsilon = params.epsilon;

% Apply potential and nonlinear evolution
psi = psi .* exp(-1i * dt / (2 * epsilon) * (V + kappa_d * abs(psi).^2));

end 