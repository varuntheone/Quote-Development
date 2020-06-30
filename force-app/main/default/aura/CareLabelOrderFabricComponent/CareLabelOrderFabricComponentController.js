({
    doInit : function(component, event, helper) {  
        component.set("v.selectedArray", component.get('v.selectedArray1'));
    },
    getSelectedcompValue:function(component, event, helper){
        var picklist=component.find('ddcompanyname');
        var picklistvalue=picklist.get('v.value');
    },
    getSelectedfabValue:function(component, event, helper){
        var picklist=component.find('ddfabricname');
        var picklistvalue=picklist.get('v.value');
    },
    addFabric: function(component, event, helper){
        var compselectedval =component.find("component").get("v.value");
        var fabselectedval =component.find("fabric").get("v.value");
        var val =parseInt(component.find("compval").get("v.value"));
        /*if(!compselectedval){
            alert('Select Component value');
            return;
        }
        else */
        if(!fabselectedval){
           var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: 'Select Fabric value',
                type: "warning"
            });
            toastEvent.fire();
            return;
        }
        else if(!val || val>100){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: 'Enter valid Value',
                type: "warning"
            });
            toastEvent.fire();
            return;
        }else if(val<=0)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: 'Entered Value is not valid',
                type: "warning"
            });
            toastEvent.fire();
            return;
        }
        var selectedfabval=component.get("v.selectedArray");
        var indexToAdd=-1;
        if(selectedfabval.length>0){
            var valueValidation=val;
            for(var i=0;i<selectedfabval.length;i++)
            {
                if(selectedfabval[i].Component==compselectedval)
                {
                    valueValidation+=selectedfabval[i].value;
                    if(selectedfabval[i].Fabric==fabselectedval)
                    {
                       indexToAdd=i;
                    }
                }
            }
            if(valueValidation>100)
            {
                if(compselectedval){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Warning",
                        message: 'Value for the Component \''+compselectedval+'\' is exceeding 100%',
                        type: "warning"
                    });
                    toastEvent.fire();
                    return;
                }
            }            
        }
        if(indexToAdd==-1){
            selectedfabval.push({
                'Component':compselectedval ,
                'Fabric': fabselectedval,
                'value':val
            });
        }
        if(indexToAdd>-1){
            selectedfabval[indexToAdd].value+=val;
        }
        component.set("v.selectedArray", selectedfabval);
        component.set("v.Displayfabval", true);
        component.find('component').set('v.value', '');
        component.find('fabric').set('v.value', '');
        component.find('compval').set('v.value', '');
        
        var changeTabColorFabricComponent = component.getEvent("changeTabColorFabricComponent");
		changeTabColorFabricComponent.fire();
    },
    selectedval: function(component, event, helper){
        var selectedfabval=component.get("v.selectedArray");
        var fabselectedval =component.find("fabvalue").get("v.value");
        var optioval =component.find("ddfabricname").get("v.value");
        var val =component.find("compval").get("v.value");
        
        var isError = false;
         var total=0;
        if(selectedfabval.length > 0){
            selectedfabval.forEach(function(item){
                var fabricName = item.Fabric;
                var matname =item.Component;
                var compare=(optioval==matname);
                if(fabselectedval != '' && val > 0 && fabricName == fabselectedval && compare!=true){
                    var existValue = parseFloat(item.value);
                    var curVal = parseFloat(val);
                    var sum = existValue + curVal;
                    total=parseFloat(total)+sum;
                    if(total>100){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "mode":'error',
                            "title": "error!",
                            "message": "The record has Value is More than 100%."
                        });
                        toastEvent.fire(); 
                         isError = true;
                    }else{
                          isError = false;
                    }  
                    /*if((parseFloat(item.value)+parseFloat(val)) > 100){
                        alert('Value Is MoreThan 100%');
                        isError = true;
                       /* var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "mode":'error',
                            "title": "Success!",
                            "message": "The record has been updated successfully."
                        });
                        toastEvent.fire();*/
                   // }*/
                }else{
                    if(fabselectedval != '' && val > 0 && fabricName == fabselectedval && compare==true)
                    {
                        var existValue = parseFloat(item.value);
                        var curVal = parseFloat(val); 
                        isError = true;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Warning",
                            message: 'This material already  having value',
                            type: "warning"
                        });
                        toastEvent.fire();
                        return;
                       }
                }
            });                
        }
        if(total<=100 && !isError){
           component.set("v.Displayfabval", true);
              component.find('compval').set('v.value', '');
            if(fabselectedval!='' && optioval !='' && val !='' ){
                selectedfabval.push({
                    'Fabric':fabselectedval ,
                    'Component': optioval,
                    'value':val
                });
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Warning",
                    message: 'please select all fields',
                    type: "warning"
                });
                toastEvent.fire();
                return;
            }
        }
        component.set("v.selectedArray", selectedfabval);
        var compareval =component.get("v.selectedArray").length;
        component.find('ddfabricname').set('v.value', '');
        component.find('ddcompanyname').set('v.value', '');
        component.find('compval').set('v.value', '');
        var test=component.get("v.selectedArray");
    },
    bindFabricData: function(component,event,helper)
    {
        component.set("v.viewedSelectedArray", component.get("v.selectedArray")); 
        component.set("v.FabricSelectedData", component.get("v.selectedArray")); 
    },
    viewbindFabricData: function(component,event,helper)
    {
        component.set("v.viewedSelectedArray", component.get("v.selectedArray")); 
    },
    removeRow: function(component, event, helper){
        var selectedArray = component.get("v.selectedArray");
        var selectedItem = event.getSource().get("v.name");
        var deletedCLLIIdList=component.get('v.deletedCLLIIdList');
        //alert(JSON.stringify(deletedFabfun));
        if(!deletedCLLIIdList)
            deletedCLLIIdList=[];
        if(selectedArray[selectedItem].fabId)
            deletedCLLIIdList.push(selectedArray[selectedItem].fabId);
        component.set('v.deletedCLLIIdList',deletedCLLIIdList);
        //alert(component.get('v.deletedCLLIIdList'));
        selectedArray.splice(selectedItem, 1);
        component.set("v.selectedArray", selectedArray);
        // helper.deletedFabfun(component, event, helper,clliId);
        alert(selectedArray.length);
        if(selectedArray.length==0){
           component.set("v.Displayfabval", false); 
        }
    },
    selectedval: function(component, event, helper){
        component.set('v.FabricSelectedData',component.get("v.selectedArray"));
    },
    clearData: function(component, event, helper) {
        component.set("v.selectedArray", []);
        component.set("v.Displayfabval", false);
    }
})