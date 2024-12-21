function kappa_d = calculate_kappa_d(kappa, dimension, epsilon, gamma_y, gamma_z)
% Calculates the dimension-dependent interaction parameter kappa_d.
%
% Args:
%     kappa: The dimensionless interaction parameter.
%     dimension: The dimension of the simulation (1, 2, or 3).
%     epsilon: The scaling parameter epsilon.
%     gamma_y: The trap anisotropy parameter in the y-direction.
%     gamma_z: The trap anisotropy parameter in the z-direction.
%
% Returns:
%     kappa_d: The dimension-dependent interaction parameter.

switch dimension
    case 1
        kappa_d = kappa;
    case 2
        kappa_d = kappa * sqrt(gamma_y) / (2 * pi * epsilon);
    case 3
        kappa_d = kappa * sqrt(gamma_y * gamma_z) / (4 * pi * epsilon^2);
    otherwise
        error('Invalid dimension: %d', dimension);
end

end 