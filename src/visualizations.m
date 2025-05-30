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
% Creates an enhanced animation dashboard of the density evolution with interactive controls.
% (Local version)

if ~isfield(results, 'density') || isempty(results.density)
    error('No density data available for animation');
end

num_frames = length(results.time);
if num_frames == 0
    error('Results structure has zero time steps for animation.');
end

% Create UI figure with enhanced styling
fig = uifigure('Name', 'GPE Simulation Dashboard', 'Scrollable', 'on');
fig.Position = [100 100 1400 900]; % Larger window
fig.Color = [0.94 0.94 0.94]; % Light gray background

% Create main grid layout
main_gl = uigridlayout(fig, [4 3]);
main_gl.RowHeight = {'5x', '2x', '1x', '0.5x'}; % Plots, Energy, Controls, Status
main_gl.ColumnWidth = {'1x', '1x', '0.6x'}; % Left plot, Right plot, Info panel

% Create axes with better styling
ax1 = uiaxes(main_gl); ax1.Layout.Row = 1; ax1.Layout.Column = 1; % Density
ax2 = uiaxes(main_gl); ax2.Layout.Row = 1; ax2.Layout.Column = 2; % Cross-section/Widths
ax3 = uiaxes(main_gl); ax3.Layout.Row = 2; ax3.Layout.Column = [1 2]; % Energy

% Info panel
info_panel = uipanel(main_gl, 'Title', 'Simulation Info', 'FontWeight', 'bold');
info_panel.Layout.Row = [1 2]; info_panel.Layout.Column = 3;
info_panel.BackgroundColor = [1 1 1];

% Create info panel layout
info_gl = uigridlayout(info_panel, [15 1]);
info_gl.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};

% Add simulation information labels
uilabel(info_gl, 'Text', 'Current Frame:', 'FontWeight', 'bold');
frame_label = uilabel(info_gl, 'Text', '1 / 1', 'FontColor', [0 0.4 0.8]);

uilabel(info_gl, 'Text', 'Current Time:', 'FontWeight', 'bold');
time_label = uilabel(info_gl, 'Text', '0.000', 'FontColor', [0 0.4 0.8]);

uilabel(info_gl, 'Text', 'Dimension:', 'FontWeight', 'bold');
dim_text = sprintf('%dD', config.simulation.dimension);
uilabel(info_gl, 'Text', dim_text, 'FontColor', [0.4 0.4 0.4]);

uilabel(info_gl, 'Text', 'Grid Size:', 'FontWeight', 'bold');
if config.simulation.dimension == 1
    grid_text = sprintf('%d', config.grid.Nx);
elseif config.simulation.dimension == 2
    grid_text = sprintf('%d × %d', config.grid.Nx, config.grid.Ny);
else
    grid_text = sprintf('%d × %d × %d', config.grid.Nx, config.grid.Ny, config.grid.Nz);
end
uilabel(info_gl, 'Text', grid_text, 'FontColor', [0.4 0.4 0.4]);

uilabel(info_gl, 'Text', 'Potential:', 'FontWeight', 'bold');
pot_text = config.potential.type;
uilabel(info_gl, 'Text', pot_text, 'FontColor', [0.4 0.4 0.4]);

uilabel(info_gl, 'Text', 'Max Density:', 'FontWeight', 'bold');
density_label = uilabel(info_gl, 'Text', '0.000', 'FontColor', [0.8 0.4 0]);

uilabel(info_gl, 'Text', 'Total Norm:', 'FontWeight', 'bold');
norm_label = uilabel(info_gl, 'Text', '1.000', 'FontColor', [0.8 0.4 0]);

% Control panel
control_panel = uipanel(main_gl, 'Title', 'Playback Controls', 'FontWeight', 'bold');
control_panel.Layout.Row = 3; control_panel.Layout.Column = [1 3];
control_panel.BackgroundColor = [0.96 0.96 0.98];

% Create control layout
ctrl_gl = uigridlayout(control_panel, [2 6]);
ctrl_gl.RowHeight = {'1x', '1x'};
ctrl_gl.ColumnWidth = {'1x', '1x', '1x', '1x', '2x', '1.2x'};

