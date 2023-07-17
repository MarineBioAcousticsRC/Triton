function [] = whistle_recursive_plot(f_plot_wnode, f_plot_freq_matrix, f_bin_Hz, f_Advance_ms, f_sample_time_length)
% File:         whistle_recursive_plot.m
% Description:  Recursively back tracks from the given point (f_plot_wnode)
%               and plots the respective points on the back track path
% Return Value: None 

   plot_time = f_plot_wnode.time_index;
   plot_freq = f_plot_wnode.freq_index;   
   f_plot_freq_matrix(1, plot_time) = plot_freq * f_bin_Hz;

%{
   % NOTE - Problem with recursion limit
if(~ isempty(f_plot_wnode.Next))
      whistle_recursive_plot_next(f_plot_wnode, f_plot_freq_matrix,f_bin_Hz); 
   end
%}
   
   % Get previous node using class method getPrevNode
   prev_wnode = f_plot_wnode.getPrevNode();                  
   
   if (~isempty(prev_wnode)) 
      whistle_recursive_plot(prev_wnode, f_plot_freq_matrix, f_bin_Hz, f_Advance_ms, f_sample_time_length);
   else
      t = (1 : f_sample_time_length) * f_Advance_ms;  
      plot(t, f_plot_freq_matrix,'.');
      hold on;
   end
%{   
 function [] = whistle_recursive_plot_next(f_plot_wnode_next, f_plot_freq_matrix,f_bin_Hz)        
    plot_time_next = f_plot_wnode_next.time_index;
    plot_freq_next = f_plot_wnode_next.freq_index;   
    f_plot_freq_matrix(1, plot_time_next) = plot_freq_next * f_bin_Hz;
        
    if(~ isempty(f_plot_wnode_next.Next))
       next_wnode = f_plot_wnode_next.getNextNode();
       whistle_recursive_plot_next(next_wnode, f_plot_freq_matrix, f_bin_Hz); 
    end      
%}