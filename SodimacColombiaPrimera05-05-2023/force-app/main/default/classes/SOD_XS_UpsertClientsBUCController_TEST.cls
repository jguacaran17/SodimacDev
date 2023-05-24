/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 21/07/2020
Description  : Test Class SOD_XS_UpsertClientsBUCController
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade A.			EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA			27/07/2020		initial version
1.1      LMG            27/01/2021      Optimize test class
********************************************************************************/
@isTest
public class SOD_XS_UpsertClientsBUCController_TEST {
    
    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup(){
        Test.startTest();
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '8603403-4', 'CL');
        test.stopTest();
    }
    
    /**
    * @description initial class
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        27/07/2020
    */ 
    @isTest static void initClassTest(){     
        Account acc = [Select id from Account where SOD_XS_NroDocumento__c =: '8603403-4'];
        Test.startTest();
        List<String> endPoint = new List<String>();
        endPoint.add(SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest('CL', SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_SEARCH) + '/CL/RUT/8603403-4');
        List<String> resBody = new List<String>();
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CL);        
        SOD_XS_JWTRestMock_TEST.getMultimock(endPoint, resBody, 404);
        SOD_XS_UpsertClientsBUCController init = SOD_XS_UpsertClientsBUCController.initClass(acc.Id);
        Test.stopTest();

        system.assertEquals(init.acc.FirstName, 'PERSONACCOUNT');
    }
    /**
    * @description Create client BUC test
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        27/07/2020
    */
    @isTest static void createClientBUCTest() {
        Account acc = [Select id from Account where SOD_XS_NroDocumento__c =: '8603403-4'];
        Test.startTest();
        List<String> endPoint = new List<String>();
        endPoint.add(SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest('CL', SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_CREATE));
        List<String> resBody = new List<String>();
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_CREATEPERSON_CL);
        SOD_XS_JWTRestMock_TEST.getMultimock(endPoint, resBody, 201);
        Account accIsPerson = SOD_XS_UpsertClientsBUCController.getRecord(acc.Id);
        acc = SOD_XS_UpsertClientsBUCController.typeAcc(acc.Id, accIsPerson.IsPersonAccount);
        String IdExterno = SOD_XS_UpsertClientsBUCController.createClientBUC(acc);
        Test.stopTest();

        system.assert(IdExterno != null);
    }
    /**
    * @description Update client BUC test
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        27/07/2020
    */
    @isTest
    public static void updateClientBUCTest() {
        Account acc = [Select id from Account where SOD_XS_NroDocumento__c =: '8603403-4'];
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_UPDATE, SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 204, ''));
        Test.startTest();
        acc.LastName = 'Sodimac2';
        acc.SOD_XS_IdExterno__c = '000019990';
        update acc;
        Test.stopTest();
        
        Account c = [Select SOD_XS_IdExterno__c from Account where SOD_XS_NroDocumento__c =: '8603403-4'];
        system.assert(c.SOD_XS_IdExterno__c != null);
    }

    /**
    * @description Delete fields from client BUC test
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        12/02/2021
    */
    @isTest
    public static void deleteClientBUCTest() {
        Account acc = [Select SOD_XS_IdExterno__c from Account where SOD_XS_NroDocumento__c =: '8603403-4'];
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_DELETE, SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 204, ''));
        Test.startTest();
        acc.PersonEmail = null;
        acc.SOD_XS_IdPersonEmail__c = 1915800;
        acc.SOD_XS_ContactoNotienecorreo__pc = true;
        update acc;
        Test.stopTest();
        
        Account c = [Select PersonEmail from Account where SOD_XS_NroDocumento__c =: '8603403-4'];
        system.assert(c.PersonEmail == null);
    }
}