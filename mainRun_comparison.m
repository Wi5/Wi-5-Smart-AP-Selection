clc
clear all
close all
%%% initialization (constructor of AP and STA objects)
initParameters
parameters.APs_locations = order_locations (parameters.APs_locations);

save('all_')
% load('all_')

%steps (inside the for) and stop are variables that simulate the time 
%in minutes. 
stop = 1200; %1200 + 3 minutes means 400 stations. 
minutes = 3; %a new flow is created with a flow generation rate equal to minutes.
%%% AP selection methods loop (two methods: sinr-based and reward-based).
%%% So, for each AP selection methods, Channel assigment algorithm is
%%% executed
for ii=1:length(selection_methods)
    clear APs STAs
    load('all_')
    parameters.method = selection_methods{ii}; 
    steps = 1;
    cont_STA = 0; %it is a counter of the stations that will be created during the simulation
    active = 0; %following the flow generation rate, every time a new flow is created the variable called "active" will be 1.
    selected_Rb_array = [];
    max_selected_Rb_array = []; %thi is used only by the data rate based algorithm
    index_AP_array = [];
    bitrate_AP = [];
    flag_AP = zeros(1,15);

    %Arrays defined for the performance evaluation
    STA_SAT = [];   %station satisfaction
    STA_QG = [];    %achieved bit rate
    STA_SINR = [];  %achieved SINR
    STA_PW = [];    %AP transmit power
    NET_EFF = [];   %network efficiency
    SAT_FLOWS = []; %number of satisfied flows for each new served one
    SAT_AP = [];    %number of saturated APs
    BLOCKED = [];
    BLOCKED_No = [];
    DATARATE = [];
    REQ = [];
    APPLICATION = [];
    assigned_AP = []; 
    selected_SINR = [];
    selected_Tx_Pw = [];
%     index_AP = [];
%     req_bitrate = [];
%     QG_index = [];
%     selected_Rb = [];
%     total_available_Rb = [];
    total_congested_AP = [];
    total_blocked = [];
    STA_activity = [];
    STA_activity_energy = [];
    saturated_AP = 0;
    
    %%% channel selection process
    APs(1) = create_AP (1,parameters);
    set_CH_n(APs(1),1);
    Assignment = [1 zeros(1,10)];
    nAPs_temp = parameters.nAPs;
    AP_number = parameters.nAPs;
    
    %This is the first channel assigment to the AP without considering the
    %stations (matrix made only by 0 and 1).
    C=[];
    for k=2:nAPs_temp
        parameters.nAPs = k;
        APs(k) = create_AP (k,parameters);
        G = generate_graphTable(APs,parameters);
        O_l=generate_costTable_singleCol(APs,parameters,k,G);
        [N F]=size(O_l);
        
        c=zeros(F,1);
        for j=1:F
            c(j)=sum(G(:,k).*O_l(j));
        end
        C=[C;c];
        A=[ones(1,F);zeros(F-1,F)];
        b=[1;zeros(F-1,1)];
        
        lb=zeros(F,1);
        ub=ones(F,1);
        
        %   ctype = "SSSS";
        %   vartype = "CCCCCCCCCCCC";
        s = 1;
        param.msglev = 1;
        param.itlim = 100;
        
        %   [xmin, fmin, status, extra] = ...
        %      glpk (c, A, b, lb, ub, [], [], s, param);
%         xmin = intlinprog(c,[1:F],[],[],A,b,lb,ub);
        ind = randi(11);
