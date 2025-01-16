function V = disordered(x, y, z, params)
% Disordered potential with optional harmonic trap.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: A structure containing potential parameters.
%             params.V0: Disorder strength.
%             params.correlation_length: Correlation length of the disorder.
%             params.seed: Random seed for reproducibility.
%             params.include_harmonic: Boolean to include harmonic trap.
%             params.gamma_y: Trap frequency ratio in y-direction (if harmonic).
%             params.gamma_z: Trap frequency ratio in z-direction (if harmonic).
%
% Returns:
%     V: The disordered potential energy array.

% Set random seed for reproducibility
if isfield(params, 'seed')
    rng(params.seed);
end

V0 = params.V0;
lc = params.correlation_length;
include_harmonic = isfield(params, 'include_harmonic') && params.include_harmonic;

% Determine dimensionality based on non-singleton dimensions
dim = 1;
if ~isempty(y) && length(y) > 1
    dim = 2;
end
if ~isempty(z) && length(z) > 1
    dim = 3;
end

if dim == 1 % 1D
    Nx = length(x);
    % Generate random potential with correlation length lc
    xi = randn(1, Nx);
    % Apply Gaussian smoothing
    xi = smoothdata(xi, 'gaussian', round(lc/mean(diff(x))));
    V = V0 * xi;
    
    if include_harmonic
        V = V + 0.5 * x.^2;
    end

elseif dim == 2 % 2D
    [X, Y] = meshgrid(x, y);
    Nx = length(x);
    Ny = length(y);
    
    % Generate 2D random potential
    xi = randn(Ny, Nx);
    % Apply 2D Gaussian smoothing
    xi = imgaussfilt(xi, lc/mean(diff(x)));
    V = V0 * xi;
    
    if include_harmonic
        gamma_y = params.gamma_y;
        V = V + 0.5 * (X.^2 + gamma_y^2 * Y.^2);
    end

else % 3D
    [X, Y, Z] = meshgrid(x, y, z);
    Nx = length(x);
    Ny = length(y);
    Nz = length(z);
    
    % Generate 3D random potential
    xi = randn(Ny, Nx, Nz);
    % Apply 3D Gaussian smoothing
    V = V0 * smooth3(xi, 'gaussian', round(lc/mean(diff(x))));
    
    if include_harmonic
        gamma_y = params.gamma_y;
        gamma_z = params.gamma_z;
        V = V + 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    end
end

end 