/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 29/01/2020
Description  : PurchaseOrder class for each Purchase
History      :
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye         RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO            29/01/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_MAPJSON360ViewOrders implements SOD_XS_MAPJSON360ViewClientExtension.PurchaseOrderInterface{

    /**
    *  @Description: Declaration of static variables
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public static final String PRV_OBJ_PRC;
    public static final String FCOMPE_STORE;
    public static final String COUNTRY_PE;
    public static final String FCOM_CC;


    /**
    *  @Description: Initialization of static variables
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    static {
        PRV_OBJ_PRC = 'PRC'; // Purchase Orders
        FCOMPE_STORE = 'F.COM PE';
		COUNTRY_PE = 'PE';
        FCOM_CC = 'F.COM';
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
    SOD_XS_JSON360ViewClient.PurchaseOrders prc;
    /**
    *  @Description: Constructor
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public SOD_XS_MAPJSON360ViewOrders(Object jsonData, String idParam, Object storeMapCC) {
        prc = (SOD_XS_JSON360ViewClient.PurchaseOrders) jsonData;
        this.storeMapCC = (Map<String, SOD_XS_CentroDeCosto__c>) storeMapCC;
        id = idParam;
        strObjectType = PRV_OBJ_PRC;
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
        //mapping
        objCase.CurrencyIsoCode = prc.currencyInformation?.isoCode;
        objCase.SOD_XS_FormadePago__c = String.valueOf(prc.paymentMethods?.get(0)?.typePaymentMethod);
        DateTime dt = prc.purchaseDate == null ? null : DateTime.parse(prc.purchaseDate?.replace('-', '/'));
        objCase.SOD_XS_FechaDeCompra__c = dt == null ? null : date.newinstance(dt?.year(), dt?.month(), dt?.day());
        objCase.SOD_XS_CreadoPorIntegracion__c = true;
    }

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_DocumentoDeVenta__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForSalesDocument() {
        objDocV = new SOD_XS_DocumentoDeVenta__c();
        //mapping
        objDocV.Name = prc.salesDocument?.documentNumber;
        objDocV.SOD_XS_IdExterno__c = prc.salesDocument?.documentNumber;
        objDocV.CurrencyIsoCode = prc.currencyInformation?.isoCode;
        objDocV.SOD_XS_TipoDeDdocumento__c = prc.salesDocument?.documentType;
        objDocV.SOD_XS_FechaDeCompra__c = prc.purchaseDate == null ? null : Datetime.parse(prc.purchaseDate?.replace('-', '/'));
        objDocV.SOD_XS_MontoTotal__c = prc?.amount;
        objDocV.SOD_XS_MedioDePago__c = String.valueOf(prc.paymentMethods?.get(0)?.typePaymentMethod);
        objDocV.SOD_XS_CodigoTiendaQueVende__c = prc.shopThatSells?.id;     
        objDocV.SOD_XS_CreadoPorIntegracion__c = true;
        SOD_XS_CentroDeCosto__c auxCC = (prc.shopThatSells?.id == null) ? 
                                null :
                                storeMapCC?.get(prc.shopThatSells?.id?.isNumeric() ? 
                                            integer.valueof(prc.shopThatSells?.id)?.format() :
                                            prc.shopThatSells?.id);
        objShopThatSell = new SOD_XS_CentroDeCosto__c();
        objShopThatSell.Id = auxCC.Id;
        objShopThatSell.Name = auxCC.Name;
        for (SOD_XS_JSON360ViewClient.Reserves r: prc.reserves) {
            if(r.salesChannel?.name == FCOM_CC && r.purchaseHolder?.Identification?.isoCountry == COUNTRY_PE){
                objShopThatSell.Name = FCOMPE_STORE;
            }
        }
    }

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_DocumentoAsociado__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForAssociatedDocument() {
        objDocA = new SOD_XS_DocumentoAsociado__c();
        //mapping
        objDocA.Name = prc.orderNumber;
        objDocA.SOD_XS_IdExterno__c = prc.orderNumber;
        objDocA.CurrencyIsoCode = prc.currencyInformation?.isoCode;
        objDocA.SOD_XS_TipoDeDdocumento__c = 'Orden de Compra';
        objDocA.SOD_XS_CreadoPorIntegracion__c = true;
        
    }

    /**
    *  @Description: Method used to iterate over a reserve
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForReserve() {
        listReserves = new List<SOD_XS_ReservasDelCaso__c>();
        //validate difference between reserve integration client and SF client

        //iterate over reserves
        for (SOD_XS_JSON360ViewClient.Reserves r: prc.reserves) {
            SOD_XS_ReservasDelCaso__c rsv = new SOD_XS_ReservasDelCaso__c();
            //mapping
            rsv.Name = r.reserveNumber;
            rsv.SOD_XS_TipoEntrega__c = r.deliveryType?.nombre;
            rsv.SOD_XS_TipoReserva__c = r.reserveType;
            rsv.SOD_XS_Estado__c = r.state?.name;
            rsv.SOD_XS_CreadoPorIntegracion__c = true;
    
            rsv.CurrencyIsoCode	= prc.currencyInformation?.isoCode;
            rsv.SOD_XS_DireccionCalle__c = r.dispatch?.address?.street;
            rsv.SOD_XS_DireccionArea__c	= r.dispatch?.address?.administrativeArea;
            rsv.SOD_XS_DireccionSubarea__c	= r.dispatch?.address?.subAdministrativeArea;
            rsv.SOD_XS_DireccionLocalidad__c	= r.dispatch?.address?.locality;
            rsv.SOD_XS_DireccionPais__c	 = r.purchaseHolder?.Identification?.isoCountry;
            rsv.SOD_XS_Observaciones__c	= r.dispatch?.observation;
            rsv.SOD_XS_NombreDespacho__c	= r.dispatch?.nameToWhomIsDispatched;
            rsv.SOD_XS_FonoDespacho1__c	= r.dispatch?.firstPhone;
            rsv.SOD_XS_FonoDespacho2__c	= r.dispatch?.secondPhone;
            rsv.SOD_XS_CanalDeVenta__c	= r.salesChannel?.name;
            rsv.SOD_XS_MontoReserva__c	= r.amount;
            rsv.SOD_XS_CodigoReservaMadre__c = r.motherReserveNumber;
            listReserves.add(rsv);
        }
    }

    /**
    *  @Description: Method used to return the External Id for a given Product
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        02/12/2021
    */
    public String makeProductIdExterno(SOD_XS_JSON360ViewClient.Reserves reserve, SOD_XS_JSON360ViewClient.Detail detail){
        String productIdExterno = null;
        String productSku = detail.product?.sku;
        String countryCode = reserve.purchaseHolder.Identification?.isoCountry;
        if(countryCode != null){
            productIdExterno = countryCode + '_' + productSku;
        }
        return productIdExterno;
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    */
    public void getMappingForProduct() {

        mapProducts = new Map<String, List<SOD_XS_ProductoDelCaso__c>>();
        Map<String, Boolean> mapProductsKeepIt = new Map<String, Boolean>();
        Map<String, String> mapProductsFamilyKeepIt = new Map<String, String>();
        Map<String, SOD_XS_GarantiaDelProducto__c> mapProductsWarranty = new Map<String, SOD_XS_GarantiaDelProducto__c>();
        Map<Id, SOD_XS_ProveedorDeServicioTecnico__c> mapProductsWarrantyProvider = new Map<Id, SOD_XS_ProveedorDeServicioTecnico__c>();
        // Determine Warranty for Products
        for (SOD_XS_JSON360ViewClient.Reserves rsv: prc.reserves) {
            for (SOD_XS_JSON360ViewClient.Detail d: rsv.detail) {
                String productIdExterno = makeProductIdExterno(rsv, d);
                if(productIdExterno != null){
                    mapProductsWarranty.put(productIdExterno, null);
                }
            }
        }
        if(!mapProductsWarranty.isEmpty()){
            List<SOD_XS_GarantiaDelProducto__c> garantiasList = [Select Id, SOD_XS_IdExterno__c, SOD_XS_TipoDePostventa__c, SOD_XS_TipoDeProducto__c, SOD_XS_ProveedorDeServicioTecnico__c FROM SOD_XS_GarantiaDelProducto__c WHERE SOD_XS_IdExterno__c IN :mapProductsWarranty.keySet()];
            if(!garantiasList.isEmpty()){
                for(SOD_XS_GarantiaDelProducto__c gdp : garantiasList){
                    mapProductsWarranty.put(gdp.SOD_XS_IdExterno__c, gdp);
                    mapProductsWarrantyProvider.put(gdp.SOD_XS_ProveedorDeServicioTecnico__c, null);
                }
                List<SOD_XS_ProveedorDeServicioTecnico__c> proveedoresList = [Select Id, SOD_XS_EncargadoComercial__c, SOD_XS_GerenteDeLinea__c FROM SOD_XS_ProveedorDeServicioTecnico__c WHERE Id IN :mapProductsWarrantyProvider.keySet()];
                if(!proveedoresList.isEmpty()){
                    for(SOD_XS_ProveedorDeServicioTecnico__c pds : proveedoresList){
                        mapProductsWarrantyProvider.put(pds.Id, pds);
                    }
                }
            }
        } 
        // Determine Keep It Products
        for (SOD_XS_JSON360ViewClient.Reserves rsv: prc.reserves) {
            for (SOD_XS_JSON360ViewClient.Detail d: rsv.detail) {
                String productIdExterno = makeProductIdExterno(rsv, d);
                if(productIdExterno != null){
                    mapProductsKeepIt.put(productIdExterno, false);
                }
            }
        } 
        List<Product2> productsTwo = new List<Product2>();
        if(mapProductsKeepIt.size() > 0){
            productsTwo = [SELECT SOD_XS_IdExterno__c, SOD_XS_KeepIt__c, ProductCode, Family FROM Product2 WHERE SOD_XS_IdExterno__c IN :mapProductsKeepIt.keySet() AND SOD_XS_KeepIt__c = true];
        }
        if(productsTwo.size() > 0){
            for(Product2 p : productsTwo){
                mapProductsKeepIt.put(p.SOD_XS_IdExterno__c, p.SOD_XS_KeepIt__c);
                mapProductsFamilyKeepIt.put(p.ProductCode, p.Family);
            }
        }
        //iterate over reserves
        for (SOD_XS_JSON360ViewClient.Reserves rsv: prc.reserves) {
            List<SOD_XS_ProductoDelCaso__c> listProducts = new List<SOD_XS_ProductoDelCaso__c>();
            //iterate over products
            for (SOD_XS_JSON360ViewClient.Detail d: rsv.detail) {
                SOD_XS_ProductoDelCaso__c prd = new SOD_XS_ProductoDelCaso__c();
                //mapping
                prd.SOD_XS_CreadoPorIntegracion__c = true;
                prd.CurrencyIsoCode	= prc.currencyInformation?.isoCode;
                prd.SOD_XS_PrecioUnitario__c	= d.unitPrice;
                prd.SOD_XS_TipoDespacho__c	= d.dispatch?.dispatchType;
                prd.SOD_XS_MotivoDevolucion__c	= d.devolution?.reason;
                prd.SOD_XS_RangoHorario__c	= d.delivery?.hourRange;
                prd.SOD_XS_FechaEntregaOriginal__c = d.delivery?.agreedDateRange?.fromDate == null ? null : Date.parse(d.delivery?.agreedDateRange?.fromDate?.replace('-', '/'));
                prd.SOD_XS_FechaEntrega__c	= d.delivery?.deliveryDate == null ? null : Date.parse(d.delivery?.deliveryDate?.replace('-', '/'));
                prd.SOD_XS_FechaDespacho__c	= d.dispatch?.dispatchDate == null ? null : Date.parse(d.dispatch?.dispatchDate?.replace('-', '/'));
                prd.SOD_XS_NCR__c = rsv.hasNcr;	
                prd.SOD_XS_NumeroGuia__c	= d.dispatch?.dispatchGuideNumber;
                prd.SOD_XS_Proveedor__c	= d.seller?.name;
                prd.SOD_XS_Cantidad__c	= d.quantity;
                prd.SOD_XS_Estado__c	= d.state?.name;
                prd.SOD_XS_Bloqueo__c	= d.isBlocked;
                prd.SOD_XS_Quiebre__c	= d.isBreak;
                prd.SOD_XS_CantidadAfectada__c = null;
                prd.SOD_XS_MontoReserva__c	= d.amount;
                prd.SOD_XS_CCDespacho__c = d.dispatch?.costCenter?.name;
                prd.SOD_XS_Origen__r = (d.delivery?.inventoryOriginCostCenter?.id == null) ?
                                                null :
                                                storeMapCC?.get(d.delivery?.inventoryOriginCostCenter?.id?.isNumeric() ? 
                                                       integer.valueof(d.delivery?.inventoryOriginCostCenter?.id)?.format() :
                                                       d.delivery?.inventoryOriginCostCenter?.id); 
                prd.SOD_XS_Despacho__r = (d.dispatch?.costCenter?.id == null) ? 
                                                null : 
                                                storeMapCC?.get(d.dispatch?.costCenter?.id?.isNumeric() ?
                                                         integer.valueof(d.dispatch?.costCenter?.id)?.format() : 
                                                         d.dispatch?.costCenter?.id);
                prd.SOD_XS_CodigoOrigen__c	= prd.SOD_XS_Origen__r?.name;
                prd.SOD_XS_CodigoDespacho__c	= prd.SOD_XS_Despacho__r?.name;

                prd.SOD_XS_CodigoProducto__c	= d.product?.sku;
                prd.SOD_XS_DescripcionDelProducto__c = d.product?.description?.left(255); 
                prd.SOD_XS_KeepIt__c = mapProductsKeepIt.get(makeProductIdExterno(rsv, d));
                If(!mapProductsWarranty.isEmpty() && mapProductsWarranty.get(makeProductIdExterno(rsv, d)) != null){
                    SOD_XS_GarantiaDelProducto__c gdp = mapProductsWarranty.get(makeProductIdExterno(rsv, d));
                    SOD_XS_ProveedorDeServicioTecnico__c pds = mapProductsWarrantyProvider.get(gdp.SOD_XS_ProveedorDeServicioTecnico__c);
                    prd.SOD_XS_GarantiaDelProducto__c = gdp.Id;
                    prd.SOD_XS_AuxTipoDePostventa__c = gdp.SOD_XS_TipoDePostventa__c;
                    prd.SOD_XS_AuxTipoDeProducto__c = gdp.SOD_XS_TipoDeProducto__c;
                    prd.SOD_XS_AuxEncargadoComercial__c = pds.SOD_XS_EncargadoComercial__c;
                    prd.SOD_XS_AuxGerenteDeLinea__c = pds.SOD_XS_GerenteDeLinea__c;
                }
                if(prd.SOD_XS_KeepIt__c){
                    Map<String, Decimal> posiblesDescuentos = new Map<String, Decimal>();
                    posiblesDescuentos.put('Abono', getEligibleKeepItDiscounts('Chile', mapProductsFamilyKeepIt.get(prd.SOD_XS_CodigoProducto__c), 'Abono', prd.SOD_XS_PrecioUnitario__c));
                    posiblesDescuentos.put('Cupón', getEligibleKeepItDiscounts('Chile', mapProductsFamilyKeepIt.get(prd.SOD_XS_CodigoProducto__c), 'Cupón', prd.SOD_XS_PrecioUnitario__c));
                    posiblesDescuentos.put('NCR + Cupón', getEligibleKeepItDiscounts('Chile', mapProductsFamilyKeepIt.get(prd.SOD_XS_CodigoProducto__c), 'NCR + Cupón', prd.SOD_XS_PrecioUnitario__c));
                    prd.SOD_XS_DescuentosKeepIt__c = JSON.serializePretty(posiblesDescuentos);
                }
                listProducts.add(prd);
            }
            mapProducts.put(rsv.reserveNumber, listProducts);
        }
    }

    /**
    *  @Description: Get the discount for Keep It Products
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        20/12/2021
    */
    public static Decimal getEligibleKeepItDiscounts(String pais, String categoria, String opcion, Decimal precio) {
        List<SOD_XS_DiscountForKeepItProduct__mdt> dkpList = SOD_XS_DiscountForKeepItProduct__mdt.getAll().values();
        Decimal discount = 0;
        for (SOD_XS_DiscountForKeepItProduct__mdt dkp : dkpList) {
            if (dkp.SOD_XS_Pais__c == pais && dkp.SOD_XS_CategoriaDelProducto__c == categoria && dkp.SOD_XS_Opcion__c == opcion && dkp.SOD_XS_Activo__c == true) {
                if(dkp.SOD_XS_PrecioLimiteInferior__c <= precio && dkp.SOD_XS_PrecioLimiteSuperior__c >= precio){
                    discount = dkp.SOD_XS_Descuento__c;
                }
            }
        }
        return discount;
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

}