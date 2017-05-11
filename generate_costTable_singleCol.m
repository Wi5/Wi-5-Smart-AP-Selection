function O_l = generate_costTable_singleCol(APs,parameters,k,G)
  d = sqrt((parameters.APs_locations(k,1)-parameters.APs_locations(1:k-1,1)).^2 ...
            + (parameters.APs_locations(k,2)-parameters.APs_locations(1:k-1,2)).^2);
  d(d==0)=0.001;          
  pwr = 10.^(([APs(1:k-1).tx_pwr]' - 10*log10((4*pi/3e8*[APs(1:k-1).freq]'.*d).^parameters.nLoss))/10);
  pwr=pwr.*G(1:k-1,k);
  for j = 1:parameters.nCH
    I = sum(parameters.I_coef([APs(1:k-1).CH_n],j).*pwr);
    O_l(j)=I;
  end
%  O_l=O_l/max(max(O_l));  %%%normalize
end