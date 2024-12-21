function V = harmonic_trap(x, y, z, params)
% Harmonic trapping potential V(x,y,z) = 0.5 * (x^2 + gamma_y^2 * y^2 + gamma_z^2 * z^2)
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: Structure containing potential parameters.
%       - gamma_y: Trap frequency ratio in the y-direction.
%       - gamma_z: Trap frequency ratio in the z-direction.
%
% Returns:
%     V: Potential energy at each grid point.

% Check if required parameters are provided
if ~isfield(params, 'gamma_y') || ~isfield(params, 'gamma_z')
    error('Missing parameters for harmonic trap potential.');
end

% Validate parameters
if params.gamma_y < 0 || params.gamma_z < 0
    error('Invalid parameters: gamma_y and gamma_z must be non-negative.');
end

% Calculate potential
switch nargin
    case 2
        V = 0.5 * x.^2;
    case 3
        V = 0.5 * (x.^2 + params.gamma_y^2 * y.^2);
    case 4
        V = 0.5 * (x.^2 + params.gamma_y^2 * y.^2 + params.gamma_z^2 * z.^2);
    otherwise
        error('Invalid number of input arguments for harmonic_trap.');
end

end 