% Enhanced control buttons with better styling
playBtn = uibutton(ctrl_gl, 'push', 'Text', '▶ Play', 'BackgroundColor', [0.2 0.8 0.2]);
playBtn.Layout.Row = 1; playBtn.Layout.Column = 1;

pauseBtn = uibutton(ctrl_gl, 'push', 'Text', '⏸ Pause', 'BackgroundColor', [0.8 0.6 0.2]);
pauseBtn.Layout.Row = 1; pauseBtn.Layout.Column = 2;

resetBtn = uibutton(ctrl_gl, 'push', 'Text', '⏮ Reset', 'BackgroundColor', [0.7 0.7 0.7]);
resetBtn.Layout.Row = 1; resetBtn.Layout.Column = 3;

stepBtn = uibutton(ctrl_gl, 'push', 'Text', '⏭ Step', 'BackgroundColor', [0.6 0.6 0.8]);
stepBtn.Layout.Row = 1; stepBtn.Layout.Column = 4;

% Speed control
uilabel(ctrl_gl, 'Text', 'Speed:', 'HorizontalAlignment', 'right');
speed_slider = uislider(ctrl_gl, 'Limits', [0.1 3], 'Value', 1);
speed_slider.Layout.Row = 1; speed_slider.Layout.Column = 6;

% Time navigation slider
uilabel(ctrl_gl, 'Text', 'Time Navigation:', 'FontWeight', 'bold');
slider = uislider(ctrl_gl);
slider.Layout.Row = 2; slider.Layout.Column = [1 6];
slider.Limits = [1 num_frames];
slider.Value = 1;
slider.MajorTicks = linspace(1, num_frames, min(num_frames, 11));

% Status bar
status_panel = uipanel(main_gl, 'BorderType', 'none');
status_panel.Layout.Row = 4; status_panel.Layout.Column = [1 3];
status_panel.BackgroundColor = [0.9 0.9 0.9];

status_gl = uigridlayout(status_panel, [1 3]);
status_gl.ColumnWidth = {'1x', 'fit', 'fit'};

status_label = uilabel(status_gl, 'Text', 'Ready', 'FontColor', [0 0.6 0]);
fps_label = uilabel(status_gl, 'Text', 'FPS: --', 'FontColor', [0.5 0.5 0.5]);
video_label = uilabel(status_gl, 'Text', '', 'FontColor', [0.8 0.2 0.2]);

% Set axis properties for better appearance
set([ax1, ax2, ax3], 'FontSize', 10);
ax1.Title.FontSize = 12; ax1.Title.FontWeight = 'bold';
ax2.Title.FontSize = 12; ax2.Title.FontWeight = 'bold';
ax3.Title.FontSize = 12; ax3.Title.FontWeight = 'bold';

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
        video_label.Text = sprintf('Recording: %s', video_filename);
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
appdata.PlaySpeed = 1;
appdata.LastUpdateTime = tic;
appdata.UIElements = struct('frame_label', frame_label, 'time_label', time_label, ...
                           'density_label', density_label, 'norm_label', norm_label, ...
                           'status_label', status_label, 'fps_label', fps_label);
set(fig, 'UserData', appdata);

% Set up callbacks
slider.ValueChangedFcn = @sliderCallback;
speed_slider.ValueChangedFcn = @speedCallback;
playBtn.ButtonPushedFcn = @playCallback;
pauseBtn.ButtonPushedFcn = @pauseCallback;
resetBtn.ButtonPushedFcn = @resetCallback;
stepBtn.ButtonPushedFcn = @stepCallback;

% Initial plot
update_plots_enhanced(1, fig, ax1, ax2, ax3);

