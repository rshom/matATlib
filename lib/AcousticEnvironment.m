classdef AcousticEnvironment
% AcousticEnvironment class hasall info for Acoustic Toolbox runs
% 
% Environments consist of basic options, a surface layer, profiles for
% each media, a bottom layer, sources, and recievers. 

% TODO document all properties and options in detail
    
    properties
        % TODO validation
        % https://www.mathworks.com/help/matlab/matlab_oop/property-validator-functions.html
        
        name(1,:) char;                 % Name used for outputs

        % Environmental limits
        maxRange(1,1) double;          % Range of simulation field (m)
        maxDepth(1,1) double;          % Depth of simulation field (m)
        cHigh(1,1) double = 1800;       % Max soundspeed (m/s)
        cLow(1,1) double = 1400;        % Min soundspeed (m/s)
        dr(1,1) double;                 % Range step (m)
        dz(1,1) double;                 % Depth setp (m)
        
        % Layers
        srf AcousticBoundary;           % Acoustic surface object
        lyrs(:,1) AcousticLayer;        % Acoustic layer object array
        flr AcousticBoundary;           % Acoustic bottom object

        % Options
        attenuationUnits (1,:) char = 'dB/wavelength'; % Attenuation units
                
    end

    properties (Dependent)
        
        fileBase(1,:) char;             % base for AT file names
        topOpts(1,6) char = '    ';     % TODO: write getter/setter
        botOpts(1,4) char = '  ';       % TODO: write getter/setter
        
        field double;                   % Struct of values in meshgrid
    end

    methods(Access=public)

        function obj = AcousticEnvironment(name,srf,lyrs,flr)
            % AcousticEnvironment builds the acoustic environment.

            obj.name = name;

            obj.srf = srf;
            obj.lyrs = lyrs;
            obj.flr = flr;
            
            obj.maxDepth = max(flr.z);
            obj.maxRange = max(flr.r); % TODO: check furthet out layer

            obj.dz = obj.maxDepth./500;
            obj.dr = obj.maxRange./500;
            
        end
        
    end
    
    methods(Access=private)             
        
        % TODO: set to be static
        function write_boundary(boundary)
        % WRITE_BOUNDARY writes the boundary
            error('not implimented')
        end
        
        % TODO: set to be static
        function write_layer(layer,nmesh)
        % WRITE_LAYER writes the profile for a single media
            error('not implimented')
        end
        
    end
    
    methods                             % getters/setters
        
        function value = get.fileBase(env)
            value = env.name;           % TODO: remove bad characters
        end
        
        function opts = get.topOpts(env)
        % Top options for env file
            switch env.lyrs(1).interpFunc
                % SSP approximation options
                % 'N' N2-Linear approximation to SSP
                % 'C' C-Linear approximation to SSP
                % 'P' PCHIP approximation to SSP
                % 'S' Spline approximation to SSP
                % 'Q' Quadrilateral approximation to range-dependent SSP (.ssp file)
                % 'H' Hexahedral approximation to range and depth dependent SSP
                % 'A' Analytic SSP option    
              case 'linear'
                opts(1) = 'N';          % TODO: N or C
              case 'n2-linear'
                opts(1) = 'N';
              case 'c-linear'
                opts(1) = 'C';
              case 'spline';
                opts(1) = 'S';
              case 'analytic'
                opts(1) = 'A';
              case 'quad'
                opts(1) = 'Q';
              otherwise
                error('Sound speed interp not implimented');
            end
            
            switch env.srf.type
                % Boundary conditions
              case 'vacuum'
                opts(2) = 'V';
              case 'rigid'
                opts(2) = 'R';
              case 'halfspace'
                opts(2) = 'A';
                error('Impliment halfspace options');
              otherwise
                error('Surface type not implimented');
            end
            
            switch env.attenuationUnits
                % Attenuation Units
              case 'ignore'
                opts(3) = ' ';
              case 'nepers/m'
                opts(3) = 'N';
              case 'dB/mkHz'
                opts(3) = 'F';
              case 'dB/m'
                opts(3) = 'M';
              case 'dB/wavelength'
                opts(3) = 'W';
              case 'Q'
                opts(3) = 'Q';
              case 'Loss tangent'
                opts(3) = 'L';
              otherwise
                error('Volume attenuation type not implimented');
            end
            
            opts(4) = ' ';              % TODO: impliment
            
        end

        function field = get.field(env) % TODO: replace with a function
        % Generate a field

            r = [0:env.dr:env.maxRange];
            z = [0:env.dz:env.maxDepth];

            [field.r,field.z] = meshgrid(r,z);
            

            % allocate fields
            field.cp = zeros(size(field.r));
            field.cs = zeros(size(field.r));
            field.rho = zeros(size(field.r));
            field.alpha = zeros(size(field.r));
            field.beta = zeros(size(field.r));
            
            % Set basement as standard
            % field.cp(:) = env.flr.cp;
            % field.cs(:) = env.flr.cs;
            % field.rho(:) = env.flr.rho;
            % field.alpha(:) = env.flr.alpha;
            % field.beta(:) = env.flr.beta;
            
            for idx = 1:length(env.lyrs)

                lyr = env.lyrs(idx).field;
                
                if size(lyr.r,2)==1 % range independent
                    lyr.r = [lyr.r env.maxRange*ones(size(lyr.r))];
                    lyr.z = repmat(lyr.z,1,2);
                    lyr.cp = repmat(lyr.cp,1,2);
                    lyr.cs = repmat(lyr.cs,1,2);
                    lyr.rho = repmat(lyr.rho,1,2);
                    lyr.alpha = repmat(lyr.alpha,1,2);
                    lyr.beta = repmat(lyr.beta,1,2);
                end

                val = interp2(lyr.r,lyr.z, ...
                              lyr.cp,...
                              field.r,field.z,'linear',NaN);
                field.cp(~isnan(val)) = val(~isnan(val));
                

                val = interp2(lyr.r,lyr.z, ...
                                   lyr.cs,...
                                   field.r,field.z,'linear',NaN);
                field.cs(~isnan(val)) = val(~isnan(val));
                
                val = interp2(lyr.r,lyr.z, ...
                                   lyr.rho,...
                                   field.r,field.z,'linear',NaN);
                field.rho(~isnan(val)) = val(~isnan(val));
                
                val = interp2(lyr.r,lyr.z, ...
                                   lyr.alpha,...
                                   field.r,field.z,'linear',NaN);
                field.alpha(~isnan(val)) = val(~isnan(val));

                val = interp2(lyr.r,lyr.z, ...
                                   lyr.beta,...
                                   field.r,field.z,'linear',NaN);
                field.beta(~isnan(val)) = val(~isnan(val));

            end

            % Override below basement
            flr = env.flr.field;
            
            if size(flr.r)==[1 1]       % Flat basement
                flr.r = [0 env.maxRange];
                flr.z = [flr.z flr.z];
                flr.cp = [flr.cp flr.cp];
                flr.cs = [flr.cs flr.cs];
                flr.rho = [flr.rho flr.rho];
                flr.alpha = [flr.alpha flr.alpha];
                flr.beta = [flr.beta flr.beta];
            end

            depth = interpn(flr.r,flr.z,field.r(1,:),...
                            env.flr.interpFunc,NaN); % modify interp
            
            idx = field.z>depth;
            
            
            field.cp(idx) = env.flr.cp;
            field.cs(idx) = env.flr.cs;
            field.rho(idx) = env.flr.rho;
            field.alpha(idx) = env.flr.alpha;
            field.beta(idx) = env.flr.beta;
            
        end
    end
end

