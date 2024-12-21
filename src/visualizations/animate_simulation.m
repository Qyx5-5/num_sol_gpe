function animate_simulation(x, y, z, results, config)
% Creates an animation of the density evolution.
%
% Args:
%     x: Spatial coordinate array for 1D, 2D, or 3D simulation.
%     y: Spatial coordinate array for 2D or 3D simulation.
%     z: Spatial coordinate array for 3D simulation.
%     results: Structure containing simulation results.
%     config: Configuration structure.

if ~isfield(results, 'density')
    error('No density data available for animation');
end

% Create figure
fig = figure('Name', 'Density Evolution Animation');

% Set up the animation based on dimension
switch config.simulation.dimension
    case 1
        % 1D animation setup
        densities = cat(1, results.density{:});
        y_max = max(densities(:)) * 1.1;
        
        % Create and save animation
        for i = 1:length(results.time)
            plot(results.density{i}, 'LineWidth', 2);
            ylim([0, y_max]);
            title(sprintf('Time: %.2f', results.time(i)));
            xlabel('Position');
            ylabel('|\psi|²');
            grid on;
            drawnow;
            
            % Optional: save frames for video
            if isfield(config.visualization, 'save_video') && config.visualization.save_video
                frames(i) = getframe(fig);
            end
            
            pause(0.05);
        end
        
    case 2
        % 2D animation setup
        [X, Y] = meshgrid(x, y);
        
        % Create and save animation
        for i = 1:length(results.time)
            surf(X, Y, results.density{i});
            shading interp;
            view(2);
            zlim([0, max(results.density{1}(:)) * 1.1]);
            title(sprintf('Time: %.2f', results.time(i)));
            xlabel('x');
            ylabel('y');
            colorbar;
            drawnow;
            
            % Optional: save frames for video
            if isfield(config.visualization, 'save_video') && config.visualization.save_video
                frames(i) = getframe(fig);
            end
            
            pause(0.05);
        end
        
    case 3
        % 3D animation setup
        [X, Y, Z] = meshgrid(x, y, z);
        
        isovalue = max(results.density{1}(:))/3;
        
        % Create and save animation
        for i = 1:length(results.time)
            density_t = results.density{i};
            
            % Plot isosurface
            p = patch(isosurface(X, Y, Z, density_t, isovalue));
            isonormals(X, Y, Z, density_t, p);
            p.FaceColor = 'red';
            p.EdgeColor = 'none';
            
            daspect([1 1 1]);
            view(3);
            camlight;
            lighting gouraud;
            
            title(sprintf('Time: %.2f', results.time(i)));
            xlabel('x');
            ylabel('y');
            zlabel('z');
            
            drawnow;
            
            % Optional: save frames for video
            if isfield(config.visualization, 'save_video') && config.visualization.save_video
                frames(i) = getframe(fig);
            end
            
            if i < length(results.time)
                cla;
            end
            
            pause(0.05);
        end
end

% Save video if requested
if isfield(config.visualization, 'save_video') && config.visualization.save_video
    video_filename = sprintf('gpe_evolution_%dD.avi', config.simulation.dimension);
    video = VideoWriter(video_filename);
    video.FrameRate = 20;
    open(video);
    writeVideo(video, frames);
    close(video);
    fprintf('Video saved as %s\n', video_filename);
end

end 