% Nested Functions for Callbacks
    function sliderCallback(src, ~)
        appdata = get(fig, 'UserData');
        appdata.CurrentFrame = round(src.Value);
        set(fig, 'UserData', appdata);
        update_plots_enhanced(appdata.CurrentFrame, fig, ax1, ax2, ax3);
    end

    function speedCallback(src, ~)
        appdata = get(fig, 'UserData');
        appdata.PlaySpeed = src.Value;
        set(fig, 'UserData', appdata);
    end

    function playCallback(~, ~)
        appdata = get(fig, 'UserData');
        if appdata.IsPlaying; return; end % Already playing
        appdata.IsPlaying = true;
        appdata.UIElements.status_label.Text = 'Playing...';
        appdata.UIElements.status_label.FontColor = [0 0.6 0];
        set(fig, 'UserData', appdata);
        
        while true % Loop controlled by IsPlaying flag
            loop_start = tic;
            appdata = get(fig, 'UserData');
            if ~appdata.IsPlaying; break; end % Stop requested
            
            current_frame = appdata.CurrentFrame;
            if current_frame >= num_frames
                appdata.IsPlaying = false; % Reached end
                appdata.UIElements.status_label.Text = 'Finished';
                appdata.UIElements.status_label.FontColor = [0.8 0.4 0];
                set(fig, 'UserData', appdata);
                break;
            end
            
            next_frame = current_frame + 1;
            appdata.CurrentFrame = next_frame;
            slider.Value = next_frame; % Update slider visually
            set(fig, 'UserData', appdata);
            
            update_plots_enhanced(next_frame, fig, ax1, ax2, ax3);
            
            % Calculate and display FPS
            loop_time = toc(loop_start);
            fps = 1 / loop_time;
            appdata.UIElements.fps_label.Text = sprintf('FPS: %.1f', fps);
            
            drawnow; % Update figure window
            pause_time = max(0.01, 0.05 / appdata.PlaySpeed); % Speed control
            pause(pause_time);
        end
    end

    function pauseCallback(~, ~)
        appdata = get(fig, 'UserData');
        appdata.IsPlaying = false;
        appdata.UIElements.status_label.Text = 'Paused';
        appdata.UIElements.status_label.FontColor = [0.8 0.6 0.2];
        set(fig, 'UserData', appdata);
    end

    function resetCallback(~, ~)
        appdata = get(fig, 'UserData');
        appdata.IsPlaying = false;
        appdata.CurrentFrame = 1;
        appdata.UIElements.status_label.Text = 'Reset';
        appdata.UIElements.status_label.FontColor = [0.5 0.5 0.5];
        slider.Value = 1;
        set(fig, 'UserData', appdata);
        update_plots_enhanced(1, fig, ax1, ax2, ax3);
    end

    function stepCallback(~, ~)
        appdata = get(fig, 'UserData');
        if appdata.CurrentFrame < num_frames
            appdata.CurrentFrame = appdata.CurrentFrame + 1;
            slider.Value = appdata.CurrentFrame;
            appdata.UIElements.status_label.Text = 'Step Forward';
            appdata.UIElements.status_label.FontColor = [0.6 0.6 0.8];
            set(fig, 'UserData', appdata);
            update_plots_enhanced(appdata.CurrentFrame, fig, ax1, ax2, ax3);
        end
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

function update_plots_enhanced(frameIdx, fig, ax1, ax2, ax3)
% Enhanced helper function to update all plots and UI elements in the animation figure.

appdata = get(fig, 'UserData');
data = appdata.Results;
cfg = appdata.Config;
coords = appdata.Coords;
ui_elements = appdata.UIElements;
dim = cfg.simulation.dimension;

frameIdx = round(frameIdx);
if frameIdx < 1 || frameIdx > length(data.time)
    return; % Invalid frame index
end

% Update UI information
ui_elements.frame_label.Text = sprintf('%d / %d', frameIdx, length(data.time));
ui_elements.time_label.Text = sprintf('%.3f', data.time(frameIdx));

% --- Update Density Plot (ax1) ---
cla(ax1); % Clear previous plot
density = data.density{frameIdx};
max_dens = max(density(:));
if max_dens == 0; max_dens = 1; end % Avoid division by zero issues

% Calculate and display density statistics
ui_elements.density_label.Text = sprintf('%.3e', max_dens);
if dim == 1
    norm_val = sum(density(:)) * (coords.x(2) - coords.x(1));
elseif dim == 2
    dx = coords.x(2) - coords.x(1);
    dy = coords.y(2) - coords.y(1);
    norm_val = sum(density(:)) * dx * dy;
else
    dx = coords.x(2) - coords.x(1);
    dy = coords.y(2) - coords.y(1);
    dz = coords.z(2) - coords.z(1);
    norm_val = sum(density(:)) * dx * dy * dz;
end
ui_elements.norm_label.Text = sprintf('%.6f', norm_val);

