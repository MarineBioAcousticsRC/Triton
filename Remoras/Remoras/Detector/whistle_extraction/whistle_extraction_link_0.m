function [ ] = whistle_extraction_link_0 (Signal, Fs, Advance_ms, Length_ms)

tic  % Keep track of execution time for algorithm in seconds

% Function - spEndpoint(Signal, Fs, 'none','Framing',{Advance_ms,Length_ms,
%                      'hamming'}) 
%            Given Signal vector function returns frame indices 
Indices = spEndpoint(Signal, Fs, 'none', ...
                            'Framing', {Advance_ms, Length_ms, 'hamming'});

% Function - spExtractionFromIndices(Indices,Signal,'Frame',1,'Framing', 
%                                   [Fs, Advance_ms, Length_ms])
%            Given Signal vector and indices function extracts portion
%            of Signal specified by frame indices 
frames = spExtractFromIndices(Indices, Signal, 'Frame', 1, ...
                              'Framing', [Fs, Advance_ms, Length_ms]);


high_cutoff_frequency = 35000;  % Whistles are normally under 35000 Hz
[sample_frequency_length, sample_time_length] = size(frames);
bin_Hz = Fs / sample_frequency_length;

% Hamming Window is created: frequency_length x 1
% Normally used for narrowband application                             
window = hamming(sample_frequency_length);  

% Windowing: To remove the high frequency component introduced during
%            selection of time domain samples.
for time_index = 1:sample_time_length
    frames(:,time_index) = frames(:,time_index) .* window;
end

%Discrete Fourier transform: Time domain -> Frequency domain
complex_spectra = fft(frames);

% Convert to dB
power_dB = complex_spectra;
for time_index=1:sample_time_length
    power_dB(:,time_index) = 10*log10(power_dB(:,time_index) .* ...
                                            conj(power_dB(:,time_index)));
end

% row wise mean (average)
mean_dB = mean(power_dB, 2);
for time_index=1:sample_time_length
    power_dB(:,time_index) = power_dB(:,time_index) - mean_dB;
end

%%%%%%%%%%%%%%%%%%%%%%%%-----? Algorithm -----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial Declaration
wnode_id = 0;                    % unique id for wnodes to be created
list_wnodes = cell(1);           % Storage of all wnodes created
current_active_wnodes = cell(1); % Nodes in current time frame
prev_time_wnodes = cell(1);      % Nodes from previous time frame

% Parameters
threshold_energy = 10;           % Assuming whistles are normally above 
                                 % 10dB energy  
threshold_length = 4;            % Nodes with length above threshold length 
                                 % are possible candidates and so are the 
                                 % nodes it backpoints to
lookup_range = 15;
freq_range = high_cutoff_frequency / bin_Hz;

