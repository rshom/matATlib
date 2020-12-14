classdef AcousticLayer
% AcousticLayer definition for AcousticEnvironment.
% 
% A layer can either be the water column or a bottom layer. 
% TODO document
    
    properties
        
        % Options
        name(1,:) char = '';            % Layer name
        interpFunc (1,:) char = 'linear';
        Nmesh(1,1) double = 0.0;        % 0 to auto calculate

        % Properties
        sigma (1,1) double = 0.0;       % Surface roughness
        z (:,1) double;                 % Profile depths
        r (1,:) double;                 % Profile ranges
        cp double;                      % Pressure wave speed
        cs double;                      % Shear wave speed
        rho double;                     % Density
        alpha double;                   % Pressure wave attenuation
        beta double;                    % Shear wave attenuation
        
        upperLimit(1,:) double;             % Range dependent surface
        lowerLimit(1,:) double;             % Range dependent depth
    end
    
    properties (Dependent)
        field double;                   % Acoustic field
        % envString char;                 % TODO:
    end        

    methods(Access=public)
        function lyr = AcousticLayer(ssp)
        % AcousticLayer constructs a simple acoustic layer profile from an 
        % profile struct.
            
        % TODO: error check
        % TODO: assert height of inputs must be at least 2
            
            lyr.z = ssp.z;              % depths
            
            if isfield(ssp,'r')
                lyr.r = ssp.r;              % ranges
            else
                lyr.r = 0;
            end

            Nd = length(lyr.z);
            Nr = length(lyr.r);
            
            function val = build_profl(val,Nd,Nr)
            % Makes creates the correct size for iso-layer values
                if size(val) == [1 1]
                    val = val*ones(Nd,Nr);
                end
                % TODO: assert that value must right shape
            end
            
            lyr.cp    = build_profl(ssp.cp,Nd,Nr);
            lyr.cs    = build_profl(ssp.cs,Nd,Nr);
            lyr.rho   = build_profl(ssp.rho,Nd,Nr);
            lyr.alpha = build_profl(ssp.alpha,Nd,Nr);
            lyr.beta  = build_profl(ssp.beta,Nd,Nr);

            % Set limits
            lyr.upperLimit = min(lyr.z);% ???: necessary
            lyr.lowerLimit = max(lyr.z);% ???: necessary
            
        end

    
    end
    
    methods                             % getter/setter

        % function val = get.envString(lyr)
        % % envString 
            
        %     val = '';
        %     val = [val sprintf('0\t0.0\t%0.6\t/\t \n',lyr.z(end))];
        %     if length(lyr.cp)==1
        %         val = [val sprintf('%0.6f\t%0.6f\t/\t\n', lyr.z(1), lyr.cp)];
        %         val = [val sprintf('%0.6f\t%0.6f\t/\t\n', lyr.z(end), lyr.cp)];
        %     else
        %         for idx=1:length(lyr.z)
        %             val = [val sprintf('%0.6f\t%0.6f\t/\t\n', lyr.z(idx), lyr.cp(idx))];
        %         end
        %     end
            

        % end


        function field = get.field(lyr)
        % Return acoustic field of profiles
            
            [field.r,field.z] = meshgrid(lyr.r,lyr.z);
            
            idx = and(field.z<=lyr.lowerLimit,field.z>=lyr.upperLimit);
            
            function x = build_field(x,idx)
            % Convert parameter to full field
                
                [m,n]=size(idx);
                
                if size(x)==[1 1];      % constant
                    x = ones(size(idx)).*x;
                elseif size(x)==[1 n]   % range dependent
                    x = repmat(x,m,n);
                elseif size(x)==[m 1]   % depth dependent
                    x = repmat(x,1,n);
                elseif size(x)==[m,n]   % full field
                    x = x;
                else
                    error('Profile incorrect size')
                end
                
                x(~idx) = NaN;
                
            end

            field.cp = build_field(lyr.cp,idx);
            field.cs = build_field(lyr.cs,idx);
            field.rho = build_field(lyr.rho,idx);
            field.alpha = build_field(lyr.alpha,idx);
            field.beta = build_field(lyr.beta,idx);
            
        end
        
    end        
    

end
