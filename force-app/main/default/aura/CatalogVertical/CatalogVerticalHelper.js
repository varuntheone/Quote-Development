({
    saveToCartNew: function (component, event, helper, index) {
        var custid = component.get("v.onselectcustomeid");
        var productData = component.get("v.completeWrap")[index];        
        var qty = productData.Quantity_temp_holder__c;
        //var qty = component.get("v.qtyEntered");
        //alert("qty:" + qty);
        if (!qty || qty <= 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: 'Entered Product Quantity is not valid',
                type: "warning"
            });
            toastEvent.fire();
            return;
        }

        var actionsave = component.get("c.saveToCart");
        actionsave.setParams({
            userId: custid,
            product: productData,
            quantity: qty
        });
        actionsave.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("Product added to cart successfully:" + response.getReturnValue());
                if (response.getReturnValue()) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "success",
                        message: 'Product added to cart successfully',
                        type: "success"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    }
                    else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            message: 'Add to cart Failed',
                            type: "Error"
                        });
                        toastEvent.fire();
                    }
            } else if (state === "ERROR") {                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(actionsave);
        component.set("qty", '');
    },

    saveToCart: function(component, event,helper,index) 
    {
        var custid = component.get("v.onselectcustomeid");
        var indexarr = index.split(" ");
        var completeData = component.get("v.completeWrap");
        //alert(JSON.stringify( component.get("v.completeWrap")));
        var productData = component.get("v.completeWrap")[indexarr[0]];
        //alert('productData.tempMap[indexarr[1]]>>'+JSON.stringify(component.get("v.completeWrap")[indexarr[0]]));
        var retailercode = productData.tempMap[indexarr[1]].value.retailercodeId;
        var qty = productData.tempMap[indexarr[1]].quantity;
        var boxquantity=productData.tempMap[indexarr[1]].value.boxquantity;
        //alert('boxquantity>>'+productData.tempMap[indexarr[1]].value.boxquantity);
        var fullboxQty=productData.tempMap[indexarr[1]].value.fullboxQty;
        var currency = productData.tempMap[indexarr[1]].value.priceByCurr;
        var custRefModel = productData.tempMap[indexarr[1]].value.custRefModel;

        // alert('qty>>'+boxquantity);
        if(!qty || qty<=0)
        {         
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Warning",
                message: 'Entered Product Quantity is not valid',
                type: "warning"
            });
            toastEvent.fire();
            return;
        }
        else if(fullboxQty && boxquantity && (qty<boxquantity || qty % boxquantity!=0))
        {
              //code to add the upper limit of box quantity by chandana 
             var result = Math.ceil(qty/boxquantity)*boxquantity;
            //alert('result '+result);
            if(result)
            {
                if (!confirm("Entered value for Product: "+component.get("v.completeWrap")[indexarr[0]].Name+" is not the multiples of Box quantity.\nCan system automatically change to nearest mutiples of box quantity ( "+result+" ) ?"))
                {
                    return; 
                }
                productData.tempMap[indexarr[1]].quantity = result;
                completeData[indexarr[0]] = productData;
                component.set("v.completeWrap", completeData);                
            }
            else
            {
                return;
            }            
        }  
        var PricebookData = productData.tempMap[indexarr[1]].value.priceBookId;
        var actionsave = component.get("c.saveSO");
        actionsave.setParams({ 
            customerData : custid,
            retailercode : retailercode,
            quantity : productData.tempMap[indexarr[1]].quantity,
            priceBookProId : PricebookData,
            priceByCurr : currency,
            custRefModel : custRefModel
        });
        actionsave.setCallback(this, function(response) 
                               {
                                   var state = response.getState();
                                   console.log('state:::'+state);
                                   if (state === "SUCCESS") 
                                   {
                                       //alert("Product added to cart successfully:"+response.getReturnValue());
                                       var toastEvent = $A.get("e.force:showToast");
                                       toastEvent.setParams({
                                           title: "success",
                                           message: 'Product added to cart successfully',
                                           type: "success"
                                       });
                                       toastEvent.fire();
                                       $A.get('e.force:refreshView').fire();
                                   }
                                   else if (state === "INCOMPLETE") {
                                       // do something
                                   }
                                       else if (state === "ERROR") 
                                       {
                                           var toastEvent = $A.get("e.force:showToast");
                                           toastEvent.setParams({
                                               title: "Error",
                                               message: 'Add to cart Failed',
                                               type: "Error"
                                           });
                                           toastEvent.fire();
                                           var errors = response.getError();
                                           if (errors) {
                                               if (errors[0] && errors[0].message) {
                                                   console.log("Error message: " + 
                                                               errors[0].message);
                                               }
                                           } 
                                           else {
                                               console.log("Unknown error");
                                           }
                                       }
                               });
        $A.enqueueAction(actionsave);  
        component.set("qty",'');
    },
    saveBulkToCart: function(component, event,helper,retailerCodeId,bulkCartDataToSave) 
    {
        //alert(JSON.stringify(bulkCartDataToSave));
        var custid = component.get("v.onselectcustomeid");
        var actionSaveBulk = component.get("c.addBulkProduct");
        actionSaveBulk.setParams({ 
            custid : custid,
            retailerCodeId : retailerCodeId,
            bulkCartDataToSave : JSON.stringify(bulkCartDataToSave),
        });
        actionSaveBulk.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state:::'+response.getState());
            if (state === "SUCCESS") 
            {
                //alert("Product added to cart successfully:"+response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "success",
                    message: 'Product added to cart successfully',
                    type: "success"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") 
                {
                    //alert(JSON.stringify(response.getError()));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: 'Add to cart Failed',
                        type: "Error"
                    });
                    toastEvent.fire();
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(actionSaveBulk);  
    }
})