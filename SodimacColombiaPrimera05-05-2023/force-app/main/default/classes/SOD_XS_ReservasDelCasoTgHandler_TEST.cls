/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Blandon
Created Date : 29/06/2021
Description  : Test Class for Object SOD_XS_ReservasDelCaso__c Trigger
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Blandon		        Blandon
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      Blandon		29/06/2021		Initial TEST class
********************************************************************************/

@isTest
public class SOD_XS_ReservasDelCasoTgHandler_TEST {
	@isTest
    private static void process(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ]; 
        System.runAs ( thisUser ) {
            
            Test.startTest();
            
            List<Case> casos = new List<Case>();
            Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();        
            SOD_XS_DataFactory.createUser();
            User userOwner = [select id from User limit 1]; 
            Account acc = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '12032234-6','CL');
            
            SOD_XS_CentroDeCosto__c cc0 = new SOD_XS_CentroDeCosto__c();
            cc0.Name = 'SOD San Miguel';
            cc0.SOD_XS_NombreCompleto__c = 'SOD San Miguel'; 
            cc0.SOD_XS_NombreCorto__c = 'SOD San Miguel'; 
            cc0.SOD_XS_TipoDeCC__c = 'TDA';
			Insert cc0;  
            
            for (Id idCase : rtMapById.keySet()){
                if(rtMapById.get(idCase).getName() == 'Reclamo' || rtMapById.get(idCase).getName() == 'Solicitud'){
                    if(!rtMapById.get(idCase).isMaster()){
                        Case caso = (Case)SOD_XS_DataFactory.createCase(false);
                        caso.AccountId= acc.Id;
                        caso.RecordTypeId = idCase;
                        caso.SOD_XS_FechaDeCompra__c = Date.today();
                        caso.SOD_XS_CheckMailLlamada__c = true; 
                        caso.Status = 'New';
                        caso.SOD_XS_CentroCostoResponsable__c = cc0.Id;
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
                        caso.SOD_XS_CentroCostoResponsable__c = cc0.Id;
                        casos.add(caso);
                    }
                }                   
            }
            insert casos;
            
            SOD_XS_CentroDeCosto__c cc = new SOD_XS_CentroDeCosto__c();
            cc.Name = 'F.COM';
            cc.SOD_XS_NombreCompleto__c = 'F.COM'; 
            cc.SOD_XS_NombreCorto__c = 'F.COM'; 
            cc.SOD_XS_TipoDeCC__c = 'TDA';
			Insert cc;            
            
            SOD_XS_ReservasDelCaso__c res = new SOD_XS_ReservasDelCaso__c();
            res.Name = '12345';
            res.SOD_XS_NombreCliente__c = acc.Id;
            res.SOD_XS_CanalDeVenta__c = 'app';
            insert res;
            
            res.SOD_XS_CanalDeVenta__c = 'F.COM';
            update res;
            
            SOD_XS_Bypass__c bypassvr = new SOD_XS_Bypass__c();
            bypassvr.SOD_XS_DesactivarProcessBuilders__c = true;
            bypassvr.SOD_XS_DesactivarFlows__c = true;
            bypassvr.SOD_XS_DesactivarValidationRules__c  = true;
            insert bypassvr;
            
            casos[0].SOD_XS_CentroCostoResponsable__c = cc.Id; 
            update casos;
            
            SOD_XS_ReservasDelCasoTriggerHandler resCase = new SOD_XS_ReservasDelCasoTriggerHandler();
            resCase.abbCountry();
            resCase.activateAssignmentRule();
            
            Test.stopTest();
            
		}
    }    
}