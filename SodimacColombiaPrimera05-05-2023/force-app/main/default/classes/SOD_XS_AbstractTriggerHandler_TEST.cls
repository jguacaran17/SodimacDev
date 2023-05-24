/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 03/09/2020
Description  : Test Class for Object SOD_XS_AbstractTriggerHandler
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye         RSO
Eilhert Andrade A           EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO            03/09/2020      Initial TEST class
1.1      EAA            07/09/2020      Update methods
1.2      LMG            27/01/2021      Optimize test class
********************************************************************************/

@isTest
public without sharing class SOD_XS_AbstractTriggerHandler_TEST {

    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup(){
        test.startTest();        
        Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '12032234-6','CL');
        test.stopTest();
    }
    public with sharing class SOD_XS_DummyTriggerHandler extends SOD_XS_AbstractTriggerHandler{
    }

    /**
    *  @description Method new data. return a case
    *  @Author      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @date        03/09/2020
    */    
    static Case  getNewCase (){
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '12032234-6'];

        List<Case> casos = new List<Case>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();        
                
        for (Id idCase : rtMapById.keySet()){
            if(rtMapById.get(idCase).getName() == 'Reclamo' || rtMapById.get(idCase).getName() == 'Solicitud')
            {
                if(!rtMapById.get(idCase).isMaster()){
                    Case caso = (Case) SOD_XS_DataFactory.createCase(false);
                    caso.AccountId= acc.Id;
                    caso.RecordTypeId = idCase;
                    caso.SOD_XS_FechaDeCompra__c =Date.today();
                    casos.add(caso);
                }
            }                   
        }
        return casos[0];
    }

    /**
    *  @description Main method test run
    *  @Author      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @date        03/09/2020
    */
   @isTest static void triggerChangeValueTest(){
        Test.startTest();
        Boolean result = false;
        Case newCase = getNewCase();

        SOD_XS_DummyTriggerHandler handler = new SOD_XS_DummyTriggerHandler();

        try {
            insert newCase;
            result = handler.isChanged(newCase, 'Subject');
        }
        catch(Exception e){
            System.assert(result);
        }

        System.assert(result);
        Test.stopTest();
    }
    /**
    *  @description method test insert virtual metohods from abstract class 
    *  @Author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @date        07/09/2020
    */    
    @isTest static void triggerInsertTest(){
        Test.startTest();
        Case newCase = getNewCase();
        SOD_XS_DummyTriggerHandler handler = new SOD_XS_DummyTriggerHandler();
        insert newCase;
        handler.beforeInsert();
        handler.afterInsert();
        String boleta = [Select SOD_XS_DocumentoDeVenta__r.SOD_XS_TipoDeDdocumento__c from Case limit 1]?.SOD_XS_DocumentoDeVenta__r.SOD_XS_TipoDeDdocumento__c;
        System.assertEquals(boleta, null);
        Test.stopTest();
    }
    /**
    *  @description method test Update virtual metohods from abstract class 
    *  @Author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @date        07/09/2020
    */    
    @isTest static void triggerUpdateTest(){
        SOD_XS_Bypass__c bypassvr = new SOD_XS_Bypass__c();
        bypassvr.SOD_XS_DesactivarValidationRules__c  = true;
        insert bypassvr;
        Test.startTest();
        Case newCase = getNewCase();
        SOD_XS_DummyTriggerHandler handler = new SOD_XS_DummyTriggerHandler();
        insert newCase;
        newCase.Description = '123456789';
        update newCase;
        handler.beforeUpdate();
        handler.afterUpdate();
        String descripcion = [Select Description from Case limit 1]?.Description;
        System.assertEquals(descripcion, '123456789');
        Test.stopTest();
    }
    /**
    *  @description method test Delete virtual metohods from abstract class 
    *  @Author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @date        07/09/2020
    */    
    @isTest static void triggerDeleteTest(){
        Test.startTest();
        Case newCase = getNewCase();
        SOD_XS_DummyTriggerHandler handler = new SOD_XS_DummyTriggerHandler();
        insert newCase;
        delete newCase;
        handler.beforeDelete();
        handler.afterDelete();
        handler.afterUndelete();
        
        String boleta = [Select SOD_XS_DocumentoDeVenta__r.SOD_XS_TipoDeDdocumento__c from Case limit 1]?.SOD_XS_DocumentoDeVenta__r.SOD_XS_TipoDeDdocumento__c;
        System.assertEquals(boleta, null);
        Test.stopTest();
    }       
    /**
    *  @description Main method test run
    *  @Author      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @date        03/09/2020
    */
     @isTest static void triggerErrorTest(){
        Test.startTest();
        Boolean result = false;
        Case newCase = getNewCase();

        SOD_XS_DummyTriggerHandler handler = new SOD_XS_DummyTriggerHandler();
        newCase.Description ='Error al guardar';
        
        String id = newCase.Id;
        try {
            insert newCase;         
        }
        catch(Exception e){
            System.assert( 0 == [SELECT Id FROM Case].size());
        }

        Test.stopTest();
    }
}