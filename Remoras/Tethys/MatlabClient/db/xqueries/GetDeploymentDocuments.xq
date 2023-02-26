import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";


let $names :=
	for $doc in %s
		%s
		return 
		base-uri($doc)

return
<ty:Result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    {(:Return base URIs in <URI> element:)
    for $name in $names
    return
        <URI>{$name}</URI>
    }
</ty:Result>

