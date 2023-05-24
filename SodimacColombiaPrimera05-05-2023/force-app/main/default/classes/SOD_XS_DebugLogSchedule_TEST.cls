/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 19/03/2021
Description  : Test class for SOD_XS_DebugLogSchedule class.
History      : CMRSC-5119
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Nelson Lepiqueo			    NL
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      NL			19/03/2021		Created the file/class
********************************************************************************/
@IsTest
public with sharing class SOD_XS_DebugLogSchedule_TEST {
    
    public static String CRON_EXP ='0 0 * * * ? *';
    public static string jobId;
    
/**
*  @Description: Test Setup
*  @Autor:       NL, Deloitte
*  @Date:        19/03/2021
*/ 
    @TestSetup    
    static void createData (){
        jobid = System.schedule('execute', CRON_EXP, new SOD_XS_DebugLogSchedule());
        SOD_XS_RegistroDepuracion__c outDebugLog = new SOD_XS_RegistroDepuracion__c();        
        
        outDebugLog.SOD_XS_TipoOperacion__c					= 'GET';
        outDebugLog.SOD_XS_CodigoEstado__c 					= 400; 
        outDebugLog.SOD_XS_CodigoIsoPais__c 				= 'CL';
        outDebugLog.SOD_XS_Guid__c 							= '12345abcde';
        outDebugLog.SOD_XS_FechaHoraTransaccion__c 		    = datetime.now();
        outDebugLog.SOD_XS_UsuarioEjecutorTransaccion__c    = userInfo.getUserId();  
        outDebugLog.SOD_XS_UrlConsumo__c 				    = 'www.test.test';
        outDebugLog.SOD_XS_ParametroTransaccionRequerido__c = 'RUT, Nombre';
        outDebugLog.SOD_XS_MensajeError__c 				    = 'Error';
		outDebugLog.CreatedDate 							= Date.today().addDays(-40);     
        insert outDebugLog; 
        
        ContentVersion file = new ContentVersion();
        file.Title = 'File';
        file.PathOnClient = 'File.txt';
        file.VersionData = Blob.valueOf('Test');
        file.ContentLocation= 's';
        Insert file; 
               
        ContentDocumentLink contDocList = new ContentDocumentLink();
        contDocList.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: file.Id].ContentDocumentId;
        contDocList.LinkedEntityId = outDebugLog.id;
        contDocList.ShareType = 'v';
        insert contDocList;
    }
/**
*  @Description: Test Scheduled SOD_XS_DebugLogSchedule
*  @Autor:       NL, Deloitte
*  @Date:        19/03/2021
*/ 
    static testMethod void testSchedule(){

        Test.startTest();        
        List<SOD_XS_RegistroDepuracion__c> debLog = [SELECT id, Name, SOD_XS_TipoOperacion__c FROM SOD_XS_RegistroDepuracion__c WHERE SOD_XS_TipoOperacion__c = 'GET' LIMIT 1];
        
        List<ContentVersion> conVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE title = 'File'];
        
        List<ContentDocument> documentsList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.stopTest();
        
    }
/**
*  @Description: Test Scheduled SOD_XS_DebugLogBatchSchedule
*  @Autor:       NL, Deloitte
*  @Date:        19/03/2021
*/    
    static testMethod void testBatch(){
        List<SOD_XS_RegistroDepuracion__c> debLog = [SELECT id, Name, SOD_XS_TipoOperacion__c FROM SOD_XS_RegistroDepuracion__c WHERE SOD_XS_TipoOperacion__c = 'GET'];
         
        List<ContentVersion> conVer = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        List<ContentDocument> documentsList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
               
        Test.startTest();
        Database.executeBatch(new SOD_XS_DebugLogBatchSchedule());        
        System.assertNotEquals(0 , documentsList.size());
        Test.stopTest();        
    }

}