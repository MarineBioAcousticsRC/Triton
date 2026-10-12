function SynctoTriton(handles,hObject)
%JAH 12-2023
% sycn Acousonde  Aux tag data to the Triton window
% preference is to the expanded window, but will sync to LTSA as well
global HANDLES sync
if get(handles.pushbutton2,'Value')
    [plot_start,data_start] = SyncAUX2TRITON;
    handles.Auxplot_start_p = sync.Auxplot_start_p ;
    handles.Auxplot_end_p = sync.Auxplot_end_p ;
    handles.index_newstart_p = sync.index_newstart_p ;
    handles.index_newend_p = sync.index_newend_p ;
    
    handles.Auxplot_start_t = sync.Auxplot_start_t ;
    handles.Auxplot_end_t = sync.Auxplot_end_t ;
    handles.index_newstart_t = sync.index_newstart_t ;
    handles.index_newend_t = sync.index_newend_t ;
    
    handles.Auxplot_start_x = sync.Auxplot_start_x ;
    handles.Auxplot_end_x = sync.Auxplot_end_x ;
    handles.index_newstart_x = sync.index_newstart_x ;
    handles.index_newend_x = sync.index_newend_x ;
    
    handles.Auxplot_start_i = sync.Auxplot_start_i ;
    handles.Auxplot_end_i = sync.Auxplot_end_i ;
    handles.index_newstart_i = sync.index_newstart_i ;
    handles.index_newend_i = sync.index_newend_i ;
    guidata(hObject, handles);
    
    if (sync.Auxplot_start_p ~= data_start)||(sync.Auxplot_start_t ~= data_start)||(sync.Auxplot_start_x ~= data_start)||(sync.Auxplot_start_i ~= data_start)
        PlotMTdata(handles)
        if get(handles.checkbox4,'Value')
            PlotANNOdata(handles)
        end
    
    end
    
end