function sldemo_parallel_rapid_accel_sims_script_setup(mdl)
    %From https://www.mathworks.com/help/simulink/slref/rapid-accelerator-simulations-using-parsim.html
    %Use to compile simulink model once to be used by all parsims
    
    % Temporarily change the current folder on the workers to an empty
    % folder so that any existing slprj folder on the client does not
    % interfere in the build process.
    currentFolder = pwd;
    tempDir = tempname;
    mkdir(tempDir);
    cd (tempDir);
    oc = onCleanup(@() cd (currentFolder));
    Simulink.BlockDiagram.buildRapidAcceleratorTarget(mdl);
end