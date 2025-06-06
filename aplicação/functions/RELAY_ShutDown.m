function  RELAY_ShutDown(arduino)
%RELAY_SHUTDOWN Shuts down all relays

for relay=1:16
    RELAY_TurnOff(relay,arduino)
end
end

