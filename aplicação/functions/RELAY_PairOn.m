function  RELAY_PairOn(positive_pin,negative_pin,map,dict)
%RELAY_PAIRON Takes the pins you want to activate as positive and negative,
%and a map between pins and relays. It will turn on the relays respective 
% to the chosen pins. The dict maps between the box pins and he chip.
%   Detailed explanation goes here

positive_pin_ = dict(positive_pin);
negative_pin_ = dict(negative_pin);

positive = map(positive_pin_+"+");
negative = map(negative_pin_+"-");

RELAY_TurnOn(str2num(positive{2}),positive{1})
RELAY_TurnOn(str2num(negative{2}),negative{1})


end

