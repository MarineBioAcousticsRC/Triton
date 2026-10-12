function    t = d3audio_sensor_offset(recdir,prefix)
%
%    t = d3audio_sensor_offset(recdir,prefix)
%     A positive number means that the sensor recording
%     started t seconds after the audio recording.
%     To align audio and sensor data, add t seconds to
%     the sensor time axis.

[cw,rw] = d3getcues(recdir,prefix) ;
[cs,rs] = d3getcues(recdir,prefix,'swv') ;
t = (rs-rw)+(cs(1,2)-cw(1,2)) ;
