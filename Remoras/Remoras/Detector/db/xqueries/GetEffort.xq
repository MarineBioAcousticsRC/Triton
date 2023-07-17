import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

let $tmp := 
<ty:Result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> 
{
(: Find Detections documents that meet criteria, e.g. Site, Deployment :)
let $groups :=
    for $detgroup in %s
        %s (: where clause if applicable :)
    return $detgroup

(: Find Effort within these documents meeting criteria, e.g. SpeciesID :)
for $g in $groups
    let $kinds :=
        for $k in $g/Effort/Kind 
          %s (: where clause if applicable :)
        return $k
return
   if (count($kinds) > 0) then
 <Effort>
  <XML_Document>{base-uri($g)}</XML_Document>
  {$g/Effort/Start}
  {$g/Effort/End}
  {$g/Description}
  {$g/DataSource}
  {$g/Algorithm}
  {$g/QualityAssurance/Description}
  {$g/QualityAssurance/ResponsibleParty}
  {$g/UserID}
  {for $k in $kinds return $k}
</Effort>
  else ()
}
</ty:Result>
return
 %s  (: format $tmp document :)
