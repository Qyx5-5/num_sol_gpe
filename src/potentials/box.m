function V = box(x, y, z, params)
% Box potential with hard walls.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: A structure containing potential parameters.
%             params.V0: Height of walls (should be large compared to other energies).
%             params.Lx: Box length in x-direction.
%             params.Ly: Box length in y-direction (for 2D/3D).
%             params.Lz: Box length in z-direction (for 3D).
%             params.smoothing: Width of smoothing region (optional).
%
% Returns:
%     V: The box potential energy array.

V0 = params.V0;
smoothing = isfield(params, 'smoothing') && params.smoothing > 0;

if smoothing
    w = params.smoothing; % Smoothing width
end

if isempty(y) && isempty(z) % 1D
    Lx = params.Lx;
    if smoothing
        V = V0 * (tanh((x + Lx/2)/w) - tanh((x - Lx/2)/w))/2;
    else
        V = zeros(size(x));
        V(abs(x) >= Lx/2) = V0;
    end

elseif isempty(z) % 2D
    [X, Y] = meshgrid(x, y);
    Lx = params.Lx;
    Ly = params.Ly;
    
    if smoothing
        Vx = V0 * (tanh((X + Lx/2)/w) - tanh((X - Lx/2)/w))/2;
        Vy = V0 * (tanh((Y + Ly/2)/w) - tanh((Y - Ly/2)/w))/2;
        V = Vx + Vy;
    else
        V = zeros(size(X));
        V(abs(X) >= Lx/2 | abs(Y) >= Ly/2) = V0;
    end

else % 3D
    [X, Y, Z] = meshgrid(x, y, z);
    Lx = params.Lx;
    Ly = params.Ly;
    Lz = params.Lz;
    
    if smoothing
        Vx = V0 * (tanh((X + Lx/2)/w) - tanh((X - Lx/2)/w))/2;
        Vy = V0 * (tanh((Y + Ly/2)/w) - tanh((Y - Ly/2)/w))/2;
        Vz = V0 * (tanh((Z + Lz/2)/w) - tanh((Z - Lz/2)/w))/2;
        V = Vx + Vy + Vz;
    else
        V = zeros(size(X));
        V(abs(X) >= Lx/2 | abs(Y) >= Ly/2 | abs(Z) >= Lz/2) = V0;
    end
end

end 