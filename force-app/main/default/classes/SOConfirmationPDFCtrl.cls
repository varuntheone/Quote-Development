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
                 (Select Id, Name, Product_Code__c, Product_Description__c, Quantity__c,Product_image_url__c
                 from Sales_Order_Line_Items__r) from Sales_Order__c where id =: SORec.Id];
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
        /*isprice = SORec.Retailer_Code1__r.Show_Price_in_SO_Confirmation_PDF__c;
        system.debug('SORec.Vertical__c: '+SORec.Vertical__c);
        if(SORec.Vertical__c =='EAS & RFID' || SORec.Vertical__c =='Labels & Tickets')
        {
            isLabelOrRFID = true;
        }
        else
            isLabelOrRFID = false;
        System.debug('isLabelOrRFID::'+isLabelOrRFID);
        
        if(con.Customer_Information__c==null)
            con.Customer_Information__c=SORec.Supplier__c;
        
        List<Retailer_Related_Data__c> retailerRelatedData = [select id,name,Manufacturer_Factory_Code__c,Supplier_Code__c,Retailer_Code__r.Show_Special_Terms_and_Conditions_PDF__c,Retailer_Code__r.Special_Terms_and_Conditions__c from Retailer_Related_Data__c where Retailer_Code__c =: SORec.Retailer_Code1__c AND Customer_Information__c =:con.Customer_Information__c ];
        if(retailerRelatedData.size()>0)
        {
            ManufacturerCode = retailerRelatedData[0].Manufacturer_Factory_Code__c;
            SupplierCode = retailerRelatedData[0].Supplier_Code__c;
        }
        retailerCode =retailerRelatedData[0].Retailer_Code__r.Show_Special_Terms_and_Conditions_PDF__c;
        //retailerCode =false;
        
        if(retailerCode == true)
            termConditions =retailerRelatedData[0].Retailer_Code__r.Special_Terms_and_Conditions__c;
        retailerName = SORec.Retailer_Code1__r.name;*/
        SOLIRecs = new List<Sales_Order_Line_Items__c>();
        
        String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();
        currentRequestURL = currentRequestURL.substringBefore('/apex/');
        currentRequestURL += '/apex/SOLICustomerPDF?Id=';
        System.debug('Current request URL: ' + currentRequestURL);
        
        for(Sales_Order_Line_Items__c soli:SORec.Sales_Order_Line_Items__r) {
            
            /*soli.Product_name__c = soli.Price_Specification_Book_Product__r.Name;
            soli.Product_Description__c = soli.Price_Specification_Book_Product__r.Description__c;
            soli.Charge_Type__c = soli.Products__r.Product_Type__c;
            soli.Family__c = soli.Products__r.Product_Family__c;
            soli.Pieces__c = soli.Price_Specification_Book_Product__r.Order_UOM__c;
            soli.Price_100_pcs__c = soli.Price_100_pcs__c!=null?soli.Price_100_pcs__c:'0';
            
            soli.DEPT_DESC__c = currentRequestURL+soli.Id;
            System.debug('soli.DEPT_DESC__c: ' + soli.DEPT_DESC__c);
            System.debug('Inside iteration :  :: '+soli.Price_100_pcs_c__c);
            total += (decimal.valueOf(soli.Supply_Quantity__c)  * decimal.valueOf(soli.Price_100_pcs__c))/100;*/
            
            SOLIRecs.add(soli);
        }
        total=total.setScale(2);
        System.debug('total :: '+total);
        System.debug('SOLIRecs :: '+SOLIRecs);
        shipToAdd = new Ship_Bill_Address__c();
        shipToAdd = [select name,Factory_Name__c,City__c,State__c,Country__c,Postcode__c 
                    from Ship_Bill_Address__c where id =: SORec.Ship_to_Address__c];
        
        billToAdd = new Ship_Bill_Address__c();
        billToAdd = [select name,Factory_Name__c,City__c,State__c,Country__c,Postcode__c 
                    from Ship_Bill_Address__c where id =: SORec.Bill_to_Address__c];
        
        /*if(SORec.Company__c.contains('Suzhou'))
        {
            suzhouFlag = true;
            buyerToAdd = new Ship_Bill_Address__c();
            buyerToAdd = [select name,Factory_Name__c,Address_1__c,Address_2__c,City__c,State__c,Country__c,Postcode__c,Contact__c,Tel_No__c,Fax_No__c,Email_Address__c from Ship_Bill_Address__c where id =: SORec.Buyer_Address__c];
            
            invToAdd = new Ship_Bill_Address__c();
            invToAdd = [select name,Factory_Name__c,Address_1__c,Address_2__c,City__c,State__c,Country__c,Postcode__c,Contact__c,Tel_No__c,Fax_No__c,Email_Address__c from Ship_Bill_Address__c where id =: SORec.Invoice_To_Address__c];
        }*/
        
    }
    
}