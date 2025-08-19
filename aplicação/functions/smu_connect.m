function SMU = smu_connect()
%SMU_CONNECT Connects to SMU and sets output-off state to High Impedance

% Connect to SMU
SMU = visadev('USB0::0x0957::0x8C18::MY51142473::0::INSTR');

% Set buffer sizes
SMU.OutputBufferSize = 8192;
SMU.InputBufferSize = 8192;

% Set output-off state to High Impedance
writeline(SMU, ':OUTP:OFF:MODE HIMP');

end
