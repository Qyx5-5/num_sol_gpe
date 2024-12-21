function psi = normalize_wavefunction(psi, dx, dy, dz, config)
% Normalizes the wave function such that the integral of |psi|^2 is 1.
%
% Args:
%     psi: The wave function.
%     dx, dy, dz: Grid spacing in each dimension.
%     config: Configuration structure.
%
% Returns:
%     psi: The normalized wave function.

dimension = config.simulation.dimension;

switch dimension
    case 1
        norm_factor = sqrt(sum(abs(psi).^2) * dx);
    case 2
        norm_factor = sqrt(sum(sum(abs(psi).^2)) * dx * dy);
    case 3
        norm_factor = sqrt(sum(sum(sum(abs(psi).^2))) * dx * dy * dz);
    otherwise
        error('Invalid dimension: %d', dimension);
end

psi = psi / norm_factor;

end 