for time_index = 1 : sample_time_length
%for time_index = 1 : 3

    fprintf('Processing time frame %d \n',time_index);
    
    % List of peaks
    [peak] = whistle_Peak(power_dB, time_index, freq_range, threshold_energy);
    
    prev_time_wnodes = current_active_wnodes;
    current_active_wnodes = cell(1);    
    for peak_index = 1 : length(peak)       
        
        % Initial declaration
        track_length = 0;        
        
        % flag_backPoint: 0 - No peak point from previous time frame found
        %                 that current peak point can point to.
        %                 1 - Atleast one peak point from previous time  
        %                 frame found that current peak point can point to.
        flag_backPoint = 0;       
        
        % peak vector is row represented where each row is frequency index
        % of peak energy point
        freq_index  = peak(peak_index, 1);
        
        % Node being created with default initial values
        wn = wnode(time_index, freq_index, track_length);
        
        if( 1 == time_index )  % Special case: 1st time frame                                
            wn.length = track_length + 1;
            current_active_wnodes(peak_index) = {wn};
            wnode_id = wnode_id + 1;
            list_wnodes(wnode_id) = {wn};
        else              
            lower_limit = freq_index - lookup_range;
            upper_limit = freq_index + lookup_range;                                                    
            
            % energy_diff: Vector stores difference between energies of  
            %              previous nodes and current node
            energy_diff = NaN(numel(prev_time_wnodes),1);      
                                              
            % Finding absolute differences of energies between current
            % and previous time frame peak points within lookup range.                       
            % Condition:Check if there are active peak points in previous 
            %           time frame            
            if(~ cellfun('isempty',prev_time_wnodes))
                for cell_index = 1:numel(prev_time_wnodes)
                   lookup_freqs = prev_time_wnodes{cell_index}.freq_index;
                   if ( (lower_limit <= lookup_freqs) && ...
                         (lookup_freqs <= upper_limit) )
                   
                      energy_diff(cell_index,1) = ...
                       abs(...
                       power_dB(prev_time_wnodes{cell_index}.freq_index,...
                                                        time_index - 1) ...
                       - power_dB(freq_index, time_index) ...
                      );
                   
                   flag_backPoint = 1;
                   end  
               end
            end
            
            % No peak point from previous time frame found that current
            % peak point can point to. So Prev property of wnode is not 
            % updated and default initial value is kept i.e. Prev = [ ]
            if(0 == flag_backPoint)  
               wnode_id = wnode_id + 1; 
               current_active_wnodes(peak_index) = {wn}; 
               list_wnodes(wnode_id) = {wn};
               continue;
            end         
            
            [min_value index]= min(energy_diff);                 
         %  count =0;
            for cell_index = 1:numel(prev_time_wnodes) 
               if (min_value == energy_diff(cell_index,1))                                                                                         
                %{
                    count = count + 1;
                %   if (count > 1)
                %       fprintf ('Hey more then 2 back pointers');
                    end
                %}
                   % Get length of previous node to which current node
                   % is going to back point
                   prev_length = prev_time_wnodes{cell_index}.length;
                   
                   % Set length of current node
                   wn.length = prev_length + 1;
                        
                   % Back point to previous time frame's choosen node 
                   wn.backPointer(prev_time_wnodes{cell_index});
                   
                   % wn.insertAfter(prev_time_wnodes{cell_index});   

                   wnode_id = wnode_id + 1;
                   current_active_wnodes(peak_index) = {wn};
                   list_wnodes(wnode_id) = {wn};
               end
            end                       
        end   % if( 1 == time_index )
    end    % for peak_index = 1 : size(peak,1)
end % for time_index = 1 : 3

% Tracing the nodes backwords
fprintf('\nPLOTTING the nodes using backpointers... \n\n');
figure ('Name','DP');
xlim([1 1000]);
ylim([1 35000]);
subplot(2,1,2)
num_wnodes = numel(list_wnodes);
for list_index = num_wnodes:-1:1
   plot_freq_matrix = NaN (1, sample_time_length);
   if(list_wnodes{list_index}.length > threshold_length)
      whistle_recursive_plot(list_wnodes{list_index}, plot_freq_matrix, bin_Hz, Advance_ms, sample_time_length);
   end
end
hold off;
title('Dynamic Programming');
xlabel 'time (ms)'
ylabel 'frequency (Hz)'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,1,1)
f = (0: bin_Hz: Fs/2 - bin_Hz);
t = (0: sample_time_length-1) * Advance_ms;
rng = find(f < high_cutoff_frequency);

h(1) = imagesc(t, f(rng), power_dB(rng,:));
title('Energy dB');
xlabel 'time (ms)'
ylabel 'frequency (Hz)'
set(gca, 'YDir', 'normal');

linkaxes
%linkprop(cell2mat(get(h, 'Parent')), {'XLim', 'YLim'});
% lock zooms together
%linkaxes( cell2mat(get(h, 'Parent')), 'xy');


time = toc;   % Keep track of execution time for algorithm in seconds
%fprintf('\nEXECUTION TIME: %d sec\n\n',time);


