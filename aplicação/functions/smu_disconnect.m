function SMU = smu_disconnect(SMU)
%SMU_DISCONNECT Disconnects the SMU

% Flush the buffers
flush(SMU);

% Delete the SMU object to close the connection
delete(SMU);

% Set the SMU variable to empty
SMU = [];
end
