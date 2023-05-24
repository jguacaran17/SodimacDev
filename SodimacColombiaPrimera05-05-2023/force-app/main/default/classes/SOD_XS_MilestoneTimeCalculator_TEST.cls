/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/05/2020
Description  : Test de la Clase SOD_XS_MilestoneTimeCalculatorTest
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			28/05/2020		initial version
1.1      PLB            28/01/2021      Optimize test class
********************************************************************************/
@isTest 
private class SOD_XS_MilestoneTimeCalculator_TEST {

    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup(){
        Test.startTest();
        SOD_XS_DataFactory.createUser();         
        Test.stopTest();
    }
    
    /**
    *  @Description: test Milestone Time Calculator
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        28/05/2020
    */
    @istest
    static void testMilestoneTimeCalculator() {
        
        Test.startTest();
        SOD_XS_Bypass__c bp = new SOD_XS_Bypass__c();
        bp.SOD_XS_DesactivarFlows__c = true;
        insert bp; 
        User u = [Select id from User limit 1];
        System.runAs(u) {
            Id accId = SOD_XS_DataFactory.NewDataXS(SOD_XS_DataFactory.PRV_STR_B2C);
            Entitlement entObj = SOD_XS_DataFactory.createEntitlement(false); 
            entObj.AccountId = accId;
            entObj.StartDate = system.today();            
            Insert entObj; 
            List<Id> idCasos = new List<Id>(); 
            List<Id> idRT = new List<Id>(); 
            String idReclamo = ''; 
            Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
            
            List<Case> Casos = [select Id, SOD_XS_Motivo__c, RecordTypeId, Status
                               from Case
                               where AccountId =: accId];  
               
            for (Id idCase : rtMapById.keySet()) {            
                if((!rtMapById.get(idCase).isMaster()) && (rtMapById.get(idCase).getDeveloperName().contains('SOD_XS_'))) {
                    idRT.add(idCase);
                }
            }           
            
            List<recordType> rType = [SELECT Id, DeveloperName  
                                   FROM recordType 
                                   where Id in :idRT]; 
            
            for(recordType rt : rType) {
                    if(rt.DeveloperName == 'SOD_XS_Reclamo') {
                        idReclamo = rt.Id; 
                    }
                }
			Boolean isClosed = false; 
            for(case caso : casos) {
                if(caso.status == 'Closed') {
                	isClosed = true;  
                } else {
                    isClosed = false; 
                    idCasos.add(caso.Id);
                    caso.SOD_XS_CheckMailLlamada__c = true; 
                    if(caso.RecordTypeId == idReclamo) {
                            caso.SOD_XS_Area__c = 'Alquiler de Herramientas';             
                            caso.SOD_XS_Motivo__c = 'Disponibilidad de Herramienta';
                    } 
                }
               	if(!isClosed)
                	Update caso;
            }            
            
        }  
        
        Test.stopTest();        
    }
    
}