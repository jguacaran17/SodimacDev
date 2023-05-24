/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 03/08/2020
Description  : JSON mapping to create and update client in BUC
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            08/07/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_MAPJSONClientsBUC {
    
    private static final String PVR_STR_PRS;
    private static final String PVR_STR_EMP;
    private static final String PVR_STR_EMAIL;
    private static final String PVR_STR_TLF;
    private static final String PVR_STR_CLL;
    private static final String PVR_SFDC_EMP;
    private static final String PVR_SFDC_PRS;
    private static final String PVR_SFDC_UDF;
    private static final String PVR_SFDC_ACT;
    private static final String PVR_SFDC_NAP;
    private static final String DOCUMENT_TYPE;
    private static final String DOCUMENT_TYPE_CO;
    private static final String CNT_CODE_CO;
    private static final Map<String, String> DOCTYPEMAP;
    
    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    static {
        PVR_STR_PRS = SOD_XS_ClientsConstant.PBC_STR_PRS;
        PVR_STR_EMP = SOD_XS_ClientsConstant.PBC_STR_EMP;
        PVR_STR_EMAIL = SOD_XS_ClientsConstant.PBC_STR_EMAIL;
        PVR_STR_TLF = SOD_XS_ClientsConstant.PBC_STR_TLF;
        PVR_STR_CLL = SOD_XS_ClientsConstant.PBC_STR_CLL;
        PVR_SFDC_EMP = SOD_XS_ClientsConstant.PBC_STR_B2B;
        PVR_SFDC_PRS = SOD_XS_ClientsConstant.PBC_STR_B2C;
        PVR_SFDC_UDF = 'No Definido';
        PVR_SFDC_ACT = 'ACTIVO';
        PVR_SFDC_NAP = 'N/A';
        DOCUMENT_TYPE = 'PASAPORTE';
        DOCUMENT_TYPE_CO = 'PAS';
        CNT_CODE_CO = 'CO';
        DOCTYPEMAP = SOD_XS_UpsertClientsBUCController.getDocTypeMap();
    }
    
    /**
    *  @Description: JSON mapping to create and update client in BUC
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static SOD_XS_JSONSendClientsBUC clientMapping(Account acc, String cntCode) {
        
        SOD_XS_JSONSendClientsBUC clt = new SOD_XS_JSONSendClientsBUC();
        String rcdType = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).getDeveloperName();
        String cntType = rcdType == PVR_SFDC_EMP ? PVR_STR_EMP : PVR_STR_PRS;
        
        clt.customerType = cntType;
        clt.customerCategory = acc.SOD_XS_CategoriaCliente__c;
        clt.comercialState = PVR_SFDC_UDF;
        clt.id = 0;
        clt.status = PVR_SFDC_ACT;
        clt.employee = false;
        
        clt.identification = new SOD_XS_JSONClientsBUC.Cls_identification();
        if(DOCTYPEMAP.get(acc.SOD_XS_TipoDocumento__c) == DOCUMENT_TYPE && cntCode == CNT_CODE_CO)
        {
            clt.identification.type = DOCUMENT_TYPE_CO;
        } else {
            clt.identification.type = DOCTYPEMAP.get(acc.SOD_XS_TipoDocumento__c); 
        }
        clt.identification.value = ( clt.identification.type == 'NIT')?acc.SOD_XS_NroDocumento__c.replace('-',''):acc.SOD_XS_NroDocumento__c;
        clt.identification.country = cntCode;
        
        clt.personalData = new SOD_XS_JSONClientsBUC.Cls_personalData();
        clt.personalData.birthday = '';
        clt.personalData.occupation = PVR_SFDC_UDF;
        clt.contactMethods = new List<SOD_XS_JSONClientsBUC.Cls_contactMethods>();
        
        if (cntType == PVR_STR_PRS) {
            clt.isSubscribedToMessaging = !acc.PersonHasOptedOutOfEmail;
            clt.personalData.name = acc.FirstName;
            clt.personalData.lastName = acc.LastName;
            clt.personalData.fantasyName = acc.FirstName + ' ' + acc.LastName;
            if (!acc.SOD_XS_ContactoNotienecorreo__pc) {
                SOD_XS_JSONClientsBUC.Cls_contactMethods ctc = new SOD_XS_JSONClientsBUC.Cls_contactMethods();
                ctc.id = (acc.SOD_XS_IdPersonEmail__c != null)?Integer.valueOf(acc.SOD_XS_IdPersonEmail__c):0;
                ctc.code = PVR_STR_EMAIL;
                ctc.value = acc.PersonEmail;
                ctc.haveSubscription = !acc.PersonHasOptedOutOfEmail;
                ctc.isPrincipal = false;
                clt.contactMethods.add(ctc);
            }
            if (acc.PersonHomePhone != Null) {
                SOD_XS_JSONClientsBUC.Cls_contactMethods ctc = new SOD_XS_JSONClientsBUC.Cls_contactMethods();
                ctc.id = (acc.SOD_XS_IdPersonHomePhone__c != null)?Integer.valueOf(acc.SOD_XS_IdPersonHomePhone__c):0;
                ctc.code = PVR_STR_TLF;
                ctc.value = acc.PersonHomePhone;
                ctc.haveSubscription = !acc.PersonDoNotCall;
                ctc.isPrincipal = true;
                clt.contactMethods.add(ctc);
            }
            if (acc.PersonMobilePhone != Null) {
                SOD_XS_JSONClientsBUC.Cls_contactMethods ctc = new SOD_XS_JSONClientsBUC.Cls_contactMethods();
                ctc.id = (acc.SOD_XS_IdPersonMobilePhone__c != null)?Integer.valueOf(acc.SOD_XS_IdPersonMobilePhone__c):0;
                ctc.code = PVR_STR_CLL;
                ctc.value = acc.PersonMobilePhone;
                ctc.haveSubscription = !acc.PersonDoNotCall;
                ctc.isPrincipal = true;
                clt.contactMethods.add(ctc);
            }
        } else if (cntType == PVR_STR_EMP) {
            clt.personalData.name = acc.name;
            clt.personalData.lastName = '';
            clt.personalData.fantasyName = '';
            clt.isSubscribedToMessaging = false;
            if (acc.Phone != Null) {
                SOD_XS_JSONClientsBUC.Cls_contactMethods ctc = new SOD_XS_JSONClientsBUC.Cls_contactMethods();
                ctc.id = (acc.SOD_XS_IdPhone__c != null)?Integer.valueOf(acc.SOD_XS_IdPhone__c):0;
                ctc.code = PVR_STR_TLF;
                ctc.value = acc.Phone;
                ctc.haveSubscription = false;
                ctc.isPrincipal = true;
                clt.contactMethods.add(ctc);
            }
        }
        
        clt.contacts = new List<SOD_XS_JSONClientsBUC.Cls_contacts>();
        if (acc.SOD_XS_AdministrativeArea__c != Null || acc.SOD_XS_Locality__c != Null || acc.SOD_XS_SubAdministrativeArea__c != Null || acc.SOD_XS_Direccion__c != Null || acc.SOD_XS_ReferenciaDireccion__c != Null) {
            clt.principalLocation = new SOD_XS_JSONClientsBUC.Cls_principalLocation();
            clt.principalLocation.id = (acc.SOD_XS_IdLocation__c != null)? Integer.valueOf(acc.SOD_XS_IdLocation__c):0;
            clt.principalLocation.address = new SOD_XS_JSONClientsBUC.Cls_address();
            clt.principalLocation.address.addressType = PVR_SFDC_NAP;
            clt.principalLocation.address.street = acc.SOD_XS_Direccion__c;
            clt.principalLocation.address.administrativeArea = acc.SOD_XS_AdministrativeArea__c != Null ? [SELECT Id, Name FROM SOD_XS_AdministrativeArea__c WHERE Id =: acc.SOD_XS_AdministrativeArea__c LIMIT 1].Name : '';
            clt.principalLocation.address.locality = acc.SOD_XS_Locality__c != Null ? [SELECT Id, Name FROM SOD_XS_Locality__c WHERE Id =: acc.SOD_XS_Locality__c LIMIT 1].Name : '';
            clt.principalLocation.address.subAdministrativeArea = acc.SOD_XS_SubAdministrativeArea__c != Null ? [SELECT Id, Name FROM SOD_XS_SubAdministrativeArea__c WHERE Id =: acc.SOD_XS_SubAdministrativeArea__c LIMIT 1].Name : '';
            clt.principalLocation.address.reference = acc.SOD_XS_ReferenciaDireccion__c;
        }

        return clt;
    }
}