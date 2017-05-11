function [index_AP_array, selected_Rb_array, max_selected_Rb_array, total_congested_AP, index_AP] = AP_selectionLB(bitrate, AP_SINR, selected_Rb_array, max_selected_Rb_array, index_AP_array, bitrate_AP, AP_stations, lambda, load_effect, d)
  
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
    AP_Rb_max=ones(length(AP_SINR),length(max_selected_Rb_array)+1)*(-1);
    AP_index=ones(length(AP_SINR),length(selected_Rb_array)+1)*(-1);
    for ap2=1:length(AP_SINR)
            [active_flows_Rb, max_active_flows_Rb, index_flows, congested] = available_bitrate2(BW, AP_SINR(ap2), selected_Rb_array, max_selected_Rb_array, index_AP_array, ap2, bitrate, bitrate_AP, AP_stations(ap2));
            AP_Rb(ap2,:) = active_flows_Rb;
            AP_Rb_max(ap2,:) =  max_active_flows_Rb;
            AP_index(ap2,:) = index_flows;
            congested_AP(ap2) = congested;
            selecting_bitrate(ap2) = active_flows_Rb(length(active_flows_Rb));
%             load_effect2=load_effect
%             lambda2=lambda
%             selecting_bitrate2=selecting_bitrate(ap2)
%             d2=d(ap2)
            load_AP(ap2) = load_effect*((lambda./selecting_bitrate(ap2)).*d(ap2));
    end
    [load_values, load_indeces]=sort(load_AP); 
    found=0;
    for ap3=1:length(load_indeces)
        if selecting_bitrate(load_indeces(ap3))>=bitrate && found==0
            selected_bitrate = selecting_bitrate(load_indeces(ap3));
            index_AP = load_indeces(ap3);
            found = 1;
        end
    end
    if found==0
        selected_bitrate = selecting_bitrate(load_indeces(length(load_indeces)));
        index_AP = load_indeces(length(load_indeces));
    end
    max_selected_Rb_array(length(max_selected_Rb_array)+1) = AP_Rb_max(index_AP, length(max_active_flows_Rb));
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
        selected_Rb_array(length(selected_Rb_array)+1) = selected_bitrate;
        index_AP_array(length(index_AP_array)+1) = index_AP;
    else
        selected_Rb_array(length(selected_Rb_array)+1) = 0;
        index_AP_array(length(index_AP_array)+1) = 0;
    end
    total_congested_AP = congested_AP(index_AP);
return
