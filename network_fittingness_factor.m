function [ff_sigma, ff, active_flows_Rb, index_flows, congested] = network_fittingness_factor(bitrate, BW, AP_SINR, selected_Rb_array, index_AP_array, bitrate_AP, ap2)

shaping = 5;
shaping_k = 1;
shaping_mine = 1.3;

[active_flows_Rb, index_flows, congested] = available_bitrate(BW, AP_SINR, selected_Rb_array, index_AP_array, ap2, bitrate, bitrate_AP);
Rb = active_flows_Rb(length(active_flows_Rb));

%active_flows_Rb is an array with the new bit rates assigned to the flows
%already active in ap2 if this AP is assigned to the new flow. The last
%element of the array is the bit rate achieved by the last flow whose the
%AP selection is needed and it is stored in Rb in this function.

%index_flows is an array with the indeces of the flows active in ap2.

%notice that if this is a new flow for ap2, active_flows_Rb is an array
%with one element and index_flows is an empty array.

%This condition is needed otherwise the ff gives infinitive.
if Rb == 0
    ff_sigma = 0;
    ff = 0;
else
    %ff computation for the new flow
    U = ((Rb*shaping_mine)/bitrate)^shaping/(1+(((Rb*shaping_mine)/bitrate)^shaping));

    lambda = 1 - (2.71828^((-shaping_k)/(((shaping-1)^(1/shaping))+(shaping-1)^((1-shaping)/shaping))));

    ff = ((1 - (2.71828^(-((shaping_k*U)/((Rb*shaping_mine)/bitrate)))))/lambda);
    
    %computation of the new ffs of the active flows. If index_flows is 
    %empty there are no other flows active in ap2. 
    if isempty(index_flows)
        sigma = 0;
    else
        AP_FF = [];
        AP_Flow = [];
        new_index = 0;
        for nf=1:length(bitrate_AP)
            c = find(index_flows==nf);
            if length(c) > 0
                new_index = new_index + 1;
                AP_Flow(new_index) = bitrate_AP(nf);
            end
        end

        for f=1:new_index
            AP_FF(f) = fittingness_factor(AP_Flow(f), active_flows_Rb(f));
        end

        AP_FF(length(AP_FF)+1) = ff;

        sigma = std(AP_FF);
    end
    ff_sigma = ff * (1 - sigma);
end
                             
return
