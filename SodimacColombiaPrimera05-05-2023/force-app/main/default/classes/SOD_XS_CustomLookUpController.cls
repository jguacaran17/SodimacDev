/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 03/08/2020
Description  : APEX Controller - Custom lookup
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			08/07/2020		initial version
********************************************************************************/
public with sharing class SOD_XS_CustomLookUpController {
    
    /**
    *  @Description: Search for objects for the custom lookup
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        
        String searchKey = searchKeyWord + '%';        
        List < sObject > returnList = new List < sObject > ();
        
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        Map<String, String> qryMap = getDynamicQuery(ObjectName, searchKey);
        String sQuery;
        if (qryMap.containsKey(ObjectName)) {
            sQuery = qryMap.get(ObjectName);
        } else {
            sQuery =  'SELECT id, Name FROM ' +ObjectName + ' WHERE Name LIKE :searchKey ORDER BY createdDate DESC limit 5';
        }       
        
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        
        return returnList;
    }
    
    /**
    *  @Description: Dynamic Query For Fetch Record List with LIMIT 5
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static Map<String, String> getDynamicQuery(String objectName, String searchKey) {
        Map<String, String> queryMap = new  Map<String, String>();        
        queryMap.put('SOD_XS_Country__c', 'SELECT id, Name, SOD_XS_Codigo__c, CurrencyIsoCode FROM ' +objectName + ' WHERE Name LIKE :searchKey AND SOD_XS_ActivoIntegracion__c = TRUE ORDER BY createdDate DESC limit 5');
        return queryMap;
    }
}