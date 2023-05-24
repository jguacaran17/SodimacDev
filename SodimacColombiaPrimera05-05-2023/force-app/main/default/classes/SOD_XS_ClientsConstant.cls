/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/12/2020
Description  : Constant variables for the Client object
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            17/12/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_ClientsConstant {

    /**
    *  @Description: Declaration of static variables
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        17/12/2020
    */
    public static final String PBC_STR_COMMA;
    public static final String PBC_STR_B2C;
    public static final String PBC_STR_B2B;
    public static final String PBC_STR_FIELDSB2BVALIDATE;
    public static final String PBC_STR_FIELDSB2CVALIDATE;
    public static final String PBC_STR_FIELDSB2BUPPERCASE;
    public static final String PBC_STR_FIELDSB2CUPPERCASE;
    public static final String PBC_STR_FIELDSB2CLOWERCASE;
    public static final String PBC_STR_FIELDSB2BLOWERCASE;
    public static final String PBC_OBJ_ACC;
    public static final String PBC_WS_BUC;
    public static final String PBC_URL_BASE;
    public static final String PBC_STR_PRS;
    public static final String PBC_STR_EMP;
    public static final String PBC_STR_EMAIL;
    public static final String PBC_STR_TLF;
    public static final String PBC_STR_CLL;
    public static final String PBC_CASE_FLC;
    public static final String PBC_CASE_CNS;
    public static final String PBC_URL_CASE;
    public static final String PBC_PTH_CRT;
    public static final String PBC_PTH_UPD;
    public static final String PBC_PTH_DEL;
    public static final String PBC_MSG_ACC;
    public static final Map<Id,Schema.RecordTypeInfo> PBC_MAP_RCT;
    public static final Map<String, String> PBC_MAP_DOCTYPE;
    public static final List<SOD_XS_Tipo_de_documento_BUC__mdt> PBC_MAP_DOCTYPEBYCOUNTRY;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        17/12/2020
    */
    static {

        /** Cross constants*/
        PBC_OBJ_ACC = 'Account';
        PBC_STR_COMMA = ',';
        PBC_STR_B2C = 'PersonAccount';
        PBC_STR_B2B = 'Business_Account';
        PBC_STR_PRS = 'PERSONA';
        PBC_STR_EMP = 'EMPRESA';
        PBC_STR_EMAIL = 'EMAIL';
        PBC_STR_TLF = 'TELEFONO';
        PBC_STR_CLL = 'CELULAR';
        PBC_MAP_RCT = Account.sobjectType.getDescribe().getRecordTypeInfosById();
        /** term of cross constants */

        /** Constants for the SOD_XS_SearchClientsBUCController class*/
        PBC_WS_BUC = Label.SOD_XS_Buscar_Clientes;
        PBC_CASE_FLC = 'SOD_XS_Felicitacion';
        PBC_CASE_CNS = 'SOD_XS_Consulta';
        PBC_URL_CASE = '/lightning/o/Case/new?recordTypeId=';
        PBC_MAP_DOCTYPE =  getDocTypeMap();
        PBC_MAP_DOCTYPEBYCOUNTRY = getDocTypeByCountry();
        /** term of SOD_XS_SearchClientsBUCController class constants */

        /** Constants for the SOD_XS_UpsertClientsBUCController class*/
        PBC_PTH_CRT = Label.SOD_XS_Crear_Cliente;
        PBC_PTH_UPD = Label.SOD_XS_Actualizar_Cliente;
        PBC_PTH_DEL = Label.SOD_XS_Eliminar_Campo;
        PBC_MSG_ACC = 'Updating clients to the BUC is not a batch process. Customer(Account) Id: ';
        /** term of SOD_XS_UpsertClientsBUCController class constants */

        /** Constants for the trigger. Class Name: SOD_XS_AccountTriggerHandler*/
        PBC_STR_FIELDSB2BVALIDATE  = 'Name,SOD_XS_TipoDocumento__c,SOD_XS_NroDocumento__c,SOD_XS_AdministrativeArea__c,SOD_XS_Locality__c,SOD_XS_SubAdministrativeArea__c,SOD_XS_Country__c,SOD_XS_Direccion__c,SOD_XS_ReferenciaDireccion__c,Phone';
        PBC_STR_FIELDSB2CVALIDATE = 'FirstName,LastName,PersonHasOptedOutOfEmail,PersonDoNotCall,PersonMobilePhone,PersonHomePhone,PersonEmail,SOD_XS_TipoDocumento__c,SOD_XS_NroDocumento__c,SOD_XS_AdministrativeArea__c,SOD_XS_Locality__c,SOD_XS_SubAdministrativeArea__c,SOD_XS_Country__c,SOD_XS_Direccion__c,SOD_XS_ReferenciaDireccion__c';
        PBC_STR_FIELDSB2BUPPERCASE = 'Name';
        PBC_STR_FIELDSB2CUPPERCASE = 'FirstName,LastName';
        PBC_STR_FIELDSB2CLOWERCASE = 'PersonEmail';
        PBC_STR_FIELDSB2BLOWERCASE = '';
        /** term of trigger constants */
    }

    /**
    *  @Description: Get the types of documents
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static List<SOD_XS_Tipo_de_documento_BUC__mdt> getDocTypeByCountry() {
        List<SOD_XS_Tipo_de_documento_BUC__mdt> docTypeList = [SELECT Label, MasterLabel, SOD_XD_Parametro_BUC__c, SOD_XS_Valor_predeterminado__c, SOD_XS_CodigoPais__c, SOD_XS_Pais__c, SOD_XS_TipoRegistro__c
                                                               FROM SOD_XS_Tipo_de_documento_BUC__mdt];        
        return docTypeList;
    }
    
    /**
    *  @Description: Get the types of documents for the BUC
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    public static Map<String, String> getDocTypeMap() {
        Map<String, String> str = new Map<String, String>();
        for (SOD_XS_Tipo_de_documento_BUC__mdt tdp :  getDocTypeByCountry()) {
            str.put(tdp.SOD_XD_Parametro_BUC__c, tdp.Label);
        }
        return str;
    }
}