({
    doInit : function(component,event,helper) {
        var Excareinstruction=component.get('v.Excareinstruction');
        //alert(JSON.stringify(Excareinstruction));
        var ExcareInstruction=component.find('ExcareInstruction').get('v.options');
        for (var i = 0; i <Excareinstruction.length; i++) {
            
            var item = {
                "label": Excareinstruction[i].Description__c,
                "value": Excareinstruction[i].Description__c
            };
            ExcareInstruction.push(item);
        }
        var exCareSelectedData=component.get('v.exCareSelectedData');
        //alert(component.get('v.exCareSelectedData'));
        component.set('v.excareInstructionList',exCareSelectedData);
        if(exCareSelectedData && exCareSelectedData.length>0)
            component.set('v.tableview',true);
        //component.set('v.selectedposition',exCareSelectedData.position);
    },
    handleExcareChange : function(component,event,helper) {
        var Excareinstruction=component.get('v.Excareinstruction');
        var ExcareInstruction=component.find('ExcareInstruction').get('v.options');
        for (var i = 0; i <Excareinstruction.length; i++) {
            
            var item = {
                "label": Excareinstruction[i].Description__c,
                "value": Excareinstruction[i].Description__c
            };
            ExcareInstruction.push(item);
        }
        var exCareSelectedData=component.get('v.exCareSelectedData');
        //alert(component.get('v.exCareSelectedData'));
        component.set('v.selectedValues',exCareSelectedData.ExcareInstructions);
        component.set('v.selectedposition',exCareSelectedData.position);
    },
    addCareInstruction: function (component, event) {
        var exCare=component.find('ExcareInstruction').get('v.value');
        var pos=component.find('ddexcarename').get('v.value');
        if(!exCare || !pos)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: 'Select both the values',
                type: "warning"
            });
            toastEvent.fire();
            return;
        }
        var excareInstructionList=component.get('v.excareInstructionList');
        if(!excareInstructionList){
            excareInstructionList=[];
        }
        for(var i=0;i<excareInstructionList.length;i++){
            if(excareInstructionList[i].exCareInstruction==exCare)
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Warning",
                    message: 'You cannot select same ExCare Instruction with different Position',
                    type: "warning"
                });
                toastEvent.fire();
                return;
            }
        }
        excareInstructionList.push({'exCareInstruction':exCare,'position':pos});
        component.set('v.excareInstructionList',excareInstructionList);
        component.set('v.tableview',true);
         var changeTabColorExcareInstructions = component.getEvent("changeTabColorExcareInstructions");
		changeTabColorExcareInstructions.fire();
        
    },
    removeRow: function(component, event, helper){
        var excareInstructionList=component.get('v.excareInstructionList');
        var selectedItem = event.getSource().get("v.name");
        var deletedCLLIIdList=component.get('v.deletedCLLIIdList');
        //alert(JSON.stringify(deletedFabfun));
        if(!deletedCLLIIdList)
            deletedCLLIIdList=[];
        if(excareInstructionList[selectedItem].excareId)
            deletedCLLIIdList.push(excareInstructionList[selectedItem].excareId);
        component.set('v.deletedCLLIIdList',deletedCLLIIdList);
        //alert(component.get('v.deletedCLLIIdList'));
        excareInstructionList.splice(selectedItem, 1);
        component.set("v.excareInstructionList", excareInstructionList);
        // helper.deletedFabfun(component, event, helper,clliId);
        //alert(excareInstructionList.length);
        if(excareInstructionList.length==0)
        {
             component.set('v.tableview',false);
        }
    },
    handleChange: function (component, event) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        
        component.set('v.position',true);
        //alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
    },
    closeExcareInstructionModel : function(component, event, helper) {
        component.set("v.viewisExCareInstructionmodal",false);
    },
    selectedExCareInst : function(component, event, helper) {
        component.set("v.exCareSelectedData", component.get("v.excareInstructionList")); 
    },
    viewselectedExCareInst : function(component, event, helper) {
        //alert(JSON.stringify(component.get("v.excareInstructionList")));
        component.set("v.viewExCareSelectedData", component.get("v.excareInstructionList")); 
    },
    /*selectedExCareInst : function(component, event, helper) {
        /*if(!component.get('v.selectedposition')){
            alert('Position is not selected');
            return;
        }
        if(!component.get('v.selectedValues') || component.get('v.selectedValues').length<1){
            alert('Excare Instruction is missing');
            return;
        }//
        var exCareSelectedData=new Object();
        exCareSelectedData.position=component.get('v.selectedposition');
        exCareSelectedData.ExcareInstructions=component.get('v.selectedValues');
        exCareSelectedData.exCareIdList=component.get('v.exCareSelectedData.exCareIdList');
        component.set('v.exCareSelectedData',exCareSelectedData);
        return exCareSelectedData;
    },*/
    /*viewselectedExCareInst : function(component, event, helper) {
        var exCareSelectedData=new Object();
        exCareSelectedData.position=component.get('v.selectedposition');
        exCareSelectedData.ExcareInstructions=component.get('v.selectedValues');
        exCareSelectedData.exCareIdList=component.get('v.exCareSelectedData.exCareIdList');
        //alert(JSON.stringify(exCareSelectedData.ExcareInstructions));
        //alert(JSON.stringify(exCareSelectedData.exCareIdList));
        component.set('v.viewExCareSelectedData',exCareSelectedData);
        return exCareSelectedData;
    },*/
    clearData: function(component, event, helper) {
        component.set('v.excareInstructionList',[]);
        component.set('v.selectedposition',[]);
        component.set('v.tableview',false);
    },
    getSelectedPositionValue: function(component, event, helper) {
        var picklist=component.find('ddexcarename');
        var picklistvalue=picklist.get('v.value');
    }
    
})