classdef AcousticEnvironment
% AcousticEnvironment class hasall info for Acoustic Toolbox runs
% 
% Environments consist of basic options, a surface layer, profiles for
% each media, a bottom layer, sources, and recievers. 
% 
% author: [Russell Shomberg](rshomberg@uri.edu)
% date: Dec 2020 

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
        dr(1,1) double;
        dz(1,1) double;
        
        % Layers
        surfaceBdry AcousticBoundary;   % Acoustic surface object
        layers(:,1) AcousticLayer;       % Acoustic layer object array
        bottomBdry AcousticBoundary;% Acoustic bottom object

        % Sources and recievers
        source AcousticSource;    % Acoustic source object
        reciever AcousticReciever;% Acoustic reciever object

        % Options
        attenuationUnits (1,:) char = 'dB/wavelength'; % Attenuation units
                
    end

    properties (Dependent)
        
        fileBase(1,:) char;
        Nmedia(1,1) int;                % TODO: write getter
        topOpts(1,6) char = '    '; % TODO: write getter/setter
        botOpts(1,4) char = '  ';   % TODO: write getter/setter
        runTypeCode(1,3) char = ' ';% TODO: write getter/setter
        
        field double;
    end

    methods(Access=public)

        function obj = AcousticEnvironment(name,maxDepth,maxRange, ...
                                           surfaceBdry,layers,bottomBdry)
            % AcousticEnvironment builds the acoustic environment.

            obj.name = name;
            obj.maxDepth = maxDepth;
            obj.maxRange = maxRange;
            obj.surfaceBdry = surfaceBdry;
            obj.layers = layers;
            obj.bottomBdry = bottomBdry;
            
            obj.dz = obj.maxDepth./500;
            obj.dr = obj.maxRange./500;

            % TODO: define source and reviever later
            %obj.source = source;
            %obj.reciever = reciever;

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
            switch env.layers(1).interpFunc
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
            
            switch env.surfaceBdry.type
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

        function field = get.field(env)
        % Generate a field

            r = [0:env.dr:env.maxRange];
            z = [0:env.dz:env.maxDepth];

            [field.r,field.z] = meshgrid(r,z);
            size(field.z)
            size(field.r)

            % allocate fields
            field.cp = zeros(size(field.r));
            field.cs = zeros(size(field.r));
            field.rho = zeros(size(field.r));
            field.alpha = zeros(size(field.r));
            field.beta = zeros(size(field.r));
            
            % Set basement as standard
            % field.cp(:) = env.bottomBdry.cp;
            % field.cs(:) = env.bottomBdry.cs;
            % field.rho(:) = env.bottomBdry.rho;
            % field.alpha(:) = env.bottomBdry.alpha;
            % field.beta(:) = env.bottomBdry.beta;
            
            for idx = 1:length(env.layers)

                disp(sprintf("Starting layer %d",idx))
                
                lyr = env.layers(idx).field;
                
                if size(lyr.r,2)==1 % range independent
                    disp("Generating range profiles")
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

            disp('Setting basement')
            % Override below basement
            bot = env.bottomBdry.field;
            
            if size(bot.r)==[1 1]       % Flat basement
                bot.r = [0 env.maxRange];
                bot.z = [bot.z bot.z];
                bot.cp = [bot.cp bot.cp];
                bot.cs = [bot.cs bot.cs];
                bot.rho = [bot.rho bot.rho];
                bot.alpha = [bot.alpha bot.alpha];
                bot.beta = [bot.beta bot.beta];
            end

            depth = interpn(bot.r,bot.z,field.r(1,:),...
                            env.bottomBdry.interpFunc,NaN); % modify interp
            
            idx = field.z>depth;
            
            
            field.cp(idx) = env.bottomBdry.cp;
            field.cs(idx) = env.bottomBdry.cs;
            field.rho(idx) = env.bottomBdry.rho;
            field.alpha(idx) = env.bottomBdry.alpha;
            field.beta(idx) = env.bottomBdry.beta;
            
        end
    end
end

