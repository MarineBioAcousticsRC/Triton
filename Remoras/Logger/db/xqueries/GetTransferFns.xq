import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";

<Result>
{ for $tf in collection("TransferFunctions")/ty:TransferFunction
    %s
    return
    $tf
}
</Result>

