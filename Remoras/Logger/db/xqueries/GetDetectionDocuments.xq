import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

<ty:Result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
{
let $groups :=
	for $detgroup in %s
		%s (: where clause if applicable :)
		return $detgroup
		
for $g in $groups
    let $names :=
        for $k in $g/Effort/Kind 
          %s (: where clause if applicable :)
        return 
		base-uri($k)

return
    (:Return base URIs in <URI> element:)
    for $name in distinct-values($names)
    return
        <URI>{$name}</URI>
}
</ty:Result>

