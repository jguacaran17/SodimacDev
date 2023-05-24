/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 14/07/2020
Description  : Test Class for Object Case Trigger (entitlement Asign )
History      : CRMSC-5038
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Jessica Gómez			    JG
Pablo López                 PLB
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JG			14/07/2020		    Initial TEST class
2.0      PLB        22/01/2021          Optimize test class
********************************************************************************/

@isTest
public class SOD_XS_CaseTriggerHandler_TEST {
    
    /**
*  @description Method new data. Create account and asociated case
*  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
*  @date        14/07/2020
*/    
    @testSetup static void  NewData (){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ]; 
        System.runAs ( thisUser ) {
            
        List<Case> casos = new List<Case>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();        
        SOD_XS_DataFactory.createUser();
        User userOwner = [select id from User limit 1]; 
        Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '12032234-6','CL');
        
        for (Id idCase : rtMapById.keySet()){
            if(rtMapById.get(idCase).getName() == 'Reclamo' || rtMapById.get(idCase).getName() == 'Solicitud'){
                if(!rtMapById.get(idCase).isMaster()){
                    Case caso = (Case)SOD_XS_DataFactory.createCase(false);
                    caso.AccountId= acc.Id;
                    caso.RecordTypeId = idCase;
                    caso.SOD_XS_FechaDeCompra__c = Date.today();
                    caso.SOD_XS_CheckMailLlamada__c = true; 
                    caso.Status = 'New';
                    casos.add(caso);
                }
            }                   
        }
        for (Id idCase : rtMapById.keySet()){
            if(rtMapById.get(idCase).getName() == 'Reclamo'){
                if(!rtMapById.get(idCase).isMaster()){
                    Case caso = (Case)SOD_XS_DataFactory.createCase(false);
                    caso.AccountId= acc.Id;
                    caso.RecordTypeId = idCase;
                    caso.SOD_XS_FechaDeCompra__c = Date.today();
                    caso.SOD_XS_CheckMailLlamada__c = true; 
                    caso.Status = 'New';
                    casos.add(caso);
                }
            }                   
        }
        insert casos;
        
        SOD_XS_Bypass__c bypassvr = new SOD_XS_Bypass__c();
        bypassvr.SOD_XS_DesactivarProcessBuilders__c = true;
        bypassvr.SOD_XS_DesactivarFlows__c = true;
        bypassvr.SOD_XS_DesactivarValidationRules__c  = true;
        insert bypassvr; 
             
        Case case1 = [SELECT id, Status, OwnerId FROM Case  Limit 1];
        case1.Status = 'On Hold';
        case1.OwnerId =  userOwner.Id;
        update case1; 
 
        CaseComment   tComment = new CaseComment();
        tComment.ParentId = casos[0].Id;
        tComment.CommentBody = 'Some Comment';
        tComment.IsPublished = TRUE;
        
        INSERT tComment;
        }
    }
    /**
*  @description Method managed data status case
*  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
*  @date        14/07/2020
*/
    @isTest
    static void  ManagedData (){

        User userOwner = [Select Id From user limit 1];
        List<Case> casesList = [SELECT id, Status, OwnerId FROM Case Where Status = 'New' Limit 1];
        for (Case caso : casesList){
            caso.Status = 'On Hold';
            caso.OwnerId = userOwner.Id;
        }
        Test.startTest();
        update casesList;
        Test.stopTest();
        
        List<Case> casesList2 = [SELECT id, Status FROM Case Where Status = 'On Hold' Limit 1];
        System.assert(casesList2.size() > 0);
    }
    /**
*  @description Method on hold data status case
*  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
*  @date        14/07/2020
*/
    @isTest
    static void  OnHoldData (){

        User userOwner = [Select Id From user limit 1];
        List<Case> casesList3 = [SELECT id, Status FROM Case Where Status = 'New' Limit 1];
        
        for (Case caso : casesList3){
            caso.Status = 'On Hold';
            caso.OwnerId = userOwner.Id;
        }
        Test.startTest();
        update casesList3;
        Test.stopTest();
        
        List<Case> casesList4 = [SELECT id, Status FROM Case Where Status = 'On Hold'];
        System.assert(casesList4.size() > 0);
    }
    /**
*  @description Method close data status case
*  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
*  @date        14/07/2020
*/
    @isTest
    static void  ClosedData (){
        
        User userOwner = [Select Id From user limit 1];
        Case case1 = [SELECT id, Status, OwnerId, SOD_XS_DescripcionCierre__c FROM Case Where  
                       Status = 'On Hold'Limit 1];
        
        Test.startTest();
        case1.Status = 'On Hold';
        case1.OwnerId = userOwner.Id;
        update case1;
        
        case1.Status = 'Gestionado';
        update case1;
        
        case1.Status = 'Closed';
        case1.SOD_XS_DescripcionCierre__c = 'cerrado test';
        case1.OwnerId = userOwner.Id;
        update case1;
        
        Test.stopTest();
            
        List<Case> casesList2 = [SELECT id, Status FROM Case Where Status = 'Closed'];
        System.assert(casesList2.size() > 0);
        
    }
    /* *
*  @description Main method test run
*  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
*  @date        14/07/2020
*/
    @isTest
    static void testRun (){
        
        Test.startTest();
        //NewData();
        CaseComment cComment =[SELECT id FROM CaseComment LIMIT 1];
        cComment.CommentBody = 'Some C123123123omment';
        update cComment; 
        Test.stopTest();
        
        List<CaseComment> cCommentList = [SELECT id, CommentBody FROM CaseComment Where CommentBody = 'Some C123123123omment'];
        System.assert(cCommentList.size()==1);
    }
}