clear all
close all
clc

load ../shadowingTable_ISD2000

parameters.PTx=10;
parameters.AG=10;
parameters.L_0=128.1;
parameters.L_exp=2.1;
refRad = 50;
refLoc = [refRad refRad];
i = 0;
j = 0;
for i=1:250
    x = 0.1 + i*0.4;
    for j = 1:250
        y = 0.1 + j*0.4;
        X(i,j) = x;
        Y(i,j) = y;
        d(i,j) = sqrt((refLoc(1) - x).^2 + (refLoc(2)-y).^2);
        [~, s_x]=min(abs(squeeze(sLocatin_table_X(:,1,1))-x));
        [~, s_y]=min(abs(squeeze(sLocatin_table_Y(1,:,1))-y));
        distloss(i,j)=parameters.L_0+10*parameters.L_exp*log10(d(i,j)/1000);
        sf_unCorr(i,j)=sValue_unCorr(s_x,s_y,1)*sqrt(5/8);
        sf_corr(i,j)=sValue_table(s_x,s_y,1)*sqrt(5/8);
        %%% w/o spatial corr
        L_without(i,j) = distloss(i,j);
        RxPwr_without(i,j)=parameters.PTx + parameters.AG - L_without(i,j);
        
        L(i,j) = distloss(i,j) + sf_corr(i,j);
        RxPwr(i,j)=parameters.PTx + parameters.AG - L(i,j);

    end    
end

figure; mesh(X,Y,RxPwr);
xlabel('X')
ylabel('Y')
zlabel('received power (dBm)')
title('APs coverage, spatially correlated shadowing consideration')
colorbar
% set(gca,'ZScale', 'log')

figure; mesh(X,Y,RxPwr_without);
xlabel('X')
ylabel('Y')
zlabel('received power (dBm)')
title('APs coverage, w/o shadowing consideration')
colorbar
% set(gca,'ZScale', 'log')

figure; contourf(X,Y,sf_corr);
xlabel('X')
ylabel('Y')
title('spatially correlated shadowing values')
colorbar

figure; contourf(X,Y,sf_unCorr);
xlabel('X')
ylabel('Y')
title('Uncorrelated shadowing values')
colorbar


% figure; contour(X,Y,L);
% figure; plot(d(refRad,:),RxPwr_without(refRad,:),d(refRad,:),RxPwr(refRad,:))