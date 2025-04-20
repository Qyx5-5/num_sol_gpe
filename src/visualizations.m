function visualizations(x, y, z, psi, results, config)
% Handles visualization of simulation results based on configuration.
%
% Dispatches to appropriate local plotting or animation functions.
%
% Args:
%     x, y, z: Spatial coordinate arrays (can be empty for lower dimensions).
%     psi: Final wave function (can be empty if only plotting results).
%     results: Structure containing simulation results (time, density, widths, energy).
%     config: Configuration structure.

dim = config.simulation.dimension;

% Check what visualizations are requested
do_plot_density = isfield(config.visualization, 'plot_density') && config.visualization.plot_density;
do_plot_widths = isfield(config.visualization, 'plot_widths') && config.visualization.plot_widths && isfield(results, 'sigma_x');
do_animate = isfield(config.visualization, 'animate') && config.visualization.animate;

% --- Dispatch to Visualization Functions ---

if do_animate
    % Animation function handles multiple plot types internally
    animate_simulation_local(x, y, z, results, config);
else
    % Static plots
    if do_plot_density && ~isempty(psi)
        switch dim
            case 1
                plot_density_1d_local(x, psi, results, config);
            case 2
                plot_density_2d_local(x, y, psi, results, config);
            case 3
                plot_density_3d_local(x, y, z, psi, results, config);
        end
    end
    
    if do_plot_widths
        plot_condensate_widths_local(results, config);
    end
end

end

% --- Local Plotting/Animation Functions ---

function plot_density_1d_local(x, psi, results, config)
% Plots the 1D density distribution.
% (Local version)

figure('Name', '1D Density Distribution');

% Plot final density
subplot(2,1,1);
plot(x, abs(psi).^2, 'LineWidth', 2);
xlabel('x');
ylabel('|\psi|²');
title('Final Density Distribution');
grid on;

% Plot density evolution if available
if ~isempty(results) && isfield(results, 'density') && ~isempty(results.density)
    subplot(2,1,2);
    if iscell(results.density)
        % Ensure all cells have the same length
        len = length(x);
        densities_mat = zeros(length(results.density), len);
        for i = 1:length(results.density)
            if length(results.density{i}) == len
                 densities_mat(i,:) = results.density{i};
            else
                 warning('Inconsistent density vector length at time index %d', i);
                 % Option: Pad or skip
            end
        end
    else
        densities_mat = results.density; % Assume already a matrix
    end
    imagesc(x, results.time, densities_mat);
    xlabel('x');
    ylabel('Time');
    title('Density Evolution');
    colorbar;
    axis xy;
end

drawnow;

end

function plot_density_2d_local(x, y, psi, results, config)
% Plots the 2D density distribution.
% (Local version)

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
axis equal tight;

% Plot density cross-sections
subplot(1,2,2);
center_x_idx = find(x >= 0, 1); % Index near center x=0
center_y_idx = find(y >= 0, 1); % Index near center y=0
if isempty(center_x_idx); center_x_idx = round(length(x)/2); end
if isempty(center_y_idx); center_y_idx = round(length(y)/2); end

plot(x, density(center_y_idx,:), 'b-', 'LineWidth', 2, 'DisplayName', sprintf('y=%.2f', y(center_y_idx)));
hold on;
plot(y, density(:,center_x_idx), 'r--', 'LineWidth', 2, 'DisplayName', sprintf('x=%.2f', x(center_x_idx)));
xlabel('Position');
ylabel('|\psi|²');
title('Density Cross-sections');
legend('show');
grid on;
hold off;

drawnow;

end

function plot_density_3d_local(x, y, z, psi, results, config)
% Plots the 3D density distribution using isosurfaces and slices.
% (Local version)

figure('Name', '3D Density Distribution');

% Create meshgrid
[X, Y, Z] = meshgrid(x, y, z);
density = abs(psi).^2;

% Plot isosurfaces
subplot(2,2,[1 3]); % Make isosurface plot larger
max_dens = max(density(:));
if max_dens == 0; max_dens = 1; end % Avoid error if density is zero
isovalues = max_dens * [0.6, 0.3, 0.1]; % Multiple levels
colors = ['r', 'g', 'b'];
alpha_vals = [0.6, 0.3, 0.2];

for i = 1:length(isovalues)
    p = patch(isosurface(X, Y, Z, density, isovalues(i)));
    isonormals(X, Y, Z, density, p);
    p.FaceColor = colors(i);
    p.EdgeColor = 'none';
    alpha(p, alpha_vals(i));
    hold on;
