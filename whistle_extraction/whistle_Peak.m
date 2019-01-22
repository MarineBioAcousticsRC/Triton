function [selected_peak] = whistle_Peak(f_power_dB, f_time_index,...
                                   f_freq_range, f_threshold_energy)
% File:         whistle_Peak.m
% Description:  Given the signal, frequency index range, time frame and 
%               and threshold energy returns a list of peaks
% Return Value: selected_peak
    
    % Initialization
    lower_limit = 1;
    selected_peak_cnt = 0;     % counter
    selected_peak = [ ];       % list of peaks
    diff_peak_index_limit = 3; % variable used to select peak from group...
                               % of nearby peaks            
                               
    % All peaks greater then threshold energy                               
    peak = find( f_power_dB(1:f_freq_range, f_time_index) >= f_threshold_energy );

    % LOGIC for selecting peak from group of peaks.
    % Selection of peak is further filtered by choosing single peak from 
    % a group of peaks it belongs to.Groups of peak are based on default
    % difference limit (diff_peak_index_limit) set during initialization
    for peak_index = 1 : size(peak,1)
        
    %   NOTE: Order of if condition important should not be change
    
        if(peak_index == size(peak,1))
           selected_peak_cnt = selected_peak_cnt + 1;
           [value position] = max ( f_power_dB ...
                                        ( peak (lower_limit : peak_index, 1)...
                                               , f_time_index...
                                        )...       
                                   );          
           selected_peak(selected_peak_cnt,1) = peak (position + (lower_limit - 1), 1);
           break;
        end        
        if( ( peak(peak_index + 1,1) -  peak(peak_index,1) )...
                                                  > diff_peak_index_limit )
                                              
           selected_peak_cnt = selected_peak_cnt + 1;
           [value position] = max ( f_power_dB ...
                                      ( peak (lower_limit : peak_index, 1)...
                                             , f_time_index...
                                      )...       
                                  );       
           
           selected_peak(selected_peak_cnt,1) = peak (position + (lower_limit - 1), 1);
           lower_limit = peak_index + 1;                                    
        end        
    end