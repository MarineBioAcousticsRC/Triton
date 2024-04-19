import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

%s

<ty:Result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Detections>
  {
    for $det at $p in %s 
	
	(: conditions on Detections group :)
	%s
  	return  
  	   for $detection in $det/%s/Detection  (: OnEffort/OffEffort :)
  	   (: conditions on individual Detections :)
  	   %s
	   return $detection
		
	

  }
</Detections>

</ty:Result>