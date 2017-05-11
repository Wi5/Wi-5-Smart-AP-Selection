function [y] = traffic_model(average)

%average represents the average duration of a required service.

z = rand;
ln_z = log(1-z);
y = -average * ln_z;

y = ceil(y);

return
