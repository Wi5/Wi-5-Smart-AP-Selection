function G = generate_graphTable(APs,parameters)
  G=zeros(parameters.nAPs,parameters.nAPs);
  for i = 1:parameters.nAPs
    for j = i+1:parameters.nAPs
        d = sqrt((parameters.APs_locations(i,1)-parameters.APs_locations(j,1)).^2 ...
             + (parameters.APs_locations(i,2)-parameters.APs_locations(j,2)).^2);
        pwr = APs(j).tx_pwr - 10*log10((4*pi/3e8*APs(i).freq.*d).^parameters.nLoss); %%% APj received power at APi
        if pwr >= parameters.graphThresh
            G(i,j)=1;
            G(j,i)=1;
        end
    end
  end
end
   