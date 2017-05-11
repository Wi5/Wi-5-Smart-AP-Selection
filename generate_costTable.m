function O_l = generate_costTable(APs,parameters,G)
  for i = 1:parameters.nAPs
    for j = 1:parameters.nCH
      temp = [APs(:).CH_n];
      temp(1,i)=0;
      temp = temp.*G(i,:);
      ind = find(temp ~= 0);
      if ~isempty(ind)
        I=0;
        for k = ind
          d = sqrt((parameters.APs_locations(k,1)-parameters.APs_locations(i,1)).^2 ...
               + (parameters.APs_locations(k,2)-parameters.APs_locations(i,2)).^2);
          if d == 0
            d=0.01;
          end
          pwr = 10.^(([APs(k).tx_pwr]' - 10*log10((4*pi/3e8*[APs(k).freq]'*d).^parameters.nLoss))/10);
          I = I + parameters.I_coef(APs(k).CH_n,j)*pwr;
        end
%        if I==0
%          I=-1;
%        end
        O_l(j,i)=I;
      else
        O_l(j,i) = -1;
      end      
    end
  end
  O_l=O_l/max(max(O_l));  %%%normalize
end