function [X, Y, I, SINR] = InterferenceEvaluation(APs,parameters)
  x_grid=200;
  y_grid=200;
  for i=1:x_grid
    for j=1:y_grid
        X(i,j)=i*parameters.area_X/x_grid;
        Y(i,j)=j*parameters.area_Y/y_grid;        
        d = sqrt((X(i,j)-parameters.APs_locations(:,1)).^2 ...
            + (Y(i,j)-parameters.APs_locations(:,2)).^2);
        d(d<=1.5)=1.5;
        pwr = 10.^(([APs(:).tx_pwr]' - 10*log10((4*pi/3e8*[APs(:).freq]'.*d).^parameters.nLoss))/10);
        ind=find(pwr==max(pwr),1);
        if ind==1
            I(i,j) = sum(parameters.I_coef([APs(2:end).CH_n],APs(ind).CH_n).*pwr(2:end));
            SINR(i,j) = 10*log10(pwr(1)/I(i,j));
        else
            I(i,j) = sum(parameters.I_coef([APs([1:ind-1 ind+1:end]).CH_n],APs(ind).CH_n).*pwr([1:ind-1 ind+1:end]));
            SINR(i,j) = 10*log10(pwr(ind)/I(i,j));
        end
    end
  end
end
   