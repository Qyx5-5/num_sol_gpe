function [sigma_x, sigma_y, sigma_z] = calculate_condensate_widths(psi, x, y, z, dx, dy, dz, dimension)
% Calculates the condensate widths (sigma_x, sigma_y, sigma_z).
%
% Args:
%     psi: The wave function.
%     x, y, z: Spatial coordinate arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     dimension: The dimension of the simulation (1, 2, or 3).
%
% Returns:
%     sigma_x: Condensate width in the x-direction.
%     sigma_y: Condensate width in the y-direction.
%     sigma_z: Condensate width in the z-direction.

rho = abs(psi).^2;

switch dimension
    case 1
        x_mean = sum(x .* rho) * dx / (sum(rho) * dx);
        sigma_x = sqrt(sum((x - x_mean).^2 .* rho) * dx / (sum(rho) * dx));
        sigma_y = NaN;
        sigma_z = NaN;
    case 2
        [X, Y] = meshgrid(x, y);
        x_mean = sum(X .* rho, 'all') * dx * dy / (sum(rho, 'all') * dx * dy);
        y_mean = sum(Y .* rho, 'all') * dx * dy / (sum(rho, 'all') * dx * dy);
        sigma_x = sqrt(sum((X - x_mean).^2 .* rho, 'all') * dx * dy / (sum(rho, 'all') * dx * dy));
        sigma_y = sqrt(sum((Y - y_mean).^2 .* rho, 'all') * dx * dy / (sum(rho, 'all') * dx * dy));
        sigma_z = NaN;
    case 3
        [X, Y, Z] = meshgrid(x, y, z);
        x_mean = sum(X .* rho, 'all') * dx * dy * dz / (sum(rho, 'all') * dx * dy * dz);
        y_mean = sum(Y .* rho, 'all') * dx * dy * dz / (sum(rho, 'all') * dx * dy * dz);
        z_mean = sum(Z .* rho, 'all') * dx * dy * dz / (sum(rho, 'all') * dx * dy * dz);
        sigma_x = sqrt(sum((X - x_mean).^2 .* rho, 'all') * dx * dy * dz / (sum(rho, 'all') * dx * dy * dz));
        sigma_y = sqrt(sum((Y - y_mean).^2 .* rho, 'all') * dx * dy * dz / (sum(rho, 'all') * dx * dy * dz));
        sigma_z = sqrt(sum((Z - z_mean).^2 .* rho, 'all') * dx * dy * dz / (sum(rho, 'all') * dx * dy * dz));
    otherwise
        error('Invalid dimension: %d', dimension);
end

end 