if dim == 1
    plot(ax1, coords.x, density, 'LineWidth', 2, 'Color', [0 0.4 0.8]);
    ylabel(ax1, '|\psi|²');
    xlabel(ax1, 'x');
    grid(ax1, 'on');
    
elseif dim == 2
    % Use a more sophisticated colormap for better visualization
    imagesc(ax1, coords.x, coords.y, density);
    axis(ax1, 'xy', 'equal', 'tight');
    colormap(ax1, 'hot'); % Better colormap for density
    colorbar(ax1);
    xlabel(ax1, 'x');
    ylabel(ax1, 'y');
    
    % Add contour lines for better visualization
    hold(ax1, 'on');
    if max_dens > 0
        contour_levels = max_dens * [0.1, 0.3, 0.5, 0.7, 0.9];
        [C, h] = contour(ax1, coords.x, coords.y, density, contour_levels, 'LineColor', 'white', 'LineWidth', 0.5);
        h.LineStyle = '--';
    end
    hold(ax1, 'off');
    
elseif dim == 3
    if size(density, 3) > 1 % Check if data is truly 3D
        [X, Y, Z] = meshgrid(coords.x, coords.y, coords.z);
        isoLevels = max_dens * [0.6, 0.3, 0.1];
        colors = {[0.8 0.2 0.2], [0.2 0.8 0.2], [0.2 0.2 0.8]}; % RGB colors
        alphas = [0.6, 0.4, 0.2];
        
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
        [X, Y] = meshgrid(coords.x, coords.y);
        surf(ax1, X, Y, density(:,:,1));
        shading(ax1, 'interp');
        view(ax1, 2);
        axis(ax1, 'equal', 'tight');
        colormap(ax1, 'hot');
        colorbar(ax1);
        xlabel(ax1, 'x');
        ylabel(ax1, 'y');
        title(ax1, sprintf('Density (2D slice) at t = %.3f', data.time(frameIdx)));
        return; % Early return for this case
    end
end

% Add enhanced title with more information
if dim == 3 && size(density,3) <= 1
    % Title already set above for the fallback case
else
    title(ax1, sprintf('Density at t = %.3f (Max: %.2e)', data.time(frameIdx), max_dens));
end
grid(ax1, 'on');

% --- Update Cross-section/Widths Plot (ax2) ---
cla(ax2); % Clear previous plot

if dim > 1 && isfield(data, 'sigma_x') % Plot widths if available
    hold(ax2, 'on');
    plot(ax2, data.time(1:frameIdx), data.sigma_x(1:frameIdx), 'b-', 'LineWidth', 2, 'DisplayName', '\sigma_x');
    
    if dim >= 2 && isfield(data, 'sigma_y') && ~all(isnan(data.sigma_y))
        plot(ax2, data.time(1:frameIdx), data.sigma_y(1:frameIdx), 'r--', 'LineWidth', 2, 'DisplayName', '\sigma_y');
    end
    if dim == 3 && isfield(data, 'sigma_z') && ~all(isnan(data.sigma_z))
         plot(ax2, data.time(1:frameIdx), data.sigma_z(1:frameIdx), 'g:', 'LineWidth', 2, 'DisplayName', '\sigma_z');
    end
    
    % Add current time indicator
    current_time = data.time(frameIdx);
    y_limits = ylim(ax2);
    plot(ax2, [current_time current_time], y_limits, 'k--', 'LineWidth', 1, 'Color', [0.3 0.3 0.3]);
    
    hold(ax2, 'off');
    xlabel(ax2, 'Time');
    ylabel(ax2, 'Width');
    title(ax2, 'Condensate Widths Evolution');
    legend(ax2, 'show', 'Location', 'best');
    grid(ax2, 'on');
    xlim(ax2, [0 data.time(end)]); % Keep x-axis fixed
    
