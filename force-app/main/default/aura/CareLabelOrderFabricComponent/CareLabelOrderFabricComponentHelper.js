({
	deletedFabfun:function(component,event,helper,clliId){
        alert('hi');
        var action1 = component.get("c.deletedFab");
        action1.setParams({
            "clliId":clliId
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                
            }
            else if(state === 'ERROR'){
                alert('ERROR OCCURED.'+JSON.stringify(response.getError()));
            }
        })
        $A.enqueueAction(action1);
    },
})