function  RELAY_TurnOn(pin,a)
%RELAY_TURNON Turns on relay board
array = ["D2", "D3", "A5", "A4", "A3", "A2", "A1", "A0", "D13", "D12", "D11", "D10", "D9", "D8", "D7", "D6"];

disp(class(a))
writeDigitalPin(a, array(pin), 0);
end

