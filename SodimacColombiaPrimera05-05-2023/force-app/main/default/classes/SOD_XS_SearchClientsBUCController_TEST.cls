/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 21/07/2020
Description  : Test Class SOD_XS_SearchClientsBUCController
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade A.			EAA
Leonardo Muñoz              LMG
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA			23/07/2020		initial version
1.1      EAA            06/10/2020      Add new country
1.2      LMG            27/01/2021      Optimize test class
********************************************************************************/
@isTest
public class SOD_XS_SearchClientsBUCController_TEST {
    
    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup Static void setup(){
		test.startTest();

        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '8603403-4','CL');
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '24956939-9','CL');
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'Cédula de Ciudadanía', '1100876493','CO');
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'Cédula de Ciudadanía', '1018481186','CO');
        
        test.stopTest();
    }
    /**
    * @description initial class
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */ 
    @isTest Static void initClass_Test(){
        
        Test.startTest();
        SOD_XS_SearchClientsBUCController obj = SOD_XS_SearchClientsBUCController.initClass();
        
        System.assert(obj.docType != null);
        Test.stopTest();
    }
    /**
    * @description search Client Chile BUC
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest Static void searchClientBUCCL_Test(){
        Test.startTest(); 
        
        List<String> endPoint = new List<String>();
        List<String> resBody = new List<String>();
        
        endPoint.add(SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest('CL', SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_SEARCH) + '/CL/RUT/8603403-4');
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CL);
        
        SOD_XS_JWTRestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        String resCL = SOD_XS_SearchClientsBUCController.searchClientBUC('RUT', '8603403-4', 'CL');
        
        System.assert(resCL != '');        
        Test.stopTest(); 
    }
    
    /**
    * @description search Client Perú BUC
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest Static void searchClientBUCPE_Test(){
        Test.startTest(); 
        List<String> endPoint = new List<String>();
        List<String> resBody = new List<String>();
        
        endPoint.add(SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest('PE', SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_SEARCH) + '/PE/DNI/09480177');
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_PE);
        
        SOD_XS_JWTRestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        String resPE = SOD_XS_SearchClientsBUCController.searchClientBUC('DNI', '09480177', 'PE');
        
        System.assert(resPE != '');        
        Test.stopTest(); 
    }
    
    /**
    * @description search Client México BUC
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest Static void searchClientBUCMX_Test(){
        Test.startTest(); 
        List<String> endPoint = new List<String>();
        List<String> resBody = new List<String>();
        
        endPoint.add(SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest('MX', SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_SEARCH) + '/MX/RFC/TETT8109249X9');
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_MX);
        
        SOD_XS_JWTRestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        String resMX = SOD_XS_SearchClientsBUCController.searchClientBUC('RFC', 'TETT8109249X9', 'MX');
        
        System.assert(resMX != '');
        Test.stopTest(); 
    }
 
    /**
    * @description search Client BUC for Colombia
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        06/10/2020
    */    
    @isTest Static void searchClientBUCCO_Test(){
        Test.startTest(); 
       List<String> endPoint = new List<String>();
        List<String> resBody = new List<String>();
        
        endPoint.add(SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest('CO', SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_SEARCH) + '/CO/CC/1018481186');
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CO);
        
        SOD_XS_JWTRestMock_TEST.getMultimock(endPoint, resBody, 200);
        
        String resCO = SOD_XS_SearchClientsBUCController.searchClientBUC('CC', '1018481186', 'CO');
        
        System.assert(resCO != '');
        Test.stopTest(); 
    }    
    /**
    * @description new record account 
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest Static void newRcdAcc_Test () {
        Account acc = [Select RecordTypeId from Account where SOD_XS_NroDocumento__c = '8603403-4'];      
        SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL' limit 1];
        
        Test.startTest();
        String jsonObj = Label.SOD_XS_ERROR404;
        SOD_XS_SearchClientsBUCController.WrapAccount cuenta2 = SOD_XS_SearchClientsBUCController.newRcdAcc(jsonObj, 'RUT', '8603403-4', pais, acc.RecordTypeId);
        Test.stopTest();

        system.assertEquals(cuenta2.acc.SOD_XS_NroDocumento__c, '8603403-4');
    }
    /**
    * @description new record account Colombia
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        07/10/2020
    */    
    @isTest Static void newRcdAccColombia_Test () {
        Account acc = [Select RecordTypeId from Account where SOD_XS_NroDocumento__c = '1100876493'];
        SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CO' limit 1];
        
        Test.startTest();
        String jsonObj = Label.SOD_XS_ERROR404;
        SOD_XS_SearchClientsBUCController.WrapAccount cuenta2 = SOD_XS_SearchClientsBUCController.newRcdAcc(jsonObj, 'CC', '1100876493', pais, acc.RecordTypeId);
        Test.stopTest();
        
        system.assertEquals(cuenta2.acc.SOD_XS_NroDocumento__c, '1100876493');
    }
    /**
    * @description new record account for clients in BUC and Salesforce
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest Static void newRcdAccBUCANDSFCD_Test () {
        Account acc = [Select RecordTypeId from Account where SOD_XS_NroDocumento__c = '8603403-4'];      
		SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL' limit 1];
        
        Test.startTest();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CL LIMIT 1];
        String jsonObj = sr.Body.toString();

        SOD_XS_SearchClientsBUCController.WrapAccount cuenta2 = SOD_XS_SearchClientsBUCController.newRcdAcc(jsonObj, 'RUT', '8603403-4', pais, acc.RecordTypeId);
        Test.stopTest();
        
        system.assertEquals(cuenta2.acc.SOD_XS_NroDocumento__c, '8603403-4');
    }
    /**
    * @description new record account for clients in BUC and Salesforce for Colombia
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        08/10/2020
    */    
    @isTest Static void newRcdAccBUCANDSFCDColombia_Test () {
        Account acc = [Select RecordTypeId from Account where SOD_XS_NroDocumento__c = '1018481186'];
        SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CO' limit 1];
        String msgError = '';

        Test.startTest();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CO LIMIT 1];
        String jsonObj = sr.Body.toString();
        SOD_XS_SearchClientsBUCController.WrapAccount cuenta2;
		try{
		    cuenta2 = SOD_XS_SearchClientsBUCController.newRcdAcc(jsonObj, 'CC', '1018481186', pais, acc.RecordTypeId);

        }catch(Exception e){
            msgError = e.getMessage();
        }
        Test.stopTest();

        System.assert(String.isBlank(msgError));
    }    
    /**
    * @description new record account no client salesforce
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest Static void newRcdAccNotClientSFDC_Test () {
        SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL' limit 1];
        Id rcdTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        Test.startTest();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CL LIMIT 1];
        String jsonObj = sr.Body.toString();
        
        SOD_XS_SearchClientsBUCController.WrapAccount cuenta2 = SOD_XS_SearchClientsBUCController.newRcdAcc(jsonObj, 'RUT', '8603403-4', pais, rcdTypeId);
        Test.stopTest();
        
        system.assertEquals(cuenta2.acc.SOD_XS_NroDocumento__c, '8603403-4');
    }

    /**
    * @description new record account no client salesforce for Colombia
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        08/10/2020
    */    
    @isTest Static void newRcdAccNotClientSFDCColombia_Test () {
        SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CO' limit 1];
        Id rcdTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        String msgError = '';

        Test.startTest();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CO LIMIT 1];
        String jsonObj = sr.Body.toString();
        SOD_XS_SearchClientsBUCController.WrapAccount cuenta2;
        try{
             cuenta2 = SOD_XS_SearchClientsBUCController.newRcdAcc(jsonObj, 'CC', '1018481186', pais, rcdTypeId);
            
        }catch(Exception e){
            msgError = e.getMessage();
        }      
        Test.stopTest();
        System.assert(String.isBlank(msgError));
    }    
    /**
    * @description new record account fail 
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest public static void newRcdAccFail_Test(){
        Account acc = [Select RecordTypeId from Account where SOD_XS_NroDocumento__c = '24956939-9'];
        SOD_XS_Country__c pais = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c limit 1];
        String msgError = '';

        Test.startTest();
        try{
            SOD_XS_SearchClientsBUCController.WrapAccount cuenta = SOD_XS_SearchClientsBUCController.newRcdAcc('', 'RUT', '24956939-9', pais, acc.RecordTypeId);
        }catch(Exception e){
            msgError = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Script-thrown exception', msgError);
    }
    
    /**
    * @description fetch RecordType Values 
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest public static void fetchRecordTypeValues_Test(){
        Test.startTest();
        List <String> listaValores =  SOD_XS_SearchClientsBUCController.fetchRecordTypeValues();

        System.assertNotEquals(0, listaValores.size(),'Test fetchRecordTypeValues successful');
        Test.stopTest();
    }
    /**
    * @description Get RecordType Values for Business_Acount 
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest public static void getRecTypeMap_Test(){
        Test.startTest();
        String rcdTypenm = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getName();
        Map<string,id> mapa = SOD_XS_SearchClientsBUCController.getRecTypeMap(rcdTypenm);

        System.assert(mapa != null);
        Test.stopTest();
    }
    
    /**
    * @description get user Country for Chile
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */ 
    
    @isTest public static void getUserCountry_Test(){
        Test.startTest();
        User u = SOD_XS_DataFactory.createUser();
        System.runAs(u){
            SOD_XS_Country__c p = [Select Id, name, CurrencyIsoCode from SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL' limit 1];
            p.SOD_XS_ActivoIntegracion__c = true;
            update p;

            SOD_XS_Country__c pais = SOD_XS_SearchClientsBUCController.getUserCountry();
            System.assert(pais != null);
        }
        Test.stopTest();            
    } 
    
    /**
    * @description new record case "Reclamo"
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        06/08/2020
    */
    @isTest public static void newRcdCase_Test(){
        Test.startTest();
        String res = SOD_XS_SearchClientsBUCController.newRcdCase('SOD_XS_Reclamo');
        System.assert(res != null);
        Test.stopTest();
    }
}