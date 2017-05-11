

%%%%%% 802.11g (ofdm), first 13 channels and channel 14
%parameters.nCH=11  + 2 +  1;
%parameters.freq=[2.412e9  +  5e6*(0:12) 2.4840e+009];

%%%%%% 802.11g (ofdm), first 11 channels
parameters.nCH=11;
parameters.freq=[2.412e9  +  5e6*(0:10)];
parameters.nLoss=2;
parameters.I_coef = ...
    [1 0.8 0.6 0.4 0.2 0 0 0 0 0 0;...
     0.8 1 0.8 0.6 0.4 0.2 0 0 0 0 0;...
     0.6 0.8 1 0.8 0.6 0.4 0.2 0 0 0 0;...
     0.4 0.6 0.8 1 0.8 0.6 0.4 0.2 0 0 0;...
     0.2 0.4 0.6 0.8 1 0.8 0.6 0.4 0.2 0 0;...
     0 0.2 0.4 0.6 0.8 1 0.8 0.6 0.4 0.2 0;...
     0 0 0.2 0.4 0.6 0.8 1 0.8 0.6 0.4 0.2;...
     0 0 0 0.2 0.4 0.6 0.8 1 0.8 0.6 0.4;...
     0 0 0 0 0.2 0.4 0.6 0.8 1 0.8 0.6;...
     0 0 0 0 0 0.2 0.4 0.6 0.8 1 0.8;...
     0 0 0 0 0 0 0.2 0.4 0.6 0.8 1;...
     ]';

parameters.ROI=300;
parameters.area_X=parameters.ROI; %%% in meters
parameters.area_Y=parameters.ROI; %%% in meters
parameters.nAPs_actual=15;
parameters.nSSID_per_AP=1;
parameters.nAPs=parameters.nAPs_actual*parameters.nSSID_per_AP;
parameters.nSTAs=400;
parameters.APs_minDist=20; %%% in meters
parameters.graphThresh = -78; %%% a threshold to create graph table
parameters.STAs_minDist=0.1; %%% in meters
parameters.vel_mps = 3;
parameters.STA_move = 'yes';
parameters.APsInitTxPwr=25; %%% in dBm

%%%% locate APs in locations at least APs_minDist far from all other APs nodes
parameters.APs_locations=[randi(parameters.area_X) randi(parameters.area_Y)];
for i=1:parameters.nSSID_per_AP:parameters.nAPs 
    x_temp=randi(parameters.area_X);
    y_temp=randi(parameters.area_Y);
  while(min(sqrt((parameters.APs_locations(:,1)-x_temp).^2 +...
                 (parameters.APs_locations(:,2)-y_temp).^2))...
                 < parameters.APs_minDist)
    x_temp=randi(parameters.area_X);
    y_temp=randi(parameters.area_Y);
  end  
  for j=i:i+parameters.nSSID_per_AP-1
    parameters.APs_locations(j,:)=[x_temp y_temp];
  end
end

%%%% locate STAs in locations at least STAs_minDist far from all other STAs/APs nodes
parameters.STAs_locations=[randi(parameters.area_X) randi(parameters.area_Y)];
for i=2:parameters.nSTAs 
    x_temp=randi(parameters.area_X);
    y_temp=randi(parameters.area_Y);
  while(min(sqrt(([parameters.APs_locations(:,1); parameters.STAs_locations(:,1)]-x_temp).^2 +...
                 ([parameters.APs_locations(:,2); parameters.STAs_locations(:,2)]-y_temp).^2))...
                 <= parameters.STAs_minDist)
    x_temp=randi(parameters.area_X);
    y_temp=randi(parameters.area_Y);
  end  
  parameters.STAs_locations(i,:)=[x_temp y_temp];
end

% parameters.QG = [1.5*10^6, 3*10^6, 6*10^6];
selection_methods={'sinr_based','reward_based','load_based'};


%figure
%hold all
%plot(parameters.STAs_locations(:,1),parameters.STAs_locations(:,2),'*b')
%plot(parameters.APs_locations(:,1),parameters.APs_locations(:,2),'or')
%
%for i=1:length(parameters.APs_locations)
%  r=65;
%  x=parameters.APs_locations(i,1);
%  y=parameters.APs_locations(i,2);
%  t = linspace(0,2*pi,100)'; 
%  circsx = r.*cos(t) + x; 
%  circsy = r.*sin(t) + y; 
%  plot(circsx,circsy);
%end 
