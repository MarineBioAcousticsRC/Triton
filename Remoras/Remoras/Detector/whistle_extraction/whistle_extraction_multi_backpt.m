function [ ] = whistle_extraction_multi_backpt...
                             (Filename, Start, Stop, Advance_ms, Length_ms)
% Filename - Name of file 
%            Example -  'palmyra092007FS192-071011-230000.wav'
% Start - Specific start point in seconds of the recording 
%         Example - 510           
% Stop - Specific stop point in seconds of the recording
%         Example - 512
% Advance_ms -  Frame advance
%         Example - 10
% Length_ms - Frame length
%         Example - 20

header = ioReadWavHeader(Filename);  % Get header information of the file

handle = fopen(Filename, 'rb', 'l'); % Open a binary file in read mode
                                     % with little endian byte order

% Initial Declaration
wnode_id = 0;                   % unique id for wnodes to be created
whistle_end_point = [];         % Storage of whistle end points

close_set = [];                 % Contains the node id's of the connected  
                                % nodes for specific number of previous 
                                % frame determined by the parameter
                                % 'frame_chunck_samples'

active_set = [];                % Contains the node id's for specific 
                                % number frame of previous frame determined 
                                % by the parameter 'frame_chunck_samples'
                                 
prev_frame_wnodes = [];         % Vector contains nodes for specific 
                                % number of previous frame determined by
                                % the parameter 'frame_chunck_samples'
                                
current_frame_wnodes = [];      % Vectors contains nodes of current frame

block_period_s = 3;             % 3 sec data is considered in each block   
power_dB = [];                  % Matrix with spectrogram details                               
prev_block_power_dB = [];       % Previous block's spectrogram details 
prev_block_frame_index_samples = 0;  % Last frame in previous block
last_frame = 0;                 % Last frame in the current block  
flag_last_block = false;        % true - last block of signal
                                % false - not the last block of signal
               
% Parameters
threshold_energy_dB = 10;        % Assuming whistles are normally above 
                                 % 10dB energy (SNR criterion)                                   
threshold_minlen_ms = 60;        % Whistles whose duration is shorter than
                                 % this threshold will be discarded.                                 
                                 
threshold_minlen_samples ...     % Threshold length in terms of samples
    = threshold_minlen_ms / Advance_ms;                                         

 
frame_chunck_ms = 40;   % Duration to look backwards for possible candidate           

frame_chunck_samples ...             % Number of frames to look 
    = frame_chunck_ms / Advance_ms;  % backwards for possible candidate
 
backpoint_limit = 3;                 % number of nodes a node can backpoint   
     
high_cutoff_frequency_Hz = 35000;    % Consider whistles are under 35000 Hz

num_block = ceil( (Stop - Start)/block_period_s  ); % Number of blocks

if (Start >= Stop)
    error('Stop should be greater then Start');
end

