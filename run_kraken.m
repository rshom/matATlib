function res = run_kraken(env,freq)
% run_kraken returns results from running the KRAKEN model.
% 
% run_kraken writes the KRAKEN input files, rusn the FORTRAN binary,
% and reads the output files into a useable result.

    % Prepare files
    write_envfil(env)
    % TODO: write other files if needed
    
    % Run acoustic toolbox
    model = 'kraken.exe';
    runmodel = which( model );

    if ( isempty( runmodel ) )
        error( '%s not found in your Matlab path', model );
    else
        eval( [ '! "' runmodel '" ' fbase ] );
    end
    
    % TODO: run field
    
    % Read results
    modes = read_modefile([env.fbase '.mod']);
    TL = read_shdfile([env.fbase '.shd.mat']);

    % Clean up files

end

function write_envfil(env,freq)
% Write acoustic toolbox env file for kraken
    
    envfil = fopen([env.fbase+'.env'],'w');
    
    fprintf(envfil,'%s \t ! TITLE \n',env.title);
    fprintf(envfil,'%0.6f \t ! FREQ (Hz) \n',freq); 
    fprintf(envfil,'%d \t ! Dummy Var \n',length(env.layers));
    fprintf(envfil,'''%s'' \t ! SSP Options \n', env.topOpts);
    for layer=layers
        fprintf(envfil,'%s \n', env.layer(1).envString);% TODO
    end
    fprintf(envfil,'%s \n', env.bottomBdry.envString)
    fprintf(envfil,'%0.6f %0.6f \t ! CLOW CHIGH (m/s)', ...
            env.cLow,env.cHigh)
    fprintf(envfil,'%0.6f \t RMAX (km)',env.maxRange/1000)
    fprintf(envfil,'%s \n', env.source.envString);% TODO
    fprintf(envfil,'%s \n', env.reciever.depthString);% TODO

    fclose(envfil);
    
end
