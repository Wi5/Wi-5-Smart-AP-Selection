function [active_flow_ap2, max_active_flow_ap2, index_flows, congested] = available_bitrate2(BW, AP_SINR, selected_Rb_array, max_selected_Rb_array, index_AP_array, ap2, bitrate, bitrate_AP, AP_stations)

%BW is considered in Hz
%SINR is considered in dB

%active_flows_ap2 is an array with the new bit rates assigned to the flows
%already active in ap2 plus the Rb assigned to the new flow. Initially in
%this array the previous flows are stored and can be changed because of the
%new flow.

%index_flows is an array with the indeces of the flows active in ap2.

active_flow_ap2 = [];
max_active_flow_ap2 = [];
index_flows = [];
size=0;
bitrate_AP_new = [];
sat_flows_before = [];
sat_flows_after = [];

for fl=1:length(index_AP_array)
    size = size+1;
    if index_AP_array(fl)==ap2
        active_flow_ap2(fl)=selected_Rb_array(fl);
        max_active_flow_ap2(fl)=max_selected_Rb_array(fl);
        bitrate_AP_new(fl) = bitrate_AP(fl);
        index_flows(fl)=fl;
    else
        active_flow_ap2(fl)=-1;
        max_active_flow_ap2(fl)=-1;
        bitrate_AP_new(fl) =-1;
        index_flows(fl)=-1;
    end
end

%%%%%%%%%%%%%computation reachable data rate for the new flow%%%%%%%%%%%%%%

%Rb_max is the maximum bit rate achievable considering the radio
%environment. This value is mapped in one of the allowed by the OFDM and
%called Rb_total

SINR = 10^(AP_SINR/10);

Rb_max = BW*log2(1+SINR);

OFDM_MDR = [0, 10^6, 2*10^6, 6*10^6, 9*10^6, 12*10^6, 18*10^6, 24*10^6, 36*10^6, 48*10^6, 54*10^6];

%when a configuration is found, assign it and get out from while.
found = 0;
i = 1;

%the available bit rate in the AP corresponds to the closer bit rate to the 
%maximum one, selected among the bit rates lower than the maximum one.
while i <= length(OFDM_MDR) && found == 0
    if OFDM_MDR(i) >= Rb_max 
        if OFDM_MDR(i) == Rb_max
            Rb_total = OFDM_MDR(i);
        else
            Rb_total = OFDM_MDR(i-1);
        end
        found = 1;
    else
        i = i+1;
    end
end

if found == 0
    Rb_total = 54*10^6;
end

%%%%%%%%%%%%%%%%updating bit rates of active flows in ap2%%%%%%%%%%%%%%%%%%

% if AP_SINR == -20
%     Rb_total = 0;
% end

if isempty(active_flow_ap2)
    active_flow_ap2(1) = Rb_total;
    max_active_flow_ap2(1) = Rb_total;
    index_flows(1)=-1;
    bitrate_AP_new(1)=bitrate;
%     max_dr_perflow = AP_capacity;
else
    active_flow_ap2(size+1) = Rb_total/(AP_stations+1);
    max_active_flow_ap2(size+1) = Rb_total;
    index_flows(size+1)=-1;
    bitrate_AP_new(size+1)=bitrate;
%     max_dr_perflow = AP_capacity/(sharing_AP+1);
end

% AP_capacity_to_be_shared = AP_capacity;
% sharing = length(active_flow_ap2);

% for kk=1:length(active_flow_ap2)
%     if active_flow_ap2(kk) < max_dr_perflow && active_flow_ap2(kk) ~= -1
%         AP_capacity_to_be_shared = AP_capacity_to_be_shared-active_flow_ap2(kk);
%         sharing = sharing-1;
%     end
% end
% 
% if AP_capacity_to_be_shared < 0
%     AP_capacity_to_be_shared = 0;
% end

for aa=1:length(active_flow_ap2)-1
    if active_flow_ap2(aa) ~= -1
%         if sharing == 0
%            sharing = 1;
%         end
        active_flow_ap2(aa) = max_active_flow_ap2(aa)/(AP_stations+1);
    end
end

new_index2 = 0;
for bb=1:length(selected_Rb_array)
    if index_AP_array(bb)==ap2
      new_index2 = new_index2+1; 
      if selected_Rb_array(bb) >= bitrate_AP(bb)
          sat_flows_before(new_index2) = 1;
      else
          sat_flows_before(new_index2) = selected_Rb_array(bb)./bitrate_AP(bb);
      end
    end
end

% new_active_flow = [];
new_active_flow_index = 0;
for bb=1:length(active_flow_ap2)
    if active_flow_ap2(bb) ~= -1
      new_active_flow_index=new_active_flow_index+1;
%       new_active_flow(new_active_flow_index) = active_flow_ap2(bb);
      if active_flow_ap2(bb) >= bitrate_AP_new(bb)
          sat_flows_after(new_active_flow_index) = 1;
      else
          sat_flows_after(new_active_flow_index) = active_flow_ap2(bb)./bitrate_AP_new(bb);
      end
    end
end

% change = mean(sat_flows_before)-mean(sat_flows_after);

% if ((mean(sat_flows_after)/mean(sat_flows_before) < 0.2) && mean(new_active_flow_after) < 100000)
if length(sat_flows_before) ~= 0 && length(sat_flows_after) ~= 0
%     if ((change*100)/mean(sat_flows_before) > 40) 
    if mean(sat_flows_after)<(mean(sat_flows_before)-(mean(sat_flows_before)*0.2))
%         active_flow_ap2(length(active_flow_ap2))=0;
        congested=1;
    else
        congested=0;
    end
else
    congested=0;
end

% if ap2==5
%    sat_flows_before2 = mean(sat_flows_before)
%    sat_flows_after2 = mean(sat_flows_after)
% end
   
    
return

