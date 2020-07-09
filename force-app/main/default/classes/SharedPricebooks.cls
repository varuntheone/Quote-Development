public with sharing class SharedPricebooks {
    
    /*
     * This method will return set of shared pricebook for an user. 
     * */
    public static Set<Id> getPricebooks(){
        
        Set<Id> pricbookAssignedForUser = new Set<Id>();
        Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];        
        //SelectOption[] Options = new SelectOption[]{};        
        set<Id> pricebookIDs = new set<Id>(); 
        for(Pricebook2 R : Records){
            pricebookIDs.add(R.Id);
        }
        
        List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, 
                                                       HasDeleteAccess FROM UserRecordAccess WHERE 
                                                       UserId=:UserInfo.getUserId() AND RecordId IN: pricebookIDs];
        
        map<Id,boolean> accessMap = new map<Id,boolean>();
        for(UserRecordAccess recAccess : listUserRecordAccess){
            accessMap.put(recAccess.RecordId, recAccess.HasReadAccess);
        }
        system.debug('accessMap:'+accessMap);
        //Options.add(new selectOption( '', '--None--'));
         for(Pricebook2 R : Records){
            if(accessMap.get(R.Id)){
                pricbookAssignedForUser.add(R.Id);
                //Options.add(new SelectOption(R.Id, R.Name));
            }
        }
        
        if(pricbookAssignedForUser.size() == 0){
            system.debug('You do not have a price book set up.  Please contact administrator.');  
        }
        //system.debug('pricbookAssignedForUser:'+pricbookAssignedForUser);
        return pricbookAssignedForUser;      
    }
}