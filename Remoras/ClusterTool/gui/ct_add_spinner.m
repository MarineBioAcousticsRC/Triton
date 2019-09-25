function spinH = ct_add_spinner(myFigHandle,spinnerPosition)

spinH = com.mathworks.widgets.BusyAffordance;
[~,spinnerH] = javacomponent(spinH.getComponent, [200,10,40,40], myFigHandle);
set(spinnerH,'units','norm', 'position',spinnerPosition)
