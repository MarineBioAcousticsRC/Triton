import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";
import module namespace lib="http://tethys.sdsu.edu/XQueryFns" at "Tethys.xq";

<ty:Result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
{for $loc in %s
%s
return
    for $posninfo in $loc/Localizations/Localization
    %s
    return $posninfo
           
}
</ty:Result>
