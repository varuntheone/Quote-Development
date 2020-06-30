/*=====================================================================================================
Author     : Seema S Yaladagi
Company    : CRMIT Solution Pvt Ltd.
Date       : 10th March 2019
Description: CatalogOrderController class helps to handle following 

* Handle the three operation search keyword,tabset,pagination,Retailer code,Selected Family,order to Company,
Preferred Currency.
* Fetch the ,Product,Product description from and Price_Specification_Book_Product__c Object.
* Save to the Sales_Order__c Order and Sales_Order_Line_Items__c of object with Cart as Record type.

=======================================================================================================*/
public without sharing class CatalogOrderController 
{    
     public Static Id CartRecordType = Schema.SObjectType.Sales_Order__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
   
    //This code handle the three operation search keyword,tabset,pagination.
    @AuraEnabled
    public static completeProductWrapper searchProducts(String SearchKeyword,String selectedTab,Integer offsetValue,String retailerCode,String selectedFamily, String orderToCompany, String preCurrency,Decimal pageNumber)
    {
        system.debug('retailerCode:'+retailerCode+' SearchKeyword: '+SearchKeyword+' selectedTab: '+selectedTab+' selectedFamily: '+selectedFamily+' orderToCompany: '+orderToCompany+' preCurrency: '+preCurrency);
        completeProductWrapper compProdWrap=new completeProductWrapper();
        //to get company label from its API name
        Map<String,String> companyAPIandName = UtilityClass.getOrderToCompanyPicklist(true);    
        //to get company API Name from its label
        Map<String,String> companyNameandAPI = UtilityClass.getOrderToCompanyPicklist(false);
        
        //to get currency API Name from its label
        Map<String,String> currencyAPIandName = UtilityClass.getPreferredCurrencyPicklist(true);
        system.debug('currencyAPIandName>>>>>>'+currencyAPIandName);
        
        //to get currency API Name from its label
        Map<String,String> currencyNameandAPI = UtilityClass.getPreferredCurrencyPicklist(false);
        system.debug('currencyNameandAPI>>>>>>'+currencyNameandAPI);
        
        //getting customer's contact data to get preferred currency and order to company
        Contact con = getcostomerinfo(retailerCode);
        system.debug('con from getcostomerinfo>>>>>>'+con);
        if(preCurrency!=null && preCurrency!='NULL' && preCurrency!='')
        {
            //override preferred currency in contact(not updating) if user selectes currency in catalog
            con.Preferred_Currency__c = preCurrency;
            
        }
        else
        {
            preCurrency = con.Preferred_Currency__c;    //if currency is not selected in catalog, taking preferred currency
        }
        if(currencyNameandAPI.containskey(preCurrency))
        {
            preCurrency=currencyNameandAPI.get(preCurrency);
        }
        
        //Query starts
        String qryPbProNames='select Name from Price_Specification_Book_Product__c';    //to get unique set of product name within the given limit
        String qryPbProDetails='select Id, Name,Product_Family__c,Price_100pcs__c, BOX_QTY__c, Order_to_Company__c, CurrencyIsoCode, Product_image_url__c, Description__c,color__c,Product_Unique_ID__c,Product_Unique_ID__r.Name,Product_Unique_ID__r.Business_Vertical__c,Product_Unique_ID__r.Product_Family__c,Retailer_Code__r.name, Retailer_Code__r.Full_Box_Order__c,Retailer_Code__r.Show_Price_in_Order__c, Retailer_Code__c,Customer_Ref_Model__c,Order_UOM__c,Variable_Data_Product__c,Sizer_Print__c from Price_Specification_Book_Product__c'; //to get the details of price specification book based on the name provided by qryPbProNames
        String qryPbProWhereClause = ' where Active__c = true AND Product_Unique_ID__r.Status__c = \'Active\' AND Hidden_Catalogue__c=false';
        
        String qryCount=' select COUNT_DISTINCT(Name) totalCount from Price_Specification_Book_Product__c where Active__c = true AND Product_Unique_ID__r.Status__c = \'Active\' AND Hidden_Catalogue__c=false ';
        if(orderToCompany!=null && orderToCompany!='NULL' && orderToCompany!='' && companyNameandAPI.containskey(orderToCompany))
        {
            orderToCompany=companyNameandAPI.get(orderToCompany);
            qryPbProWhereClause+=' AND Order_to_Company__c =\''+orderToCompany+'\'';
            qryCount+=' AND Order_to_Company__c =\''+orderToCompany+'\'';
        }
        else
        {
            orderToCompany = con.Order_to_Company__c;
            qryPbProWhereClause+=' AND Order_to_Company__c =\''+orderToCompany+'\'';    //if company is not selected in catalog, taking prferred order to company
            qryCount+=' AND Order_to_Company__c =\''+orderToCompany+'\'';
        }
        if(selectedTab!=null)
        {
            qryPbProWhereClause+=' AND Product_Unique_ID__r.Business_Vertical__c =\''+selectedTab+'\'';
            qryCount+=' AND Product_Unique_ID__r.Business_Vertical__c =\''+selectedTab+'\'';
        }
        if(retailerCode!=null)
        {
            qryPbProWhereClause+='AND Retailer_Code__c=\''+retailerCode+'\'';
            qryCount+=' AND Retailer_Code__c=\''+retailerCode+'\'';
        }
        if(selectedFamily!=null && selectedFamily!='NULL')
        {
            qryPbProWhereClause+=' AND Product_Family__c =\''+selectedFamily+'\'';
            qryCount+=' AND Product_Family__c =\''+selectedFamily+'\'';
            /*if(selectedFamily.contains('SIZER'))
            {
                qryPbProWhereClause+=' AND Variable_Data_Product__c=\'Yes\'';
                qryCount+=' AND Variable_Data_Product__c=\'Yes\'';
            }*/
        }
        if(preCurrency!=null && preCurrency!='NULL')
        {
            qryPbProWhereClause+=' AND id IN(select Price_Book_Product__c from Price_Product_by_Currency__c  where CurrencyIsoCode=\''+preCurrency+'\')';
            qryCount +=' AND id IN(select Price_Book_Product__c from Price_Product_by_Currency__c  where CurrencyIsoCode=\''+preCurrency+'\')';
        }
        if(selectedFamily!=null && selectedFamily!='NULL')
        {
            qryCount+=' AND Product_Unique_ID__c IN (select Id from Product__c  where Status__c = \'Active\' AND Product_Family__c =\''+selectedFamily+'\' AND Business_Vertical__c =\''+selectedTab+'\')';
            
        }
        else
        {
            //qryPbProWhereClause+=' AND Product_Unique_ID__c IN \''+SearchKeyword+'\'';
            qryCount+=' AND Product_Unique_ID__c IN (select Id from Product__c  where Status__c = \'Active\' AND Business_Vertical__c =\''+selectedTab+'\')';
        }
        //this part should always be at last to prevent offset and limit attribute during search by product names
        if(SearchKeyword!=null && SearchKeyword!='')
        {
            system.debug('inside keyword>>'+SearchKeyword); 
            SearchKeyword ='%'+searchKeyWord +'%';
            qryPbProWhereClause+=' AND Keywords__c Like \''+SearchKeyword+'\'';
            qryCount+=' AND Keywords__c Like \''+SearchKeyword+'\'';
        }
        
        qryPbProNames=qryPbProNames + qryPbProWhereClause;
        
        Integer pageRecSize = 36;
        if(SearchKeyword!=null && SearchKeyword!='')  //if searching product name don't include limit and offset
        {
            pageNumber = 1;pageRecSize = 200;  //changes specific to search by name feature
            qryPbProNames=qryPbProNames + ' group by Name order by name ';
        }
        else
        {
            qryPbProNames=qryPbProNames + ' group by Name order by name Limit 36 OFFSET:offsetValue';
        }
        
        //code added for Pagination
        System.debug('pageNumber:'+pageNumber);
        Integer offset = ((Integer)pageNumber - 1) * pageRecSize;
        System.debug('qryCount>>>>>>'+qryCount);
        compProdWrap.totalRecords = Integer.valueOf(Database.query(qryCount)[0].get('totalCount'));
        compProdWrap.pageSize = pageRecSize;
        compProdWrap.pageNumber = (Integer) pageNumber;
        
        system.debug('qryPbProNames>>>>>>'+qryPbProNames);
        //executing Query to get price specification book names
        List<AggregateResult> listofprodNames = (Database.query(qryPbProNames));    //to get unique names of products with given limit in query
        
        Set<String> pruductNameSet = new Set<String>();
        for(AggregateResult priceBookPro : listofprodNames)
        {
            system.debug('priceBookPro>>'+String.valueOf(priceBookPro.get('Name')));
            pruductNameSet.add( String.valueOf( priceBookPro.get('Name') ) );
        }
        system.debug(' pruductNameSet>> '+pruductNameSet.size()+' '+pruductNameSet);
        
        //executing Query to get price specification book details
        qryPbProDetails=qryPbProDetails + qryPbProWhereClause+ ' AND Name IN:pruductNameSet order by name';
        system.debug('qryPbProDetails>>>>>>'+qryPbProDetails);
        List<Price_Specification_Book_Product__c> listofprod = (Database.query(qryPbProDetails));   //to get unique names of products with given limit in query
        system.debug('listofprod>>>>>>'+listofprod.size());
        
        //Special Price Starts | currency of customer and ERP customer code should match in product price by currency object
        Id billToRecordType = Schema.SObjectType.Ship_Bill_Address__c.getRecordTypeInfosByName().get('Bill To').getRecordTypeId();  //bill to records id of billtoShip to address object
        Id billToLockedRecordType = Schema.SObjectType.Ship_Bill_Address__c.getRecordTypeInfosByName().get('Bill to Locked').getRecordTypeId();  //bill to records id of billtoShip to address object
        
        //to store customer code from Bill to ERP link object
        Set<String> ERPCustomerCode = new Set<String>();    
        //to store pricebook id from listofprod list
        Set<Id> pbIdSet = new Set<Id>();    
        for(Bill_to_ERP_Link__c ERPLink:[select id, name, Local_ERP_customer_code__c, Local_ERP_Payment_Code__c, Locked_Bill_To__c, Mainetti_Company__c, Mainetti_Company__r.name from Bill_to_ERP_Link__c where Parent_Bill_To__r.Customer_Information__c =:con.Customer_Information__c and Parent_Bill_To__r.Is_Default__c =: true AND (Parent_Bill_To__r.RecordTypeId =: billToRecordType OR Parent_Bill_To__r.RecordTypeId =: billToLockedRecordType)])
        {
            ERPCustomerCode.add(ERPLink.Local_ERP_customer_code__c);
        }
        //Special Price ends
        
        //Normal Price starts
        for(Price_Specification_Book_Product__c psbp : listofprod)
        {
            system.debug('psbp>>'+psbp);
            pbIdSet.add(psbp.Id);
        }
        system.debug('pbIdSet>>>>>>'+pbIdSet);
        system.debug('pbIdSet size>>>>>>'+pbIdSet.size());
        
        Map<Id,List<Price_Product_by_Currency__c>> pbIdPriceCurrMap = new Map<Id,List<Price_Product_by_Currency__c>>(); //key=> pbsp id and value => product price by currency
        //Map<String,List<String>> mapOfcompAndCurrency = new Map<String,List<String>>(); //#advanced key=> pbsp company name => currency name
        Map<Id,Price_Product_by_Currency__c> pbIdSpecialPriceMap = new Map<Id,Price_Product_by_Currency__c>();  //key=> pbsp id and value => special product price for customer
        for(Price_Product_by_Currency__c procurr : [select id,name, CurrencyIsoCode, Local_ERP_customer_code__c, Price_100_pcs__c, Price_1000_pcs__c,Price_Book_Product__c,Price_Book_Product__r.Order_to_Company__c from Price_Product_by_Currency__c where Price_Book_Product__c IN:pbIdSet])
        {
            /*
String [] currencySplit = con.Preferred_Currency__c.split('-');
String ResCurr = currencySplit[0].trim();
String CurrCode;
if(ResCurr.size()>1)
{
CurrCode = ResCurr[0];
}
*/
            system.debug('con.Preferred_Currency__c '+con.Preferred_Currency__c+' procurr.CurrencyIsoCode '+procurr.CurrencyIsoCode);
            if(con.Preferred_Currency__c.contains(procurr.CurrencyIsoCode) && ERPCustomerCode.contains(procurr.Local_ERP_customer_code__c) )    //if special price is defined for current customer
            {
                pbIdSpecialPriceMap.put(procurr.Price_Book_Product__c,procurr);
            }
            else if(con.Preferred_Currency__c.contains(procurr.CurrencyIsoCode))    //to get normal price in case special price is not there
            {
                if(pbIdPriceCurrMap.containskey(procurr.Price_Book_Product__c))
                {
                    pbIdPriceCurrMap.get(procurr.Price_Book_Product__c).add(procurr);
                }
                else
                {
                    List<Price_Product_by_Currency__c> currList = new List<Price_Product_by_Currency__c>();
                    currList.add(procurr);
                    pbIdPriceCurrMap.put(procurr.Price_Book_Product__c,currList);
                }
            }
            else    //pricebook don't have any record for preferred currency
            {
                system.debug(' currency not found ');
            }
        }
        //Normal Price ends
        //Addedto cart disable functionality
        Map<Id,String> addToCartData=new Map<Id,String>();
        Map<Id,String> addedaslabelData=new Map<Id,String>();
        Map<Id,Decimal> addToCartQuantity=new Map<Id,Decimal>();
        Map<Id,String> prodIdaddedColorListMap=new Map<Id,String>();
        try
        {
            contact contactid=UtilityClass.getCurrentUserContact();
            for(Sales_Order_Line_Items__c soli:[select id,name,Colour__c,Quantity__c,Added_As_a_Label__c,Products__c,Price_Specification_Book_Product__r.id from Sales_Order_Line_Items__c where Sales_Order__r.Retailer_Code1__c=:retailerCode AND Sales_Order__r.RecordType.Name='Cart' AND Sales_Order__r.Supplier__c=:contactid.Customer_Information__c])
            {
                if(soli.Added_As_a_Label__c)
                    addedaslabelData.put(soli.Price_Specification_Book_Product__r.id,soli.Colour__c);
                addToCartData.put(soli.Price_Specification_Book_Product__r.id,soli.Colour__c);
                //addToCartData.put(soli.Price_Specification_Book_Product__r.id,new List<String> {soli.Colour__c,soli.Quantity__c});
                addToCartQuantity.put(soli.Price_Specification_Book_Product__r.id,decimal.valueOf(soli.Quantity__c));
                
                if(prodIdaddedColorListMap.containsKey(soli.Products__c))
                {
                    //prodIdaddedColorListMap.get(soli.Products__c).add(soli.Colour__c);
                    if(soli.Added_As_a_Label__c)
                    {
                        prodIdaddedColorListMap.put(soli.Products__c,'Pending');
                    }
                }
                else
                {
                    if(soli.Added_As_a_Label__c)
                    {
                        prodIdaddedColorListMap.put(soli.Products__c,'Pending');
                    }
                    else
                    {
                        prodIdaddedColorListMap.put(soli.Products__c,'Added');
                    }
                }
            }
            system.debug('addToCartData>>>>'+addToCartData);
        }
        catch(Exception e)
        {
            
        }
    //system.debug();
        List<ProductWrapper> productList = new List<ProductWrapper>(); 
        //to store product family form pricebook product
        Set<String> proFamily= new Set<String>();
        //Set<Id> prodIdSet = new Set<Id>();    //to store product id for counting purpose
        
        //looping through products in the query results
        Map<String,ProductWrapper> productMap = new Map<String,ProductWrapper>();
        if(selectedTab.contains('Hanger'))
        {
            for(Price_Specification_Book_Product__c psbp : listofprod)  
            {
                if(productMap.containskey(psbp.Name))
                {
                    system.debug('psbp name>>'+psbp.Name);
                    ProductWrapper prod = productMap.get(psbp.Name);
                    
                    ProductSecificationWrapper pbdata = new ProductSecificationWrapper();
                    pbdata.proddescription = psbp.Description__c;
                    pbdata.prodid=psbp.Product_Unique_ID__c;
                    pbdata.proImgURL =psbp.Product_image_url__c;
                    pbdata.retailerCodeId =psbp.Retailer_Code__c; 
                    pbdata.retailerCodeName =psbp.Retailer_Code__r.name;
                    pbdata.fullboxQty=psbp.Retailer_Code__r.Full_Box_Order__c;
                    pbdata.boxquantity=psbp.BOX_QTY__c;
                    if(addToCartQuantity.containsKey(psbp.id) && addToCartQuantity.get(psbp.id)!=null)
                    {
                        pbdata.quantity=addToCartQuantity.get(psbp.id);
                    }
                    if(addToCartData.containsKey(psbp.id) && addToCartData.get(psbp.id).contains(psbp.color__c)){
                        pbdata.addedToCart=true;
                    }else
                        pbdata.addedToCart=false;
                    if(addedaslabelData.containsKey(psbp.id) && addedaslabelData.get(psbp.id).contains(psbp.color__c)){
                        pbdata.addedAsLabel=true;
                    }else
                        pbdata.addedAsLabel=false;
                    if(prodIdaddedColorListMap.containsKey(psbp.Product_Unique_ID__c) && (psbp.Product_Family__c.contains('SIZER') || psbp.Product_Family__c.contains('STICKER')))
                    {
                        if(prodIdaddedColorListMap.get(psbp.Product_Unique_ID__c)=='Pending')
                        {
                            pbdata.addedAsLabel=true;
                            
                        }
                        else
                        {
                            pbdata.addedAsLabel=false;
                        }
                        pbdata.addedToCart=true;
                    }
                    pbdata.color=psbp.color__c;
                    pbdata.MainettiModelCode=psbp.Name;
                    pbdata.custRefModel=psbp.Customer_Ref_Model__c;
                    pbdata.priceBookId = psbp.id;
                    pbdata.showPrice=psbp.Retailer_Code__r.Show_Price_in_Order__c;
                    pbdata.UomOrder=psbp.Order_UOM__c;
                    pbdata.vardataproduct=psbp.Variable_Data_Product__c;
                    pbdata.prodFamily=psbp.Sizer_Print__c;
                    //pbdataList.add(pbdata);
                    //if there is a special price in the pricebook for current customer
                    if(pbIdSpecialPriceMap.containskey(psbp.id))    
                    {
                        pbdata.proPrice=pbIdSpecialPriceMap.get(psbp.id).Price_100_pcs__c;
                        pbdata.currencyType=pbIdSpecialPriceMap.get(psbp.id).CurrencyIsoCode;
                        pbdata.priceByCurr=pbIdSpecialPriceMap.get(psbp.id).Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    //if special price is not present for th customer take normal price in preferred currency
                    else if(pbIdPriceCurrMap.containskey(psbp.id))
                    {
                        List<Price_Product_by_Currency__c> currList = pbIdPriceCurrMap.get(psbp.id);
                        pbdata.proPrice=currList[0].Price_100_pcs__c;
                        pbdata.currencyType=currList[0].CurrencyIsoCode;
                        pbdata.priceByCurr=currList[0].Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    prod.ProductDataMap.put( psbp.color__c , pbdata );
                    productMap.put( psbp.Name , prod );
                    system.debug('productMap>>>>>>'+productMap);
                }
                else
                {
                    system.debug('inside else######');
                    ProductWrapper pro = new ProductWrapper();
                    pro.Id =psbp.Product_Unique_ID__c; 
                    //pro.Name =psbp.Product_Unique_ID__r.Name; 
                    pro.Name = psbp.Name;
                    pro.producttype = psbp.Product_Unique_ID__r.Business_Vertical__c;
                    selectedTab = psbp.Product_Unique_ID__r.Business_Vertical__c;
                    pro.productfamily=psbp.Product_Unique_ID__r.Product_Family__c;
                    pro.selectedColor=psbp.color__c;
                    
                    ProductSecificationWrapper pbdata = new ProductSecificationWrapper();
                    pbdata.MainettiModelCode=psbp.Name;
                    pbdata.prodid=psbp.Product_Unique_ID__c;
                    pbdata.custRefModel=psbp.Customer_Ref_Model__c;
                    pbdata.proddescription = psbp.Description__c;
                    pbdata.proImgURL =psbp.Product_image_url__c;
                    pbdata.retailerCodeId =psbp.Retailer_Code__c; 
                    pbdata.retailerCodeName =psbp.Retailer_Code__r.name;
                    pbdata.fullboxQty=psbp.Retailer_Code__r.Full_Box_Order__c;
                    pbdata.boxquantity=psbp.BOX_QTY__c;
                    if(addToCartQuantity.containsKey(psbp.id) && addToCartQuantity.get(psbp.id)!=null)
                    {
                        pbdata.quantity=addToCartQuantity.get(psbp.id);
                    }
                     if(addToCartData.containsKey(psbp.id) && addToCartData.get(psbp.id).contains(psbp.color__c)){
            pbdata.addedToCart=true;
          }else
            pbdata.addedToCart=false;
                    if(addedaslabelData.containsKey(psbp.id) && addedaslabelData.get(psbp.id).contains(psbp.color__c)){
            pbdata.addedAsLabel=true;
          }else
            pbdata.addedAsLabel=false;
                    if(prodIdaddedColorListMap.containsKey(psbp.Product_Unique_ID__c) && (psbp.Product_Family__c.contains('SIZER') || psbp.Product_Family__c.contains('STICKER')))
                    {
                        if(prodIdaddedColorListMap.get(psbp.Product_Unique_ID__c)=='Pending')
                        {
                            pbdata.addedAsLabel=true;
                        }
                        else
                        {
                            pbdata.addedAsLabel=false;
                        }
                        pbdata.addedToCart=true;
                    }
                    pbdata.color=psbp.color__c;
                    pbdata.priceBookId = psbp.id;
                    pbdata.showPrice=psbp.Retailer_Code__r.Show_Price_in_Order__c;
                    pbdata.UomOrder=psbp.Order_UOM__c;
                    pbdata.vardataproduct=psbp.Variable_Data_Product__c;
                    pbdata.prodFamily=psbp.Sizer_Print__c;
                    //pbdataList.add(pbdata);
                    
                    //if there is a special price in the pricebook for current customer
                    if(pbIdSpecialPriceMap.containskey(psbp.id))    
                    {
                        pbdata.proPrice=pbIdSpecialPriceMap.get(psbp.id).Price_100_pcs__c;
                        pbdata.currencyType=pbIdSpecialPriceMap.get(psbp.id).CurrencyIsoCode;
                        pbdata.priceByCurr=pbIdSpecialPriceMap.get(psbp.id).Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    //if special price is not present for th customer take normal price in preferred currency
                    else if(pbIdPriceCurrMap.containskey(psbp.id))
                    {
                        List<Price_Product_by_Currency__c> currList = pbIdPriceCurrMap.get(psbp.id);
                        pbdata.proPrice=currList[0].Price_100_pcs__c;
                        pbdata.currencyType=currList[0].CurrencyIsoCode;
                        pbdata.priceByCurr=currList[0].Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    pro.ProductDataMap.put( psbp.color__c , pbdata );
                    productMap.put( psbp.Name , pro );
                    system.debug('productMap>>>>>>'+productMap);
                }
            }
        }           //for Hanger vertical ENDS
        else{
            for(Price_Specification_Book_Product__c psbp : listofprod)  
            {
                if(productMap.containskey(psbp.Customer_Ref_Model__c))
                {
                    system.debug('psbp name>>'+psbp.Customer_Ref_Model__c);
                    ProductWrapper prod = productMap.get(psbp.Customer_Ref_Model__c);
                    
                    ProductSecificationWrapper pbdata = new ProductSecificationWrapper();
                    pbdata.proddescription = psbp.Description__c;
                    pbdata.prodid=psbp.Product_Unique_ID__c;
                    pbdata.proImgURL =psbp.Product_image_url__c;
                    pbdata.retailerCodeId =psbp.Retailer_Code__c; 
                    pbdata.retailerCodeName =psbp.Retailer_Code__r.name;
                    pbdata.fullboxQty=psbp.Retailer_Code__r.Full_Box_Order__c;
                    pbdata.boxquantity=psbp.BOX_QTY__c;
                    pbdata.color=psbp.color__c;
                    if(addToCartQuantity.containsKey(psbp.id) && addToCartQuantity.get(psbp.id)!=null)
                    {
                        pbdata.quantity=addToCartQuantity.get(psbp.id);
                    }
                    if(addToCartData.containsKey(psbp.id) && addToCartData.get(psbp.id).contains(psbp.color__c)){
                        pbdata.addedToCart=true;
                    }else
                        pbdata.addedToCart=false;
                    if(addedaslabelData.containsKey(psbp.id) && addedaslabelData.get(psbp.id).contains(psbp.color__c)){
                        pbdata.addedAsLabel=true;
                    }else
                        pbdata.addedAsLabel=false;
                    
                    pbdata.MainettiModelCode=psbp.Name;
                    pbdata.custRefModel=psbp.Customer_Ref_Model__c;
                    pbdata.priceBookId = psbp.id;
                    pbdata.showPrice=psbp.Retailer_Code__r.Show_Price_in_Order__c;
                    pbdata.UomOrder=psbp.Order_UOM__c;
                    pbdata.vardataproduct=psbp.Variable_Data_Product__c;
                    pbdata.prodFamily=psbp.Sizer_Print__c;
                    //pbdataList.add(pbdata);
                    
                    //if there is a special price in the pricebook for current customer
                    if(pbIdSpecialPriceMap.containskey(psbp.id))    
                    {
                        pbdata.proPrice=pbIdSpecialPriceMap.get(psbp.id).Price_100_pcs__c;
                        pbdata.currencyType=pbIdSpecialPriceMap.get(psbp.id).CurrencyIsoCode;
                        pbdata.priceByCurr=pbIdSpecialPriceMap.get(psbp.id).Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    //if special price is not present for th customer take normal price in preferred currency
                    else if(pbIdPriceCurrMap.containskey(psbp.id))
                    {
                        List<Price_Product_by_Currency__c> currList = pbIdPriceCurrMap.get(psbp.id);
                        pbdata.proPrice=currList[0].Price_100_pcs__c;
                        pbdata.currencyType=currList[0].CurrencyIsoCode;
                        pbdata.priceByCurr=currList[0].Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    prod.ProductDataMap.put( psbp.color__c , pbdata );
                    productMap.put( psbp.Customer_Ref_Model__c , prod );
                    system.debug('productMap>>>>>>'+productMap);
                }
                else
                {
                    system.debug('inside else######');
                    ProductWrapper pro = new ProductWrapper();
                    pro.Id =psbp.Product_Unique_ID__c; 
                    //pro.Name =psbp.Product_Unique_ID__r.Name; 
                    pro.Name = psbp.Name;
                    pro.producttype = psbp.Product_Unique_ID__r.Business_Vertical__c;
                    selectedTab = psbp.Product_Unique_ID__r.Business_Vertical__c;
                    pro.productfamily=psbp.Product_Unique_ID__r.Product_Family__c;
                    pro.selectedColor=psbp.color__c;
                    
                    ProductSecificationWrapper pbdata = new ProductSecificationWrapper();
                    pbdata.custRefModel=psbp.Customer_Ref_Model__c;
                    pbdata.prodid=psbp.Product_Unique_ID__c;
                    pbdata.proddescription = psbp.Description__c;
                    pbdata.proImgURL =psbp.Product_image_url__c;
                    pbdata.retailerCodeId =psbp.Retailer_Code__c; 
                    pbdata.retailerCodeName =psbp.Retailer_Code__r.name;
                    pbdata.fullboxQty=psbp.Retailer_Code__r.Full_Box_Order__c;
                    pbdata.boxquantity=psbp.BOX_QTY__c;
                    pbdata.color=psbp.color__c;
                    if(addToCartQuantity.containsKey(psbp.id) && addToCartQuantity.get(psbp.id)!=null)
                    {
                        pbdata.quantity=addToCartQuantity.get(psbp.id);
                    }
                    if(addToCartData.containsKey(psbp.id) && addToCartData.get(psbp.id).contains(psbp.color__c)){
            pbdata.addedToCart=true;
          }else
            pbdata.addedToCart=false;
                    if(addedaslabelData.containsKey(psbp.id) && addedaslabelData.get(psbp.id).contains(psbp.color__c)){
            pbdata.addedAsLabel=true;
          }else
            pbdata.addedAsLabel=false;
                    
                    pbdata.MainettiModelCode=psbp.Name;
                    pbdata.priceBookId = psbp.id;
                    pbdata.showPrice=psbp.Retailer_Code__r.Show_Price_in_Order__c;
                    pbdata.UomOrder=psbp.Order_UOM__c;
                    pbdata.vardataproduct=psbp.Variable_Data_Product__c;
                    pbdata.prodFamily=psbp.Sizer_Print__c;
                    //pbdataList.add(pbdata);
                    
                    //if there is a special price in the pricebook for current customer
                    if(pbIdSpecialPriceMap.containskey(psbp.id))    
                    {
                        pbdata.proPrice=pbIdSpecialPriceMap.get(psbp.id).Price_100_pcs__c;
                        pbdata.currencyType=pbIdSpecialPriceMap.get(psbp.id).CurrencyIsoCode;
                        pbdata.priceByCurr=pbIdSpecialPriceMap.get(psbp.id).Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    //if special price is not present for th customer take normal price in preferred currency
                    else if(pbIdPriceCurrMap.containskey(psbp.id))
                    {
                        List<Price_Product_by_Currency__c> currList = pbIdPriceCurrMap.get(psbp.id);
                        pbdata.proPrice=currList[0].Price_100_pcs__c;
                        pbdata.currencyType=currList[0].CurrencyIsoCode;
                        pbdata.priceByCurr=currList[0].Id;
                        
                        proFamily.add(psbp.Product_Family__c);
                    }
                    pro.ProductDataMap.put( psbp.color__c , pbdata );
                    productMap.put( psbp.Customer_Ref_Model__c , pro );
                    system.debug('productMap>>>>>>'+productMap);
                }
            }
        }
        
        List<String> ListOfProductFamily = new List<String>();
        //ListOfProductFamily.addAll(proFamily);  //current page family
        ListOfProductFamily = getPicklistValues(qryPbProWhereClause);  //product family from all the eligible pricebooks
    ListOfProductFamily.sort();

        if(companyAPIandName.containskey(orderToCompany))
        {
            compProdWrap.Ocomp=companyAPIandName.get(orderToCompany);
        }
        else
        {
            compProdWrap.Ocomp=orderToCompany;
        }
        if(currencyAPIandName.containskey(preCurrency))
        {
            compProdWrap.Pcurr=currencyAPIandName.get(preCurrency);
        }
        else
        {
            compProdWrap.Pcurr=preCurrency;
        }
        compProdWrap.PcurrList = getDependentPicklistValues(compProdWrap.Ocomp,'Order_Country__c','Preferred_Currency__c');
        compProdWrap.productList=productMap.values();
        //to used in product search to filter by product family
        compProdWrap.productFamilyList = ListOfProductFamily;
        //compProdWrap.tabOverride = selectedTab;   //commented since not to be used
        system.debug('compProdWrap>>>'+compProdWrap);
        return compProdWrap; 
    }
    //sizer selection 
    Public class SizerWrap{
        @AuraEnabled
        Public Map<String ,List<String>> colorSizeDependentList;
        @AuraEnabled
        Public List<Price_Specification_Book_Product__c> sizerList;
    }
  @AuraEnabled
  public static sizerWrap productSizerDetails(String prodname,String retailerCode,String orderToCompany, String preCurrency)
  {
      	SizerWrap sizeWrap=new SizerWrap();
        system.debug('prodname>>>'+prodname);
    	system.debug('orderToCompany>>>'+orderToCompany);
    	system.debug('preCurrency>>>'+preCurrency);
   		//to get company label from its API name
        Map<String,String> companyAPIandName = UtilityClass.getOrderToCompanyPicklist(true);    
        //to get company API Name from its label
        Map<String,String> companyNameandAPI = UtilityClass.getOrderToCompanyPicklist(false);
        
        //to get currency API Name from its label
        Map<String,String> currencyAPIandName = UtilityClass.getPreferredCurrencyPicklist(true);
        system.debug('currencyAPIandName>>>>>>'+currencyAPIandName);
        
        //to get currency API Name from its label
        Map<String,String> currencyNameandAPI = UtilityClass.getPreferredCurrencyPicklist(false);
        system.debug('currencyNameandAPI>>>>>>'+currencyNameandAPI);
        
        //getting customer's contact data to get preferred currency and order to company
        Contact con = getcostomerinfo(retailerCode);
        
        if(preCurrency!=null && preCurrency!='NULL' && preCurrency!='')
        {
            //override preferred currency in contact(not updating) if user selectes currency in catalog
            con.Preferred_Currency__c = preCurrency;
            
        }
        else
        {
            preCurrency = con.Preferred_Currency__c;    //if currency is not selected in catalog, taking preferred currency
        }
        if(currencyNameandAPI.containskey(preCurrency))
        {
            preCurrency=currencyNameandAPI.get(preCurrency);
        }
        Map<String ,List<String>> productdataziserMap = new  Map<String ,List<String>>();
        String qrysizer='select id,name,Color__c,Sizer_Print__c,Product_image_url__c,Description__c,Retailer_Code__r.Full_Box_Order__c,BOX_QTY__c,Customer_Ref_Model__c,Order_to_Company__c,ProductCategory__c,Product_Sub_Category__c,variable_data_product__c,Retailer_Code__c,CurrencyIsoCode,(select id,name,CurrencyIsoCode from Price_Product_by_Currency__r) from Price_Specification_Book_Product__c where name=:prodname and Retailer_Code__c=:retailerCode AND variable_data_product__c=\'YES\' AND ProductCategory__c=\'ACCESSORIES\' AND (Product_Sub_Category__c=\'SIZER\' OR Product_Sub_Category__c=\'STICKER\') AND Active__c = true AND Product_Unique_ID__r.Status__c = \'Active\' AND Hidden_Catalogue__c=false';
        if(orderToCompany!=null && orderToCompany!='NULL' && orderToCompany!='' && companyNameandAPI.containskey(orderToCompany))
        {
          orderToCompany=companyNameandAPI.get(orderToCompany);
          qrysizer+=' AND Order_to_Company__c =\''+orderToCompany+'\'';
        }
        else
        {
          orderToCompany = con.Order_to_Company1__c;
          qrysizer+=' AND Order_to_Company__c =\''+orderToCompany+'\'';       
        }
        if(preCurrency!=null && preCurrency!='NULL')
        {
          qrysizer+=' AND id IN(select Price_Book_Product__c from Price_Product_by_Currency__c  where CurrencyIsoCode=\''+preCurrency+'\')';
        }
      system.debug('Database.query(qrysizer)>>'+Database.query(qrysizer));
      sizeWrap.sizerList=Database.query(qrysizer);
        for(Price_Specification_Book_Product__c psbpsizer : sizeWrap.sizerList)
        {
            if(productdataziserMap.containskey(psbpsizer.Color__c))
            {
                List<String> lstdata=productdataziserMap.get(psbpsizer.Color__c);
                lstdata.add(psbpsizer.Sizer_Print__c);
                productdataziserMap.put(psbpsizer.Color__c,lstdata);
            }
            else
            {
                productdataziserMap.put(psbpsizer.Color__c,new List<String>{psbpsizer.Sizer_Print__c});
            }
        }
           system.debug('productdataziserMap>>>'+productdataziserMap);
      sizeWrap.colorSizeDependentList=productdataziserMap;
      return sizeWrap;
  }
    @AuraEnabled
    public static Integer getCartDataCount(String customerid)
    {
       Integer count= SOController.getAllCartDetails(customerid).size();
        system.debug('count>>>'+count);
        return count;
    }
    @AuraEnabled
    public static List<Sales_Order_Line_Items__c> getSizerList(String  retailercode,String customerid)
    {
        system.debug('retailercode>>>'+retailercode);
        system.debug('customerid>>>'+customerid);
        return [select id,name,Colour__c,Quantity__c,Size__c,Print__c,Sales_Order__c,Price_Specification_Book_Product__r.id,Customer_Ref_Model__c,Mainetti_Model_Code__c,Added_As_a_Label__c,BOX_QTY__c,Full_Box_Order__c from Sales_Order_Line_Items__c where Sales_Order__r.Retailer_Code1__c=:retailerCode AND Sales_Order__r.Supplier__c=:customerid and Added_As_a_Label__c=true];//And Products__r.Mainetti_Model__c=:productname
    }
    @AuraEnabled
    public static string addSizerToCart(String retailercode,String customerid)
    {
        List<Sales_Order_Line_Items__c> sizrList=getSizerList(retailercode,customerid);
        if(sizrList.size()>0)
        {
            for(Sales_Order_Line_Items__c sizer:sizrList)
            {
                sizer.Added_As_a_Label__c=false;
            }
            update sizrList;
        }
        return 'SUCCESS';
    }
    //Get Contact Related Retailer List.
    @AuraEnabled
    public static List<Retailer_Code__c> retailerCodeDisplay()
    {
        List<Retailer_Code__c> crrlist=UtilityClass.getContactRelatedRetailer();
        
        return crrlist;
    } 
    @AuraEnabled
    public static void deletedSOLI(Id soliIdToDelete)    
    {
        if(soliIdToDelete!=null)
        {
            Sales_Order_Line_Items__c soli=new Sales_Order_Line_Items__c(id=soliIdToDelete);
            system.debug('soli>>>'+soli);
            delete soli;
            system.debug('soli>>>'+soli);
        }
    }
    
    //Get Current User Details.
    @AuraEnabled
   /* public static contact getcostomerinfo(String retailerCode)
  {
    system.debug('retailerCode getcostomerinfo:::'+retailerCode);
    contact contactid=UtilityClass.getCurrentUserContact();
    system.debug('contactid getcostomerinfo'+contactid);


    for(Retailer_Related_Data__c rrd:[Select Id,Order_to_Company__c,Preferred_Currency__c from Retailer_Related_Data__c where ContactID__c =:contactid.Id AND Status__c = 'Active' AND Retailer_Code__c =:retailerCode ])
    {
      system.debug('rrd getcostomerinfo'+rrd);
      //contactid.Order_to_Company1__c=companyNameandAPI.get(contactid.Order_to_Company1__c);
      contactid.Order_to_Company__c=rrd.Order_to_Company__c;
      contactid.Preferred_Currency__c=rrd.Preferred_Currency__c;
      
    }
    system.debug('contactid>> getcostomerinfo >>'+contactid);
    //to get API names
    Map<String,String> companyNameandAPI = UtilityClass.getOrderToCompanyPicklist(false);
    Map<String,String> currencyNameandAPI = UtilityClass.getPreferredCurrencyPicklist(false);
    
    for(String comp:companyNameandAPI.keyset())
    {
      system.debug('comp name>>>>>>'+comp);
      system.debug('contactid.Order_to_Company1__c >>'+contactid.Order_to_Company1__c);
    }
    
    if(companyNameandAPI.containskey(contactid.Order_to_Company__c))
    {
      contactid.Order_to_Company1__c=companyNameandAPI.get(contactid.Order_to_Company1__c);
      contactid.Order_to_Company__c=companyNameandAPI.get(contactid.Order_to_Company__c);
    }
    system.debug('contactid>>>>>>'+contactid);

    return contactid;
  }*/
    
    //Store Sales Order Based on Retailer.
    @AuraEnabled
    public static Sales_Order__c checkRetailerInSO(String customerid)
    {
        Sales_Order__c cartSO=UtilityClass.getSORecordAsCart(customerid);
        system.debug('cartSO'+cartSO);
        if(cartSO.Id != null)
        {
            return cartSO;
            
        }
        else
            return null;
    }
    
    //Get Product Family List
    @AuraEnabled
    public static List<String> getPicklistValues(String queryWhereClause)
    { 
    system.debug('queryWhereClause>>>>>>'+queryWhereClause);
        Set<String> proFamily= new Set<String>();
        /*for(Price_Specification_Book_Product__c psbp: [select Name,Product_Unique_ID__c,Product_Family__c,Retailer_Code__c from Price_Specification_Book_Product__c where Active__c = true AND Retailer_Code__c=: retailerCode AND Product_Unique_ID__r.Business_Vertical__c =: vertical])
        {
            //proFamily.add(psbp.Product_Family__c);
        }*/
    if(queryWhereClause.contains('AND Product_Family__c ='))
    {
      integer firstIndex = queryWhereClause.indexOf('AND Product_Family__c');
      String secString = queryWhereClause.substring(firstIndex+1);
      integer lastIndex = secString.indexOf('AND');
      queryWhereClause = queryWhereClause.substring(0,firstIndex);
      queryWhereClause = queryWhereClause + secString.substring(lastIndex);
      system.debug('queryWhereClause 2 nd last >>'+queryWhereClause);
    }
    String qryPbProFamily='select Name,Product_Family__c from Price_Specification_Book_Product__c'+queryWhereClause;
    system.debug('qryPbProFamily>>>>>>'+qryPbProFamily);
    List<Price_Specification_Book_Product__c> listofPriceBookProd = (Database.query(qryPbProFamily));   //to get unique names of products with given limit in query
        system.debug('listofprod>>>>>>'+listofPriceBookProd.size());
    for(Price_Specification_Book_Product__c psbp: listofPriceBookProd)
        {
            proFamily.add(psbp.Product_Family__c);
        }
    
        List<String> ListOfProductFamily = new List<String>();
        ListOfProductFamily.addAll(proFamily);
        return ListOfProductFamily;
    }
    
    @AuraEnabled
    /*public static List<string> getDependentPicklistValues(String controllingValue, String controllingFields, String dependentField)
    {
        List<string> listValues = new List<string>();
        
        listValues = SOController.DependentPicklist(controllingValue,controllingFields,dependentField);
        
        return listValues;
    }*/
    
    // code to save SO and SOLI(Cart record type) by chandana 
    @AuraEnabled
    public static string saveSO(id customerData,id retailercode, string quantity,id priceBookProId,id priceByCurr,string custRefModel)
    {
        system.debug('customerData==='+customerData);
        system.debug('retailerData==='+retailercode);
        system.debug('priceBookProId==='+priceBookProId);
        system.debug('quantity==='+quantity);
        // system.debug('priceByCurr==='+priceByCurr);
        String res = SOController.saveCart(customerData,retailercode,quantity,priceBookProId,priceByCurr,custRefModel);
        return res;
    } 
    
    /*Added by seema for bulk add to cart: --START--*/
    @AuraEnabled
    public static string addBulkProduct(String custid,String retailerCodeId,String bulkCartDataToSave)
    {
        List<BulkAddToCartWrap> bulkCartDataToSaveDes = (List<BulkAddToCartWrap>)JSON.deserialize(bulkCartDataToSave , List<BulkAddToCartWrap>.class);
        system.debug('bulkCartDataToSaveDes>>'+bulkCartDataToSaveDes);
        String res = SOController.saveBulkCart(custid,retailerCodeId,bulkCartDataToSaveDes);
        return res;
    }
     /*Bulk add to cart: --END--*/
    @AuraEnabled
    public static string addSizerProduct(String obj,string addTo)
    {
        SizerAddToCartWrap sizerCartDataToSaveDes =(SizerAddToCartWrap)JSON.deserialize(obj , SizerAddToCartWrap.class);
        system.debug('sizerCartDataToSaveDes>>'+sizerCartDataToSaveDes);
        addTo='';
        String res = SOController.saveSizerCart(sizerCartDataToSaveDes,addTo);
        return res;
    }
    @AuraEnabled
    public static void deleteRow(String idTODalete)
    {
        Sales_Order_Line_Items__c soli=[select id,Sales_Order__c from Sales_Order_Line_Items__c where id=:idTODalete];
        String soId=soli.Sales_Order__c;
        delete soli;
        Sales_Order__c soData=new Sales_Order__c();
        soData=[select id,(select id from Sales_Order_Line_Items__r) from Sales_Order__c where id=:soId];
        if(soData.Sales_Order_Line_Items__r.size()==0)
        {
            delete soData;
        }
    }
    
    @AuraEnabled
    public static List<SOController.SOLIWrapper> CheckCartDetailsForUpdate(id customerid)
    {
        List<SOController.SOLIWrapper> res = SOController.getAllCartDetails(customerid);
        return res;
    }
    
    //Wrapper Class For Product Count and details  
    public class completeProductWrapper {
        @AuraEnabled
        public Integer pageSize;
        @AuraEnabled
        public Integer pageNumber;
        @AuraEnabled
        public Integer totalRecords; 
        @AuraEnabled
        public Integer recordStart;
        @AuraEnabled
        public Integer recordEnd;
        @AuraEnabled
        public String tabOverride;
        @AuraEnabled
        public List<ProductWrapper> productList;
        @AuraEnabled
        public List<String> productFamilyList;
        @AuraEnabled
        public String Ocomp;
        @AuraEnabled
        public String Pcurr;
        @AuraEnabled
        public List<String> PcurrList;
    }
    
    //wrapper for product Details
    public class ProductWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String producttype;
        @AuraEnabled
        public String selectedColor;
        @AuraEnabled
        public String productfamily;
        @AuraEnabled
        public Map<string, ProductSecificationWrapper> ProductDataMap=new Map<string, ProductSecificationWrapper>();
    }
    
    //Wrapper for Product specification book product details.
    public class ProductSecificationWrapper{
        @AuraEnabled
        public String proddescription;
        @AuraEnabled
        public String color;
        @AuraEnabled
        public String MainettiModelCode; 
        @AuraEnabled
        public String priceByCurr;  
        @AuraEnabled
        public Decimal proPrice;  
        @AuraEnabled
        public String proImgURL; 
        @AuraEnabled
        public String retailercodeId; 
        @AuraEnabled
        public String retailerCodeName;
        @AuraEnabled
        public String priceBookId;   
        @AuraEnabled
        public Decimal quantity; 
        @AuraEnabled
        public Boolean showPrice; 
        @AuraEnabled
        public String currencyType;
        @AuraEnabled
        public Boolean fullboxQty;
        @AuraEnabled
        public Decimal boxquantity;  
        @AuraEnabled
        public String custRefModel;
        @AuraEnabled
        public String prodid;
        @AuraEnabled
        public String UomOrder;
        @AuraEnabled
        public string vardataproduct;
        @AuraEnabled
        public Boolean addedToCart;
        @AuraEnabled
        public Boolean addedAsLabel;
        @AuraEnabled
        public string prodFamily;
    }
      public class BulkAddToCartWrap{
        @AuraEnabled
        public string retailerCodeId;
        @AuraEnabled
        public string pricebookId;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public string cur;
        @AuraEnabled
        public string custRefModel;
        @AuraEnabled
        public string color;
    }
    public class SizerAddToCartWrap{
        @AuraEnabled
        public string retailerCodeId;
        @AuraEnabled
        public string pricebookId;
        @AuraEnabled
        public Integer quantity;
        @AuraEnabled
        public string pricebycur;
        @AuraEnabled
        public string preCurrency;
        @AuraEnabled
        public string custRefModel;
        @AuraEnabled
        public string color;
    @AuraEnabled
        public string size;
        @AuraEnabled
        public string customeid;
    }
}