function [a1, a2]= box_connect(port1, port2)
% box_connect Connects too the arduino box
% 
% % Default ports if not provided
% if nargin < 1
%     port1 = "COM6"; % Default for port1
% end
% if nargin < 2
%     port2 = "COM5"; % Default for port2
% end

% Connect to the Arduinos
a1 = arduino(port1, "ProMini328_5V");
a2 = arduino(port2, "ProMini328_5V");

% Define relay pins
relayPins = ["D2", "D3", "A5", "A4", "A3", "A2", "A1", "A0", ...
    "D13", "D12", "D11", "D10", "D9", "D8", "D7", "D6"];

% Set pins to Pullup mode to stabilize them
for i = 1:numel(relayPins)
    configurePin(a1, relayPins(i), 'Pullup');
    configurePin(a2, relayPins(i), 'Pullup');
end

pause(1); % to stabilize boards

% Reconfigure pins as DigitalOutput without toggling state
for i = 1:numel(relayPins)
    configurePin(a1, relayPins(i), 'DigitalOutput');
    writeDigitalPin(a1, relayPins(i), 1); % Ensure they remain off (HIGH)
    configurePin(a2, relayPins(i), 'DigitalOutput');
    writeDigitalPin(a2, relayPins(i), 1); % Ensure they remain off (HIGH)
end

end
