/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 21/07/2020
Description  : Test Class SOD_XS_MAPJSONClientsBUC
History      : CRMSC-5038
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade A.			EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA			23/07/2020		initial version
2.0      PLB            03/02/2021      optimize code
********************************************************************************/
@isTest
public class SOD_XS_MAPJSONClientsBUC_TEST {
    
        /**
    * @description test setup
    * @Autor       PLB/LMG, Deloitte
    * @date        01/02/2021
    */
    
    @testSetup static void setup(){
        Account cuentaPer = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '11161111-4','CL');
        Account cuentaEmp = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2B, 'RUT', '11161321-4','CL');
    }
      
    
    /**
    * @description client Mapping Person
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */
    @isTest static void clientMappingPerson_TEST(){
        Test.startTest();
        Account cuentaPer = [Select Id, FirstName, LastName, SOD_XS_ContactoNotienecorreo__pc, PersonHomePhone, PersonMobilePhone, RecordTypeId, SOD_XS_NroDocumento__c, 
                             SOD_XS_TipoDocumento__c, PersonHasOptedOutOfEmail, SOD_XS_IdPersonEmail__c, PersonEmail, PersonDoNotCall, SOD_XS_AdministrativeArea__c, SOD_XS_Locality__c,
                             SOD_XS_SubAdministrativeArea__c, SOD_XS_Direccion__c, SOD_XS_ReferenciaDireccion__c, SOD_XS_IdLocation__c, SOD_XS_IdPersonHomePhone__c, SOD_XS_IdPersonMobilePhone__c, SOD_XS_CategoriaCliente__c
                             From Account Where SOD_XS_NroDocumento__c = '11161111-4' Limit 1];
        cuentaPer.PersonHomePhone = '987654321';
        SOD_XS_JSONSendClientsBUC cltP = SOD_XS_MAPJSONClientsBUC.clientMapping(cuentaPer,'CL');
        System.assert(cltP.customerType != null);
        Test.stopTest();
    }
    /**
    * @description client Mapping Business
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        23/07/2020
    */    
    @isTest static void clientMappingBusiness_TEST(){
        Test.startTest();
        Account cuentaEmp = [Select Id, Name, Phone, SOD_XS_ContactoNotienecorreo__pc, SOD_XS_IdPhone__c, PersonHomePhone, PersonMobilePhone, RecordTypeId, SOD_XS_NroDocumento__c, 
                             SOD_XS_TipoDocumento__c, PersonHasOptedOutOfEmail, SOD_XS_IdPersonEmail__c, PersonEmail, PersonDoNotCall, SOD_XS_AdministrativeArea__c, SOD_XS_Locality__c,
                             SOD_XS_SubAdministrativeArea__c, SOD_XS_Direccion__c, SOD_XS_ReferenciaDireccion__c, SOD_XS_IdLocation__c, SOD_XS_IdPersonHomePhone__c, SOD_XS_IdPersonMobilePhone__c, SOD_XS_CategoriaCliente__c
                             From Account Where SOD_XS_NroDocumento__c = '11161321-4' Limit 1];
        SOD_XS_JSONSendClientsBUC cltE = SOD_XS_MAPJSONClientsBUC.clientMapping(cuentaEmp,'CL');
        System.assert(cltE.customerType != null);
        Test.stopTest();
    }
}