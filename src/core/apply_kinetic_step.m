function psi = apply_kinetic_step(psi, kx, ky, kz, dt, params, dimension)
% Applies the kinetic evolution step of the TSSP method.
%
% Args:
%     psi: Wave function.
%     kx, ky, kz: Wave number arrays.
%     dt: Time step.
%     params: Structure containing parameters.
%     dimension: Dimension of the system (1, 2, or 3).
%
% Returns:
%     psi: Updated wave function.

epsilon = params.epsilon;

% Apply kinetic evolution in Fourier space
switch dimension
    case 1
        psi_hat = fft(psi);
        K = kx.^2;
        psi = ifft(exp(-1i * epsilon * dt * K / 2) .* psi_hat);
        
    case 2
        psi_hat = fft2(psi);
        [KX, KY] = meshgrid(kx, ky);
        K = KX.^2 + KY.^2;
        psi = ifft2(exp(-1i * epsilon * dt * K / 2) .* psi_hat);
        
    case 3
        psi_hat = fftn(psi);
        [KX, KY, KZ] = meshgrid(kx, ky, kz);
        K = KX.^2 + KY.^2 + KZ.^2;
        psi = ifftn(exp(-1i * epsilon * dt * K / 2) .* psi_hat);
end

end 