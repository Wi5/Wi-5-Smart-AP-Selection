function [STA_SAT, STA_QG, SAT_FLOWS, STA_SINR, STA_PW, assigned_AP, NET_EFF, saturated_AP, selected_Rb, DATARATE] = performances(req_bitrate, index_AP, selected_SINR, selected_Tx_Pw, assigned_AP, selected_Rb, STA_SAT, STA_QG, STA_SINR, STA_PW, NET_EFF, SAT_FLOWS, STA_activity, saturated_AP, cont_STA, DATARATE)
      
      sat_flows = 0;
      total_sat = 0;
      extra_band = 0;
      throughput = 0;
      cont_flows = 0;
      assigned_AP(cont_STA) = index_AP(cont_STA);
      for f=1:cont_STA
          if STA_activity(f) >0 && assigned_AP(f)~=0
              cont_flows = cont_flows+1;
              if selected_Rb(f) >= req_bitrate(f)
                  selected_Rb(f) = req_bitrate(f);
                  sat_flows = sat_flows+1;
                  total_sat = total_sat+1;
                  extra_band = extra_band+(selected_Rb(f)-req_bitrate(f));
              else
                  total_sat = total_sat+(selected_Rb(f)./req_bitrate(f));
              end
              throughput = throughput+selected_Rb(f);
              STA_QG(cont_STA) = throughput/cont_flows;
              STA_SAT(cont_STA) = total_sat/cont_flows;
              NET_EFF(cont_STA) = extra_band/cont_flows;
              SAT_FLOWS(cont_STA) = sat_flows/cont_flows;
              DATARATE(f) = selected_Rb(f);
          end
      end
      STA_SINR = selected_SINR;
      STA_PW = selected_Tx_Pw;
                
return