end
daspect([1 1 1]);
view(3);
camlight;
lighting gouraud;
xlabel('x');
ylabel('y');
zlabel('z');
title(sprintf('Isosurfaces at %.1f, %.1f, %.1f max', isovalues/max_dens));
grid on;
hold off;

% Plot slices at center
subplot(2,2,2);
center_x_val = x(find(x >= 0, 1)); if isempty(center_x_val); center_x_val=x(round(length(x)/2)); end
center_y_val = y(find(y >= 0, 1)); if isempty(center_y_val); center_y_val=y(round(length(y)/2)); end
center_z_val = z(find(z >= 0, 1)); if isempty(center_z_val); center_z_val=z(round(length(z)/2)); end

hslice = slice(X, Y, Z, density, [], center_y_val, []); % Slice at y=0
set(hslice,'FaceColor','interp','EdgeColor','none', 'FaceAlpha', 0.75);
hold on;
hslice = slice(X, Y, Z, density, center_x_val, [], []); % Slice at x=0
set(hslice,'FaceColor','interp','EdgeColor','none', 'FaceAlpha', 0.75);
hslice = slice(X, Y, Z, density, [], [], center_z_val); % Slice at z=0
set(hslice,'FaceColor','interp','EdgeColor','none', 'FaceAlpha', 0.75);
hold off;
daspect([1 1 1]);
view(3);
xlabel('x');
ylabel('y');
zlabel('z');
title('Center Slices');
colorbar;

% Plot cross-sections at center
subplot(2,2,4);
center_x_idx = find(x >= 0, 1); if isempty(center_x_idx); center_x_idx=round(length(x)/2); end
center_y_idx = find(y >= 0, 1); if isempty(center_y_idx); center_y_idx=round(length(y)/2); end
center_z_idx = find(z >= 0, 1); if isempty(center_z_idx); center_z_idx=round(length(z)/2); end

plot(x, squeeze(density(center_y_idx,:,center_z_idx)), 'b-', 'LineWidth', 1.5, 'DisplayName', sprintf('y=%.1f, z=%.1f', y(center_y_idx), z(center_z_idx)));
hold on;
plot(y, squeeze(density(:,center_x_idx,center_z_idx)), 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('x=%.1f, z=%.1f', x(center_x_idx), z(center_z_idx)));
plot(z, squeeze(density(center_y_idx,center_x_idx,:)), 'g:', 'LineWidth', 1.5, 'DisplayName', sprintf('x=%.1f, y=%.1f', x(center_x_idx), y(center_y_idx)));
xlabel('Position');
ylabel('|\psi|²');
title('Center Cross-sections');
legend('show', 'Location', 'best');
grid on;
hold off;

drawnow;

end

function plot_condensate_widths_local(results, config)
% Plots the evolution of condensate widths over time.
% (Local version)

if ~isfield(results, 'time') || isempty(results.time)
    warning('No time data available in results for width plot');
    return;
end
if ~isfield(results, 'sigma_x') || isempty(results.sigma_x)
    warning('No width data (sigma_x) available in results for width plot');
    return;
end

figure('Name', 'Condensate Widths Evolution');

% Plot x-direction width
plot(results.time, results.sigma_x, 'b-', 'LineWidth', 2, 'DisplayName', '\sigma_x');
hold on;

% Plot y-direction width if 2D or 3D
if config.simulation.dimension >= 2 && isfield(results, 'sigma_y') && ~all(isnan(results.sigma_y))
    plot(results.time, results.sigma_y, 'r--', 'LineWidth', 2, 'DisplayName', '\sigma_y');
end

% Plot z-direction width if 3D
if config.simulation.dimension == 3 && isfield(results, 'sigma_z') && ~all(isnan(results.sigma_z))
    plot(results.time, results.sigma_z, 'g:', 'LineWidth', 2, 'DisplayName', '\sigma_z');
end

xlabel('Time');
ylabel('Width');
title('Condensate Widths Evolution');
legend('show');
grid on;
hold off;
drawnow;

end

function animate_simulation_local(x, y, z, results, config)
% Creates an animation of the density evolution with interactive controls.
% (Local version)

if ~isfield(results, 'density') || isempty(results.density)
    error('No density data available for animation');
end

num_frames = length(results.time);
if num_frames == 0
    error('Results structure has zero time steps for animation.');
end

% Create UI figure with controls
fig = uifigure('Name', 'GPE Simulation Animation', 'Scrollable', 'on');
fig.Position(3:4) = [1000 800];

