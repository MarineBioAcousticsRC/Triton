function lt_lVis_plotLabels_options
global HANDLES

%%controls where labels are plotted
if HANDLES.display.ltsa.Value
    lt_lVis_plot_LTSA_labels
end

if HANDLES.display.specgram.Value
    lt_lVis_plot_WAV_labels
end

if HANDLES.display.timeseries.Value
    lt_lVis_plot_TS_labels
end


    