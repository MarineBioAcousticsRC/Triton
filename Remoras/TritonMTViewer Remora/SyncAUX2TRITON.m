function [plot_start,data_start] = SyncAUX2TRITON(out,handles)
% Run this function as a button-up function when the "SYNC TO LTSA" button
% is selected.
%
%   1. Detect desired time limits to sync with (ax1), and AUX to sync (ax2)
%   2. Compare ax1 to HANDLES.subplt for ltsa, spectrogram, and save the limits as plot_start/end
%   3. Set the current axis to these limits
%%

currentFolder = pwd ; %Save current directory before running PlotMTdata.m


%1. Detect desired time limits to sync with, and AUX to sync
global HANDLES PARAMS

while PARAMS.pick.button.value == 0
    uiwait(msgbox({'  Turn on Pickxyz in Triton Message Window' '         then click OK.'})) ;
end

savalue = get(HANDLES.display.ltsa,'Value');
tsvalue = get(HANDLES.display.timeseries,'Value');
spvalue = get(HANDLES.display.spectra,'Value');
sgvalue = get(HANDLES.display.specgram,'Value');

if sgvalue
    ax1 = HANDLES.subplt.specgram ;
elseif tsvalue
   ax1 = HANDLES.subplt.timeseries ;
elseif savalue
    ax1 = HANDLES.subplt.ltsa ;
else
end

%2. Compare ax1 to HANDLES.subplt for ltsa, spectrogram, etc and get

%       plot_start and plot_end values.
        if ax1 == HANDLES.subplt.ltsa
            plot_start = datenum(datevec(PARAMS.ltsa.plot.dnum)+[2000 0 0 0 0 0]) ;
            plot_tseg = PARAMS.ltsa.tseg.hr * 3600 ; %+PARAMS.ltsa.tave*PARAMS.ltsa.plotStartBin ;
            plot_end = datenum( datevec(plot_start) + [0 0 0 0 0 plot_tseg] ) ;
        	data_start = datenum( PARAMS.ltsa.start.dvec + [2000 0 0 0 0 0] );
        	data_end = datenum( PARAMS.ltsa.dvecEnd(end,:)  + [2000 0 0 0 0 0] );
            %fprintf('Time for ALL LTSA data:\n\tStart:\t%s\n\tEnd:\t%s\n\n', datestr(LTSAdata_start),  datestr(LTSAdata_end)) ;
        elseif ax1==HANDLES.subplt.specgram || ax1==HANDLES.subplt.timeseries || ax1==HANDLES.subplt.spectra
            plot_start = datenum(datevec(PARAMS.plot.dnum)+[2000 0 0 0 0 0]);
            plot_tseg = PARAMS.tseg.sec ;
            plot_end = datenum( datevec(plot_start)+ [0 0 0  0 0 plot_tseg] ) ;
            data_start = datenum( PARAMS.start.dvec + [2000 0 0 0 0 0] );
            data_end = datenum( datevec(PARAMS.end.dnum)  + [2000 0 0 0 0 0] );
        else
            fprintf('Your selection for the desired axis was not recognized.\n')
        end

%3.  Set time limits of AUX  
global all sync
        sync.index_newstart_p = find(all.press(:,end)>= plot_start,1,'first') ;
        sync.index_newend_p = find(all.press(:,end) >= plot_end,1,'first') ;
        sync.Auxplot_start_p = all.press(sync.index_newstart_p);
        sync.Auxplot_end_p = all.press(sync.index_newend_p) ;
        
        sync.index_newstart_t = find(all.temp(:,end)>= plot_start,1,'first') ;
        sync.index_newend_t = find(all.temp(:,end) >= plot_end,1,'first') ;
        sync.Auxplot_start_t = all.temp(sync.index_newstart_t);
        sync.Auxplot_end_t = all.temp(sync.index_newend_t) ; 
        
        sync.index_newstart_x = find(all.xaccel(:,end)>= plot_start,1,'first') ;
        sync.index_newend_x = find(all.xaccel(:,end) >= plot_end,1,'first') ;
        sync.Auxplot_start_x = all.xaccel(sync.index_newstart_x);
        sync.Auxplot_end_x = all.xaccel(sync.index_newend_x) ;
        
        sync.index_newstart_i = find(all.iaccel(:,end)>= plot_start,1,'first') ;
        sync.index_newend_i = find(all.iaccel(:,end) >= plot_end,1,'first') ;
        sync.Auxplot_start_i = all.iaccel(sync.index_newstart_i);
        sync.Auxplot_end_i = all.iaccel(sync.index_newend_i) ;
       
        
        
cd(currentFolder) %Change directory back to original folder.
end

  
    
    
    
    
    