% Create grid layout for better resizing
gl = uigridlayout(fig, [3 2]);
gl.RowHeight = {'6x', '1x', 30}; % Main plots, Slider, Buttons
gl.ColumnWidth = {'1x', '1x'};

% Create axes
ax1 = uiaxes(gl); ax1.Layout.Row = 1; ax1.Layout.Column = 1; % Density
ax2 = uiaxes(gl); ax2.Layout.Row = 1; ax2.Layout.Column = 2; % Cross-section/Widths
ax3 = uiaxes(gl); ax3.Layout.Row = 2; ax3.Layout.Column = [1 2]; % Energy
% ax4 = uiaxes(gl); ax4.Layout.Row = 2; ax4.Layout.Column = 2; % Energy

% Add slider for time navigation
slider = uislider(gl); slider.Layout.Row = 3; slider.Layout.Column = [1 2];
slider.Limits = [1 num_frames];
slider.Value = 1;
slider.MajorTicks = linspace(1, num_frames, min(num_frames, 11));
slider.MajorTickLabelsMode = 'auto';

% UI elements panel
% panel = uipanel(gl); panel.Layout.Row = 3; panel.Layout.Column = [1 2];
% btn_gl = uigridlayout(panel, [1 3]);
% Add control buttons
% playBtn = uibutton(btn_gl, 'Text', 'Play'); playBtn.Layout.Column = 1;
% pauseBtn = uibutton(btn_gl, 'Text', 'Pause'); pauseBtn.Layout.Column = 2;
% stopBtn = uibutton(btn_gl, 'Text', 'Stop'); stopBtn.Layout.Column = 3;

% Simplified buttons for now
playBtn = uibutton(fig, 'push', 'Text', 'Play', 'Position', [450, 10, 60, 22], 'ButtonPushedFcn', @playCallback);
pauseBtn = uibutton(fig, 'push', 'Text', 'Pause', 'Position', [520, 10, 60, 22], 'ButtonPushedFcn', @pauseCallback);

% Initialize video writer if requested
video_writer = [];
if isfield(config.visualization, 'save_video') && config.visualization.save_video
    try
        video_filename = 'gpe_simulation.avi';
        video_writer = VideoWriter(video_filename);
        if isfield(config.visualization, 'frame_rate')
            video_writer.FrameRate = config.visualization.frame_rate;
        else
            video_writer.FrameRate = 15;
        end
        open(video_writer);
        fprintf('Saving animation to %s\n', video_filename);
    catch ME
        warning(ME.identifier, 'Could not create video file: %s', ME.message);
        video_writer = [];
    end
end

% Store data in figure for callbacks
appdata.Results = results;
appdata.Config = config;
appdata.Coords = struct('x', x, 'y', y, 'z', z);
appdata.VideoWriter = video_writer;
appdata.IsPlaying = false;
appdata.CurrentFrame = 1;
set(fig, 'UserData', appdata);

% Set up callback for slider
slider.ValueChangedFcn = @sliderCallback;

% Initial plot
update_plots(1, fig, ax1, ax2, ax3);

% Nested Functions for Callbacks
    function sliderCallback(src, ~)
        appdata = get(fig, 'UserData');
        appdata.CurrentFrame = round(src.Value);
        set(fig, 'UserData', appdata);
        update_plots(appdata.CurrentFrame, fig, ax1, ax2, ax3);
    end

    function playCallback(~, ~)
        appdata = get(fig, 'UserData');
        if appdata.IsPlaying; return; end % Already playing
        appdata.IsPlaying = true;
        set(fig, 'UserData', appdata);
        
        while true % Loop controlled by IsPlaying flag
            appdata = get(fig, 'UserData');
            if ~appdata.IsPlaying; break; end % Stop requested
            
            current_frame = appdata.CurrentFrame;
            if current_frame >= num_frames
                appdata.IsPlaying = false; % Reached end
                set(fig, 'UserData', appdata);
                break;
            end
            
            next_frame = current_frame + 1;
            appdata.CurrentFrame = next_frame;
            slider.Value = next_frame; % Update slider visually
            set(fig, 'UserData', appdata);
            
            update_plots(next_frame, fig, ax1, ax2, ax3);
            drawnow; % Update figure window
            pause(0.05); % Control animation speed
        end
    end

    function pauseCallback(~, ~)
        appdata = get(fig, 'UserData');
        appdata.IsPlaying = false;
        set(fig, 'UserData', appdata);
    end

