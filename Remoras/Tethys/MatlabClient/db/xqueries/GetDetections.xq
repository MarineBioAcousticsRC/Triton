import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";


let $xmldocument := 0  (: first document :)
let $xmldocs := ()     (: no documents so far :)

let $detections := for $item in ( 
    for $det at $p in %s 
	let $xmldocument := $xmldocument + 1
	let $xmldocs := ($xmldocs, $det/DataSource)
	(: conditions on Detections group :)
	%s 
  	return  
  	   for $detection in $det/%s/Detection  (: OnEffort/OffEffort :)
  	   (: conditions on individual Detections :)
  	   %s 
	   return
		(: Return the Detection entry augmented with 
                   an index indicating its position :)
	   	element { fn:QName(fn:namespace-uri($detection),
	 			   fn:name($detection)) }		
	   	{$detection/(@*|node()),
                 <idx>{xs:integer($p)}</idx> }
	)
  return $item 

let $sources := distinct-values(for $d in $detections return $d/idx)

return 
<ty:Result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Detections>
  {(: Rewrite the detections mapping each detection to a deployment/ensemble :)
   for $detection in $detections
   order by $detection/Start
   return
     <Detection>
      {$detection/Start}
      {$detection/End}
      %s<idx>{index-of(($sources), $detection/idx)}</idx>
     </Detection>
  }
</Detections>
<Sources>
  {
   (: Write out the information for the deployment/ensembles :)
   for $source in $sources
     return 
      collection("Detections")[xs:decimal($source)]/ty:Detections/DataSource
  }
</Sources>
</ty:Result>
