function    t = audio_sensor_offset(tag)
%
%    t = audio_sensor_offset(tag)
%     A positive number means that the sensor recording
%     started t seconds after the audio recording.
%     To align audio and sensor data, add t seconds to
%     the sensor time axis.

try
   loadcal(tag,'CUETAB') ;
   t = diff(CUETAB(1,[2 7])) ;
catch
   t = 0.029 ;    % this is only good for md13_134a - need to fix
end
