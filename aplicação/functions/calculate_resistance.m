function m = calculate_resistance(V,I)
%CALCULATE_RESISTANCE Simply calculates the resistance given a VI curve

n = numel(V);
coefs =polyfit(V(0.1*n:end-0.1*n),I(0.1*n:end-0.1*n),1);
m = coefs(1);
end

