function animate_simulation(x, y, z, results, config)
% Creates an animation of the density evolution with interactive controls.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     results: Structure containing simulation results.
%     config: Configuration structure.

if ~isfield(results, 'density')
    error('No density data available for animation');
end

% Create UI figure with controls
fig = uifigure('Name', 'GPE Simulation Animation');
fig.Position(3:4) = [1000 800];  % Wider figure for combined plots

% Create main axes grid
ax1 = uiaxes(fig, 'Position', [50 400 450 350]);  % Density plot
ax2 = uiaxes(fig, 'Position', [550 400 400 350]); % Cross-section
ax3 = uiaxes(fig, 'Position', [50 50 450 300]);   % Widths
ax4 = uiaxes(fig, 'Position', [550 50 400 300]);  % Energy

% Add slider for time navigation
slider = uislider(fig, 'Position', [50 370 900 3]);
slider.Limits = [1 length(results.time)];
slider.Value = 1;

% Add control buttons
playBtn = uibutton(fig, 'Text', 'Play', ...
    'Position', [450 330 60 25], ...
    'ButtonPushedFcn', @(btn,~) playAnimation(btn));
pauseBtn = uibutton(fig, 'Text', 'Pause', ...
    'Position', [520 330 60 25], ...
    'ButtonPushedFcn', @(~,~) setappdata(fig, 'Playing', false));

% Initialize video writer if requested
if isfield(config.visualization, 'save_video') && config.visualization.save_video
    v = VideoWriter('gpe_simulation.avi');
    v.FrameRate = 20;
    open(v);
    setappdata(fig, 'VideoWriter', v);
end

% Store data in figure for callbacks
setappdata(fig, 'Results', results);
setappdata(fig, 'Config', config);
setappdata(fig, 'Coords', struct('x', x, 'y', y, 'z', z));
setappdata(fig, 'Playing', false);

% Set up callback for slider
slider.ValueChangedFcn = @(s,~) updatePlots(s.Value);

% Initial plot
updatePlots(1);

    function playAnimation(btn)
        setappdata(fig, 'Playing', true);
        while getappdata(fig, 'Playing') && slider.Value < length(results.time)
            slider.Value = slider.Value + 1;
            updatePlots(slider.Value);  % Explicitly call updatePlots
            drawnow limitrate;  % Force immediate update with rate limiting
            pause(0.01);  % Shorter pause for smoother animation
        end
    end

    function updatePlots(frameIdx)
        frameIdx = round(frameIdx);
        data = getappdata(fig, 'Results');
        cfg = getappdata(fig, 'Config');
        coords = getappdata(fig, 'Coords');
        
        % Update density plot
        density = data.density{frameIdx};
        if cfg.simulation.dimension == 1
            plot(ax1, coords.x, density);
            title(ax1, sprintf('Density at t = %.2f', data.time(frameIdx)));
            xlabel(ax1, 'x');
            ylabel(ax1, '|\psi|²');
        elseif cfg.simulation.dimension == 2
            imagesc(ax1, coords.x, coords.y, density);
            axis(ax1, 'equal', 'tight');
            colorbar(ax1);
            title(ax1, sprintf('Density at t = %.2f', data.time(frameIdx)));
            xlabel(ax1, 'x');
            ylabel(ax1, 'y');
        else
            % 3D case: show multiple isosurfaces
            [X, Y, Z] = meshgrid(coords.x, coords.y, coords.z);
            cla(ax1);
            isoLevels = linspace(0.1 * max(density(:)), max(density(:)), 4);
            for lvl = isoLevels
                p = patch(ax1, isosurface(X, Y, Z, density, lvl));
                isonormals(X, Y, Z, density, p);
                p.FaceColor = 'interp';
                p.EdgeColor = 'none';
                alpha(p, 0.2);
                hold(ax1, 'on');
            end
            view(ax1, 3);
            camlight(ax1, 'headlight');
            lighting(ax1, 'gouraud');
            title(ax1, sprintf('3D Density at t = %.2f', data.time(frameIdx)));
            xlabel(ax1, 'x');
            ylabel(ax1, 'y');
            zlabel(ax1, 'z');
            hold(ax1, 'off');
        end
        
        % Update cross-section plot
        if cfg.simulation.dimension > 1
            center_y = round(length(coords.y)/2);
            plot(ax2, coords.x, density(:,center_y), 'LineWidth', 2);
            title(ax2, 'Density Cross-section (y-center)');
            xlabel(ax2, 'x');
            ylabel(ax2, '|\psi|²');
            grid(ax2, 'on');
        end
        
        % Update widths plot if available
        if isfield(data, 'sigma_x')
            plot(ax3, data.time(1:frameIdx), data.sigma_x(1:frameIdx), 'r', ...
                 data.time(1:frameIdx), data.sigma_y(1:frameIdx), 'g', ...
                 'LineWidth', 2);
            title(ax3, 'Condensate Widths');
            xlabel(ax3, 'Time');
            ylabel(ax3, 'Width');
            legend(ax3, 'σ_x', 'σ_y');
            grid(ax3, 'on');
        end
        
        % Update energy plot if available
        if isfield(data, 'energy')
            plot(ax4, data.time(1:frameIdx), data.energy(1:frameIdx), 'k', 'LineWidth', 2);
            title(ax4, 'Energy Evolution');
            xlabel(ax4, 'Time');
            ylabel(ax4, 'Energy');
            grid(ax4, 'on');
        end
        
        % Save video frame if enabled
        if isfield(cfg.visualization, 'save_video') && cfg.visualization.save_video
            v = getappdata(fig, 'VideoWriter');
            frame = getframe(fig);
            writeVideo(v, frame);
        end
    end

% Clean up when figure is closed
set(fig, 'CloseRequestFcn', @cleanup);

    function cleanup(~,~)
        % Stop animation if running
        setappdata(fig, 'Playing', false);
        
        % Close video writer if open
        if isfield(config.visualization, 'save_video') && config.visualization.save_video
            v = getappdata(fig, 'VideoWriter');
            close(v);
        end
        
        % Delete figure
        delete(fig);
    end
end 