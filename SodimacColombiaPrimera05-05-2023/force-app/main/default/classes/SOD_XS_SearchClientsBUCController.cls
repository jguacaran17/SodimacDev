/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 08/07/2020
Description  : APEX Controller - Search clients(BUC & SFCD)
History      : CMRSC-3784, CMRSC-4548
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            08/07/2020      initial version
2.0      RSO            15/10/2020      bug CMRSC-4548
********************************************************************************/
public without sharing class SOD_XS_SearchClientsBUCController {
    
    @AuraEnabled public String accLabels {get;set;}
    @AuraEnabled public List<SOD_XS_Tipo_de_documento_BUC__mdt> docType {get;set;}
    @AuraEnabled public String rcdTypeCaseFLC {get;set;}
    @AuraEnabled public String rcdTypeCaseCNS {get;set;}
    @AuraEnabled public List<String> rcdTypeValues{get;set;}
    @AuraEnabled public SOD_XS_Country__c dftCnt{get;set;}
    
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static SOD_XS_SearchClientsBUCController initClass() {
        SOD_XS_SearchClientsBUCController obj = new SOD_XS_SearchClientsBUCController();
        try {
            obj.accLabels = SOD_XS_EnUtility.getDescribedObjects( new List<String>{SOD_XS_ClientsConstant.PBC_OBJ_ACC} );
            obj.rcdTypeValues = fetchRecordTypeValues();
            obj.rcdTypeCaseFLC = SOD_XS_ClientsConstant.PBC_CASE_FLC;
            obj.rcdTypeCaseCNS = SOD_XS_ClientsConstant.PBC_CASE_CNS;
            obj.docType = SOD_XS_ClientsConstant.PBC_MAP_DOCTYPEBYCOUNTRY;
            obj.dftCnt = getUserCountry();
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, e.getMessage(), e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        }
        return obj;
    }
    
    /**
    *  @Description: Wrapper used to find out if a customer exists or not
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public class WrapAccount {
        @AuraEnabled public Account acc {get; set;}
        @AuraEnabled public Boolean exists {get; set;}
        
        //Constructor used when instantiating an account. The exists value indicates whether or not the record exists in the SFCD DB
        public wrapAccount(Account a) {
            acc = a;
            exists = false;
        }
    }
    
    /**
    *  @Description: Get all types of account records
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();    
        Map<Id, String> str = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getDeveloperName() == SOD_XS_ClientsConstant.PBC_STR_B2C || rt.getDeveloperName() == SOD_XS_ClientsConstant.PBC_STR_B2B) {
                str.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return str.values();
    }
    
    /**
    *  @Description: Get all types of account records
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static Map<String, id> getRecTypeMap(String recordTypeLabel){
        Map<String, id> str;

        try {
            Id recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
            String devName = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getDeveloperName();
            str = new Map<String, id>{devName => recid};   
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());           
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, Label.SOD_XS_ClienteErrorInterno, e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        }

        return str;
    }
    
    /**
    *  @Description: Get the default country the user has
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static SOD_XS_Country__c getUserCountry() {
        SOD_XS_Country__c cnt = new SOD_XS_Country__c();
        try {
            String str = [SELECT Country FROM user WHERE id =: UserInfo.getUserId()].country;
            cnt = [SELECT id, Name, SOD_XS_Codigo__c, CurrencyIsoCode FROM SOD_XS_Country__c WHERE SOD_XS_ActivoIntegracion__c = TRUE AND (SOD_XS_Codigo__c =: str OR Name =: str) LIMIT 1];
        } catch(Exception e) {
            system.debug('e.getMessage()' + e.getMessage() + 'getTypeName' + e.getTypeName() + ' e.getCause()' + e.getCause());
        }        
        return cnt;
    }
    
    /**
    *  @Description: Get URL to force case creation page
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static String newRcdCase(String devName) {
        String url;
        try {
            url = System.URL.getSalesforceBaseUrl().toExternalForm() + SOD_XS_ClientsConstant.PBC_URL_CASE + Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(devName).getRecordTypeId();
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());           
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, Label.SOD_XS_ClienteErrorInterno, e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        }
        return url;
    }

    /**
    *  @Description: Wrapping for customer search service
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static string searchClientBUC(String docType, String docNumber, String cntCode) {
        String str;
        try {
            str = webServiceBUC(docType, docNumber, cntCode);
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, e.getMessage(), e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, e.getMessage(), e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        }
        return str;
    }
    
    /**
    *  @Description: Web service that gets customers
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static String webServiceBUC(String docType, String docNumber, String cntCode) {
        Map<String, String> pathParam = new Map<String, String>();
        pathParam.put('identificationCountry', cntCode);
        pathParam.put('identificationType', docType);
        if(docType == 'NIT'){
            docNumber = docNumber.replace('-','');
        }
        pathParam.put('value', docNumber);
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('X-country',cntCode);
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put('header', mapHeader);
        setConf.put('path', pathParam);
        SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(cntCode, SOD_XS_ClientsConstant.PBC_WS_BUC);
        return jwt.callService(setConf,'').getBody();
    }    
    
    /**
    *  @Description: Wrapping method used to find out if a customer exists or not
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    @AuraEnabled
    public static WrapAccount newRcdAcc(String jsonObj, String docTypeSFDC, String docNumSFCD, SOD_XS_Country__c rcdCnt, Id rcdType) {
        WrapAccount wrp;
        try {
            wrp = mappingAcc(jsonObj, docTypeSFDC, docNumSFCD, rcdCnt, rcdType);
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, Label.SOD_XS_ClienteErrorInterno, e.getLineNumber());
            throw new AuraHandledException (JSON.serialize(data));*/
        }
        return wrp;
    }
    
    /**
    *  @Description: Method to map the client whether it exists in salesforce or in the buc / Bug (CMRSC-4548)
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        03/08/2020
    *  @Date:        15/10/2020
    */
    public static WrapAccount mappingAcc(String jsonObj, String docTypeSFDC, String docNumSFCD, SOD_XS_Country__c rcdCnt, Id rcdType) {
        
        String rcdTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(rcdType).getDeveloperName();
        WrapAccount wrp;

        if (jsonObj != null && jsonObj != Label.SOD_XS_ERROR404 && jsonObj != Label.SOD_XS_ERROR500 && jsonObj != Label.SOD_XS_ERROR503) {

            SOD_XS_JSONResponseClientsBUC obj = (SOD_XS_JSONResponseClientsBUC)JSON.deserialize(jsonObj, SOD_XS_JSONResponseClientsBUC.class);
            wrp = typeAcc(obj.customerType, String.valueOf(obj.id), SOD_XS_ClientsConstant.PBC_MAP_DOCTYPE.get(docTypeSFDC), docNumSFCD, rcdCnt, rcdType);
            SOD_XS_MAPSFDCClientsBUC objClass = new SOD_XS_MAPSFDCClientsBUC(wrp.acc, obj);
            wrp.acc = objClass.mappingAcc(wrp.exists, rcdType);

        } else {
            wrp = typeAcc(rcdTypeName, 'exists(Null)', SOD_XS_ClientsConstant.PBC_MAP_DOCTYPE.get(docTypeSFDC), docNumSFCD, rcdCnt, rcdType);
        }
        return wrp;
    }
    
    /**
    *  @Description: Search for customers in salesforce for personal or business account
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static WrapAccount typeAcc(String typeAcc, String externalId, String docTypeSFDC, String docNumSFCD, SOD_XS_Country__c rcdCnt, Id rcdType) {
        
        WrapAccount wrp = new WrapAccount(new Account());
        try {
            if (typeAcc == SOD_XS_ClientsConstant.PBC_STR_PRS || typeAcc == SOD_XS_ClientsConstant.PBC_STR_B2C) {
                wrp.acc = [SELECT FirstName, LastName, Name, SOD_XS_TipoDocumento__c, SOD_XS_NroDocumento__c, SOD_XS_ContactoNotienecorreo__pc, PersonEmail,
                           PersonHomePhone, PersonMobilePhone, SOD_XS_IdExterno__c, SOD_XS_Country__c, isPersonAccount, RecordTypeId, CreatedById, CurrencyIsoCode, SOD_XS_RegistradoBUC__c,
                           SOD_XS_ActualizacionPorIntegracion__c, SOD_XS_SubAdministrativeArea__c, SOD_XS_AdministrativeArea__c, SOD_XS_Locality__c, SOD_XS_Direccion__c, SOD_XS_ReferenciaDireccion__c,
                           SOD_XS_IdPersonHomePhone__c, SOD_XS_IdPersonMobilePhone__c, SOD_XS_IdPersonEmail__c, SOD_XS_IdLocation__c, SOD_XS_CategoriaCliente__c
                           FROM Account
                           WHERE (SOD_XS_IdExterno__c = :externalId AND SOD_XS_Country__c =:rcdCnt.Id)
                           OR (SOD_XS_TipoDocumento__c = :docTypeSFDC AND SOD_XS_NroDocumento__c = :docNumSFCD AND SOD_XS_Country__c =:rcdCnt.Id AND RecordTypeId = :rcdType)
                           LIMIT 1];
                wrp.exists = true;
            } else if (typeAcc == SOD_XS_ClientsConstant.PBC_STR_EMP || typeAcc == SOD_XS_ClientsConstant.PBC_STR_B2B) {
                wrp.acc = [SELECT Name, Phone, SOD_XS_TipoDocumento__c, SOD_XS_NroDocumento__c, SOD_XS_IdExterno__c, SOD_XS_Country__c, isPersonAccount,
                           RecordTypeId, CreatedById, CurrencyIsoCode, SOD_XS_RegistradoBUC__c, SOD_XS_ActualizacionPorIntegracion__c,
                           SOD_XS_SubAdministrativeArea__c, SOD_XS_AdministrativeArea__c, SOD_XS_Locality__c, SOD_XS_Direccion__c, SOD_XS_ReferenciaDireccion__c,
                           SOD_XS_IdPhone__c, SOD_XS_IdLocation__c, SOD_XS_CategoriaCliente__c
                           FROM Account
                           WHERE (SOD_XS_IdExterno__c = :externalId AND SOD_XS_Country__c =:rcdCnt.Id)
                           OR (SOD_XS_TipoDocumento__c = :docTypeSFDC AND SOD_XS_NroDocumento__c = :docNumSFCD AND SOD_XS_Country__c =:rcdCnt.Id AND RecordTypeId = :rcdType)
                           LIMIT 1];
                wrp.exists = true;
            }            
        } catch(Exception e) {
            system.debug('e.getMessage()' + e.getMessage() + 'getTypeName' + e.getTypeName() + ' e.getCause()' + e.getCause());
        } finally {
            wrp.acc.SOD_XS_TipoDocumento__c = docTypeSFDC;
            wrp.acc.SOD_XS_Country__c = rcdCnt.Id;
            wrp.acc.SOD_XS_NroDocumento__c = docNumSFCD;
            wrp.acc.CurrencyIsoCode = rcdCnt.CurrencyIsoCode;
        }
        return wrp;
        
    }    

    /**
    *  @Description: Throw Aura Handled Exception 
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    private static void throwAuraException(Exception e, String logIdentifier){
        SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()), e.getLineNumber());
        throw new AuraHandledException (JSON.serialize(data));
        //throw new AuraHandledException (SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()));
    }

}