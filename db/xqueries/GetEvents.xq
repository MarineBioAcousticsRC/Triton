import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

<ty:Result>
{
  for $event in collection("events")
    %s
  return 
  <Event>
    {$event}
  </Event>
}
</ty:Result>
