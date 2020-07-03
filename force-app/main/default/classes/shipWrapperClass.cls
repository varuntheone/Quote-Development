public with sharing class shipWrapperClass {
    @AuraEnabled
    public Sales_Order_Line_Items__c soli;
    @AuraEnabled
    public List<Product_Bundle__c> bundleProducts;
}
