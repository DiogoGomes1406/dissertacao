function sendCommandWithCheck(visaObj, cmd)
fprintf(visaObj, cmd);
pause(0.02);  % Reduced minimal pause between commands
fprintf(visaObj, ':SYSTEM:ERROR?');
err = readline(visaObj);
if ~contains(err, '0,"No error"')
    error('SMU error after "%s": %s', cmd, err);
end
end
