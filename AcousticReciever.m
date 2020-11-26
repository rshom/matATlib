classdef AcousticReciever
% AcousticReciever array for an AcousticEnvironment.
% 
% Recievers can be point recievers, line arrays, or mesh arrays. Array
% elements must be evenly spaced in range and evenly spaced in depth.
    
    properties
        % TODO: add propery descriptions somehow
        r(1,:) double {mustBePositive};
        z(:,1) double {mustBePositive};
    end
    
    properties(Dependent)
        N(1,1) int16;
    end
    
    methods(Access=public)
        function obj = AcousticReciever(r,z);
        % Define array acoustic recievers.
            obj.r = r;
            obj.z = z;
        end
    end
    
    methods
        function value = get.N(obj)
        % N number of recievers
            value = length(obj.r)*length(obj.z);
        end
    end

end
