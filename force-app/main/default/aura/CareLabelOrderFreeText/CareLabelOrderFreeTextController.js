({
    FreetextData:function(component, event, helper) {
        //var Style_Number=component.find("StyleNumber").get("v.value");
        var freetextData=new Object();
        freetextData.freeTextId=component.get("v.freeTextId");
        freetextData.StyleNumber=component.get("v.StyleNumber");
        freetextData.RNNumber=component.get("v.RNNumber");
        freetextData.LotNumber=component.get("v.LotNumber");
        freetextData.careinstruct=component.get("v.careinstruct");
        freetextData.SupplierNumber=component.get("v.SupplierNumber");
        freetextData.LabellingCode=component.get("v.LabellingCode");
        freetextData.PackagingCode=component.get("v.PackagingCode");
        freetextData.SeasonMonth=component.get("v.SeasonMonth");
        freetextData.SeasonYear=component.get("v.SeasonYear");
        freetextData.ItemNumber=component.get("v.ItemNumber");
        
        component.set("v.freetextData",freetextData);        
       
    },
    viewFreetextData:function(component, event, helper) {
        //var Style_Number=component.find("StyleNumber").get("v.value");
        var freetextData=new Object();
        freetextData.freeTextId=component.get("v.freeTextId");
        freetextData.StyleNumber=component.get("v.StyleNumber");
        freetextData.RNNumber=component.get("v.RNNumber");
        freetextData.LotNumber=component.get("v.LotNumber");
        freetextData.careinstruct=component.get("v.careinstruct");
        freetextData.SupplierNumber=component.get("v.SupplierNumber");
        freetextData.LabellingCode=component.get("v.LabellingCode");
        freetextData.PackagingCode=component.get("v.PackagingCode");
        freetextData.SeasonMonth=component.get("v.SeasonMonth");
        freetextData.SeasonYear=component.get("v.SeasonYear");
        freetextData.ItemNumber=component.get("v.ItemNumber");
        
        component.set("v.viewFreetextData",freetextData);        
       
    },
    clearData: function(component, event, helper) {
        //component.set("v.freeTextId",'');
        component.set("v.StyleNumber",'');
        component.set("v.RNNumber",'');
        component.set("v.LotNumber",'');
        component.set("v.careinstruct",'');
        component.set("v.SupplierNumber",'');
        component.set("v.LabellingCode",'');
        component.set("v.PackagingCode",'');
        component.set("v.SeasonMonth",'');
        component.set("v.SeasonYear",'');
        component.set("v.ItemNumber",'');
    },
    onblurFreeText: function(component, event, helper)
    {
        var changeTabColorFreeText = component.getEvent("changeTabColorFreeText");
		changeTabColorFreeText.fire();
    }
})