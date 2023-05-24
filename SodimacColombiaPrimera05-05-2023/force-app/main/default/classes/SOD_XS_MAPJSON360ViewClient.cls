/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 26/10/2020
Description  : JSON mapping to expose 360 ​​view of a client
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            26/10/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_MAPJSON360ViewClient {

    public SOD_XS_JSON360ViewClient obj {get;set;}    
    public List<DataTableWrapper> dataTable {get;set;}
    public Map<String, Object> mapPurchases;
    public Account acc;
    /**
    *  @Description: Wrapper class to hold response - This response is used in the 360 ​​view data table
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class DataTableWrapper  {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public SOD_XS_DocumentoDeVenta__c objDocV {get;set;}
        @AuraEnabled public SOD_XS_DocumentoAsociado__c objDocA {get;set;}
        @AuraEnabled public SOD_XS_CentroDeCosto__c objShopThatSell {get;set;}
        @AuraEnabled public SOD_XS_SubproyectoDelCaso__c objSubP {get;set;}
    }

    /**
    *  @Description: Constructor used to receive a 360 view json
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public SOD_XS_MAPJSON360ViewClient (SOD_XS_JSON360ViewClient str, Account acc) {
        this.obj = str;
        this.acc = acc;        
        List<SOD_XS_JSON360ViewClient.PurchaseOrders> listPurchaseOrder = obj?.threeHundredAndSixtyView?.purchaseOrders != null ? obj?.threeHundredAndSixtyView?.purchaseOrders : obj?.purchaseOrders;
        List<SOD_XS_JSON360ViewClient.PaymentVouchers> listPaymentVouchers = obj?.threeHundredAndSixtyView?.paymentVouchers != null ? obj?.threeHundredAndSixtyView?.paymentVouchers : obj?.paymentVouchers;
        List<SOD_XS_JSON360ViewClient.SpecialServices> listSpecialServices = obj?.threeHundredAndSixtyView?.specialServices != null ? obj?.threeHundredAndSixtyView?.specialServices : obj?.specialServices;
        Map<String, SOD_XS_CentroDeCosto__c> storeMapCC = getStoreMap(acc.SOD_XS_Country__r.SOD_XS_Codigo__c);

        // Init variables
        Integer id = 0;
        mapPurchases = new Map<String, Object>();

        // Process the node 
        List<Object> objUntypeList = new List<Object>();
        if(listPurchaseOrder != Null) {
            listPurchaseOrder.sort();
            objUntypeList.addAll(listPurchaseOrder);
            listPurchaseOrder.clear();
        }
        if(listPaymentVouchers != Null) {
            objUntypeList.addAll(listPaymentVouchers);
            listPaymentVouchers.clear();
        }
        if(listSpecialServices != Null) {
            listSpecialServices.sort();
            objUntypeList.addAll(listSpecialServices);
            listSpecialServices.clear();
        }
        for (Object objUntype: objUntypeList) {
            mapPurchases.put(String.valueOf(id), new SOD_XS_MAPJSON360ViewClientExtension.PurchaseFactory().getPurchase(objUntype, String.valueOf(id), storeMapCC));
            id++;
            validateClientIn360View(objUntype, acc);
        }
        objUntypeList.clear();
    }

    /**
    *  @Description: Method used to get the purchase order data table from data mapped
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public List<SOD_XS_MAPJSON360ViewClient.DataTableWrapper> getPurchasesDataTable()
    {
        dataTable = new List<SOD_XS_MAPJSON360ViewClient.DataTableWrapper>();
        for (Object pur: mapPurchases.values()) {
            
            if ( pur instanceof SOD_XS_MAPJSON360ViewClientExtension.PurchaseOrderInterface ) {
                SOD_XS_MAPJSON360ViewClientExtension.PurchaseOrderInterface castPur = (SOD_XS_MAPJSON360ViewClientExtension.PurchaseOrderInterface) pur;
                DataTableWrapper objData = new DataTableWrapper();
                objData.id = castPur.getId();
                objData.objDocV = castPur.getSalesDocument();
                objData.objDocA = castPur.getAsocDocument();
                objData.objShopThatSell = castPur.getShopThatSell();
                dataTable.add(objData);
            }

            if ( pur instanceof SOD_XS_MAPJSON360ViewClientExtension.PaymentVoucherInterface ) {
                SOD_XS_MAPJSON360ViewClientExtension.PaymentVoucherInterface castPur = (SOD_XS_MAPJSON360ViewClientExtension.PaymentVoucherInterface) pur;
                DataTableWrapper objData = new DataTableWrapper();
                objData.id = castPur.getId();
                objData.objDocV = castPur.getSalesDocument();
                objData.objDocA = new SOD_XS_DocumentoAsociado__c();
                objData.objShopThatSell = castPur.getShopThatSell();
                dataTable.add(objData);
            }

            if ( pur instanceOf SOD_XS_MAPJSON360ViewClientExtension.SpecialServicesInterface ) {
                SOD_XS_MAPJSON360ViewClientExtension.SpecialServicesInterface castPur = (SOD_XS_MAPJSON360ViewClientExtension.SpecialServicesInterface) pur;
                SOD_XS_DocumentoAsociado__c auxDocA = castPur.getAsocDocument();
                if (!(castPur.getSubProjects()).get(auxDocA.SOD_XS_IdExterno__c).isEmpty()) {
                    for ( SOD_XS_SubproyectoDelCaso__c sbp: (castPur.getSubProjects()).get(auxDocA.SOD_XS_IdExterno__c)) {
                        DataTableWrapper objData = new DataTableWrapper();
                        objData.id = castPur.getId() + '-SPJ-' + sbp.Name;
                        objData.objDocV = (castPur.getSalesDocument()).get(sbp.Name);
                        objData.objDocA = auxDocA;
                        objData.objShopThatSell = (castPur.getShopThatSell()).get(objData.objDocV.SOD_XS_IdExterno__c);
                        objData.objSubP = sbp;
                        dataTable.add(objData);
                    }
                } else {
                    DataTableWrapper objData = new DataTableWrapper();
                    objData.id = castPur.getId();
                    objData.objDocV = new SOD_XS_DocumentoDeVenta__c();
                    objData.objDocA = auxDocA;
                    objData.objShopThatSell = new SOD_XS_CentroDeCosto__c();
                    objData.objSubP = new SOD_XS_SubproyectoDelCaso__c();
                    dataTable.add(objData);
                }
                
            }

        }
        return dataTable;
    }
    
    /**
    *  @Description: Method used to get the purchase object related to a search
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public Object getPurchaseObject()
    {
        List<Object> listPurchases = mapPurchases.values();
        return listPurchases[0];
    }

    /**
    *  @Description: Method used to validate client in 360View
    *  @Author:      Rodolfo Valencia, FTC
    *  @Date:        11/03/2021
    */
    private void validateClientIn360View(Object jsonData, Account acc) {
        SOD_XS_JSON360ViewClient.Identification clientIdentification;
        // PurchaseOrders
        if ( jsonData instanceof SOD_XS_JSON360ViewClient.PurchaseOrders ) {
            SOD_XS_JSON360ViewClient.PurchaseOrders prc = (SOD_XS_JSON360ViewClient.PurchaseOrders) jsonData;
            clientIdentification = (prc.reserves.size() > 0) ? (prc.reserves[0]?.purchaseHolder?.Identification) : null;
        }
        // PaymentVouchers
        if ( jsonData instanceof SOD_XS_JSON360ViewClient.PaymentVouchers ) {
            SOD_XS_JSON360ViewClient.PaymentVouchers pmt = (SOD_XS_JSON360ViewClient.PaymentVouchers) jsonData;
            clientIdentification = pmt.purchaseHolder?.Identification;
        }
        // SpecialServices
        if ( jsonData instanceof SOD_XS_JSON360ViewClient.SpecialServices ) {
            SOD_XS_JSON360ViewClient.SpecialServices sps = (SOD_XS_JSON360ViewClient.SpecialServices) jsonData;
            clientIdentification = sps.purchaseHolder?.Identification;
        }

        // If Label is true, we validate the clients document number
        if(Boolean.valueOf(Label.SOD_XS_V360OCValidacionCliente)) {
            if(!accClientAndIntClientHaveSameDocNumber(clientIdentification, acc)){
                throw new InvalidDocNumberException (Label.SOD_XS_V360OCMensajeError,1);
            }
        } 
    }

    /**
    *  @Description: Method used to validate that the doc number of the account client and integration client is the same
    *  @Author:      Rodolfo Valencia, FTC
    *  @Date:        11/03/2021
    */
    private Boolean accClientAndIntClientHaveSameDocNumber(SOD_XS_JSON360ViewClient.Identification identification, Account acc) {
        String nroDocCli = (acc.SOD_XS_NroDocumento__c?.substringBefore('-'))?.replaceAll('[,.]','');
        String nroDocInt = (identification?.value?.substringBefore('-'))?.replaceAll('[,.]','');

        // Take into account workaround for Peru DNI - BUG 5315
        // Take into account workaround for Colombia NIT - CREC-1258
        if(nroDocCli != null && nroDocCli.isNumeric() && nroDocCli.length() != nroDocInt.length()){
            Integer i = Integer.valueOf(nroDocCli); // removes leading zeroes
            String v = String.valueOf(i);
            if(acc.SOD_XS_TipoDocumento__c.equals('DNI')){
                nroDocCli = v.substring(0, v.length()-1);
            } else if(acc.SOD_XS_TipoDocumento__c.equals('Número Identificación Tributaria')){
                nroDocCli = v.substring(0, 9);
                nroDocInt = nroDocInt.substring(0, 9);
            }
        }
        
        return ((nroDocInt != null && nroDocCli != null) && nroDocInt == nroDocCli);
    }

    /**
    *  @Description: Invalid document number exception, wrapper class used to set a service exception
    *  @Autor:       EA, Deloitte, eandradea@deloitte.com
    *  @Date:        05/03/2021
    */    
    public class InvalidDocNumberException extends Exception {
        public Integer code;
        public InvalidDocNumberException(String message, Integer code)
        {
            this(message);
            this.code = code;            
        }
    }

    /**
    *  @Description: get map of SOD_XS_CentroDeCosto__c with country code
    *  @Autor:       EA, Deloitte, eandradea@deloitte.com
    *  @Date:        05/03/2021
    */
    public Map<String, SOD_XS_CentroDeCosto__c> getStoreMap(String strCountryId) {
        
        List<SOD_XS_CentroDeCosto__c> listStore = new List<SOD_XS_CentroDeCosto__c>([SELECT Id, Name, SOD_XS_CentroDeCosto__c
                                                        FROM SOD_XS_CentroDeCosto__c 
                                                        WHERE SOD_XS_Country__r.SOD_XS_Codigo__c = :strCountryId]);
        
        Map<String, SOD_XS_CentroDeCosto__c> mapStore = new Map<String, SOD_XS_CentroDeCosto__c>();
        for (SOD_XS_CentroDeCosto__c store : listStore) {
            mapStore.put(store.SOD_XS_CentroDeCosto__c, store);
        }
        return mapStore;
    }
    
    
    /**
    *  @Description: Method used to validate that the doc number of the account client and integration client is the same
    *  @Author:      Rodolfo Valencia, FTC
    *  @Date:        11/03/2021
    */
    private Boolean accClientAndIntClientHaveSameDocNumber(SOD_XS_JSON360ViewClient.Reserves r, Account acc) {
        String nroDocCli = (acc.SOD_XS_NroDocumento__c.substringBefore('-'))?.replaceAll('[,.]','');
        String nroDocInt = (r.purchaseHolder?.Identification?.value.substringBefore('-'))?.replaceAll('[,.]','');
        // Take into account workaround for Peru DNI - BUG 5315
        if(acc.SOD_XS_TipoDocumento__c.equals('DNI')){
            if(nroDocCli != null && nroDocCli.isNumeric()){
                Integer i = Integer.valueOf(nroDocCli); // removes leading zeroes
                String v = String.valueOf(i);
                nroDocCli = v.substring(0, v.length()-1);
            }
        } 
        return ((nroDocInt != null && nroDocCli != null) && nroDocInt == nroDocCli);
    }

    /**
    *  @Description: Method used to validate client in 360View
    *  @Author:      Rodolfo Valencia, FTC
    *  @Date:        11/03/2021
    */
    private void validateClientIn360View(SOD_XS_JSON360ViewClient.Reserves r, Account acc) {
        // If Label is true, we validate the clients document number
        if(Boolean.valueOf(Label.SOD_XS_V360OCValidacionCliente)) {
            if(!accClientAndIntClientHaveSameDocNumber(r, acc)){
                throw new InvalidDocNumberException (Label.SOD_XS_V360OCMensajeError,1);
            }
        } 
    }

}