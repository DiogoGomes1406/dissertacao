function RELAY_TurnOff(pin,a)
%RELAY_TURNOFF Turns off relay board
%   Note!: at the beggining every relay is on! (its normal state) so it
%   is required to manually shut every one off
array = ["D2", "D3", "A5", "A4", "A3", "A2", "A1", "A0", "D13", "D12", "D11", "D10", "D9", "D8", "D7", "D6"];

writeDigitalPin(a, array(pin), 1);
end

