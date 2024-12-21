function E = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config)
% Calculates the total energy of the system.
%
% Args:
%     psi: Wave function.
%     V: Potential energy array.
%     kx, ky, kz: Wave number arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     params: Structure containing parameters.
%     config: Configuration structure.
%
% Returns:
%     E: Total energy of the system.

% Get parameters
epsilon = params.epsilon;
kappa_d = params.kappa_d;
dimension = config.simulation.dimension;

% Calculate kinetic energy
switch dimension
    case 1
        psi_hat = fft(psi);
        K = kx.^2;
        E_kin = epsilon/2 * sum(K .* abs(psi_hat).^2) * dx;
        dV = dx;
        
    case 2
        psi_hat = fft2(psi);
        [KX, KY] = meshgrid(kx, ky);
        K = KX.^2 + KY.^2;
        E_kin = epsilon/2 * sum(K .* abs(psi_hat).^2, 'all') * dx * dy;
        dV = dx * dy;
        
    case 3
        psi_hat = fftn(psi);
        [KX, KY, KZ] = meshgrid(kx, ky, kz);
        K = KX.^2 + KY.^2 + KZ.^2;
        E_kin = epsilon/2 * sum(K .* abs(psi_hat).^2, 'all') * dx * dy * dz;
        dV = dx * dy * dz;
end

% Calculate potential energy
E_pot = sum(V .* abs(psi).^2, 'all') * dV;

% Calculate interaction energy
E_int = kappa_d/2 * sum(abs(psi).^4, 'all') * dV;

% Total energy
E = real(E_kin + E_pot + E_int);

end 