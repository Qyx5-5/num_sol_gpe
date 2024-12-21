function plot_density_1d(x, psi, results, config)
% Plots the 1D density distribution.
%
% Args:
%     x: Spatial coordinate array.
%     psi: Final wave function.
%     results: Structure containing simulation results.
%     config: Configuration structure.

figure('Name', '1D Density Distribution');

% Plot final density
subplot(2,1,1);
plot(x, abs(psi).^2, 'LineWidth', 2);
xlabel('x');
ylabel('|\psi|²');
title('Final Density Distribution');
grid on;

% Plot density evolution if available
if ~isempty(results) && isfield(results, 'density')
    subplot(2,1,2);
    if iscell(results.density)
        densities = cat(1, results.density{:});
    else
        densities = results.density;
    end
    imagesc(x, results.time, densities);
    xlabel('x');
    ylabel('Time');
    title('Density Evolution');
    colorbar;
    axis xy;
end

drawnow;

end 