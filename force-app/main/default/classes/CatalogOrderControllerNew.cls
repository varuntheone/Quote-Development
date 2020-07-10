/*=====================================================================================================
Author     : Varun
Company    : Kasetti Technologies Pvt Ltd.
Date       : 18th June 2020
Description: CatalogOrderController class helps to handle following 

* Handle the operation search keyword.
* Fetch the Product,Product description from and Product Object.
* Save to the Sales_Order__c Order and Sales_Order_Line_Items__c of object as a cart.

=======================================================================================================*/

public with sharing class CatalogOrderControllerNew {

    //Getting userId of the logged in user which will be stored in onselectcustomeid attribute in cmp.
    @AuraEnabled
    public static Id getUserId() {
        Id currentuserId = UserInfo.getUserId();
        System.debug('currentuserId:'+currentuserId);
        return currentuserId;
    }


    //Getting list of products on init.
    @AuraEnabled
    public static List<Product2> listProducts() {
        /*Product List will be filtered based on PriceBook because different PriceBook may be 
        assigned for a perticular uer/group/role.*/
        
        //Get assigned PriceBook for an user.
        //There should be only one PriceBook for an user
        //Administrator user will have access to multiple PriceBook, consider only one PriceBook for admin.
        Set<Id> pricbookAssignedForUser =  SharedPricebooks.getPricebooks();        
        System.debug('pricbookAssignedForUser:'+pricbookAssignedForUser);
        String priceBookId = '';
        for(Id priceBook : pricbookAssignedForUser){
            priceBookId = priceBook;
            break;
        }
        System.debug('priceBookId:'+priceBookId);

        List<PricebookEntry> priceBookEntryItems = [select Pricebook2Id,Product2Id,ProductCode 
                                                    from PricebookEntry where 
                                                    Pricebook2Id =:priceBookId];
        System.debug('priceBookEntryItems:'+priceBookEntryItems);

        Set<Id> uniquePrdId = new Set<Id>();
        if (priceBookEntryItems <> null && priceBookEntryItems.size() > 0) {
            for (PricebookEntry priceEntry : priceBookEntryItems) {
                uniquePrdId.add(priceEntry.Product2Id);
            }
        }
        List<Product2> productList = [SELECT Name,ProductCode,Family,Description,Quantity_temp_holder__c,
                                      Product_image_url__c,Product_Type__c FROM Product2 WHERE Id in :uniquePrdId]; 
        System.debug('productList:'+productList);       
        return productList;
    }

    //Searching specific products based on enetred keyword.
    @AuraEnabled
    public static List<Product2> searchProducts(String SearchKeyword) {
        System.debug('SearchKeyword:'+SearchKeyword);
        String keyword = '%'+ SearchKeyword +'%';

        /*Product List will be filtered based on PriceBookEntry list because different PriceBook may be 
        assigned for a perticular uer/group/role.*/
        List<PricebookEntry> priceBookEntryItems = [select Pricebook2Id,Product2Id,ProductCode 
                                                    from PricebookEntry];
        System.debug('priceBookEntryItems:'+priceBookEntryItems);

        Set<Id> uniquePrdId = new Set<Id>();
        if (priceBookEntryItems <> null && priceBookEntryItems.size() > 0) {
            for (PricebookEntry priceEntry : priceBookEntryItems) {
                uniquePrdId.add(priceEntry.Product2Id);
            }
        }
        List<Product2> productSearched = [SELECT Name,ProductCode,Family,Description,Quantity_temp_holder__c,
                                         Product_image_url__c FROM Product2 WHERE Description LIKE :keyword AND Id in :uniquePrdId];
        System.debug('productSearched:'+productSearched);                                
        return productSearched;
    }

    /*
    Method is called on click of 'Add to Cart'
    this will store added product to salesOrderLineItem object.
    */
    @AuraEnabled
    public static Boolean saveToCart(String userId, Product2 product, Double quantity) {
        System.debug('userId:'+userId+' '+'quantity:'+quantity);
        System.debug('product:'+product);
            Boolean insertSuccess = true;
            try {
                if(product.Product_Type__c == 'Bundle'){
                    List<Sales_Order__c> SOList=new List<Sales_Order__c>(); 
                    SOList =[select id from Sales_Order__c where UserId__c =:userId and Status__c ='New Order'];
                    system.debug('SOList>>'+SOList);
                    system.debug('SOList.size>>'+SOList.size());

                    if(SOList.size()==0){ // if no data on the respective customer then insert the new SO and SOLI
                        Sales_Order__c So=new Sales_Order__c();
                        So.UserId__c = userId;
                        So.Status__c = 'New Order';
                        insert So;
                        Sales_Order_Line_Items__c SOli = new Sales_Order_Line_Items__c();
                        SOli.Sales_Order__c = So.Id;
                        SOli.Product__c = product.Id;
                        SOli.Product_Type__c = product.Product_Type__c;
                        SOli.Product_Name__c = product.Name;
                        SOli.Product_Code__c = product.ProductCode;
                        SOli.Product_Description__c = product.Description;
                        SOli.Product_image_url__c = product.Product_image_url__c;
                        SOli.Quantity__c = quantity;
                        insert SOli;
                    } else {
                        // insert only SOLI
                        List<Sales_Order_Line_Items__c> SoliList=new List<Sales_Order_Line_Items__c>();
                        SoliList =[select id, name,Sales_Order__c,Product_Code__c,Product_Description__c,
                                  Quantity__c from Sales_Order_Line_Items__c where 
                                  Sales_Order__c=:SOList[0].id and Product_Code__c=:product.ProductCode
                                  and Product_Type__c =:product.Product_Type__c];                    
                        system.debug('SoliList>>>>'+SoliList);
                        system.debug('SoliList.size>>'+SoliList.size());

                        if(SoliList.size()==0){ // if no data on the respective productCode then insert the SOLI
                            Sales_Order_Line_Items__c soline=new Sales_Order_Line_Items__c();
                            soline.Sales_Order__c=SOList[0].id;
                            soline.Product__c = product.Id;
                            soline.Product_Type__c = product.Product_Type__c;
                            soline.Product_Name__c = product.Name;
                            soline.Product_Code__c = product.ProductCode;
                            soline.Product_Description__c = product.Description;
                            soline.Product_image_url__c = product.Product_image_url__c;
                            soline.Quantity__c = quantity;
                            insert soline;
                        } else {
                            //if data is there upsert thesame SOLI
                            system.debug('SoliList in else >>'+SoliList[0]);
                            SoliList[0].Quantity__c = quantity;
                            upsert SoliList[0];
                        }

                    }
                } else{
                
                List<Sales_Order__c> SOList=new List<Sales_Order__c>(); 
                SOList =[select id from Sales_Order__c where UserId__c =:userId and Status__c ='New Order'];
                system.debug('SOList>>'+SOList);
                system.debug('SOList.size>>'+SOList.size());

                if(SOList.size()==0){ // if no data on the respective customer then insert the new SO and SOLI
                    Sales_Order__c So=new Sales_Order__c();
                    So.UserId__c = userId;
                    So.Status__c = 'New Order';
                    insert So;
                    Sales_Order_Line_Items__c SOli = new Sales_Order_Line_Items__c();
                    SOli.Sales_Order__c = So.Id;
                    SOli.Product__c = product.Id;
                    SOli.Product_Type__c = product.Product_Type__c;
                    SOli.Product_Name__c = product.Name;
                    SOli.Product_Code__c = product.ProductCode;
                    SOli.Product_Description__c = product.Description;
                    SOli.Product_image_url__c = product.Product_image_url__c;
                    SOli.Quantity__c = quantity;
                    insert SOli;
                } else {
                    // insert only SOLI
                    List<Sales_Order_Line_Items__c> SoliList=new List<Sales_Order_Line_Items__c>();
                    SoliList =[select id, name,Sales_Order__c,Product_Code__c,Product_Description__c,
                              Quantity__c from Sales_Order_Line_Items__c where 
                              Sales_Order__c=:SOList[0].id and Product_Code__c=:product.ProductCode
                              and Product_Type__c =:product.Product_Type__c];                    
                    system.debug('SoliList>>>>'+SoliList);
                    system.debug('SoliList.size>>'+SoliList.size());

                    if(SoliList.size()==0){ // if no data on the respective productCode then insert the SOLI
                        Sales_Order_Line_Items__c soline=new Sales_Order_Line_Items__c();
                        soline.Sales_Order__c=SOList[0].id;
                        soline.Product__c = product.Id;
                        soline.Product_Type__c = product.Product_Type__c;
                        soline.Product_Name__c = product.Name;
                        soline.Product_Code__c = product.ProductCode;
                        soline.Product_Description__c = product.Description;
                        soline.Product_image_url__c = product.Product_image_url__c;
                        soline.Quantity__c = quantity;
                        insert soline;
                    } else {
                        //if data is there upsert thesame SOLI
                        system.debug('SoliList in else >>'+SoliList[0]);
                        SoliList[0].Quantity__c = quantity;
                        upsert SoliList[0];
                    }
                }
            }
            } catch (DmlException e) {
                insertSuccess = false;
                System.debug('Failed to insert:' + e);
            }
            return insertSuccess;
    }

    @AuraEnabled
    public static Integer getCartDataCount(String customerid) {

        List<Sales_Order_Line_Items__c> SOList = [SELECT Id FROM Sales_Order_Line_Items__c WHERE
                                                 Sales_Order__r.UserId__c =:customerid AND 
                                                 Sales_Order__r.Status__c = 'New Order'];
        system.debug('SOList>>'+SOList);
        Integer count= SOList.size();
        system.debug('count>>>'+count);
        return count;
    }
}