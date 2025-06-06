function SMU = smu_connect()
%SMU_CONNECT Connects to SMU

% Connect SMU
SMU = visadev('USB0::0x0957::0x8C18::MY51142473::0::INSTR');

% Set buffer sizes
SMU.OutputBufferSize = 8192;
SMU.InputBufferSize = 8192;

end

