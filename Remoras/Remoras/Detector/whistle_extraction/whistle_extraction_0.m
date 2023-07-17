function [ ] = whistle_extraction_0 (Signal, Fs, Advance_ms, Length_ms)

% File:         whistle_extraction_0.m
% Description:  Given the signal vector, sampling frequency,
%               frame advance and frame length extracts the whisltes
%               [NOTE: not yet done!!!!]

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

%Convert to dB
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
wnode_id = 1;               % unique id for wnodes to be created
active_wnode = cell(1);     % list of wnodes
active = zeros(1,1);        % tracking array for previous time frame wnodes 
                            % (freq index) 
process = zeros(1,1);       % tracking array for current processing wnodes 
                            % (freq index)
wnode_created = zeros(1,1); % stores wnode_id for previous time frame

%for t_index = 1 : 3
for t_index = 1 : sample_time_length
    peak = find( power_dB(1:700, t_index) >= 10 );
    process = peak;    
    [active_wnode wnode_id wnode_created] = create_node_0 (process, ...
                   t_index, wnode_id, active, active_wnode, wnode_created);
    active = process;    
end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f = (0: bin_Hz: Fs/2 - bin_Hz);
t = (0: sample_time_length-1) * Advance_ms;
rng = find(f < high_cutoff_frequency);

figure ('Name','DP');

h(1) = imagesc(t, f(rng), power_dB(rng,:));
title('Energy dB');
colorbar
xlabel 'time (ms)'
ylabel 'frequency (Hz)'
set(gca, 'YDir', 'normal');
%linkprop(cell2mat(get(h, 'Parent')), {'XLim', 'YLim'});
% lock zooms together
%linkaxes( cell2mat(get(h, 'Parent')), 'xy');

time = toc;   % Keep track of execution time for algorithm in seconds
fprintf('\nEXECUTION TIME: %d sec\n\n',time);


