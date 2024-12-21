function plot_density_3d(x, y, z, psi, results, config)
% Plots the 3D density distribution using isosurfaces and slices.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     psi: Final wave function.
%     results: Structure containing simulation results.
%     config: Configuration structure.

figure('Name', '3D Density Distribution');

% Create meshgrid
[X, Y, Z] = meshgrid(x, y, z);
density = abs(psi).^2;

% Plot isosurfaces
subplot(2,2,1);
isovalue = max(density(:))/3;
p = patch(isosurface(X, Y, Z, density, isovalue));
isonormals(X, Y, Z, density, p);
p.FaceColor = 'red';
p.EdgeColor = 'none';
daspect([1 1 1]);
view(3);
camlight;
lighting gouraud;
xlabel('x');
ylabel('y');
zlabel('z');
title('Isosurface');

% Plot slices
subplot(2,2,2);
center_x = round(length(x)/2);
center_y = round(length(y)/2);
center_z = round(length(z)/2);

slice(X, Y, Z, density, x(center_x), y(center_y), z(center_z));
xlabel('x');
ylabel('y');
zlabel('z');
title('Density Slices');
colorbar;

% Plot cross-sections
subplot(2,2,3);
plot(x, density(:,center_y,center_z), 'b-', 'LineWidth', 2, 'DisplayName', 'x-section');
hold on;
plot(y, density(center_x,:,center_z), 'r--', 'LineWidth', 2, 'DisplayName', 'y-section');
plot(z, squeeze(density(center_x,center_y,:)), 'g:', 'LineWidth', 2, 'DisplayName', 'z-section');
xlabel('Position');
ylabel('|\psi|²');
title('Density Cross-sections');
legend('show');
grid on;

% Optional: Create animation if requested
if config.visualization.animate && ~isempty(results)
    figure('Name', '3D Density Evolution');
    for i = 1:length(results.time)
        density_t = results.density{i};
        p = patch(isosurface(X, Y, Z, density_t, isovalue));
        isonormals(X, Y, Z, density_t, p);
        p.FaceColor = 'red';
        p.EdgeColor = 'none';
        daspect([1 1 1]);
        view(3);
        camlight;
        lighting gouraud;
        title(sprintf('Time: %.2f', results.time(i)));
        drawnow;
        pause(0.1);
        if i < length(results.time)
            clf;
        end
    end
end

drawnow;

end 