% Clean up when figure is closed
set(fig, 'CloseRequestFcn', @cleanup);

    function cleanup(src, ~)
        % Stop animation if running
        appdata = get(src, 'UserData');
        appdata.IsPlaying = false;
        set(src, 'UserData', appdata);
        pause(0.1); % Allow play loop to exit
        
        % Close video writer if open
        if ~isempty(appdata.VideoWriter)
            try
                close(appdata.VideoWriter);
                disp('Animation video saved.');
            catch ME
                warning(ME.identifier, 'Error closing video file: %s', ME.message);
            end
        end
        
        % Delete figure
        delete(src);
    end

end

function update_plots(frameIdx, fig, ax1, ax2, ax3)
% Helper function to update all plots in the animation figure.

appdata = get(fig, 'UserData');
data = appdata.Results;
cfg = appdata.Config;
coords = appdata.Coords;
dim = cfg.simulation.dimension;

frameIdx = round(frameIdx);
if frameIdx < 1 || frameIdx > length(data.time)
    return; % Invalid frame index
end

% --- Update Density Plot (ax1) ---
cla(ax1); % Clear previous plot
density = data.density{frameIdx};
max_dens = max(density(:));
if max_dens == 0; max_dens = 1; end % Avoid division by zero issues

% --- DEBUG PRINTS ---
fprintf('\n--- Debug Info for frame %d ---\n', frameIdx);
fprintf('Density size: %s\n', mat2str(size(density)));
fprintf('Max density value: %.4e\n', max(density(:)));
% --- END DEBUG PRINTS ---

if dim == 1
    plot(ax1, coords.x, density, 'LineWidth', 1.5);
    ylabel(ax1, '|\psi|²');
    xlabel(ax1, 'x');
elsif dim == 2
    % [X, Y] = meshgrid(coords.x, coords.y); % Not needed for imagesc
    imagesc(ax1, coords.x, coords.y, density); % Use imagesc instead of surf
    axis(ax1, 'xy', 'equal', 'tight'); % Set axis properties for imagesc
    % surf(ax1, X, Y, density); % Original surf command
    % shading(ax1, 'interp'); % Temporarily commented out
    % view(ax1, 2);           % Temporarily commented out
    % axis(ax1, 'equal', 'tight'); % Temporarily commented out
    colorbar(ax1);
    xlabel(ax1, 'x');
    ylabel(ax1, 'y');
elseif dim == 3
    if size(density, 3) > 1 % Check if data is truly 3D
        [X, Y, Z] = meshgrid(coords.x, coords.y, coords.z);
        isoLevels = max_dens * [0.6, 0.3, 0.1];
        colors = {'red', 'green', 'blue'};
        alphas = [0.5, 0.3, 0.1];
        hold(ax1, 'on');
        for i = 1:length(isoLevels)
            if isoLevels(i) > 0 % Only plot if isovalue is positive
                p = patch(ax1, isosurface(X, Y, Z, density, isoLevels(i)));
                isonormals(X, Y, Z, density, p);
                p.FaceColor = colors{i};
                p.EdgeColor = 'none';
                alpha(p, alphas(i));
            end
        end
        hold(ax1, 'off');
        view(ax1, 3);
        camlight(ax1, 'headlight');
        lighting(ax1, 'gouraud');
        axis(ax1, 'equal', 'tight');
        xlabel(ax1, 'x');
        ylabel(ax1, 'y');
        zlabel(ax1, 'z');
    else
        % Fallback for dim=3 but Nz=1 case
        warning('Visualization:DataNot3D', '3D visualization requested, but density data appears to be 2D (Nz=1?). Plotting as 2D surface.');
        [X, Y] = meshgrid(coords.x, coords.y);
        surf(ax1, X, Y, density(:,:,1)); % Plot the first (only) slice
        shading(ax1, 'interp');
        view(ax1, 2);
        axis(ax1, 'equal', 'tight');
        colorbar(ax1);
        xlabel(ax1, 'x');
        ylabel(ax1, 'y');
        title(ax1, sprintf('Density (Nz=1) at t = %.3f', data.time(frameIdx)));
        grid(ax1, 'on');
        % Skip the rest of the 3D specific plotting for ax1
    end
end
if ~(dim == 3 && size(density,3) <= 1) % Add title if not handled by fallback
    title(ax1, sprintf('Density at t = %.3f', data.time(frameIdx)));
end
grid(ax1, 'on');

