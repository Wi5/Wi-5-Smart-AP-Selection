function [ff] = fittingness_factor(Rreq, Rb)

shaping = 5;
shaping_k = 1;
shaping_mine = 1.3;

if Rb == 0
    ff = 0;
else

    U = ((Rb*shaping_mine)/Rreq)^shaping/(1+(((Rb*shaping_mine)/Rreq)^shaping));

    lambda = 1 - (2.71828^((-shaping_k)/(((shaping-1)^(1/shaping))+(shaping-1)^((1-shaping)/shaping))));

    ff = ((1 - (2.71828^(-((shaping_k*U)/((Rb*shaping_mine)/Rreq)))))/lambda);
    
end
                             
return
