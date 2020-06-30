({
    doInit : function(component,event,helper) {
        var sizelist=component.get('v.sizelist');
        for(var i=0;i<sizelist.length;i++)
        {
            sizelist[i].selectedsizechart=false;
            if(sizelist[i].Id==component.get('v.sizeChartData').Id)
                sizelist[i].selectedsizechart=true;
        }
    },
    selectedSize:function(component,helper,event){
        var sizechartdata=component.get('v.sizelist');   
        for (var i = 0; i <sizechartdata.length; i++) {
            if (sizechartdata[i].selectedsizechart == true) {
                component.set("v.sizeChartData",sizechartdata[i]);               
            }
        }  
    },
    viewselectedSize:function(component,helper,event){
        var sizechartdata=component.get('v.sizelist');   
        for (var i = 0; i <sizechartdata.length; i++) {
            if (sizechartdata[i].selectedsizechart == true) {
                component.set("v.viewSizeChartData",sizechartdata[i]);               
            }
        }  
    },
    clearData: function(component, event, helper) {
    },
    handleSelected: function(component, event, helper) {
        var changeTabColorSizeChart = component.getEvent("changeTabColorSizeChart");
		changeTabColorSizeChart.fire();
        
        var checkvalue = component.find("checknames");
        var resetValue = false;
        if (Array.isArray(checkvalue)) {
            checkvalue.forEach(function(checkbox){
                checkbox.set('v.value', resetValue);
            });  
        }
        else {
            checkvalue.set('v.value', resetValue);
        }
        event.getSource().set("v.value",true);
    }
})