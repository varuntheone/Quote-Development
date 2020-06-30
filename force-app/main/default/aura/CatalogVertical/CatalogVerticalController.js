({ 
    doInit : function(component, event,helper) 
    { 
       // alert('Working on Side Sizer');
       // alert('hi');
        var id = component.get('v.onselectcustomeid');
    },

    saveproddataNew :function(component, event, helper) {
        var index = event.currentTarget;
        var indexval = index.dataset.record;
        helper.saveToCartNew(component, event, helper,indexval);
    },

    handleCatalogEvent:function(component, event, helper){
       // alert('3');
        var flag = event.getParam("flag");
        if(flag=='fromSizer')
        {
           // alert('4');
            component.set('v.catalogVertical',true);
        }
        
    },
    close:function(component, event, helper)
    {
        alert('hie');
      //component.set('v.isSizerQuickview',false);   
    },
    colorChange: function(component, event, helper){
        var ind=event.target.name;
        var color=event.target.id;
        var completeWrap=component.get('v.completeWrap');
        console.log(JSON.stringify(completeWrap));
        completeWrap[ind].selectedColor = color;
        
        component.set('v.completeWrap',completeWrap);
    },
    renderCart:function(component, event, helper) {
        component.set("v.parentcmp",false);
        component.set("v.isShipcmp",true);
    },
    // code for Saving SO and SOLI by chandana 
    saveproddata :function(component, event, helper) {
        var index = event.currentTarget;
        var indexval = index.dataset.record;
        //alert('indexval>>'+indexval);
        helper.saveToCart(component, event, helper,indexval);
    },
    //code for bulk add to cart by Seema
    bulkAdd: function (component, event, helper) {
        console.log(component.get('v.completeWrap'));
        var completeWrap=component.get('v.completeWrap');
        var bulkCartDataToSave=[];
        var retailerCodeId='';
        for(var i=0;i<completeWrap.length;i++)
        {
            //alert(JSON.stringify(completeWrap[i]));
            for(var j=0;j<completeWrap[i].tempMap.length;j++)
            {
                //alert(JSON.stringify(completeWrap[i].tempMap[j]));
                //alert(completeWrap[i].tempMap[j].value.retailercodeId);
                //alert(completeWrap[i].tempMap[j].quantity);
                //alert(completeWrap[i].tempMap[j].value.priceByCurr);
                //alert(completeWrap[i].tempMap[j].value.custRefModel);
                if(completeWrap[i].tempMap[j].quantity && !completeWrap[i].tempMap[j].value.addedToCart)
                {
                    //alert(completeWrap[i].tempMap[j].value.fullboxQty);
                    //alert(completeWrap[i].tempMap[j].value.boxquantity);
                    //alert(completeWrap[i].tempMap[j]);
                    if(completeWrap[i].tempMap[j].value.fullboxQty && completeWrap[i].tempMap[j].value.boxquantity && (completeWrap[i].tempMap[j].quantity<completeWrap[i].tempMap[j].value.boxquantity || completeWrap[i].tempMap[j].quantity % completeWrap[i].tempMap[j].value.boxquantity!=0))
                    {
                        var result = Math.ceil(completeWrap[i].tempMap[j].quantity/completeWrap[i].tempMap[j].value.boxquantity)*completeWrap[i].tempMap[j].value.boxquantity;
                        if (!confirm("Entered value for Product: "+completeWrap[i].tempMap[j].value.MainettiModelCode+" is not the multiples of Box quantity.\nCan system automatically change to nearest mutiples of box quantity ( "+result+" ) ?"))
                        {
                            return; 
                        }
                        retailerCodeId=completeWrap[i].tempMap[j].value.retailercodeId;
                        var singlecartDataToSave={"color":completeWrap[i].tempMap[j].key,"pricebookId":completeWrap[i].tempMap[j].value.priceBookId,"quantity":result,"cur":completeWrap[i].tempMap[j].value.priceByCurr,"custRefModel":completeWrap[i].tempMap[j].value.custRefModel};
                        bulkCartDataToSave.push(singlecartDataToSave);
                    }
                    else
                    {
                        retailerCodeId=completeWrap[i].tempMap[j].value.retailercodeId;
                        var singlecartDataToSave={"color":completeWrap[i].tempMap[j].key,"pricebookId":completeWrap[i].tempMap[j].value.priceBookId,"quantity":completeWrap[i].tempMap[j].quantity,"cur":completeWrap[i].tempMap[j].value.priceByCurr,"custRefModel":completeWrap[i].tempMap[j].value.custRefModel};
                        bulkCartDataToSave.push(singlecartDataToSave); 
                    }
                }
            }
        }
        //alert(JSON.stringify(bulkCartDataToSave));
        if(bulkCartDataToSave.length>0)
            helper.saveBulkToCart(component, event, helper,retailerCodeId,bulkCartDataToSave);
    },
    quickviewcmp :function(component, event, helper)
    {  
        //alert(component.get('v.completeWrap')[event.currentTarget.name].productfamily);
        if(component.get('v.selectedTab')=='Labels & Tickets')            
        { 
            component.set("v.LabelQuickview",true);
            component.set("v.quickviewedProduct",component.get('v.completeWrap')[event.currentTarget.name]); 
        }
        else
            component.set("v.quickviewedProduct",component.get('v.completeWrap')[event.currentTarget.name]);
        if(component.get('v.completeWrap')[event.currentTarget.name].productfamily.includes('SIZER'))
        {
            component.set("v.sizerIndex",event.currentTarget.name);
            component.set("v.quickviewSizer",true);
        }
        else
        {
            component.set("v.quickview",true);
        }
    },
    SelectLabel :function(component, event, helper)
    {
        component.set("v.quickviewedProduct",component.get('v.completeWrap')[event.currentTarget.name]); 
        component.set("v.quickview",true);
        component.set("v.catalogVertical",false);
        component.set("v.displayPagination",false);
        component.set("v.careLabelOrder",true);

    },
    //function helps to hide the increment and  decrement of number field
    afterRender: function (component, event, helper) {
        this.superAfterRender();
        
        //disable up, down, right, left arrow keys
        window.addEventListener("keydown", function(e) {
            if([37, 38, 39, 40].indexOf(e.keyCode) > -1) {
                e.preventDefault();
            }
        }, false);
        
        //disable mousewheel
        window.addEventListener("mousewheel", function(e) {
            e.preventDefault();
        }, false);
        
        window.addEventListener("DOMMouseScroll", function(e) {
            e.preventDefault();
        }, false);
        
    },
    SizerProduct :function(component, event, helper)
    {  
        component.set("v.sizerIndex",event.target.name);
        component.set("v.catalogVertical",false);
        component.set("v.sizerhanger",true);   
        component.set("v.displayPagination",false);
    },
    
})