elseif dim > 1 % Plot cross-section if widths not available
    center_x_idx = find(coords.x >= 0, 1); if isempty(center_x_idx); center_x_idx=round(length(coords.x)/2); end
    center_y_idx = find(coords.y >= 0, 1); if isempty(center_y_idx); center_y_idx=round(length(coords.y)/2); end
    
    if dim == 2
        hold(ax2, 'on');
        plot(ax2, coords.x, density(center_y_idx,:), 'b-', 'LineWidth', 2, 'DisplayName', sprintf('y=%.1f', coords.y(center_y_idx)));
        plot(ax2, coords.y, density(:,center_x_idx), 'r--', 'LineWidth', 2, 'DisplayName', sprintf('x=%.1f', coords.x(center_x_idx)));
        hold(ax2, 'off');
        xlabel(ax2, 'Position');
        ylabel(ax2, '|\psi|²');
        title(ax2, 'Density Cross-sections');
        legend(ax2, 'show', 'Location', 'best');
    elseif dim == 3
         center_z_idx = find(coords.z >= 0, 1); if isempty(center_z_idx); center_z_idx=round(length(coords.z)/2); end
         hold(ax2, 'on');
         plot(ax2, coords.x, squeeze(density(center_y_idx,:,center_z_idx)), 'b-', 'LineWidth', 2, 'DisplayName', 'x-scan');
         plot(ax2, coords.y, squeeze(density(:,center_x_idx,center_z_idx)), 'r--', 'LineWidth', 2, 'DisplayName', 'y-scan');
         plot(ax2, coords.z, squeeze(density(center_y_idx,center_x_idx,:)), 'g:', 'LineWidth', 2, 'DisplayName', 'z-scan');
         hold(ax2, 'off');
         xlabel(ax2, 'Position');
         ylabel(ax2, '|\psi|²');
         title(ax2, 'Center Cross-sections');
         legend(ax2, 'show', 'Location', 'best');
    end
    grid(ax2, 'on');
else
    % For 1D, show density evolution over time
    if isfield(data, 'density') && iscell(data.density) && frameIdx > 1
        time_evolution = zeros(frameIdx, length(coords.x));
        for i = 1:frameIdx
            if length(data.density{i}) == length(coords.x)
                time_evolution(i, :) = data.density{i};
            end
        end
        imagesc(ax2, coords.x, data.time(1:frameIdx), time_evolution);
        colormap(ax2, 'hot');
        colorbar(ax2);
        xlabel(ax2, 'x');
        ylabel(ax2, 'Time');
        title(ax2, 'Density Evolution');
        axis(ax2, 'xy');
    else
        title(ax2, 'Evolution Plot (Insufficient Data)');
    end
end

% --- Update Energy Plot (ax3) ---
cla(ax3);
if isfield(data, 'energy') && ~all(isnan(data.energy))
    hold(ax3, 'on');
    plot(ax3, data.time(1:frameIdx), data.energy(1:frameIdx), 'k-', 'LineWidth', 2);
    
    % Add current time indicator
    current_time = data.time(frameIdx);
    y_limits = ylim(ax3);
    plot(ax3, [current_time current_time], y_limits, 'r--', 'LineWidth', 1, 'Color', [0.8 0.4 0.4]);
    
    hold(ax3, 'off');
    xlabel(ax3, 'Time');
    ylabel(ax3, 'Energy');
    title(ax3, 'Energy Evolution');
    grid(ax3, 'on');
    xlim(ax3, [0 data.time(end)]); % Keep x-axis fixed
    
    % Add enhanced energy statistics
    min_E = min(data.energy(1:frameIdx));
    max_E = max(data.energy(1:frameIdx));
    curr_E = data.energy(frameIdx);
    initial_E = data.energy(1);
    
    % Create text box with energy info
    info_text = sprintf('Initial: %.4f\nCurrent: %.4f\nMin: %.4f\nMax: %.4f\nΔE: %.2e', ...
                       initial_E, curr_E, min_E, max_E, curr_E - initial_E);
    text(ax3, 0.02, 0.98, info_text, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'BackgroundColor', [1 1 1 0.8], 'EdgeColor', [0.5 0.5 0.5], 'FontSize', 9);
else
    title(ax3, 'Energy Evolution (Not Available)');
    text(ax3, 0.5, 0.5, 'Energy data not calculated', 'HorizontalAlignment', 'center', ...
         'Units', 'normalized', 'FontSize', 12, 'Color', [0.6 0.6 0.6]);
end

% Save video frame if enabled
if ~isempty(appdata.VideoWriter)
    try
        frame = getframe(fig);
        writeVideo(appdata.VideoWriter, frame);
    catch ME
        warning(ME.identifier, 'Could not write video frame: %s', ME.message);
    end
end

end 