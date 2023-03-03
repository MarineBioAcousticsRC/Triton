import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";

<Result>
{ 
for $cal in collection("Calibrations")/ty:Calibration
    %s
    return $cal
}
</Result>

