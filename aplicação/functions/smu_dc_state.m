function smu_dc_state(smu, channel, state)
    % Controls channel state (on/off)
    if state == 1
        fprintf(smu, [':OUTP', num2str(channel), ' ON']);
    else
        fprintf(smu, [':OUTP', num2str(channel), ' OFF']);
    end
    
    % Check for errors
    fprintf(smu, ':SYSTEM:ERROR?');
    err = readline(smu);
    if ~contains(err, '0,"No error"')
        warning('Error setting output state (Ch %d): %s', channel, err);
    end
end