% --- Update Cross-section/Widths Plot (ax2) ---
cla(ax2); % Clear previous plot
if dim > 1 && isfield(data, 'sigma_x') % Plot widths if available
    plot(ax2, data.time(1:frameIdx), data.sigma_x(1:frameIdx), 'b-', 'LineWidth', 1.5, 'DisplayName', '\sigma_x');
    hold(ax2, 'on');
    if dim >= 2 && isfield(data, 'sigma_y') && ~all(isnan(data.sigma_y))
        plot(ax2, data.time(1:frameIdx), data.sigma_y(1:frameIdx), 'r--', 'LineWidth', 1.5, 'DisplayName', '\sigma_y');
    end
    if dim == 3 && isfield(data, 'sigma_z') && ~all(isnan(data.sigma_z))
         plot(ax2, data.time(1:frameIdx), data.sigma_z(1:frameIdx), 'g:', 'LineWidth', 1.5, 'DisplayName', '\sigma_z');
    end
    hold(ax2, 'off');
    xlabel(ax2, 'Time');
    ylabel(ax2, 'Width');
    title(ax2, 'Condensate Widths');
    legend(ax2, 'show', 'Location', 'best');
    grid(ax2, 'on');
    xlim(ax2, [0 data.time(end)]); % Keep x-axis fixed
elseif dim > 1 % Plot cross-section if widths not available
    center_x_idx = find(coords.x >= 0, 1); if isempty(center_x_idx); center_x_idx=round(length(coords.x)/2); end
    center_y_idx = find(coords.y >= 0, 1); if isempty(center_y_idx); center_y_idx=round(length(coords.y)/2); end
    if dim == 2
        plot(ax2, coords.x, density(center_y_idx,:), 'b-', 'LineWidth', 1.5, 'DisplayName', sprintf('y=%.1f', coords.y(center_y_idx)));
        hold(ax2, 'on');
        plot(ax2, coords.y, density(:,center_x_idx), 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('x=%.1f', coords.x(center_x_idx)));
        hold(ax2, 'off');
        xlabel(ax2, 'Position');
        ylabel(ax2, '|\psi|²');
        title(ax2, 'Density Cross-sections');
        legend(ax2, 'show', 'Location', 'best');
    elseif dim == 3
         center_z_idx = find(coords.z >= 0, 1); if isempty(center_z_idx); center_z_idx=round(length(coords.z)/2); end
         plot(ax2, coords.x, squeeze(density(center_y_idx,:,center_z_idx)), 'b-', 'LineWidth', 1.5, 'DisplayName', 'x-scan');
         hold(ax2, 'on');
         plot(ax2, coords.y, squeeze(density(:,center_x_idx,center_z_idx)), 'r--', 'LineWidth', 1.5, 'DisplayName', 'y-scan');
         plot(ax2, coords.z, squeeze(density(center_y_idx,center_x_idx,:)), 'g:', 'LineWidth', 1.5, 'DisplayName', 'z-scan');
         hold(ax2, 'off');
         xlabel(ax2, 'Position');
         ylabel(ax2, '|\psi|²');
         title(ax2, 'Center Cross-sections');
         legend(ax2, 'show', 'Location', 'best');
    end
    grid(ax2, 'on');
else
    % Placeholder for 1D second plot or leave empty
    title(ax2, 'N/A for 1D');
end

% --- Update Energy Plot (ax3) ---
cla(ax3);
if isfield(data, 'energy') && ~all(isnan(data.energy))
    plot(ax3, data.time(1:frameIdx), data.energy(1:frameIdx), 'k-', 'LineWidth', 1.5);
    xlabel(ax3, 'Time');
    ylabel(ax3, 'Energy');
    title(ax3, 'Energy Evolution');
    grid(ax3, 'on');
    xlim(ax3, [0 data.time(end)]); % Keep x-axis fixed
    % Add min/max energy text
    min_E = min(data.energy(1:frameIdx));
    max_E = max(data.energy(1:frameIdx));
    curr_E = data.energy(frameIdx);
    text(ax3, 0.05, 0.9, sprintf('Min E: %.4f', min_E), 'Units', 'normalized');
    text(ax3, 0.05, 0.8, sprintf('Max E: %.4f', max_E), 'Units', 'normalized');
    text(ax3, 0.05, 0.7, sprintf('Curr E: %.4f', curr_E), 'Units', 'normalized');
else
    title(ax3, 'Energy not available');
end

% Save video frame if enabled
if ~isempty(appdata.VideoWriter)
    try
        frame = getframe(fig);
        writeVideo(appdata.VideoWriter, frame);
    catch ME
        warning(ME.identifier, 'Could not write video frame: %s', ME.message);
        % Consider closing video writer if errors persist
        % close(appdata.VideoWriter);
        % appdata.VideoWriter = [];
        % set(fig, 'UserData', appdata);
    end
end

end 