%         Assignment = [Assignment; xmin'];
%         ind=find(xmin == 1);
        set_CH_n(APs(k),ind);
    end
    
    %%%% result summarization
    sum(Assignment,1)
    G = generate_graphTable(APs,parameters);
    O_l=generate_costTable(APs,parameters,G);
    
    while steps <= stop
        
        %STA_activity is an array indicating the activity of each station.
        %each time a new station joins the network, an assigment should be done, so
        %active = 1 indicate this.
        
        if mod(steps, minutes) == 0 %every "minutes" it generates a new station represented by its array of three different quality grades (QG)
            active = 1;
            
            cont_STA = cont_STA+1;
            %av_duration is the the average duration of a video
            av_duration = 100000;
            
            %the first array is a counter updating the ongoing activity durations,
            %while the second one memorizes each duration of each flow that will be
            %used for the computation of the energy.
            STA_activity(cont_STA) = traffic_profile(av_duration);
            STA_activity_energy(cont_STA) = STA_activity(cont_STA);
            
        end
        
        %if there is a new active station (i.e., active == 1) let's execute the
        %algorithm.
        if cont_STA > 0 && active == 1
            
            %AP_selection is the function that executes the algorithm. It takes as
            %input the new flow in terms of bit rate requirement (i.e., the array
            %QG), the information about the APs (i.e., SINR), the array AP_stations
            %that represents the number of active flows for each AP, and AP_RW that
            %represents the value of the rewards achieved by active STAs used to
            %compute the standard deviation.
            %lambda is used for load_based solution
            lambda = stop - (cont_STA*3);
            application = 0;
            STAs(cont_STA) = create_STA(cont_STA,lambda,application,selected_Rb_array,max_selected_Rb_array,index_AP_array,bitrate_AP,flag_AP,APs,parameters);
%             AP_association(STAs(cont_STA),APs,parameters,1)
            selected_SINR(cont_STA) = STAs(cont_STA).Rx_Table.SINR;
            selected_Tx_Pw(cont_STA) = STAs(cont_STA).Rx_Table.RxPwr;
%             index_AP(cont_STA) = STAs(cont_STA).AP_ID;
%             QG2 = parameters.QG;
%             QG_index(cont_STA) = STAs(cont_STA).QG_index2;
            bitrate_AP(cont_STA) = STAs(cont_STA).req_bitrate;
            APPLICATION(cont_STA) = STAs(cont_STA).application;
            selected_Rb_array = STAs(cont_STA).selected_Rb_array2;
            max_selected_Rb_array = STAs(cont_STA).max_selected_Rb_array2;
            index_AP_array = STAs(cont_STA).index_AP_array2;
            total_congested_AP(cont_STA) = STAs(cont_STA).total_congested_AP2;
            total_blocked(cont_STA) = STAs(cont_STA).total_congested_AP2;
            if cont_STA == 1
                assigned_AP(1) = index_AP_array(cont_STA);
            end
            
            %%%%%%%%%% PERFORMANCE EVALUATION PER STATION%%%%%%%%%%%%%%%%%
            [STA_SAT, STA_QG, SAT_FLOWS, STA_SINR, STA_PW, assigned_AP, NET_EFF, saturated_AP, selected_Rb_array, DATARATE] = performances(bitrate_AP, index_AP_array, selected_SINR, selected_Tx_Pw, assigned_AP, selected_Rb_array, STA_SAT, STA_QG, STA_SINR, STA_PW, NET_EFF, SAT_FLOWS, STA_activity, saturated_AP, cont_STA, DATARATE);
            SAT_AP(cont_STA) = sum(total_congested_AP);
%             BLOCKED(cont_STA) = (sum(total_blocked)./cont_STA)*100;
            BLOCKED(cont_STA) = sum(total_blocked);
            REQ(cont_STA) = bitrate_AP(cont_STA);
%             BLOCKED_No(cont_STA) = sum(total_blocked);
            active = 0;
        end
        
        steps = steps + 1;
        
    end
    
    for ff=1:cont_STA
        STA_SAT2(ff) = sum(STA_SAT(1:ff))./ff;
        STA_QG2(ff) = sum(STA_QG(1:ff))./ff;
        SAT_FLOWS2(ff) = (sum(SAT_FLOWS(1:ff))./ff)*100;
        NET_EFF2(ff) = sum(NET_EFF(1:ff))./ff;
        BLOCKED2(ff) = sum(BLOCKED(1:ff))./ff;
    end
    if ii == 2
       STA_SAT_FF = STA_SAT2;
       STA_QG_FF = STA_QG2;
       SAT_FLOWS_FF = SAT_FLOWS2;
       NET_EFF_FF = NET_EFF2;
       SAT_AP_FF = SAT_AP;
       BLOCKED_FF = BLOCKED2;
       DATARATE_FF = DATARATE;
       REQ_FF = REQ;
       APPLICATION_FF = APPLICATION;
%        BLOCKED_No_FF = BLOCKED_No;
    elseif ii == 1 
       STA_SAT_DR = STA_SAT2;
       STA_QG_DR = STA_QG2;
       SAT_FLOWS_DR = SAT_FLOWS2;
       NET_EFF_DR = NET_EFF2;
       SAT_AP_DR = SAT_AP;
       BLOCKED_DR = BLOCKED2;
       BLOCKED_No_DR = BLOCKED_No;
       DATARATE_SINR = DATARATE;
       REQ_SINR = REQ;
       APPLICATION_DR = APPLICATION;
    else
       STA_SAT_LB = STA_SAT2;
       STA_QG_LB = STA_QG2;
       SAT_FLOWS_LB = SAT_FLOWS2;
       NET_EFF_LB = NET_EFF2;
       SAT_AP_LB = SAT_AP;
       BLOCKED_LB = BLOCKED2;  
       DATARATE_LB = DATARATE;
       REQ_LB = REQ;
       APPLICATION_LB = APPLICATION;
%        BLOCKED_No_LB = BLOCKED_No;
    end
    if ii == 2
          save performance_results_flow_ff DATARATE_FF REQ_FF 
    elseif ii == 1
          save performance_results_flow_sinr DATARATE_SINR REQ_SINR 
    else
%         save performance_results_flow_lb STA_SAT_LB STA_QG_LB SAT_FLOWS_LB NET_EFF_LB SAT_AP_LB BLOCKED_LB 
%           save performance_results_flow_lb STA_QG_LB SAT_FLOWS_LB DATARATE_LB REQ_LB APPLICATION_LB %BLOCKED_LB
    end


end
