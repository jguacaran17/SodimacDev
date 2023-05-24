/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 29/01/2020
Description  : PaymentVoucher class for each Purchase
History      :
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye         RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO            29/01/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_MAPJSON360ViewPaymentVoucher implements SOD_XS_MAPJSON360ViewClientExtension.PaymentVoucherInterface{

    /**
    *  @Description: Declaration of static variables
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public static final String PRV_OBJ_PMT;
    private static final String PRV_OBJ_PMT_MTP;


    /**
    *  @Description: Initialization of static variables
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    static {
        PRV_OBJ_PMT = 'PMT';    // Payment Vouchers
        PRV_OBJ_PMT_MTP = 'Tarjeta CMR';   // PaymentMethod
    }

    @AuraEnabled public String id;
    @AuraEnabled public String strObjectType;
    @AuraEnabled public Case objCase {get;set;}
    @AuraEnabled public SOD_XS_DocumentoDeVenta__c objDocV {get;set;}
    @AuraEnabled public SOD_XS_DocumentoAsociado__c objDocA {get;set;}
    @AuraEnabled public SOD_XS_CentroDeCosto__c objShopThatSell {get;set;}
    @AuraEnabled public List<SOD_XS_ReservasDelCaso__c> listReserves {get;set;}
    @AuraEnabled public Map<String, List<SOD_XS_ProductoDelCaso__c>> mapProducts {get;set;}
    public Map<String, SOD_XS_CentroDeCosto__c> storeMapCC;
    SOD_XS_JSON360ViewClient.PaymentVouchers pmt;
    /**
    *  @Description: Constructor
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public SOD_XS_MAPJSON360ViewPaymentVoucher(Object jsonData, String idParam, Object storeMapCC) {
        pmt = (SOD_XS_JSON360ViewClient.PaymentVouchers) jsonData;
        id = idParam;
        this.storeMapCC = (Map<String, SOD_XS_CentroDeCosto__c>) storeMapCC;
        strObjectType = PRV_OBJ_PMT;
        getMappingForCase();
        getMappingForSalesDocument();
        getMappingForAssociatedDocument();
        getMappingForReserve();
        getMappingForProduct();
    }

    /**
    *  @Description: Method used to map a Salesforce Case
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForCase() {
        objCase = new Case();
        // Mapping
        objCase.CurrencyIsoCode = pmt.currencyInformation?.isoCode;
        objCase.SOD_XS_FormadePago__c = getMainPaymentMethodForPaymentVoucher(pmt?.paymentMethods);
        DateTime dt =  pmt.dateOfIssue == null ? null : Datetime.parse(pmt.dateOfIssue?.replace('-', '/').substring(0,(pmt.dateOfIssue.length() - 3)));
        objCase.SOD_XS_FechaDeCompra__c = date.newinstance(dt.year(), dt.month(), dt.day());
        objCase.SOD_XS_CreadoPorIntegracion__c = true;
    }

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_DocumentoDeVenta__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForSalesDocument() {
        objDocV = new SOD_XS_DocumentoDeVenta__c();
        // Mapping
        objDocV.Name = pmt?.documentNumber;
        objDocV.SOD_XS_IdExterno__c = pmt?.documentNumber;
        objDocV.CurrencyIsoCode = pmt.currencyInformation?.isoCode;
        objDocV.SOD_XS_TipoDeDdocumento__c = pmt?.documentType;
        objDocV.SOD_XS_FechaDeCompra__c = pmt.dateOfIssue == null ? null : Datetime.parse(pmt.dateOfIssue?.replace('-', '/').substring(0,(pmt.dateOfIssue?.length() - 3)));

        objDocV.SOD_XS_MontoTotal__c = pmt?.amount;
        objDocV.SOD_XS_CodigoTiendaQueVende__c = pmt.shopThatSells?.id;
        // Specific Mapping for Payment Voucher
        objDocV.SOD_XS_FechaDeEmision__c = date.newinstance(objDocV.SOD_XS_FechaDeCompra__c?.year(), objDocV.SOD_XS_FechaDeCompra__c?.month(), objDocV.SOD_XS_FechaDeCompra__c?.day());                        
        objDocV.SOD_XS_HoraDeEmision__c = time.newInstance(objDocV.SOD_XS_FechaDeCompra__c?.hour(), objDocV.SOD_XS_FechaDeCompra__c?.minute(), objDocV.SOD_XS_FechaDeCompra__c?.second(), objDocV.SOD_XS_FechaDeCompra__c?.millisecond());
        objDocV.SOD_XS_NumeroDeLaOrdenDeCompra__c = pmt?.salesOrderNumber;
        objDocV.SOD_XS_Descuento__c = pmt?.discount;
        objDocV.SOD_XS_ImporteTotal__c = pmt?.totalPrice;
        objDocV.SOD_XS_MedioDePago__c = getMainPaymentMethodForPaymentVoucher(pmt?.paymentMethods);
        objDocV.SOD_XS_MedioDePago2__c = getOtherPaymentMethodForPaymentVoucher(objDocV.SOD_XS_MedioDePago__c, pmt?.paymentMethods);

        objDocV.SOD_XS_NCR__c = null;
        objDocV.SOD_XS_CreadoPorIntegracion__c = true;
        objShopThatSell = (pmt.shopThatSells?.id == null) ?
                                null : 
                                storeMapCC?.get(pmt.shopThatSells?.id?.isNumeric() ? 
                                          integer.valueof(pmt.shopThatSells?.id)?.format() :
                                          pmt.shopThatSells?.id);
    }   

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_DocumentoAsociado__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForAssociatedDocument() {
        objDocA = new SOD_XS_DocumentoAsociado__c();
        // no mapping for Associated Document when is a PaymentVoucher
    }

    /**
    *  @Description: Method used to iterate over a reserve
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForReserve() {
        listReserves = new List<SOD_XS_ReservasDelCaso__c>();
        SOD_XS_ReservasDelCaso__c rsv = new SOD_XS_ReservasDelCaso__c();
        // Mapping
        rsv.Name = pmt?.documentNumber;  //dummy reserve with Sales Document Number
        listReserves.add(rsv);
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForProduct() {
        
        mapProducts = new Map<String, List<SOD_XS_ProductoDelCaso__c>>();
        // iterate over products
        List<SOD_XS_ProductoDelCaso__c> lstPrd = new List<SOD_XS_ProductoDelCaso__c>();
        for (SOD_XS_JSON360ViewClient.DetailPayment d: pmt.detail) {
            SOD_XS_ProductoDelCaso__c prd = new SOD_XS_ProductoDelCaso__c();
            // Mapping
            prd.SOD_XS_CreadoPorIntegracion__c = true;
            prd.CurrencyIsoCode	= pmt.currencyInformation?.isoCode;
            prd.SOD_XS_CodigoProducto__c	= d?.product?.sku;
            prd.SOD_XS_DescripcionDelProducto__c = d?.product?.description?.left(255); 
            prd.SOD_XS_PrecioUnitario__c	= d?.unitPrice;
            prd.SOD_XS_Cantidad__c	= d?.quantity;
            prd.SOD_XS_CantidadAfectada__c = null;
            // Specific Mapping for Payment Voucher
            prd.SOD_XS_PrecioUnitario__c = d?.unitPrice;
            prd.SOD_XS_Descuento__c = d?.discount;
            prd.SOD_XS_ImporteTotal__c = d?.amount;


            lstPrd.add(prd);
        }
        mapProducts.put(objDocV.Name, lstPrd);
        
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public String getId() {
        return id;
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public SOD_XS_DocumentoDeVenta__c getSalesDocument() {
        return objDocV;
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public SOD_XS_DocumentoAsociado__c getAsocDocument() {
        return objDocA;
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public SOD_XS_CentroDeCosto__c getShopThatSell() {
        return objShopThatSell;
    }
    /**
    *  @Description: Method used to determinate the Main Payment Method for the Sale Document
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    private String getMainPaymentMethodForPaymentVoucher(List<SOD_XS_JSON360ViewClient.PaymentMethods> listPaymentMethods ) {
        Double maxAmount = 0;
        String mainPaymentMethod = null;
        // in the case the list has only 1 value
        if(listPaymentMethods?.size() == 1 ) {
            mainPaymentMethod = listPaymentMethods.get(0).typePaymentMethod;
        }
        // in the case the list has more than 1 value
        else if(listPaymentMethods?.size() > 1) {
            // iterate the list
            for(SOD_XS_JSON360ViewClient.PaymentMethods pm: listPaymentMethods) {
                // if we have a winner
                if (pm.amount > maxAmount || (pm.amount == maxAmount && 
                                              maxAmount > 0 && 
                                              pm?.typePaymentMethod?.compareTo(PRV_OBJ_PMT_MTP) == 0)) {
                    maxAmount = pm.amount;
                    mainPaymentMethod = pm.typePaymentMethod;
                }
            }
        }
        return mainPaymentMethod;
    }

    /**
    *  @Description: Method used to determinate the Other Payment Method for the Sale Document
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    private String getOtherPaymentMethodForPaymentVoucher(String mainPaymentMethod,
                                                          List<SOD_XS_JSON360ViewClient.PaymentMethods> listPaymentMethods ) {
        String OtherPaymentMethod = null;
        // check if the list has more than 2 value
        if(listPaymentMethods?.size() > 2) {
            // iterate the list
            for(SOD_XS_JSON360ViewClient.PaymentMethods pm: listPaymentMethods) {
                // Add the Payment Method only if it is not the main Payment Method 
                if (pm?.typePaymentMethod?.compareTo(mainPaymentMethod) != 0) {
                    OtherPaymentMethod = (OtherPaymentMethod == null) ? pm.typePaymentMethod : pm.typePaymentMethod + ',' + OtherPaymentMethod;
                }
            }
        }
        return OtherPaymentMethod;
    }

}