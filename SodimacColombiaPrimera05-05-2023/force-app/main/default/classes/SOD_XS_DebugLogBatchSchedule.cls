/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 18/03/2021
Description  : Batch apex for delete SOD_XS_RegistroDepuracion__c and ContentDocument Objects.
History      : CMRSC-5119
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Nelson Lepiqueo			    NL
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      NL			18/03/2021		Created the file/class
********************************************************************************/
global with sharing class SOD_XS_DebugLogBatchSchedule implements Database.Batchable<sObject> {
           
    global Iterable<SObject> start(Database.BatchableContext context) {
        
        List<SObject> recordList = new List<SObject>();
        List<SObject> contDocLinkList = new List<SObject>();
        set<Id> contDocIdList = new set<Id>();
        String dayLabel = System.Label.SOD_XS_FiltrarRegistroDepuracion;        
        Integer days = integer.valueof(dayLabel);
        Date dayNumber = Date.today().addDays(-days);
        String query;
        
        Map<Id, SObject> debugLogMap = new Map<Id, SObject>([SELECT Id FROM SOD_XS_RegistroDepuracion__c WHERE CreatedDate <: dayNumber]);
        Set<Id> newSet = debugLogMap.keySet();
        
        if (newSet.size() == 1) {
            Id entityId = new List<Id>(newSet)[0];
            query = 'SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: entityId';
        } else if(newSet.size() > 1) {
            query = 'SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: newSet';                                                                                                 
        }        
        
        if (query == null) {
            return recordList;
        }
        
        for(SObject contDocId : Database.query(query)) {    
            if (contDocId instanceof ContentDocumentLink) {
                ContentDocumentLink objContDoc = (ContentDocumentLink) contDocId;
				contDocIdList.add(objContDoc.ContentDocumentId);
            }
        }
        
        List<ContentDocument> contDocList =  [SELECT Id FROM ContentDocument WHERE id IN: contDocIdList];            

        recordList.addAll(debugLogMap.values());
        recordList.addAll(contDocList);
        
        return recordList;
    }
    
    global void execute(Database.BatchableContext context, List<SObject> records) {
        delete records;
    }
    
    global void finish(Database.BatchableContext ctx) {
    }
    
}