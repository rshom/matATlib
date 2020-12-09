function res = run_bellhop(env,src,rcv,runType)
% run_bellhop returns results from running the BELLHOP model.
%   
% run_bellhop writes the BELLHOP input files, runs the FORTRAN
% binary, and reads the output files into a useable result. 
% 
% TODO: include information about bellhop.
    
    
    % Prepare files
    write_envfil(env,src,rcv,runType);
    % TODO: write other files if needed
    % brcfil = fopen([fileBase+'.brc'], 'w');
    % trcfil = fopen([fileBase+'.trc'], 'w');
    % ircfil = fopen([fileBase+'.irc'], 'w');    
    
    % Run acoustic toolbox
    model = 'bellhop.exe';
    runmodel = which( model );

    if ( isempty( runmodel ) )
        error( '%s not found in your Matlab path', model );
    else
        eval( [ '! "' runmodel '" ' env.fileBase ] );
    end
    
    % Read results
    rays = read_rayfile([env.fileBase '.ray']) % TODO
    % TODO: read other results if necessary
    
    % TODO: Clean up files
    

end
    

function write_envfil(env, src, rcv, runType)
% Write acoustic toolbox env file for bellhop
    
    switch lower(runType)
      case 'ray'
        runCode = 'R';
      case 'coherant'
        runCode = 'C';
      case 'incoherant'
        runCode = 'I';
      case 'semicoherant'
        runCode = 'S';
      otherwise
        error('Run type (%s) not valid',runType);
    end

    envfil = fopen([env.fileBase '.env'], 'w');

    fprintf(envfil,'''%s'' \t ! TITLE \n',env.name);
    fprintf(envfil,'%0.6f \t ! Dummy Var \n',src.freq);% FREQ not used
    fprintf(envfil,'%d \t ! Dummy Var \n',1);% NMEDIA not used
    fprintf(envfil,'''%s'' \t ! SSP Options \n', env.topOpts);
    
    lyr = env.layers(1);                % bellhop only uses the first layer
    fprintf(envfil, ...
            '%d %0.6f %0.6f \t ! NMESH SIGMA ZMAX \n',...
            0, lyr.sigma, lyr.z(end));
    for idx =1:length(lyr.z)        % TODO: better than loop
        fprintf(envfil, ...
                '\t%0.6f %0.6f %0.6f %0.6f /\t! Z CP CS RHO \n', ...
                lyr.z(idx,1), lyr.cp(idx,1), lyr.cs(idx,1), lyr.rho(idx,1));
    end
    
    botOpts = '  ';
    if length(env.layers)>1
        % if multiple layers, second layer becomes an acoustic halfspace
        botOpts(1) = 'A';
        fprintf(envfil, ...
                '''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                botOpts,bdry.sigma);
        fprintf(envfil, ...
                '\t %0.6f %0.6f %0.6f %0.6f / \t ! Z CP CS RHO \n', ...
                bdry.z(1,1), bdry.cp(1,1), bdry.cs(1,1), bdry.rho(1,1)/1000);
    else
        bdry = env.bottomBdry;
        switch bdry.type
          case 'vacuum'
            botOpts(1) = 'V';
            fprintf(envfil,'''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                    botOpts,bdry.sigma);
            % Vacuum only has one lines
          case 'halfspace'
            botOpts(1) = 'A';
            fprintf(envfil, ...
                    '''%s'' \t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                    botOpts,bdry.sigma);
            fprintf(envfil, ...
                    '\t %0.6f %0.6f %0.6f %0.6f / \t ! Z CP CS RHO \n', ...
                    bdry.z(1), bdry.cp(1), bdry.cs(1), bdry.rho(1)/1000);
          otherwise
            error('Bottom boundary type not implemented');
    end
        
    end

    % Source information
    fprintf(envfil,'%d \n',length(src.z));
    fprintf(envfil,'%0.6f ',src.z);
    fprintf(envfil, '/ \t ! NSD SD(1:NSD) \n');
    
    % Reciever Depths
    fprintf(envfil,'%d \n', length(rcv.z) );
    fprintf(envfil,'%0.6f %0.6f ', min(rcv.z), max(rcv.z));
    fprintf(envfil, '/ \t ! NRD RD(1:NRD) \n' );

    % Reciever Ranges
    fprintf(envfil,'%d \n',length(rcv.r));
    fprintf(envfil,'%0.6f %0.6f ',min(rcv.r),max(rcv.r));
    fprintf(envfil, '/ \t ! NRR RR(1:NRR) \n');

    % Bellhop Options
    fprintf(envfil,'''%s'' \t ! Run-type ''R/C/I/S'' \n', runCode);
    fprintf(envfil,'%d \n',length(src.alpha));
    fprintf(envfil,'%0.6f %0.6f ',min(src.alpha), max(src.alpha));
    fprintf(envfil, '/ \t ! NBEAMS ALPHA(1:NBEAMS) (degrees) \n');

    % Mesh
    fprintf(envfil,'%0.6f %0.6f %0.6f \t ! STEP (m) ZBOX (m) RBOX (km)', ...
            0,env.maxDepth,env.maxRange/1000.0);
    
    fclose(envfil)
end

