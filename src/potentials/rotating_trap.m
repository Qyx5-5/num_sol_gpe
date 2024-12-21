function V = rotating_trap(x, y, z, params)
% Rotating trap potential with optional stirring beam.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: A structure containing potential parameters.
%             params.omega_x: Trap frequency in x-direction.
%             params.omega_y: Trap frequency in y-direction.
%             params.Ws: Stirring potential strength.
%             params.Vs: Stirring potential width.
%             params.r0: Radius of stirring motion.
%             params.omega_s: Stirring frequency.
%             params.t: Current time.
%
% Returns:
%     V: The rotating trap potential energy array.

if ~isempty(z)
    error('Rotating trap is typically implemented in 2D only');
end

% Extract parameters
omega_x = params.omega_x;
omega_y = params.omega_y;
Ws = params.Ws;
Vs = params.Vs;
r0 = params.r0;
omega_s = params.omega_s;
t = params.t;

% Create 2D grid
[X, Y] = meshgrid(x, y);

% Calculate stirring beam position
rs_t = [r0 * cos(omega_s * t), r0 * sin(omega_s * t)];

% Calculate harmonic trap and stirring potential
V_harmonic = 0.5 * (omega_x^2 * X.^2 + omega_y^2 * Y.^2);
V_stirring = Ws * exp(-4 * ((X - rs_t(1)).^2 + (Y - rs_t(2)).^2) / Vs^2);

% Total potential
V = V_harmonic + V_stirring;

end 