for index_block = 1 : num_block

   if (index_block == num_block)
       % special case - last block
       block_period_s  = Stop - Start;       
       flag_last_block = true;
   end
   
   % Retrives the data between start and end given the file handle and
   % header 
   Signal = ioReadWav(handle, header, Start, Start + block_period_s, ...
                                                             'Units', 's');
   
   Start = Start + block_period_s;     
   
   % Retrives indices for overlapping frames of data for a data set
   % which contains samples(1st argument of following function)
   Indices = spFrameIndices(header.fs * block_period_s, ...                   
                  header.fs * Length_ms/1000, header.fs * Advance_ms/1000);
   
   bin_Hz = header.fs / Indices.FrameLength;    % Frequency bin
   freq_range = high_cutoff_frequency_Hz / bin_Hz; 
   
   lookup_range_Hz = 600; % Previous frames are searched in this frequency 
                          % range to find possible candidate to backpoint to
   lookup_range = lookup_range_Hz / bin_Hz; % Search range  
   
   if(true == flag_last_block)
      last_frame = Indices.FrameCount;
   else
      % For transition between blocks last frame of current block is 
      % considered in next block(Frame Advance)
      last_frame = Indices.FrameCount - 1; 
   end
           
   prev_block_power_dB = power_dB;               

   % Does windowing (Hamming) and discrete fourier transform on the
   % extracted frames 
   [comp_spec] = whistle_frame_processing(Signal(:,1), Indices);
   
   power_dB = comp_spec;
   
   % Convert to dB
   for frame_index = 1 : Indices.FrameCount
      power_dB(:,frame_index) = 10*log10(power_dB(:,frame_index) .* ...
                                            conj(power_dB(:,frame_index)));
   end
   
   % Row wise mean (average)
   mean_dB = mean(power_dB, 2);
   for frame_index = 1 : Indices.FrameCount
      power_dB(:,frame_index) = power_dB(:,frame_index) - mean_dB;
   end      
   
   power_dB = [prev_block_power_dB power_dB]; % Previous block's power_dB   
                                              % prepend to present power_dB
                                             
   for frame_index = 1 + prev_block_frame_index_samples : ...
                                last_frame + prev_block_frame_index_samples
       
       fprintf('Processing frame %d \n',frame_index);
       
       % List of peaks      
       [peak] = spPeakSelector(power_dB(1:freq_range,frame_index),...
                                                            'Type','peak');
    
       % Remove peaks that don't meet SNR criterion
       peak(power_dB(peak, frame_index) < threshold_energy_dB) = [];  
       
       if(isempty(peak))            
          % active_set and prev_frame_wnodes needs to be updated every time 
          % new frame is considered. If no peak is found then a fake node
          % is added with all properties of node empty.Node with all 
          % properties empty is indicator of the end of adding current 
          % frame nodes to storage vector prev_frame_wnodes
          
          active_set = [active_set NaN];   
          prev_frame_wnodes = [prev_frame_wnodes wnode([],[],[],[],[])];
       end       
       
       for peak_index = 1 : length(peak)            
          
           % Initial declaration ------------------------------------------
          prev_node_vector = [];  % Tracks the possible nodes to backpoint
                                  % when a current node backpoints to more 
                                  % then 1 previous frame node
                                   
          % flag_backPoint: false - No node from previous time frame found 
          %                         that current peak point can point to.
          %                 true- Atleast one node from previous time frame 
          %                     found that current peak point can point to.
          flag_backPoint = false;                                                       
          
          energy_diff = [];  % Vector for storing energy differences 
                             % between current peak point and previous nodes  
          energy_index = 0; 
          index_mapping =[]; % Vector used for mapping indexes of  
                             % energy_diff to prev_frame_wnodes
          
          %----------------------------------------------------------------  
          
          wnode_id = wnode_id + 1;
          
          % peak vector is column represented where each column is freq.
          % index of peak energy point
          freq_index  = peak(peak_index);          
          
          prev_frame_wnodes = [prev_frame_wnodes current_frame_wnodes];
          current_frame_wnodes = [];
          
          if(frame_index == 1)                       
             current_frame_wnodes = [current_frame_wnodes ...
                                            wnode(wnode_id, frame_index,...
                                                 freq_index, 1, [])];                       
             % active_set
             if(peak_index == length(peak))
                 % NaN is added to indicate the start of next frame 
                 active_set = [active_set wnode_id NaN];
             else
                 active_set = [active_set wnode_id];
             end
             continue;
          else                           
             for prev_index = length(prev_frame_wnodes)-1: -1 : 1              
                lower_limit = freq_index - lookup_range;
                upper_limit = freq_index + lookup_range;                                                    
                             
                if( isempty(prev_frame_wnodes(prev_index).node_id) )                   
                   if(flag_backPoint == true)
                     % Indicates that backpoint to a node is found in exact 
                     % previous frame no need to continue to the search
                     % for previous previous frame
                     
                     break;      
                   end
                   continue;
                end
                lookup_freqs = prev_frame_wnodes(prev_index).freq_index;
                
                % Energy difference is determined only if the previous 
                % nodes freq_index lies in the lookup range
                if ( (lower_limit <= lookup_freqs) && ...
                     (lookup_freqs <= upper_limit) )
                
                   energy_index = energy_index + 1;
                                
                   energy_diff(energy_index) = ...
                   abs(...
                       power_dB(lookup_freqs, ...
                               prev_frame_wnodes(prev_index).time_index)...
                       - power_dB(freq_index, frame_index) ...
                       );                 
                                
                   index_mapping(energy_index) = prev_index;                                
                               
                   flag_backPoint = true;                                                                 
                end
             end 
             
             % No peak point from previous time frame found that current
             % peak point can point to. So Prev property of wnode is empty 
             % i.e. Prev = [ ]
             if(false == flag_backPoint)                                
                current_frame_wnodes = [current_frame_wnodes ...
                          wnode(wnode_id, frame_index, freq_index, 1, [])];
                 
                %active_set
                if(peak_index == length(peak))
                   % NaN is added to indicate the start of next frame 
                   active_set = [active_set wnode_id NaN];
                else
                   active_set = [active_set wnode_id];
                end
                continue;         
             end             
             
             if(length(energy_diff) < 3)
                % If current possible peak has energy difference with less
                % then 3 previous nodes we just backpoint to node whose
                % energy difference with current peak point is minimum as
                % there are only two possible nodes to backpoint to
                [nouse index] = min(energy_diff);
                prev_node_index = index_mapping(index);
              
                % Get length of previous node to which current node
                % is going to back point
                prev_length = prev_frame_wnodes(prev_node_index).length; 
                               
                current_frame_wnodes = [current_frame_wnodes ...
                                     wnode(wnode_id, frame_index,...
                                     freq_index, prev_length + 1,...
                                     prev_frame_wnodes(prev_node_index)) ]; 

                %closedset
                close_set = [close_set prev_node_index];
                
                %active_set
                if(peak_index == length(peak))
                   % NaN is added to indicate the start of next frame
                   active_set = [active_set wnode_id NaN];
                else
                   active_set = [active_set wnode_id];
                end
             else                 
                % If current possible peak has energy differences with more 
                % then 3 previous nodes then current peak point backpoints 
                % to certain number of previous nodes, that is determined 
                % by one of the parameter 'backpoint_limit'.
                % For example:
                % backpoint_limit = 3 Peak can point to 3 previous node
                % backpoint_limit = 4 Peak can point to 4 previous node
                
                for backpoint_index = 1 : backpoint_limit
                   [nouse index] = min(energy_diff);                                  
                   prev_node_vector = [prev_node_vector ...
                                                     index_mapping(index)];
                   energy_diff(index) = NaN;                                
                end     
                
                % Next property of the node is used when peak points to
                % more then 1 nodes.
                %                       Prev
                % previous node#1 <------------- Peak (Current Node)
                %   |  
                %   |          Next                            Next
                %   - -> ----------------> previuos node#2 --------------> previous node#3                
                
                for vector_index = 1 : length(prev_node_vector) - 1             
                   prev_frame_wnodes(prev_node_vector(vector_index)).nextPointer( prev_frame_wnodes (prev_node_vector(vector_index + 1)) );             
                end
          
                % Get length of previous node to which current node
                % is going to back point
                prev_length= prev_frame_wnodes(prev_node_vector(1)).length; 
                
                current_frame_wnodes = [current_frame_wnodes ...
                                        wnode(wnode_id, frame_index,...
                                        freq_index, prev_length + 1,...
                                prev_frame_wnodes(prev_node_vector(1)) ) ];
             
                %closeset
                close_Set= [close_set prev_node_vector];
                %active_set
                if(peak_index == length(peak))
                   % NaN is added to indicate the start of next frame
                   active_set = [active_set wnode_id NaN];
                else
                   active_set = [active_set wnode_id];
                end
             end                    
          end
       end   % for peak_index = 1 : length(peak)    
       
       % Logic to maintain all nodes in the prev_frame_wnodes for specific 
       % previous duration that is determined by the parameter 
       % frame_chunck_ms. For computation we use frame_chunck_samples
       % derived from frame_chunck_ms.      
       if(frame_chunck_samples < frame_index)
           active_index = find(isnan(active_set),1);
           for prev_frame_index = 1 : active_index - 1
               if(prev_frame_wnodes(prev_frame_index).length >= ...
                                                  threshold_minlen_samples)                                     
                   if(isempty(close_set))
                      % whistle_end_point contains only those nodes that 
                      % satisfies threshold length and is the end node of
                      % the whistle. Nodes in whistle_end_point further 
                      % backpoints to other nodes in whistle
                     
                      whistle_end_point = [whistle_end_point ...
                                      prev_frame_wnodes(prev_frame_index)];
                   elseif(~ any(close_set == prev_frame_index))
                      whistle_end_point = [whistle_end_point ...
                                      prev_frame_wnodes(prev_frame_index)];                   
                   end                   
               end
           end
           
           % prev_frame_wnodes and close_set are updated for processing of
           % next frame
           active_set(1:active_index) = [];           
           prev_frame_wnodes(1:active_index) = [];            
           close_set(find (close_set <= (active_index - 1)) ) = [];
           close_set = close_set - active_index;
       end
       
       % Fake node is added at the end of the each frame. Act as a
       % indicator where the nodes of next frame starts
       current_frame_wnodes = [current_frame_wnodes wnode([],[],[],[],[])];
       
   end  % for frame_index = 1 : Indices.FrameCount                                      

   prev_block_frame_index_samples = prev_block_frame_index_samples + ...
                                                                last_frame;
