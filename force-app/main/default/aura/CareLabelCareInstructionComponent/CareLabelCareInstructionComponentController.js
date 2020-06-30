({
    doInit : function(component,event,helper) {
        var CareSelectedData=component.get('v.CareSelectedData');
        var Careinstruction=component.get('v.Careinstruction');
        var otherInstruction={};
        var careInstructionImage={};
        var tempString=[];
        var ImageList=[];
        for (var i = 0; i < Careinstruction.length; i++) {
            var washInstruction=[];
            for (var j = 0; j < Careinstruction[i].careInsts.length; j++) {
                var item = {
                    "label": Careinstruction[i].careInsts[j],
                    "value": Careinstruction[i].careInsts[j],
                };
                washInstruction.push(item);
                if(Careinstruction[i].othersInsts){
                    otherInstruction[Careinstruction[i].careInsts[j]]=Careinstruction[i].othersInsts[Careinstruction[i].careInsts[j]];
                }
                if(Careinstruction[i].CareInstImage){
                    careInstructionImage[Careinstruction[i].careInsts[j]]=Careinstruction[i].CareInstImage[Careinstruction[i].careInsts[j]];
                }
            }
            Careinstruction[i].options=washInstruction;
            var tempInsList=[];
            var tempIdList=[];
            for (var k = 0; k < CareSelectedData.length; k++) {
                //alert(JSON.stringify(CareSelectedData[k]));
                if(CareSelectedData[k].instGrp=='Retailer Care Code')
                {
                    if(Careinstruction[i].othersInsts){
                       // alert(JSON.stringify(CareSelectedData[k].instDetails.toString()));
                        //alert(Careinstruction[i].othersInsts[CareSelectedData[k].instDetails.toString()]);
                        //tempString.push(Careinstruction[i].othersInsts[CareSelectedData[k].instDetails.toString()]);
                        tempString.push({'instr':CareSelectedData[k].instDetails.toString(),
                                'descr':Careinstruction[i].othersInsts[CareSelectedData[k].instDetails.toString()]
                                });
                    }
                }
                if(CareSelectedData[k].instGrp==Careinstruction[i].washInstructionGroup)
                {
                ImageList.push({
                    'group':Careinstruction[i].washInstructionGroup,
                    'instr':CareSelectedData[k].instDetails.toString(),
                    'descr':careInstructionImage[CareSelectedData[k].instDetails.toString()]
                });
                }
                if(CareSelectedData[k].instGrp==Careinstruction[i].washInstructionGroup)
                {
                    
                    tempInsList.push(CareSelectedData[k].instDetails.toString());
                    tempIdList.push(CareSelectedData[k].careIdList.toString());
                    //Careinstruction[i].careIdList=CareSelectedData[k].careIdList;
                }
            }
            Careinstruction[i].selectedValues=tempInsList;
            Careinstruction[i].careIdList=tempIdList;
        }
        component.set('v.SelectedInstImage',ImageList);
        component.set('v.otherInst',false);
        component.set('v.otherInstruction',otherInstruction);
        component.set('v.selectedcareImage',careInstructionImage);
        component.set('v.Careinstruction',Careinstruction);
        if(tempString.length>0)
        {
            component.set('v.selectedOtherInstruction',tempString);            
            component.set("v.showDiv",true);
        }
        if(tempString.length==0)
        {
            component.set("v.showDiv",false);
        }
    },
    bindSelectedData : function(component, event) {
        var washInstruction=component.find('washInstruction');
        var selectedCareInstList=[];
        if(washInstruction.length){
            for(var i=0;i<washInstruction.length;i++)
            {
                //alert(JSON.stringify(washInstruction[i].get('v.name')));
                var selectedCareInst=new Object();
                selectedCareInst.careIdList=washInstruction[i].get('v.name');
                if(washInstruction[i].get('v.value').length>0){
                    selectedCareInst.instDetails=washInstruction[i].get('v.value');
                    selectedCareInst.instGrp=washInstruction[i].get('v.label');
                    selectedCareInstList.push(selectedCareInst);
                }
            }
        }
        else{
            //alert(JSON.stringify(washInstruction.get('v.name')));
            var selectedCareInst=new Object();
            selectedCareInst.careIdList=washInstruction.get('v.name');
            if(washInstruction.get('v.value').length>0){
                selectedCareInst.instDetails=washInstruction.get('v.value');
                selectedCareInst.instGrp=washInstruction.get('v.label');
                selectedCareInstList.push(selectedCareInst);
            }
        }
        component.set('v.CareSelectedData',selectedCareInstList);
        component.set("v.showDiv",true);
        return selectedCareInstList;
    },
    viewbindSelectedData : function(component, event) {
        
        /*var tempVar=component.get('v.selectedCarTabId');
        for(var i=0;i<10;i++){
            component.set('v.selectedCarTabId','care-'+i);
        }
        component.set('v.selectedCarTabId',tempVar);*/
        var washInstruction=component.find('washInstruction');
       
        var selectedCareInstList=[];
        //alert(washInstruction.length);
        if(washInstruction.length){
            for(var i=0;i<washInstruction.length;i++)
            {
                //alert(JSON.stringify(washInstruction[i].get('v.name')));
                var selectedCareInst=new Object();
                selectedCareInst.careIdList=washInstruction[i].get('v.name');
                if(washInstruction[i].get('v.value').length>0){
                    selectedCareInst.instDetails=washInstruction[i].get('v.value');
                    selectedCareInst.instGrp=washInstruction[i].get('v.label');
                    selectedCareInstList.push(selectedCareInst);
                }
            }
        }
        else{
            //alert(JSON.stringify(washInstruction.get('v.name')));
            var selectedCareInst=new Object();
            selectedCareInst.careIdList=washInstruction.get('v.name');
            if(washInstruction.get('v.value').length>0){
                selectedCareInst.instGrp=washInstruction.get('v.label');
                selectedCareInst.instDetails=washInstruction.get('v.value');
                selectedCareInstList.push(selectedCareInst);
            }
        }
        component.set('v.vaiwCareSelectedData',selectedCareInstList);
        return selectedCareInstList;
    },
    clearData: function(component, event, helper) {
        var params = event.getParam('arguments');
        //params.CloneORClear;
        var washInstruction=component.find('washInstruction');
        if(washInstruction.length){
            for(var i=0;i<washInstruction.length;i++)
            {
                if(params.CloneORClear=='Clear')
                    washInstruction[i].set('v.value','');
            }
        }
        else{
            if(washInstruction.get('v.value').length>0)
            {
                if(params.CloneORClear=='Clear')
                    washInstruction.set('v.value','');
            }
        }
          component.set('v.selectedOtherInstruction','');
          component.set("v.showDiv",false);
    },
    selectedCareInst : function(component, event, helper) {
        var washInstruction=component.find('washInstruction');
        var selectedCareInstList=[];
        for(var i=0;i<washInstruction.length;i++)
        {
            if(washInstruction[i].get('v.value').length>0){
                var selectedCareInst=new Object();
                selectedCareInst.instGrp=washInstruction[i].get('v.label');
                selectedCareInst.instDetails=washInstruction[i].get('v.value');
                selectedCareInstList.push(selectedCareInst);
            }
        }
       
        component.set('v.CareSelectedData',selectedCareInstList);
        component.set("v.viewisCareInstructionmodal",false);
    },
    tabChangeHandler: function (component, event) {
        // alert(event.target.id);
        component.set('v.tabIndex',event.target.id);
        
    },
    handleChange: function (component, event,helper) {
        //alert(JSON.stringify(component.get('v.Careinstruction')));
        // This will contain an array of the "value" attribute of the selected options
        //var allTab=component.find('washInstruction');
        var group=event.getSource().get("v.label");
        var selectedOptionValue = event.getParam("value");
        //alert(JSON.stringify(selectedOptionValue));
        var options=event.getSource().get("v.options");
        var notPrsentValues=[];
        for(var jj=0;jj<options.length;jj++)
        {
            if(!selectedOptionValue.includes(options[jj].label))
            {
                notPrsentValues.push(options[jj].label);
            }
        }
        //alert(JSON.stringify(notPrsentValues));
        var indexvar = event.getSource().get("v.value");
        //var indexvar=event.currentTarget.parentElement.parentElement.id;
        //alert(event.getParam("label"));
        var otherInstruction=component.get('v.otherInstruction');
        
        //alert(group);
        if(group=='Retailer Care Code')
        {
            var tempString=[];
            for(var i=0;i<selectedOptionValue.length;i++){
                if(otherInstruction[selectedOptionValue[i]])
                {
                    // alert('If other Instructions')
                    tempString.push({
                        'instr':selectedOptionValue[i],
                        'descr':otherInstruction[selectedOptionValue[i]]
                    });
                }
                
            }
            component.set('v.selectedOtherInstruction',tempString);
            component.set("v.showDiv",true);
        }
        var selectedcareImage=component.get('v.selectedcareImage');
        var ImageList=component.get('v.SelectedInstImage');
		var removedIdList=[];
        if(selectedOptionValue.length>0)
        {
            for(var i=0;i<selectedOptionValue.length;i++)
            {
                if(selectedcareImage[selectedOptionValue[i]])
                {
                    var instructionPresent=[];
                    for(var ii=0;ii<ImageList.length;ii++)
                    {
                        if(ImageList[ii].instr ==selectedOptionValue[i])
                        {
                            instructionPresent.push(selectedOptionValue[i]);
                        }
                        if(notPrsentValues.includes(ImageList[ii].instr) && !removedIdList.includes(ii))
                        {
                            removedIdList.push(ii);
                        }
                    }
                    // alert('If other Instructions')
                    if(!instructionPresent.includes(selectedOptionValue[i]))
                    {
                        ImageList.push({
                            'group':group,
                            'instr':selectedOptionValue[i],
                            'descr':selectedcareImage[selectedOptionValue[i]]
                        });
                    }
                }
            }
        }
        else
        {
            for(var ii=0;ii<ImageList.length;ii++)
            {
                if(notPrsentValues.includes(ImageList[ii].instr))
                {
                    removedIdList.push(ii);
                }
            }
        }
        //alert(JSON.stringify(removedIdList));
        for(var idind=removedIdList.length-1;idind>=0;idind--)
        {
            ImageList.splice(removedIdList[idind],1);
        }
        //alert(JSON.stringify(ImageList));
        component.set('v.SelectedInstImage',ImageList);
        
        if(selectedOptionValue==''||selectedOptionValue=='Null')
        {
            helper.tabcolorRemove(component, event,helper);
        }
        else
        {
            helper.tabcolorSel(component, event,helper);
        }
        //component.set("v.showDiv",true);
        //var index = evt.currentTarget.dataset.index;
        var changeTabColorCareInstructionDetails = component.getEvent("changeTabColorCareInstructionDetails");
        changeTabColorCareInstructionDetails.fire(); 
    },
    
})