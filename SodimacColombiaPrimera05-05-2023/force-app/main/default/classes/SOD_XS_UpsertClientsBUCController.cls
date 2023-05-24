/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 24/07/2020
Description  : APEX Controller - Creating and updating clients(BUC)
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            24/07/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_UpsertClientsBUCController {
    
    @AuraEnabled public Integer rsp {get;set;}
    @AuraEnabled public Account acc {get;set;}
    
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static SOD_XS_UpsertClientsBUCController initClass(Id rcdId) {
        SOD_XS_UpsertClientsBUCController init = new SOD_XS_UpsertClientsBUCController();
        Account obj = getRecord(rcdId);
        init.acc = typeAcc(obj.Id, obj.isPersonAccount);
        if (init.acc.SOD_XS_IdExterno__c == Null) {
            Map<String, String> docType = getDocTypeMap();
            try {
                String res = SOD_XS_SearchClientsBUCController.webServiceBUC(docType.get(init.acc.SOD_XS_TipoDocumento__c), init.acc.SOD_XS_NroDocumento__c, init.acc.SOD_XS_Country__r.SOD_XS_Codigo__c);
            } catch (SOD_XS_JWTRestConnection.ServiceException e) {
                if (e.code == 404) {
                    init.rsp = 404;
                }
                String logIdentifier = SOD_XS_EnLogger.logError(e, rcdId);
            } catch (Exception e) {    
                String logIdentifier = SOD_XS_EnLogger.logError(e, rcdId);
                throwAuraException(e, logIdentifier);        
                //throw new AuraHandledException (e.getMessage());
            }
        }
        return init;
    }
    
    /**
    *  @Description: Get the client to know if it is a personal account or not
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static account getRecord(Id rcdId) {
        return [SELECT Id, isPersonAccount FROM Account WHERE Id = :rcdId];
    }
    
    /**
    *  @Description: Search for customers in salesforce for personal or business account
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static account typeAcc(Id rcdId, Boolean isPersonAcc) {
        Account acc;
        try {
            if (isPersonAcc) {
                acc = [SELECT FirstName, LastName, Name, SOD_XS_TipoDocumento__c, SOD_XS_NroDocumento__c, SOD_XS_ContactoNotienecorreo__pc, PersonEmail,
                       PersonHomePhone, PersonMobilePhone, SOD_XS_IdExterno__c, SOD_XS_Country__c, isPersonAccount, RecordTypeId, CreatedById, CurrencyIsoCode, SOD_XS_RegistradoBUC__c,
                       SOD_XS_Country__r.SOD_XS_Codigo__c, SOD_XS_FechaCreacionBUC__c, PersonDoNotCall, PersonHasOptedOutOfEmail, SOD_XS_ActualizacionPorIntegracion__c,
                       SOD_XS_SubAdministrativeArea__c, SOD_XS_AdministrativeArea__c, SOD_XS_Locality__c, SOD_XS_Direccion__c, SOD_XS_ReferenciaDireccion__c, SOD_XS_IdPersonHomePhone__c,
                       SOD_XS_IdPersonMobilePhone__c, SOD_XS_IdPersonEmail__c, SOD_XS_IdLocation__c, SOD_XS_CategoriaCliente__c
                       FROM Account
                       WHERE Id = :rcdId LIMIT 1];
            } else if (!isPersonAcc) {
                acc = [SELECT Name, Phone, SOD_XS_TipoDocumento__c, SOD_XS_NroDocumento__c, SOD_XS_IdExterno__c, SOD_XS_Country__c, isPersonAccount,
                       RecordTypeId, CreatedById, CurrencyIsoCode, SOD_XS_RegistradoBUC__c, SOD_XS_Country__r.SOD_XS_Codigo__c, SOD_XS_FechaCreacionBUC__c, SOD_XS_ActualizacionPorIntegracion__c,
                       SOD_XS_SubAdministrativeArea__c, SOD_XS_AdministrativeArea__c, SOD_XS_Locality__c, SOD_XS_Direccion__c, SOD_XS_ReferenciaDireccion__c, SOD_XS_IdPhone__c, SOD_XS_IdLocation__c, SOD_XS_CategoriaCliente__c
                       FROM Account
                       WHERE Id = :rcdId LIMIT 1];
            }
        } catch (Exception e) {
	    system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, Label.SOD_XS_ClienteErrorInterno, e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));
        }
        return acc;
    }
    
    /**
    *  @Description: Get the types of documents for the BUC
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static Map<String, String> getDocTypeMap() {
        Map<String, String> str = new Map<String, String>();
        for (SOD_XS_Tipo_de_documento_BUC__mdt tdp :  SOD_XS_ClientsConstant.PBC_MAP_DOCTYPEBYCOUNTRY) {
            str.put(tdp.Label, tdp.SOD_XD_Parametro_BUC__c);
        }
        return str;
    }
    
    /**
    *  @Description: Wrapper for client creation service
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        03/08/2020
    *  @Date:        27/10/2020
    */
    @AuraEnabled
    public static String createClientBUC(Account acc) {
        Map<Id, String> cntMap = getMapCountry();
        try {
            String rsp = wsCreateClientBUC(SOD_XS_MAPJSONClientsBUC.clientMapping(acc, cntMap.get(acc.SOD_XS_Country__c)), cntMap.get(acc.SOD_XS_Country__c));            
            SOD_XS_JSONResponseClientsBUC clt = (SOD_XS_JSONResponseClientsBUC)JSON.deserialize(rsp , SOD_XS_JSONResponseClientsBUC.class);
            SOD_XS_MAPSFDCClientsBUC objClass = new SOD_XS_MAPSFDCClientsBUC();
            acc.SOD_XS_IdExterno__c =  String.valueOf(clt.id);
            acc.SOD_XS_RegistradoBUC__c = true;
            acc.SOD_XS_FechaCreacionBUC__c = system.now();
            acc.SOD_XS_ActualizacionPorIntegracion__c = true;
            acc = objClass.getDirection(acc, clt.principalLocation);
            if (acc.isPersonAccount) {
                acc = objClass.getContactabilityDataPers(acc, objClass.getCtbData(clt.contactMethods));
                update acc;
            } else {
                acc = objClass.getContactabilityDataBiz(acc, objClass.getCtbData(clt.contactMethods));
                update acc;
            }

        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, acc.Id);
            throwAuraException(e, logIdentifier); 
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, e.getMessage(), e.code);
            throw new AuraHandledException (JSON.serialize(data));*/
        } catch(Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, acc.Id);
            throwAuraException(e, logIdentifier); 
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, Label.SOD_XS_ClienteErrorInterno, e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        }        
        return acc.SOD_XS_IdExterno__c;
    }
    
    /**
    *  @Description: Customer creation web service
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static String wsCreateClientBUC(SOD_XS_JSONSendClientsBUC clt, String cntCode) {
        
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('X-country', String.valueOf(clt.identification.country));
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put('header', mapHeader);
        SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(cntCode, SOD_XS_ClientsConstant.PBC_PTH_CRT);
        return jwt.callService(setConf, JSON.serialize(clt, true)).getBody();
        
    }
    
    /**
    *  @Description: Customer update web service
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static Integer wsUpdateClientBUC(SOD_XS_JSONSendClientsBUC clt, String idExterno, String cntCode) {

        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('X-country', String.valueOf(clt.identification.country));
        Map<String, String> pathParam = new Map<String, String>();
        pathParam.put('idExterno', idExterno);
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put('header', mapHeader);
        setConf.put('path', pathParam);
        SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(cntCode, SOD_XS_ClientsConstant.PBC_PTH_UPD);
        return jwt.callService(setConf, JSON.serialize(clt, true)).getStatusCode();

    }
    
    /**
    *  @Description: Customer selected fields Delete web service
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        11/02/2021
    */
    public static Integer wsDeleteFieldClientBUC(String idExterno, String idField, String cntCode) {

        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('X-country', cntCode);
        Map<String, String> pathParam = new Map<String, String>();
        pathParam.put('idExterno', idExterno);
        pathParam.put('contact-methods', 'contact-methods');
        pathParam.put('idField', idField);
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put('header', mapHeader);
        setConf.put('path', pathParam);
        SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(cntCode, SOD_XS_ClientsConstant.PBC_PTH_DEL);
        return jwt.callService(setConf, '').getStatusCode();
    }    
    
    /**
    *  @Description: Method invoked by a process builder when updating a client
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static void enqueueUpdateClientBUC(List<Account> accounts, String idFieldDel) {
        System.enqueueJob(new UpdateClientBUC(accounts, idFieldDel));
    }
    
    /**
    *  @Description: Queueable method for updating clients in the BUC
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public class UpdateClientBUC implements Queueable, Database.AllowsCallouts {
        
        private List<Account> acc;
        private String idFieldDel;
        public UpdateClientBUC(List<Account> records, String idFieldDel) {
            this.acc = records;
            this.idFieldDel = idFieldDel; 
        }
        
        public void execute(QueueableContext context) {
            Map<Id, String> cntMap = getMapCountry();
            if (acc.size() == 1) {
                Account a = acc[0];
                try {
                    if(idFieldDel == null){
                        wsUpdateClientBUC(SOD_XS_MAPJSONClientsBUC.clientMapping(a, cntMap.get(a.SOD_XS_Country__c)), a.SOD_XS_IdExterno__c, cntMap.get(a.SOD_XS_Country__c));
                    }else{
                        wsDeleteFieldClientBUC(a.SOD_XS_IdExterno__c, idFieldDel,  cntMap.get(a.SOD_XS_Country__c));
                    }
                        
                } catch (SOD_XS_JWTRestConnection.ServiceException e) {
                    if ( e.code == 204 ) {
                        a = [SELECT Id,SOD_XS_FechaActualizacionBUC__c FROM Account WHERE Id = :a.Id LIMIT 1]; 
                        a.SOD_XS_FechaActualizacionBUC__c = system.now();
                        update a;
                    }
                    String logIdentifier = SOD_XS_EnLogger.logError(e, a.Id);
                }                                
            }            
        }
    }
    
    /**
    *  @Description: Get a map of all countries
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static Map<Id, String> getMapCountry() {
        Map<Id, String> cntMap = new Map<Id, String>();
        for (SOD_XS_Country__c cnt : [SELECT id, Name, SOD_XS_Codigo__c, CurrencyIsoCode FROM SOD_XS_Country__c]) {
            cntMap.put(cnt.Id, cnt.SOD_XS_Codigo__c);
        }
        return cntMap;
    }
    
    /**
    *  @Description: Throw Aura Handled Exception 
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    private static void throwAuraException(Exception e, String logIdentifier){
        throw new AuraHandledException (SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()));
    }

}