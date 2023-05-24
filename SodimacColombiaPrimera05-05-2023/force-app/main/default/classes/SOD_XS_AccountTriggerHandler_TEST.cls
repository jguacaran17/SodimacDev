/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 22/10/2020
Description  : Trigger Test class for Account object (data update for BUC)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO			22/10/2020		Initial definition of the class.
1.1      LMG            28/01/2021      Optimize test class
********************************************************************************/

@isTest
public class  SOD_XS_AccountTriggerHandler_TEST {

    /**
    * @description: Setup for test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup(){
        test.startTest();
        test.stopTest();
    }
    /**
    *  @description Method test for testing Updates on Account records, triggering update to BFF/BUC (mock)
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    @isTest
    static void accountTriggerUpdateTest() {
        Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '8603403-4', 'CL');
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_UPDATE, SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 204, ''));
        Test.startTest();
        acc.LastName = 'Sodimac2';
        acc.SOD_XS_IdExterno__c = '000019990';
        update acc;
        Test.stopTest();
        system.assertEquals(acc.LastName,'Sodimac2');
    }

    /**
    *  @description Method test for testing Delete a field on Account records, triggering delete to BFF/BUC 
    *  @author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @date        12/02/2021
    */
    @isTest
    static void accountTriggerDeleteTest() {
        Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '8603403-4', 'CL');
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_DELETE, SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 204, ''));
        Test.startTest();
        acc.PersonEmail = null;
        acc.SOD_XS_ContactoNotienecorreo__pc = true;
        acc.SOD_XS_IdExterno__c = '000019990';
        update acc;
        Test.stopTest();
        system.assertEquals(acc.PersonEmail,null);
    }

    /**
    *  @description Method test for testing Inserts on Account records
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    @isTest
    static void accountTriggerInsertTest() { 
        Account acc = SOD_XS_DataFactory.createAccountXS(false, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '10663558-7', 'CL');
        Test.startTest();
        acc.FirstName = 'nombre minuscula';
        acc.LastName = 'apellido minuscula';
        acc.PersonEmail = 'MAYUSCULA@test.cl';
        insert acc;
        Test.stopTest();
        system.assertEquals(acc.PersonEmail,'MAYUSCULA@test.cl');
    }

}