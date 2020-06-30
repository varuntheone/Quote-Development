({ 
    doInit : function(component, event,helper,page) 
    {
        //helper.GetcustomInfoid(component, event, helper);
        //var res = helper.pickListVal(component,component.get("v.SelectedRetailer"),'Retailer_Code_Hidden__c','Order_Country__c');
        //helper.getCartCount(component, event, helper);
        helper.GetcustomInfoidNew(component, event, helper);
        helper.productListNew(component, event, helper);
        //helper.getCartCount(component, event, helper);
    },
    cartCount: function (component, event, helper) {
        helper.getCartCount(component, event, helper);
    },
    Search: function(component, event, helper) 
    {
        component.set("v.page",1)
        helper.productSearchNew(component, event, helper);
    },
    Shipcmp:function(component, event, helper) {
        component.set("v.parentcmp",false);
        component.set("v.isShipcmp",true);
    },
    selectTab : function(component, event, helper) 
    {
        /*component.set("v.showSpinner",true);
        helper.toCheckSORetailer(component, event, helper,event.getSource().get('v.id'));  
        component.set("v.viewbulk",true);
        component.set("v.selectedFamily",'NULL');
        component.set("v.displayPagination",true);
        component.set("v.catalogVertical",true);
        component.set("v.catalogOrder",false);
        component.set("v.sizerhanger",false);
        component.set("v.careLabelOrder",false);*/
        component.set("v.showSpinner",false); 
        component.set("v.viewbulk",false);
        component.set("v.selectedFamily",'NULL');
        component.set("v.displayPagination",false);
        component.set("v.catalogVertical",false);
        component.set("v.catalogOrder",false);
        component.set("v.sizerhanger",false);
        component.set("v.careLabelOrder",false);
        
    },
    pageChange: function(component, event, helper) {
        //var spinner = component.find('spinner');
        //$A.util.toggleClass(spinner, "slds-hide");
        var page = component.get("v.page") || 1;
        var direction = event.getParam("direction");
        page = direction === "previous" ? (page - 1) : (page + 1);
        component.set("v.page",page);
        
        if(component.get("v.isSearch"))
        {
            helper.productSearch(component, event, helper);
        }
        else
        {
            helper.toGetTabData(component, event, helper,component.get("v.selectedTab"));
        }
    },
    /*Shipcmp:function(component, event, helper) {
        component.set("v.parentcmp",false);
        component.set("v.isShipcmp",true);
    },*/
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
    OrderToCompany:function(component, event, helper)
    {
        var compName = event.getSource().get("v.value");
        helper.pickListVal(component,compName,'Order_Country__c','Preferred_Currency__c');
    },
    preferredCurrency:function(component, event, helper)
    {
        component.set('v.selectedFamily','NULL');
        var templist = [];
        component.set('v.fieldList',templist);
    },
    handleCatalogEvent:function(component, event, helper){
        var flag = event.getParam("flag");
        if(flag=='BlockRetailer')
        {
            component.set('v.cartFlag',true);
        }
        else if(flag=='fromSizer')
        {  
            helper.productSearch(component, event, helper);
        }
        else if(flag=='allSizerRemoved' && !component.get('v.CartCount'))
        {
            component.set('v.cartFlag',false);
        }
    },
    /*bulkAdd:function(component,event,helper)
    {
        var bulkadd='';
        if(component.get('v.selectedTab')=='Hanger Business')            
        {
            bulkadd = component.find("hangerBulkaddId");
        }
        else if(component.get('v.selectedTab')=='Flexible Packaging')
        {
            bulkadd = component.find("fexyBulkaddId");
        }
            else if(component.get('v.selectedTab')=='TLA')
            {
                bulkadd = component.find("tlaBulkaddId");
            }
                else if(component.get('v.selectedTab')=='EAS & RFID')
                {
                    bulkadd = component.find("rfidBulkaddId");
                }
                    else if(component.get('v.selectedTab')=='Labels & Tickets')
                    {
                        bulkadd = component.find("labelBulkaddId");
                    }
        var status=bulkadd.getBulkData();
    },*/
    UploadImage:function(component, event, helper){
        
        component.set('v.searchKeyword','Tcg');
        component.set("v.page",1)
        helper.productSearch(component, event, helper);        
    }
})