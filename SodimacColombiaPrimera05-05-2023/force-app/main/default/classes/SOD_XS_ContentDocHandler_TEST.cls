/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/02/2021
Description  : Test Class for Object Content Document Trigger - SOD_XS_ContentDocTriggerHandler
History      : CRMSC-5037
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Nelson Lepiqueo			    NL
Pablo L�pez                 PLB
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      NL			17/02/2021		    Initial TEST class
********************************************************************************/

@isTest
public class SOD_XS_ContentDocHandler_TEST {
    
     /**
    *  @description Method setup
    *  @Author      Nelson Lepiqueo, Deloitte
    *  @date        18/02/2021
    */ 
    @testSetup static void setup(){
        
        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ]; 
        System.runAs ( thisUser ) {
            
            Case caso = SOD_XS_DataFactory.createCase(true);
            Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '12032234-6','CL');
    
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Content Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv; 

        }
    }
    
    /**
    *  @description Test Method for insertion ContentDocument
    *  @Author      Nelson Lepiqueo, Deloitte
    *  @date        18/02/2021
    */ 
    @isTest
    static void  insertContentDocument(){

        List<Case> casesList = [SELECT id, Status, OwnerId 
                                FROM Case 
                                Limit 1];
   
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = casesList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        System.assertEquals(cdl.ShareType, 'V');
        Test.stopTest(); 
    }
   
    /**
    *  @description Test Method for delete ContentDocument
    *  @Author      Nelson Lepiqueo, Deloitte
    *  @date        18/02/2021
    */ 
    @isTest
    static void  deleteContentDocument(){

        List<Case> casesList = [SELECT id, Status, OwnerId 
                                FROM Case 
                                Limit 1];
           
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = casesList[0].id;
        cdl.ContentDocumentId = documents1[0].Id;
        cdl.shareType = 'V';
        
        insert cdl;        
        delete documents1;
        
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        System.assertEquals(0, documents2.size());
        Test.stopTest(); 
    }
    
    /**
    *  @description Test Method for insertion ContentDocument
    *  @Author      Nelson Lepiqueo, Deloitte
    *  @date        18/02/2021
    */ 
    @isTest
    static void  bypassTrigger(){

        List<Case> casesList = [SELECT id, Status, OwnerId 
                                FROM Case 
                                Limit 1];
   
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        SOD_XS_Bypass__c byPassTrigger = new SOD_XS_Bypass__c();
        byPassTrigger.SOD_XS_DesactivarTriggers__c = true;
        insert byPassTrigger;
        
        Test.startTest();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = casesList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        System.assertEquals(cdl.shareType, 'V');
        Test.stopTest(); 
    }
}