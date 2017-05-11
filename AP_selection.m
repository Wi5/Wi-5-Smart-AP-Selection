function [bitrate, index_AP_array, selected_Rb_array, total_congested_AP, index_AP] = AP_selection(bitrate, AP_SINR, selected_Rb_array, index_AP_array, bitrate_AP)
  
    BW = 20*10^6; %BW is the available bandwidth of the APs.
    
    %bitrate is the required bit rate by the new flow.
    
    %AP_SINR is an array with the SINRs that the new flow can achieve with
    %each AP.
    
    %selected_Rb_array is an array with size=number of current active flows 
    %with all their assigned data rates updated for each new flow
    %connection. Note that in case of assignment this array includes also
    %the bit rate of the last flow.
    
    %index_AP_array is an array with size=number of current active flows 
    %with the indeces of the APs they are connected to. Note that in case 
    %of assignment this array include also the index of the AP assigned to 
    %the last flow.
    
    %bitrate_AP is an array with size=number of current active flows with 
    %the required bit rates. This array should be updated outside this
    %function with the bitrate required by the new flow when it is assigned
    %to an AP.
    
    %for the first flow selected_Rb_array, index_AP_array and bitrate_AP 
    %will be empty arrays. 
    
    %AP_capacity is an array with all the available maximum data rates in
    %each AP that takes into accounts the radio environment conditions
    %(notice that this value is 54 Mbps for each AP at the moment).
    %ff is an array with the fittingness factor values achieved for the new
    %flow considering each SINR sensed from each AP. 
    
    %active_flows_Rb is an array with the new bit rates assigned to the flows
    %already active in ap2 if this AP is assigned to the new flow. The last
    %element of the array is the bit rate achieved by the last flow whose the
    %AP selection is needed and it is stored in Rb.
    AP_Rb=ones(length(AP_SINR),length(selected_Rb_array)+1)*(-1);
    AP_index=ones(length(AP_SINR),length(selected_Rb_array)+1)*(-1);
    for ap2=1:length(AP_SINR)
            [ff_sigma, ff, active_flows_Rb, index_flows, congested] = network_fittingness_factor(bitrate, BW, AP_SINR(ap2), selected_Rb_array, index_AP_array, bitrate_AP, ap2);
            ff_sigma_value(ap2) = ff_sigma;
            ff_value(ap2) = ff;  
            AP_Rb(ap2,:) = active_flows_Rb;
            AP_index(ap2,:) = index_flows;
            congested_AP(ap2) = congested;
     end
     [selected_ff_sigma, index_AP] = max(ff_sigma_value);
     selected_ff = ff_value(index_AP);
     
     %the updating happens only if the flow is not blocked
     if congested_AP(index_AP)==0
         for ss=1:length(selected_Rb_array)
             c = find(AP_index(index_AP,:)==ss);
             if length(c) > 0
                 selected_Rb_array(ss) = AP_Rb(index_AP, ss);
             end
         end
     end
     if congested_AP(index_AP)==0
        selected_Rb_array(length(selected_Rb_array)+1) = AP_Rb(index_AP, length(active_flows_Rb));
        index_AP_array(length(index_AP_array)+1) = index_AP;
     else
        selected_Rb_array(length(selected_Rb_array)+1) = 0;
        index_AP_array(length(index_AP_array)+1) = 0;
     end
     total_congested_AP = congested_AP(index_AP);
return
