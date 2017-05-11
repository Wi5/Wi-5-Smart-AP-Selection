classdef create_STA < handle
    properties
        ID
        lambda
        selected_Rb_array = [];
        max_selected_Rb_array = []; %this is used only by the data rate based algorithm
        index_AP_array = [];
        bitrate_AP = [];
        flag_AP = [];
        STA_locations
        STA_angle
        lambda_ave
        STA_move
        Rx_Table
        AP_ID
%         QG_index2
        selected_Rb_array2 = [];
        max_selected_Rb_array2 = []; %this is used only by the data rate based algorithm
        index_AP_array2 = [];
        bitrate_AP2 = [];
        req_bitrate
        application
%         total_available_Rb2
        total_congested_AP2
%         flow_number
        total_blocked
        vel_mps
    end
    
    methods
        function obj = create_STA(cont_STA,lambda,application,selected_Rb_array,max_selected_Rb_array,index_AP_array,bitrate_AP,flag_AP,APs,parameters,varargin)
            obj.ID=cont_STA;
            obj.lambda=lambda;
            obj.application=application;
            obj.selected_Rb_array=selected_Rb_array;
            obj.max_selected_Rb_array=max_selected_Rb_array;
            obj.index_AP_array=index_AP_array;
            obj.flag_AP=flag_AP;
            obj.bitrate_AP=bitrate_AP;
            obj.STA_locations(1,:)=parameters.STAs_locations(obj.ID,:);
            AP_association(obj,APs,parameters,1);
            obj.vel_mps=parameters.vel_mps;
            obj.STA_move=parameters.STA_move;
            obj.STA_angle=2*pi*rand(1);            
            %                 obj.Rx_Table.SINR =   ;
            %                 obj.STA_locations(2:parameters.nTTI,1)=obj.STA_locations(1,1);
            %                 obj.STA_locations(2:parameters.nTTI,2)=obj.STA_locations(1,2);
            %                 creatTrace_perTTI(obj,parameters,1)
            %                 creatPath(obj,parameters)
        end
        function AP_association(obj,APs,parameters,t)
            d=sqrt((parameters.APs_locations(:,1)-obj.STA_locations(1,1)).^2 + (parameters.APs_locations(:,2)-obj.STA_locations(1,2)).^2);
            pwr = [APs(:).tx_pwr] - 10*log10((4*pi/3e8*[APs(:).freq].*d').^parameters.nLoss);
            for ii=1:length(pwr)
                sinr(ii) =  pwr(ii) - 10*log10(sum(10.^(pwr/10)) - 10.^(pwr(ii)/10));
            end
            %I create a variable random included between 1 and 5 that
            %represents a kind of application.
            %load_effect is needed for the load_based algorithm
            bitrate_index = randi(5);
            if bitrate_index == 1
                bitrate = 50000; %onlinegame
                load_effect = 0.5;
                obj.application = 1;
            else
                if bitrate_index == 2
                    bitrate = 40000; %VoIP
                    load_effect = 0.5;
                    obj.application = 2;
                else
                    if bitrate_index == 3
                        bitrate = 500000; %YouTube
                        load_effect = 1;
                        obj.application = 3;
                    else
                        if bitrate_index == 4
                            bitrate = 1000000; %YouTube premium
                            load_effect = 1;
                            obj.application = 4;
                        else
                            bitrate = 5000000; %NetFlix HQ
                            load_effect = 1;
                            obj.application = 5;
                        end
                    end
                end
            end      
            if strcmp(parameters.method,'sinr_based')
                AP_stations = [APs(:).AP_stations];
                [index_AP_array3, selected_Rb_array3, max_selected_Rb_array3, congested_AP, index_AP3] = AP_selectionDR(bitrate, sinr, obj.selected_Rb_array, obj.max_selected_Rb_array, obj.index_AP_array, obj.bitrate_AP, AP_stations);
                obj.req_bitrate = bitrate;  
                obj.AP_ID(1) = index_AP3;
                APs(obj.AP_ID).AP_stations = APs(obj.AP_ID).AP_stations+1;
                obj.selected_Rb_array2 = selected_Rb_array3;
                obj.max_selected_Rb_array2 = max_selected_Rb_array3;
                obj.index_AP_array2 = index_AP_array3;
                obj.total_congested_AP2 = congested_AP;
                obj.Rx_Table.RxPwr = pwr(obj.AP_ID);
                obj.Rx_Table.SINR = sinr(obj.AP_ID);  
            elseif strcmp(parameters.method,'reward_based')                 
                [bitrate, index_AP_array3, selected_Rb_array3, congested_AP, index_AP3] = AP_selection(bitrate, sinr, obj.selected_Rb_array, obj.index_AP_array, obj.bitrate_AP);
                obj.req_bitrate = bitrate;  
                obj.AP_ID(1) = index_AP3;
                obj.selected_Rb_array2 = selected_Rb_array3;
                obj.index_AP_array2 = index_AP_array3;
%                 obj.total_available_Rb2(t) = total_available_Rb;
                obj.total_congested_AP2 = congested_AP;
                obj.Rx_Table.RxPwr = pwr(obj.AP_ID(t));
                obj.Rx_Table.SINR = sinr(obj.AP_ID(t));                
%                 APs(AP_ind).AP_stations = APs(AP_ind).AP_stations+1;
%                 obj.flow_number(t) = APs(AP_ind).AP_stations;
%                 for k=1:length(d)
%                     if k == AP_ind
%                         APs(k).AP_BR(obj.ID) = bitrate;
%                     else
%                         APs(k).AP_BR(obj.ID) = 0;
%                     end
%                 end                
            else
                AP_stations = [APs(:).AP_stations];
%                 ID2=obj.ID
%                 lambda2=obj.lambda
                [index_AP_array3, selected_Rb_array3, max_selected_Rb_array3, congested_AP, index_AP3] = AP_selectionLB(bitrate, sinr, obj.selected_Rb_array, obj.max_selected_Rb_array, obj.index_AP_array, obj.bitrate_AP, AP_stations, obj.lambda, load_effect, d);
                obj.req_bitrate = bitrate;  
                obj.AP_ID(1) = index_AP3;
                APs(obj.AP_ID).AP_stations = APs(obj.AP_ID).AP_stations+1;
                obj.selected_Rb_array2 = selected_Rb_array3;
                obj.max_selected_Rb_array2 = max_selected_Rb_array3;
                obj.index_AP_array2 = index_AP_array3;
%                 obj.total_available_Rb2(t) = total_available_Rb;
                obj.total_congested_AP2 = congested_AP;
                obj.Rx_Table.RxPwr = pwr(obj.AP_ID);
                obj.Rx_Table.SINR = sinr(obj.AP_ID);   
            end
        end
        function move_STA(obj,parameters,t)
            u_t=1;%%parameters.tResolution*parameters.TTI; %%%%time resolution unit
            obj.STA_locations(t,:)=obj.STA_locations(max(t-1,1),:) + [obj.vel_mps*u_t*cos(obj.STA_angle) obj.vel_mps*u_t*sin(obj.STA_angle)];
            angleTemp=obj.STA_angle;
            while norm([0.5*[parameters.area_X,parameters.area_Y] - obj.STA_locations(t,:)],2) >= 1.5*parameters.ROI/2
                obj.STA_angle=angleTemp + pi + pi/8*randperm(16,1);
                obj.STA_locations(t,:)=obj.STA_locations(max(t-1,1),:);
            end
        end
    end
end