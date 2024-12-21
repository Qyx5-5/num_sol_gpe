function psi = initialize_wavefunction(x, y, z, dx, dy, dz, config)
% Initializes the wave function based on the configuration.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     dx, dy, dz: Grid spacing in each dimension.
%     config: Configuration structure.
%
% Returns:
%     psi: The initial wave function.

% Get initial condition type and parameters
init_type = config.initial_condition.type;
params = config.initial_condition.parameters;

% Initialize wave function based on type
switch init_type
    case 'gaussian'
        % Gaussian initial condition
        sigma_x = params.sigma_x;
        if isfield(params, 'sigma_y')
            sigma_y = params.sigma_y;
        else
            sigma_y = sigma_x;
        end
        if isfield(params, 'sigma_z')
            sigma_z = params.sigma_z;
        else
            sigma_z = sigma_x;
        end
        
        if isempty(y) && isempty(z) % 1D
            psi = exp(-x.^2 / (2 * sigma_x^2));
        elseif isempty(z) % 2D
            [X, Y] = meshgrid(x, y);
            psi = exp(-X.^2 / (2 * sigma_x^2) - Y.^2 / (2 * sigma_y^2));
        else % 3D
            [X, Y, Z] = meshgrid(x, y, z);
            psi = exp(-X.^2 / (2 * sigma_x^2) - Y.^2 / (2 * sigma_y^2) - Z.^2 / (2 * sigma_z^2));
        end
        
    case 'thomas_fermi'
        % Thomas-Fermi initial condition (not implemented yet)
        error('Thomas-Fermi initial condition not implemented yet.');
        
    case 'custom'
        % Custom initial condition (not implemented yet)
        error('Custom initial condition not implemented yet.');
        
    otherwise
        error('Invalid initial condition type: %s', init_type);
end

% Normalize the wave function
psi = normalize_wavefunction(psi, dx, dy, dz, config);

end 