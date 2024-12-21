function plot_condensate_widths(results, config)
% Plots the evolution of condensate widths over time.
%
% Args:
%     results: Structure containing simulation results.
%     config: Configuration structure.

if ~isfield(results, 'sigma_x')
    error('No width data available in results');
end

figure('Name', 'Condensate Widths Evolution');

% Plot x-direction width
plot(results.time, results.sigma_x, 'b-', 'LineWidth', 2, 'DisplayName', '\sigma_x');
hold on;

% Plot y-direction width if 2D or 3D
if config.simulation.dimension >= 2 && ~all(isnan(results.sigma_y))
    plot(results.time, results.sigma_y, 'r--', 'LineWidth', 2, 'DisplayName', '\sigma_y');
end

% Plot z-direction width if 3D
if config.simulation.dimension == 3 && ~all(isnan(results.sigma_z))
    plot(results.time, results.sigma_z, 'g:', 'LineWidth', 2, 'DisplayName', '\sigma_z');
end

xlabel('Time');
ylabel('Width');
title('Condensate Widths Evolution');
legend('show');
grid on;

drawnow;

end 