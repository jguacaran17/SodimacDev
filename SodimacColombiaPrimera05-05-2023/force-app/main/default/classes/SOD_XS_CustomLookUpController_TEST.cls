/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 13/07/2020
Description  : Test Class for the SOD_XS_CustomLookUpController class
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade Alvi?rez 	EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA			13/07/2020		Craeted the file/class
1.1      LMG            28/01/2021      Optimize test class
********************************************************************************/

@isTest
public class SOD_XS_CustomLookUpController_TEST {
    
    @testSetup static void setup(){
        test.startTest();
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '10663558-7','CL');
        test.stopTest();
    }
    /**
    * @description Test class for Search objects for the custom lookup
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        13/07/2020
    */
    static testMethod void fetchLookUpValuesTest(){
        
        
        Test.startTest();
        SOD_XS_Country__c pais = SOD_XS_DataFactory.createPais(false);
        pais.SOD_XS_ActivoIntegracion__c = true;
        insert pais;
        
        List < sObject > lista = SOD_XS_CustomLookUpController.fetchLookUpValues('C', 'SOD_XS_Country__c');
        if(lista.size() > 0){
            System.assertEquals(1,lista.size());
        }
        
        Account cuenta = [Select id, name from Account where SOD_XS_NroDocumento__c =: '10663558-7' ];
        cuenta.Name = 'Cliente Sodimac';
        
        List < sObject > lista2 = SOD_XS_CustomLookUpController.fetchLookUpValues('C', 'Account');
        if(lista2.size() > 0){
            System.assertEquals(1,lista2.size());
        }
        
        Test.stopTest();
        
    }
}