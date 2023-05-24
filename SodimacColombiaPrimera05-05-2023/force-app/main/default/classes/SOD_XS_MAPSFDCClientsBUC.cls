/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/12/2020
Description  : Mapping class from a json to a client
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            28/12/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_MAPSFDCClientsBUC {

    private Account acc;
    private SOD_XS_JSONResponseClientsBUC obj;
    /**
    *  @Description: Constructor used to receive a Client and JSON from the buc
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        28/12/2020
    */
    public SOD_XS_MAPSFDCClientsBUC (Account client, SOD_XS_JSONResponseClientsBUC str) {
        this.acc = client;
        this.obj = str;
    }

    /**
    *  @Description: Empty constructor
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/12/2020
    */
    public SOD_XS_MAPSFDCClientsBUC () {}

    /**
    *  @Description: Method to map the client whether it exists in salesforce or in the buc / Bug (CMRSC-4548)
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        03/08/2020
    *  @Date:        15/10/2020
    */
    public Account mappingAcc(Boolean exists, Id rcdType) {
        acc = getDirection(acc, obj.principalLocation);// Bug (CMRSC-4548)
        acc.SOD_XS_RegistradoBUC__c = true;
        // Customer does not exist in Salesforce, but in the BUC
        if (!exists) {
            acc.SOD_XS_IdExterno__c = String.valueOf(obj.id);
            acc.RecordTypeId = rcdType;
            acc.SOD_XS_CategoriaCliente__c = obj.customerCategory;
            acc = getContactabilityData(acc);
        // Customer exists in Salesforce and also in the BUC
        } else if (exists) {
            acc.SOD_XS_IdExterno__c = acc.SOD_XS_IdExterno__c == Null ? String.valueOf(obj.id) : acc.SOD_XS_IdExterno__c;
            acc.SOD_XS_ActualizacionPorIntegracion__c = true;
            acc.SOD_XS_CategoriaCliente__c = (acc.SOD_XS_CategoriaCliente__c != null && acc.SOD_XS_CategoriaCliente__c.equals('Influencer')) ? acc.SOD_XS_CategoriaCliente__c : obj.customerCategory; // rvalenciat: CUSTCRMC-361 Segmentacion Influener PE
            acc = getContactabilityData(acc);
            update acc;
        }
        return acc;
    }

    /**
    *  @Description: Obtain the mapping of contactability data according to the type of client
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/12/2020
    */
    public Account getContactabilityData(Account accObj) {
        Map<String, SOD_XS_JSONClientsBUC.Cls_contactMethods> ctbMap = getCtbData(obj.contactMethods);
        if (obj.customerType == SOD_XS_ClientsConstant.PBC_STR_PRS) {
            accObj.FirstName = obj.personalData.name;// Bug (CMRSC-4548)
            accObj.LastName = obj.personalData.lastName;// Bug (CMRSC-4548)
            accObj = getContactabilityDataPers(accObj, ctbMap);
        } else {
            accObj.Name = obj.personalData.name;
            accObj = getContactabilityDataBiz(accObj, ctbMap);
        }
        return accObj;
    }

    /**
    *  @Description: Obtains the contactability data mapping for a Personal Account
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/12/2020
    */
    public Account getContactabilityDataPers(Account accObj, Map<String, SOD_XS_JSONClientsBUC.Cls_contactMethods> ctbMap) {
        
        accObj.PersonEmail = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_EMAIL) && SOD_XS_EnUtility.validateEmail(ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_EMAIL).value)
                             ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_EMAIL).value 
                             : Null;
        accObj.SOD_XS_ContactoNotienecorreo__pc =  accObj.PersonEmail != Null 
                                                   ? false
                                                   : true;
        accObj.PersonHomePhone = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_TLF) 
                                 ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_TLF).value
                                 : Null;
        accObj.PersonMobilePhone = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_CLL)
                                   ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_CLL).value
                                   : Null;
        accObj.SOD_XS_IdPersonHomePhone__c = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_TLF)
                                             ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_TLF).Id 
                                             : 0;
        accObj.SOD_XS_IdPersonMobilePhone__c = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_CLL)
                                               ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_CLL).Id
                                               : 0;
        accObj.SOD_XS_IdPersonEmail__c = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_EMAIL)
                                         ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_EMAIL).Id
                                         : 0;
        return accObj;
    }

    /**
    *  @Description: Obtains the contactability data mapping for a Business Account
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/12/2020
    */
    public Account getContactabilityDataBiz(Account accObj, Map<String, SOD_XS_JSONClientsBUC.Cls_contactMethods> ctbMap) {
        accObj.Phone = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_TLF)
                       ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_TLF).value
                       : Null;
        accObj.SOD_XS_IdPhone__c = ctbMap.containsKey(SOD_XS_ClientsConstant.PBC_STR_TLF)
                                   ? ctbMap.get(SOD_XS_ClientsConstant.PBC_STR_TLF).Id
                                   : 0;
        return accObj;
    }


    /**
    *  @Description: BUC code map: search the largest element in the list / Bug (CMRSC-4548)
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        03/08/2020
    *  @Date:        15/10/2020
    */
    public Map<String, SOD_XS_JSONClientsBUC.Cls_contactMethods>  getCtbData(SOD_XS_JSONClientsBUC.Cls_contactMethods[] ctb) {
        Map<String, SOD_XS_JSONClientsBUC.Cls_contactMethods> ctbMap = new  Map<String, SOD_XS_JSONClientsBUC.Cls_contactMethods>();
        Integer phoneIndex = 0;
        Integer phoneId = 0;
        Integer celIndex = 0;
        Integer celId = 0;
        Integer emailIndex = 0;
        Integer emailId = 0;

        // search the element with largest id
        for (integer i = 0; i < ctb.size(); i++) {
            if (ctb[i].code.toUpperCase('es').compareTo(SOD_XS_ClientsConstant.PBC_STR_EMAIL) == 0 && ctb[i].id >= emailId) { 
                emailIndex = i; 
                emailId = ctb[i].id;
            }
            if (ctb[i].code.toUpperCase('es').compareTo(SOD_XS_ClientsConstant.PBC_STR_TLF) == 0 && ctb[i].id >= phoneId) { 
                phoneIndex = i; 
                phoneId = ctb[i].id;
            }
            if (ctb[i].code.toUpperCase('es').compareTo(SOD_XS_ClientsConstant.PBC_STR_CLL) == 0 && ctb[i].id >= celId) { 
                celIndex = i; 
                celId = ctb[i].id;
            }
        }

        // if the largest id was found, then assign the values 
        if (emailId > 0) {
            ctbMap.put(ctb[emailIndex].code, ctb[emailIndex]);
        }
        if (phoneId > 0) {
            ctbMap.put(ctb[phoneIndex].code, ctb[phoneIndex]);
        }
        if (celId > 0) {
            ctbMap.put(ctb[celIndex].code, ctb[celIndex]);
        }
        return ctbMap;
    }

    /**
    *  @Description: Get direction of client / Bug (CMRSC-4548)
    *  @Author:      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        03/08/2020
    *  @Date:        15/10/2020
    */
    public Account getDirection(Account accObj, SOD_XS_JSONClientsBUC.Cls_principalLocation[] pplLoc) {
        Integer locIndex = 0;
        Integer locId = 0;

        // search the element with largest id
        for (integer i = 0; i < pplLoc.size(); i++) {
            if(pplLoc[i].id >= locId) { 
                locIndex = i; 
                locId = pplLoc[i].id;
            }
        }
        // if the largest id was found, then assign the values 
        if (locId > 0) {
            accObj.SOD_XS_IdLocation__c = pplLoc[locIndex].Id;
            accObj.SOD_XS_Direccion__c = pplLoc[locIndex].address.street;
            accObj.SOD_XS_ReferenciaDireccion__c = pplLoc[locIndex].address.reference;
            try {
                accObj.SOD_XS_AdministrativeArea__c = [SELECT Id, Name FROM SOD_XS_AdministrativeArea__c WHERE Name =: pplLoc[locIndex].address.administrativeArea AND SOD_XS_Country__c =: accObj.SOD_XS_Country__c LIMIT 1]?.Id;
                accObj.SOD_XS_Locality__c = [SELECT Id, Name FROM SOD_XS_Locality__c WHERE Name =: pplLoc[locIndex].address.locality AND SOD_XS_AdministrativeArea__c =: accObj.SOD_XS_AdministrativeArea__c LIMIT 1]?.Id;
                accObj.SOD_XS_SubAdministrativeArea__c = [SELECT Id, Name FROM SOD_XS_SubAdministrativeArea__c WHERE Name =: pplLoc[locIndex].address.subAdministrativeArea AND SOD_XS_Locality__c =: accObj.SOD_XS_Locality__c LIMIT 1]?.Id;            
            } catch(Exception e){
                system.debug('e.getMessage()' + e.getMessage() + 'getTypeName' + e.getTypeName() + ' e.getCause()' + e.getCause());
            }
        }
        return accObj;
    }
}