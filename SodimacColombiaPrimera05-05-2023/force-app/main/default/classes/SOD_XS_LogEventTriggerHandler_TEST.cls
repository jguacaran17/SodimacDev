/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : FTC
Created Date : 07/02/2022
Description  : Trigger Test class for Log Event (Used for logging exceptions)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodolfo Valencia Tapia      RVT
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RVT      07/02/2022    Initial definition of the class.
********************************************************************************/
@isTest
public class SOD_XS_LogEventTriggerHandler_TEST {
    @isTest
    static void testGenerateLogIdentifier() {
        Test.startTest();
            String logIdentifier = SOD_XS_LogEventTriggerHandler.generateLogIdentifier();
            String testLogIdentifier = Datetime.now().format('yyMMddHHmm', 'UTC');
        Test.stopTest();
        System.assert(logIdentifier.contains(testLogIdentifier));
    }
    @isTest
    static void testAfterInsert() {
        SOD_XS_JWTRestConnection.ServiceException e = new SOD_XS_JWTRestConnection.ServiceException(null, null, 'Test Exception', 404);
        Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '8603403-4', 'CL');
        Id testId = acc.Id;
        Test.startTest();
            SOD_XS_EnLogger.logError(e, testId);
        Test.stopTest();
        List<SOD_XS_RegistroDepuracion__c> rd = [Select Id, SOD_XS_IdRegistroDesencadenador__c, SOD_XS_Identificador__c FROM SOD_XS_RegistroDepuracion__c WHERE SOD_XS_IdRegistroDesencadenador__c =: String.valueOf(testId)];
        System.assertEquals(rd[0].SOD_XS_IdRegistroDesencadenador__c, String.valueOf(testId));
    }
}