public Class SOConfirmationPDFCtrl
{
    public String SOId {get;set;}
    public Sales_Order__c SORec {get;set;}   
    public String ManufacturerCode {get;set;}
    public String SupplierCode {get;set;}
    public date SOcreatedDate{get;set;}
    public Ship_Bill_Address__c shipToAdd{get;set;}
    public Ship_Bill_Address__c billToAdd{get;set;}
    public Ship_Bill_Address__c buyerToAdd{get;set;}
    public Ship_Bill_Address__c invToAdd{get;set;}
    public List<Sales_Order_Line_Items__c> SOLIRecs {get;set;}
    public String retailerName{get;set;}
    public boolean retailerCode {get;set;}
    public string termConditions  {get;set;}
    public Boolean suzhouFlag{get;set;}
    public boolean isLabelOrRFID{get;set;}
    public String isSoliLink{get;set;}
    public String CI{get;set;}
    public boolean isprice{get;set;}
    public Decimal total{get;set;}

    public List<shipWrapper> shipWrapList{get;set;}
    
    public SOConfirmationPDFCtrl(ApexPages.StandardController controller) {
        System.debug('inside SOPDF::');
        String curcAccRecordId = controller.getRecord().id; 
        System.debug('curcAccRecordId::'+curcAccRecordId);
        SOId = curcAccRecordId;
        isSoliLink='0';
        isSoliLink = ApexPages.currentPage().getParameters().get('sol');	//assinged in SalesOrderTable js controller
        System.debug('isSoliLink::'+isSoliLink);
        this.fetchSOData();
    }

    public void fetchSOData() {   
        total = 0.00;
        //total = total.setScale(5);
        SORec = new Sales_Order__c();
        /*Contact con = UtilityClass.getCurrentUserContact();
        if(con == null)
            con = new contact();
        if(SOId == null)
        {
            SORec = UtilityClass.getSORecordAsCart(con.Customer_Information__c);
        }
        System.debug('con 1::'+con);*/
        if(SORec.Id == null)
        {
            SORec.Id = SOId;
        }
        //SORec.Id = 'a0X2D000000jkUmUAI';
        SORec = [Select Id, Name, CreatedDate, Company__c, Currency__c, Delivery_Instruction__c, Expected_Delivery_Date__c,
                 Status__c, Bill_to_Address__c, Ship_to_Address__c, Transportation_Details__c, Shipping_Mark__c,
                 (Select Id, Name,Product_Name__c, Product_Code__c, Product_Description__c, Quantity__c,Product_image_url__c,
                 Product_Type__c,Product__c from Sales_Order_Line_Items__r) from Sales_Order__c where id =: SORec.Id];
        System.debug('SORec 2::'+SORec);
        System.debug('SORec Sales_Order_Line_Items__r::'+SORec.Sales_Order_Line_Items__r);
        
        SOId = SORec.Name;
        SOcreatedDate = SORec.CreatedDate.date();
        String shipMark='';
        if(SORec.Shipping_Mark__c!=null)
        {
            integer latestSpaceIndex = 0;
            for(integer i=0;i<SORec.Shipping_Mark__c.length();i++)
            {
                //math.mod(50, i)==0?shipMark+=SORec.Shipping_Mark__c.charAt(i)+'/n\n':shipMark+=SORec.Shipping_Mark__c.charAt(i);
                if(SORec.Shipping_Mark__c.substring(i, i+1) == '\n')
                    latestSpaceIndex = i;
                
                if((i - latestSpaceIndex)!=0 && math.mod(i - latestSpaceIndex, 70)==0)
                {
                    shipMark+=SORec.Shipping_Mark__c.substring(i, i+1)+'\n';
                }
                else
                {
                    shipMark+=SORec.Shipping_Mark__c.substring(i, i+1);
                }
            }
            SORec.Shipping_Mark__c=shipMark;
        }
        
        String trans='';
        if(SORec.Transportation_Details__c!=null)
        {
            integer latestSpaceIndex = 0;
            for(integer i=0;i<SORec.Transportation_Details__c.length();i++)
            {
                //math.mod(50, i)==0?shipMark+=SORec.Shipping_Mark__c.charAt(i)+'/n\n':shipMark+=SORec.Shipping_Mark__c.charAt(i);
                if(SORec.Transportation_Details__c.substring(i, i+1) == '\n')
                    latestSpaceIndex = i;
                
                if((i - latestSpaceIndex)!=0 && math.mod(i - latestSpaceIndex, 70)==0)
                {
                    trans+=SORec.Transportation_Details__c.substring(i, i+1)+'\n';
                }
                else
                {
                    trans+=SORec.Transportation_Details__c.substring(i, i+1);
                }
            }
            SORec.Transportation_Details__c=trans;
        }
        
        SORec.Transportation_Details__c = SORec.Transportation_Details__c!=null?SORec.Transportation_Details__c:'';
        SORec.Shipping_Mark__c = SORec.Shipping_Mark__c!=null?SORec.Shipping_Mark__c:'';
        
        SOLIRecs = new List<Sales_Order_Line_Items__c>();
        
        String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();
        currentRequestURL = currentRequestURL.substringBefore('/apex/');
        currentRequestURL += '/apex/SOLICustomerPDF?Id=';
        System.debug('Current request URL: ' + currentRequestURL);
        
        
        //Get bundleProducts.
        Set<Id> parentProducts = new Set<Id>();
        if (SORec.Sales_Order_Line_Items__r <> null && SORec.Sales_Order_Line_Items__r.size() > 0) {
            for (Sales_Order_Line_Items__c soLineItm : SORec.Sales_Order_Line_Items__r) {
                parentProducts.add(soLineItm.Product__c);
            }
        }
        List<Product_Bundle__c> prodBundleList = [SELECT Parent_Product__c,Child_Product__c,Quantity__c,
                                                  Child_Product__r.Name,Child_Product__r.ProductCode,
                                                  Child_Product__r.Description,Child_Product__r.Product_image_url__c
                                                  FROM Product_Bundle__c WHERE Parent_Product__c <> null AND
                                                  Child_Product__c <> null AND Parent_Product__c IN :parentProducts];
        system.debug('prodBundleList:'+prodBundleList);
        system.debug('prodBundleListSize:'+prodBundleList.Size());
        shipWrapList = new List<shipWrapper>();

        for(Sales_Order_Line_Items__c soli:SORec.Sales_Order_Line_Items__r) {            
            List<Product_Bundle__c> prodBundSubList = new List<Product_Bundle__c>();
            shipWrapper shipWrap = new shipWrapper();
            shipWrap.soli = soli;
            
            if(soli.Product_Type__c == 'Bundle'){
                for(Product_Bundle__c prdBund : prodBundleList){
                    if(soli.Product__c == prdBund.Parent_Product__c){
                        Product_Bundle__c prodBundle = prdBund.clone(true, true, false, false);
                        prodBundle.Quantity__c = prdBund.Quantity__c * soli.Quantity__c;
                        prodBundSubList.add(prodBundle);
                    }
                }
                shipWrap.bundleProducts = prodBundSubList;
            }
            shipWrapList.add(shipWrap);            
            SOLIRecs.add(soli);
            
        }
        system.debug('shipWrapList:'+shipWrapList);

        total=total.setScale(2);
        System.debug('total :: '+total);
        System.debug('SOLIRecs :: '+SOLIRecs);
        shipToAdd = new Ship_Bill_Address__c();
        shipToAdd = [select name,Factory_Name__c,City__c,State__c,Country__c,Postcode__c 
                    from Ship_Bill_Address__c where id =: SORec.Ship_to_Address__c];
        
        billToAdd = new Ship_Bill_Address__c();
        billToAdd = [select name,Factory_Name__c,City__c,State__c,Country__c,Postcode__c 
                    from Ship_Bill_Address__c where id =: SORec.Bill_to_Address__c];
        
    }

    public class shipWrapper{        
        public Sales_Order_Line_Items__c soli {get; set;}        
        public List<Product_Bundle__c> bundleProducts {get; set;}
    }
    
}