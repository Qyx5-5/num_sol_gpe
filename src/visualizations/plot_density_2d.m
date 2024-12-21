function plot_density_2d(x, y, psi, results, config)
% Plots the 2D density distribution.
%
% Args:
%     x, y: Spatial coordinate arrays.
%     psi: Final wave function.
%     results: Structure containing simulation results.
%     config: Configuration structure.

figure('Name', '2D Density Distribution');

% Plot final density
subplot(1,2,1);
[X, Y] = meshgrid(x, y);
density = abs(psi).^2;
surf(X, Y, density);
shading interp;
view(2);
xlabel('x');
ylabel('y');
title('Final Density Distribution');
colorbar;

% Plot density cross-sections
subplot(1,2,2);
center_x = round(length(x)/2);
center_y = round(length(y)/2);
plot(x, density(:,center_y), 'b-', 'LineWidth', 2, 'DisplayName', 'x-section');
hold on;
plot(y, density(center_x,:), 'r--', 'LineWidth', 2, 'DisplayName', 'y-section');
xlabel('Position');
ylabel('|\psi|²');
title('Density Cross-sections');
legend('show');
grid on;

% Optional: Create animation if requested
if config.visualization.animate
    if isempty(results) || ~isfield(results, 'density')
        warning('No density data available for animation.');
    else
        figure('Name', '2D Density Evolution');
        for i = 1:length(results.time)
            surf(X, Y, results.density{i});
            shading interp;
            view(2);
            xlabel('x');
            ylabel('y');
            title(sprintf('Time: %.2f', results.time(i)));
            colorbar;
            drawnow;
            pause(0.1);
        end
    end
end

drawnow;

end 