end  % for index_block = 1 : num_block                  

%---------------------------------------------
% Tracing the nodes backwords
% --------------------------------------------
fprintf('\nPLOTTING the nodes using backpointers... \n\n');
figure ('Name','DP');
subplot(2,1,2)
num_wnodes = length(whistle_end_point);

for whistle_index = num_wnodes: -1 : 1
   plot_freq_matrix = NaN (1, size(power_dB,2) - 1);  
   whistle_recursive_plot(whistle_end_point(whistle_index), ...
                          plot_freq_matrix, bin_Hz, Advance_ms,...
                          size(power_dB,2) - 1);
end

hold off;
text_h1 = title('Dynamic Programming');
set(text_h1,'FontSize',14);
set(gca,'FontSize',12);
xlabel 'time (ms)'
ylabel 'frequency (Hz)'

% Spectrogram
subplot(2,1,1)
f = (0: bin_Hz: header.fs/2 - bin_Hz);
t = (0: size(power_dB,2)) * Advance_ms;
rng = find(f < high_cutoff_frequency_Hz);

h(1) = imagesc(t, f(rng), power_dB(rng,:));
text_h2 = title('Energy dB');
set(text_h2,'FontSize',14);
set(gca,'FontSize',12);
xlabel 'time (ms)'
ylabel 'frequency (Hz)'
set(gca, 'YDir', 'normal');

linkaxes