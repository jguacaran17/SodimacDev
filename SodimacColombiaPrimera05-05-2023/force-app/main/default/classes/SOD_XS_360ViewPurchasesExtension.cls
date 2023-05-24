/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 18/12/2020
Description  : APEX Extension - Search Purcharses
History      : CMRSC-3934
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye         RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO            18/12/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_360ViewPurchasesExtension {

    public Map<String, Object> mapData;
    public Account accObject;
    public Case caseObject;
    public SOD_XS_DocumentoDeVenta__c sellDocumentObject;
    public SOD_XS_DocumentoAsociado__c asocDocumentObject;
    public SOD_XS_CentroDeCosto__c shopThatSaleObject;
    public SOD_XS_CentroDeCosto__c ccResponsableObject;
    public List<SOD_XS_ReservasDelCaso__c> listReserves;
    public List<SOD_XS_SubproyectoDelCaso__c> listSubProject; 
    public Map<String, List<SOD_XS_ProductoDelCaso__c>> mapProducts;
    public Map<String, List<SOD_XS_ProductoDelCaso__c>> mapSubProjectProd; 
    public Map<String, String> mapStore;
    public Map<String, Map<String, String>> mapTranslator;
    public Map<String, String> mapDocAssocType;
    public Map<String, String> mapStateSubProj;
    public Map<String, String> mapBasketType;
    public Map<String, String> mapStateDocAsoc;
    public Map<String, String> mapStateProduct;
    public Map<String,Schema.RecordTypeInfo> mapDocAssocRecordType;
    public String strObjectType;

    /**
    *  @Description: Declaration of static variables
    *  @Author:      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/12/2020
    */
    private static final String PRV_JS_OBJ_ACC;
    private static final String PRV_JS_OBJ_DOCV;
    private static final String PRV_JS_OBJ_DOCA;
    private static final String PRV_JS_OBJ_RSV;
    private static final String PRV_JS_OBJ_PRD;
    private static final String PRV_JS_OBJ_CASE;
    private static final String PRV_JS_OBJ_SPJ; 
    private static final String PRV_JS_OBJ_SHOP; 
    private static final String PRV_JS_OBJ_CCResp; 
    private static final String PRV_JS_LST_RSV;
    private static final String PRV_JS_LST_SPJ; 
    private static final String PRV_JS_LST_PRD;
    private static final String PRV_JS_ATT_ISCONSULT;
    private static final String PRV_JS_ATT_CCRESP;
    private static final String PRV_JS_ATT_ASESOR;
    private static final String PRV_WS_TRANS_CDV;
    private static final String PRV_WS_TRANS_DV;
    private static final String PRV_WS_TRANS_ERS;
    private static final String PRV_WS_TRANS_ER;
    private static final String PRV_WS_TRANS_MP;
    private static final String PRV_WS_TRANS_MD;
    private static final String PRV_WS_TRANS_TE;
    private static final String PRV_WS_TRANS_TEV;
    private static final String PRV_WS_TRANS_TR;
    private static final String PRV_WS_TRANS_RT_OC;
    private static final String PRV_WS_TRANS_RT_PRY;
    private static final String PRV_JS_OBJ_TYPE;
    private static final String PRV_JS_OBJ_PRJ;
    private static final String PRV_JS_OBJ_SUBPRJ;


    /**
    *  @Description: Initialization of static variables
    *  @Author:      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/12/2020
    */
    static {
        PRV_JS_OBJ_ACC = 'objClient';
        PRV_JS_OBJ_DOCV = 'objSellDoc';
        PRV_JS_OBJ_DOCA = 'objAsocDoc';
        PRV_JS_OBJ_RSV = 'objReserve';
        PRV_JS_OBJ_CASE = 'objCase';
        PRV_JS_OBJ_SPJ = 'objReserve'; 
        PRV_JS_OBJ_SHOP = 'objShopThatSell'; 
        PRV_JS_OBJ_CCResp = 'objCCResponsable'; 
        PRV_JS_LST_RSV = 'lstReserves';
        PRV_JS_LST_SPJ = 'lstReserves'; 
        PRV_JS_LST_PRD = 'lstProducts';
        PRV_JS_ATT_ISCONSULT = 'boolRecordTypeConsultaSelected';
        PRV_JS_ATT_CCRESP = 'strCCReserve';
        PRV_JS_ATT_ASESOR = 'strAsesor';
        PRV_WS_TRANS_CDV = 'Canal de Venta';
        PRV_WS_TRANS_DV = 'Documento de Venta';
        PRV_WS_TRANS_ERS = 'Estados Reserva SKU';
        PRV_WS_TRANS_ER = 'Estados de Reserva';
        PRV_WS_TRANS_MP = 'Medios de Pago';
        PRV_WS_TRANS_MD = 'Motivos Devolucion';
        PRV_WS_TRANS_TE = 'Tipos de Entrega';
        PRV_WS_TRANS_TEV = 'Tipos de Eventos';
        PRV_WS_TRANS_TR = 'Tipos de Reserva';
        PRV_JS_OBJ_TYPE = 'strObjectType';
        PRV_WS_TRANS_RT_OC = 'SOD_XS_ODC';
        PRV_WS_TRANS_RT_PRY = 'SOD_XS_PRY';
        PRV_JS_OBJ_PRJ = 'SSP_PRJ';
        PRV_JS_OBJ_SUBPRJ = 'SSP_SUBP';

    }

    /**
    *  @Description: Constructor used to receive a json, account and case record for F.com integration
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */
    public SOD_XS_360ViewPurchasesExtension (String jsonData, Account acc, Case cas) {
        // Initialize map data key varibles
        String FCOM_JS_OBJ_DOCV = 'objDocV';
        String FCOM_JS_OBJ_DOCA = 'objDocA';
        String FCOM_JS_LST_RSV = 'listReserves';
        String FCOM_JS_OBJ_PRD = 'mapProducts';
        // Initialize json map data, account and case records
        mapData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        accObject = SOD_XS_360ViewPurchasesController.getRecord(acc.Id);
        caseObject = cas;
        // Deserialize json representation of purchase order
        strObjectType = (String) JSON.deserialize(JSON.serialize(mapData?.get(PRV_JS_OBJ_TYPE)), String.class);
        sellDocumentObject = (SOD_XS_DocumentoDeVenta__c) JSON.deserialize(JSON.serialize(mapData?.get(FCOM_JS_OBJ_DOCV)), SOD_XS_DocumentoDeVenta__c.class);
        asocDocumentObject = (SOD_XS_DocumentoAsociado__c) JSON.deserialize(JSON.serialize(mapData?.get(FCOM_JS_OBJ_DOCA)), SOD_XS_DocumentoAsociado__c.class);
        shopThatSaleObject = (SOD_XS_CentroDeCosto__c) JSON.deserialize(JSON.serialize(mapData?.get(PRV_JS_OBJ_SHOP)), SOD_XS_CentroDeCosto__c.class);
        ccResponsableObject = (SOD_XS_CentroDeCosto__c) JSON.deserialize(JSON.serialize(mapData?.get(PRV_JS_OBJ_CCResp)), SOD_XS_CentroDeCosto__c.class);
        // Initialize collections and variables
        listSubProject = new List<SOD_XS_SubproyectoDelCaso__c>();
        listReserves = new List<SOD_XS_ReservasDelCaso__c>();
        mapProducts = new Map<String, List<SOD_XS_ProductoDelCaso__c>>();
        SOD_XS_SubproyectoDelCaso__c subProject = new SOD_XS_SubproyectoDelCaso__c();
        SOD_XS_ReservasDelCaso__c reserve = new SOD_XS_ReservasDelCaso__c();
        List<Object> listReserveJSON = (List<Object>) mapData?.get(FCOM_JS_LST_RSV);
        // Loop over list of Reserves
        for(Object r : listReserveJSON) {
            Map<String, Object> rMap = (Map<String, Object>) r;
            // Determine if json object type is Proyect, Subproyect or Reserve
            if(strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ){
                subProject = (SOD_XS_SubproyectoDelCaso__c) JSON.deserialize(JSON.serialize(rMap.get(PRV_JS_OBJ_SPJ)), SOD_XS_SubproyectoDelCaso__c.class);
                listSubProject.add(subProject);
            }else{
                reserve = (SOD_XS_ReservasDelCaso__c) JSON.deserialize(JSON.serialize(r), SOD_XS_ReservasDelCaso__c.class);
                listReserves.add(reserve);
            } 
            // Initialize collection and variables for products
            Map<String, Object> mapProdJSON = (Map<String, Object>) mapData?.get(FCOM_JS_OBJ_PRD);
            List<Object> listProdJSON = (List<Object>) mapProdJSON?.get(reserve.Name);
            List<SOD_XS_ProductoDelCaso__c> listProdSF = new List<SOD_XS_ProductoDelCaso__c>();
            // Loop over Products
            for (Object p : listProdJSON) {
                SOD_XS_ProductoDelCaso__c product = (SOD_XS_ProductoDelCaso__c) JSON.deserialize(JSON.serialize(p), SOD_XS_ProductoDelCaso__c.class);
                listProdSF.add(product);
            }
            // Determine if json object type is Proyect, Subproyect or Reserve
            if(strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ){
                mapProducts.put(subProject.Name, listProdSF);
            }else{
                mapProducts.put(reserve.Name, listProdSF);
            }
        }
        // Initialize global maps with describe information
        mapStore = getStoreMap(accObject.SOD_XS_Country__r.Id);
        mapTranslator = getPicklistTranslationMap(accObject.SOD_XS_Country__r.SOD_XS_Codigo__c);
        mapDocAssocRecordType = getAssocDocRecordTypeMap();
        mapDocAssocType = getPicklistObjectMap(SOD_XS_DocumentoAsociado__c.SOD_XS_TipoDeDdocumento__c.getDescribe(), true);
        mapStateSubProj = getPicklistObjectMap(SOD_XS_SubproyectoDelCaso__c.SOD_XS_Estado__c.getDescribe(), true);
        mapBasketType = getPicklistObjectMap(SOD_XS_SubproyectoDelCaso__c.SOD_XS_TipoCanasto__c.getDescribe(), true);
        mapStateDocAsoc = getPicklistObjectMap(SOD_XS_DocumentoAsociado__c.SOD_XS_Estado__c.getDescribe(), true);
        mapStateProduct = getPicklistObjectMap(SOD_XS_ProductoDelCaso__c.SOD_XS_Estado__c.getDescribe(), true);
    }

    /**
    *  @Description: Store the Case Data for F.com integration to Database Record
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */    
    public void storeCaseFcomData(){
        caseObject.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
        caseObject.SOD_XS_DocumentoAsociado__c = asocDocumentObject?.Id;
        /* rlvalencia: lineas comentadas hasta tener claro como se asignaran estas variables a casos F.com
        caseObject.SOD_XS_CentroCostoResponsable__c = ccResponsableObject?.Id;
        caseObject.SOD_XS_TiendaVende__c = shopThatSaleObject?.Id;
        caseObject.SOD_XS_ActualizacionPorIntegracion__c = true;
        */
        caseObject.SOD_XS_Asesor__c = (strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ) 
                                        ? (String)mapData.get(PRV_JS_ATT_ASESOR) : null;
        caseObject.SOD_XS_ErrorIntegracion__c = '';
        update caseObject;        
    }
    /**
    *  @Description: Utility method to determine if service response has Product 
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */    
    private Boolean hasProduct(List<String> productCodes, String productCode){
        if(productCodes.isEmpty()) return true;
        for(String pc : productCodes){
            if(pc.equals(productCode)) return true;
        }
        return false;
    }
    /**
    *  @Description: Store the Product data for F.com integration to Database Record
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */    
    public void storeProductsFcomData(List<String> productCodes) {
        // completamos la información de los productos asociados a las reservas
        List<SOD_XS_ProductoDelCaso__c> listCaseProducts = new List<SOD_XS_ProductoDelCaso__c>();
        Map<String, Product2> mapNewProduct2 = new Map<String, Product2>();
        Boolean caseIsConsulta = (Boolean) mapData?.get(PRV_JS_ATT_ISCONSULT);
        if (caseIsConsulta == null || !caseIsConsulta) { // ! (Boolean) mapData?.get(PRV_JS_ATT_ISCONSULT)
            List<SOD_XS_ReservasDelCaso__c> reservasActualizar = new List<SOD_XS_ReservasDelCaso__c>();
            Map<Id, SOD_XS_ReservasDelCaso__c> mapaReservasActualizar = new Map<Id, SOD_XS_ReservasDelCaso__c>();
            for(SOD_XS_ReservasDelCaso__c r : listReserves) {
                List<SOD_XS_ProductoDelCaso__c> lpcase = mapProducts.get(r.Name);
                List<SOD_XS_ProductoDelCaso__c> fpcase = new List<SOD_XS_ProductoDelCaso__c>();
                // Si se pasaron codigos del producto en el llamado al servicio desde F.com, filtrar los productos del caso en base a los codios del producto (SKU Id)
                if(Boolean.valueOf(Label.SOD_XS_FcomFiltrarProductosDelCaso) && productCodes != null && !productCodes.isEmpty()) {
                    for(SOD_XS_ProductoDelCaso__c pdc : lpcase) {
                        for(String pc : productCodes){
                            if(pdc.SOD_XS_CodigoProducto__c == pc){
                                fpcase.add(pdc);
                                break;
                            }
                        }
                    }
                } else {
                    fpcase = lpcase;
                }
                Product2 prd;
                Product2 prdReference;
                for(SOD_XS_ProductoDelCaso__c pcase : fpcase) {
                    prdReference = new Product2(SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + pcase.SOD_XS_CodigoProducto__c);
                    pcase.SOD_XS_Producto__r = prdReference;
                    pcase.SOD_XS_NombreCliente__c = accObject.Id;
                    pcase.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
                    pcase.SOD_XS_DocumentoAsociado__c = asocDocumentObject?.Id;
                    pcase.SOD_XS_Country__c = accObject.SOD_XS_Country__c;
                    pcase.CurrencyIsoCode = String.isBlank(pcase.CurrencyIsoCode) ? accObject.CurrencyIsoCode : pcase.CurrencyIsoCode;
                    pcase.SOD_XS_ReservaDelCaso__c = r?.Id; 
                    pcase.SOD_XS_Despacho__c = pcase.SOD_XS_Despacho__r.id; 
                    pcase.SOD_XS_Origen__c = pcase.SOD_XS_Origen__r.id; 
                    pcase.SOD_XS_TipoDespacho__c = mapTranslator.get(PRV_WS_TRANS_TE)?.get(pcase.SOD_XS_TipoDespacho__c?.toUpperCase()); 
                    pcase.SOD_XS_MotivoDevolucion__c = mapTranslator.get(PRV_WS_TRANS_MD)?.get(pcase.SOD_XS_MotivoDevolucion__c?.toUpperCase()); 
                    pcase.SOD_XS_Estado__c = mapTranslator.get(PRV_WS_TRANS_ERS)?.get(pcase.SOD_XS_Estado__c?.toUpperCase());  
                    pcase.SOD_XS_Caso__c = caseObject.Id;
                    pcase.SOD_XS_KeepIt__c = false; // DEBUG - System.DmlException value not of required type: : [SOD_XS_KeepIt__c]
                    pcase.SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + pcase.SOD_XS_CodigoProducto__c + '_' + pcase.SOD_XS_Caso__c;
                    listCaseProducts.add(pcase);

                    prd = new Product2();
                    prd.Name = pcase.SOD_XS_CodigoProducto__c + '-' + pcase.SOD_XS_DescripcionDelProducto__c?.left(230);
                    prd.Description = pcase.SOD_XS_DescripcionDelProducto__c;
                    prd.SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + pcase.SOD_XS_CodigoProducto__c;
                    prd.SOD_XS_Country__c = accObject.SOD_XS_Country__c;
                    prd.CurrencyIsoCode = String.isBlank(pcase.CurrencyIsoCode) ? accObject.CurrencyIsoCode : pcase.CurrencyIsoCode;
                    prd.SOD_XS_CreadoPorIntegracion__c = true;
                    prd.ProductCode = pcase.SOD_XS_CodigoProducto__c;
                    prd.StockKeepingUnit = prd.SOD_XS_IdExterno__c;
                    prd.SOD_XS_BypassIntegracion__c = true;
                    mapNewProduct2.put(pcase.SOD_XS_CodigoProducto__c, prd);
                    if(r.Id != null){
                        reservasActualizar.add(r);
                    }
                }
                r.SOD_XS_CreadoPorFcom__c = true;
                if(r.Id != null){
                    reservasActualizar.add(r);
                }  
            }
            upsert mapNewProduct2.values() SOD_XS_IdExterno__c;
            upsert listCaseProducts SOD_XS_IdExterno__c;
            mapaReservasActualizar.putAll(reservasActualizar);
            if(!mapaReservasActualizar.isEmpty()){
                update mapaReservasActualizar.values();
            }
        }
    }

    /**
    *  @Description: Constructor used to receive a json
    *  @Author:      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/12/2020
    */
    public SOD_XS_360ViewPurchasesExtension (String jsonData) {
        mapData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        accObject = (Account) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_ACC)), Account.class);
        caseObject = (Case) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_CASE)), Case.class);
        sellDocumentObject = (SOD_XS_DocumentoDeVenta__c) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_DOCV)), SOD_XS_DocumentoDeVenta__c.class);
        asocDocumentObject = (SOD_XS_DocumentoAsociado__c) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_DOCA)), SOD_XS_DocumentoAsociado__c.class);
        strObjectType = (String) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_TYPE)), String.class);
        shopThatSaleObject = (SOD_XS_CentroDeCosto__c) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_SHOP)), SOD_XS_CentroDeCosto__c.class);
        ccResponsableObject = (SOD_XS_CentroDeCosto__c) JSON.deserialize(JSON.serialize(mapData.get(PRV_JS_OBJ_CCResp)), SOD_XS_CentroDeCosto__c.class);

        if(strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ){
            listSubProject = new List<SOD_XS_SubproyectoDelCaso__c>();
        }else{
            listReserves = new List<SOD_XS_ReservasDelCaso__c>();
        }
        
        mapProducts = new Map<String, List<SOD_XS_ProductoDelCaso__c>>();
        SOD_XS_SubproyectoDelCaso__c subProject = new SOD_XS_SubproyectoDelCaso__c();
        SOD_XS_ReservasDelCaso__c reserve = new SOD_XS_ReservasDelCaso__c();

        List<Object> listReserveJSON = (List<Object>) mapData.get(PRV_JS_LST_RSV);
        for(Object r : listReserveJSON) {
            Map<String, Object> rMap = (Map<String, Object>) r;
            
            if(strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ){
                subProject = (SOD_XS_SubproyectoDelCaso__c) JSON.deserialize(JSON.serialize(rMap.get(PRV_JS_OBJ_SPJ)), SOD_XS_SubproyectoDelCaso__c.class);
                listSubProject.add(subProject);
            }else{
                reserve = (SOD_XS_ReservasDelCaso__c) JSON.deserialize(JSON.serialize(rMap.get(PRV_JS_OBJ_RSV)),SOD_XS_ReservasDelCaso__c.class);
                listReserves.add(reserve);
            }

            List<Object> listProdJSON = (List<Object>) rMap?.get(PRV_JS_LST_PRD);
            List<SOD_XS_ProductoDelCaso__c> listProdSF = new List<SOD_XS_ProductoDelCaso__c>();
            for (Object p : listProdJSON) {
                SOD_XS_ProductoDelCaso__c product = (SOD_XS_ProductoDelCaso__c) JSON.deserialize(JSON.serialize(p), 
                                                                                                 SOD_XS_ProductoDelCaso__c.class);
                listProdSF.add(product);
            }
            if(strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ){
                mapProducts.put(subProject.Name, listProdSF);
            }else{
                mapProducts.put(reserve.Name, listProdSF);
            }
            
        }

        mapStore = getStoreMap(accObject.SOD_XS_Country__r.Id);
        mapTranslator = getPicklistTranslationMap(accObject.SOD_XS_Country__r.SOD_XS_Codigo__c);
        mapDocAssocRecordType = getAssocDocRecordTypeMap();

        mapDocAssocType = getPicklistObjectMap(SOD_XS_DocumentoAsociado__c.SOD_XS_TipoDeDdocumento__c.getDescribe(), true);
        mapStateSubProj = getPicklistObjectMap(SOD_XS_SubproyectoDelCaso__c.SOD_XS_Estado__c.getDescribe(), true);
        mapBasketType = getPicklistObjectMap(SOD_XS_SubproyectoDelCaso__c.SOD_XS_TipoCanasto__c.getDescribe(), true);
        mapStateDocAsoc = getPicklistObjectMap(SOD_XS_DocumentoAsociado__c.SOD_XS_Estado__c.getDescribe(), true);
        mapStateProduct = getPicklistObjectMap(SOD_XS_ProductoDelCaso__c.SOD_XS_Estado__c.getDescribe(), true);

    }

    /**
    *  @Description: Get a Map with the ids of the stores for the Country passed as param
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public static Map<String, String> getStoreMap(String strCountryId) {
        List<SOD_XS_CentroDeCosto__c> l = new List<SOD_XS_CentroDeCosto__c>(
                                                        [SELECT Id, Name, SOD_XS_CentroDeCosto__c
                                                        FROM SOD_XS_CentroDeCosto__c 
                                                        WHERE SOD_XS_Country__c = :strCountryId
                                                        AND SOD_XS_CentroDeCosto__c <> null]);

        Map<String, String> m = new Map<String, String>();
        for (SOD_XS_CentroDeCosto__c s : l) {
            m.put(s.SOD_XS_CentroDeCosto__c, s.Id);
        }
        return m;
    }

    /**
    *  @Description: Get a Map with translations for picklist from the integration
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public static Map<String, Map<String, String>> getPicklistTranslationMap(String strCountryCode) {
        List<SOD_XS_WS_Translator_Catalog__mdt> l = new List<SOD_XS_WS_Translator_Catalog__mdt>(
                                                        [SELECT SOD_XS_WS_PickListTypeName__c, SOD_XS_WS_CorporateCode__c, SOD_XS_WS_CorporateName__c
                                                         FROM SOD_XS_WS_Translator_Catalog__mdt 
                                                         WHERE SOD_XS_WS_CountryISOCode__c = :strCountryCode
                                                         ORDER BY SOD_XS_WS_PickListTypeName__c]);
        Map<String, Map<String, String>> m = new Map<String, Map<String, String>>();
        Map<String, String> i;
        for (SOD_XS_WS_Translator_Catalog__mdt t : l) {
            if (m.get(t.SOD_XS_WS_PickListTypeName__c) == null) {
                i = new Map<String, String>();
                m.put(t.SOD_XS_WS_PickListTypeName__c, i);
            }
            i = m.get(t.SOD_XS_WS_PickListTypeName__c);
            i.put(t.SOD_XS_WS_CorporateName__c.toUpperCase(), t.SOD_XS_WS_CorporateCode__c);
        }

        return m;
    }
 
    /**
    *  @Description: Get a Map with translations for objects
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        23/03/2021
    */    
    public static Map<String, String> getPicklistObjectMap(Schema.DescribeFieldResult obj, Boolean valueUppercase) {
        Map<String, String> m = new Map<String, String>();
        List<Schema.PicklistEntry> values = obj.getPicklistValues();
        for( Schema.PicklistEntry v : values) {
           if(valueUppercase){
            m.put(v.getLabel().toUpperCase(), v.getValue().toUpperCase());
           }else{
            m.put(v.getLabel().toUpperCase(), v.getValue());
           }

        }
        return m;
    }    

    /**
    *  @Description: Method used to get the Record Types for DOCA
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        11/03/2020
    */
    public Map<String,Schema.RecordTypeInfo> getAssocDocRecordTypeMap()
    {
        Schema.DescribeSObjectResult d = Schema.SObjectType.SOD_XS_DocumentoAsociado__c; 
        Map<String,Schema.RecordTypeInfo> rtMapByDevelName = d.getRecordTypeInfosByDeveloperName();
        return rtMapByDevelName;
    }

    /**
    *  @Description: Store the Sell Document Data to Database Record
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public void storeSellDocumentData() {
        if(sellDocumentObject != null){
            
            sellDocumentObject.SOD_XS_NombreCliente__c = accObject?.Id;
            sellDocumentObject.SOD_XS_TiendaQueVende__c = (sellDocumentObject?.SOD_XS_CodigoTiendaQueVende__c == null) ? 
                                                            null :
                                                            mapStore?.get(sellDocumentObject?.SOD_XS_CodigoTiendaQueVende__c?.isNumeric() ? 
                                                                            integer.valueof(sellDocumentObject?.SOD_XS_CodigoTiendaQueVende__c)?.format() :
                                                                            sellDocumentObject?.SOD_XS_CodigoTiendaQueVende__c);
            sellDocumentObject.SOD_XS_TipoDeDdocumento__c = mapTranslator.get(PRV_WS_TRANS_DV)?.get(sellDocumentObject?.SOD_XS_TipoDeDdocumento__c?.toUpperCase());
            sellDocumentObject.SOD_XS_MedioDePago__c = mapTranslator.get(PRV_WS_TRANS_MP)?.get(sellDocumentObject?.SOD_XS_MedioDePago__c?.toUpperCase());
            sellDocumentObject.SOD_XS_MedioDePago2__c = getValuesForMultipicklist(sellDocumentObject?.SOD_XS_MedioDePago2__c);
            sellDocumentObject.CurrencyIsoCode = String.isBlank(sellDocumentObject?.CurrencyIsoCode) ? accObject?.CurrencyIsoCode : sellDocumentObject?.CurrencyIsoCode;
            sellDocumentObject.SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' +  
                                                     sellDocumentObject?.SOD_XS_TipoDeDdocumento__c?.toUpperCase() + '_' + 
                                                     sellDocumentObject?.SOD_XS_IdExterno__c;
            upsert sellDocumentObject SOD_XS_IdExterno__c;
        }
    }

    /**
    *  @Description: Store the ASoc Document Data to Database Record
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public void storeAsocDocumentData() {
        asocDocumentObject.SOD_XS_NombreCliente__c = accObject.Id;
        String rcdType = (strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ) ? PRV_WS_TRANS_RT_PRY : PRV_WS_TRANS_RT_OC;
        asocDocumentObject.RecordTypeId = mapDocAssocRecordType.get(rcdType).recordtypeid;

        if( strObjectType != PRV_JS_OBJ_PRJ && strObjectType != PRV_JS_OBJ_SUBPRJ ){
            asocDocumentObject.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
        }
        asocDocumentObject.SOD_XS_TipoDeDdocumento__c = mapDocAssocType.get(asocDocumentObject?.SOD_XS_TipoDeDdocumento__c?.toUpperCase());
        asocDocumentObject.CurrencyIsoCode = String.isBlank(asocDocumentObject.CurrencyIsoCode) ? accObject.CurrencyIsoCode : asocDocumentObject.CurrencyIsoCode;
        asocDocumentObject.SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r.SOD_XS_Codigo__c.toUpperCase() + '_' + 
                                                 asocDocumentObject.SOD_XS_TipoDeDdocumento__c.toUpperCase() + '_' + 
                                                 asocDocumentObject.SOD_XS_IdExterno__c;
        
        asocDocumentObject.SOD_XS_Estado__c = mapStateDocAsoc.get(asocDocumentObject?.SOD_XS_Estado__c?.toUpperCase());
        upsert asocDocumentObject SOD_XS_IdExterno__c;
    }

    /**
    *  @Description: Store the Case Data to Database Record
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public void storeCaseData() {
        //completamos la información del caso
        //Se incorpora el Contacto cuando cliente sea persona
        caseObject.ContactId = accObject?.IsPersonAccount ? accObject?.PersonContactId : null;
        caseObject.AccountId = accObject.Id;
        caseObject.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
        caseObject.SOD_XS_DocumentoAsociado__c = asocDocumentObject?.Id;
        caseObject.SOD_XS_CentroCostoResponsable__c = ccResponsableObject?.Id;
        caseObject.SOD_XS_TiendaVende__c = shopThatSaleObject?.Id;
        //caseObject.SOD_XS_FormadePago__c = mapTranslator.get(PRV_WS_TRANS_MP)?.get(caseObject.SOD_XS_FormadePago__c?.toUpperCase());
        caseObject.SOD_XS_Asesor__c = (strObjectType == PRV_JS_OBJ_PRJ || strObjectType == PRV_JS_OBJ_SUBPRJ) 
                                        ? (String)mapData.get(PRV_JS_ATT_ASESOR) : null;
        insert caseObject;
    }

    /**
    *  @Description: Store the Reserve Data to Database Record
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public void storeReserveData() {
        // completamos la información de las reservas
        for(SOD_XS_ReservasDelCaso__c r : listReserves) {
            r.SOD_XS_NombreCliente__c = accObject?.Id;
            r.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
            r.SOD_XS_DocumentoAsociado__c = asocDocumentObject?.Id;
            r.CurrencyIsoCode = String.isBlank(r.CurrencyIsoCode) ? accObject.CurrencyIsoCode : r.CurrencyIsoCode;
            r.SOD_XS_CanalDeVenta__c = mapTranslator.get(PRV_WS_TRANS_CDV)?.get(r.SOD_XS_CanalDeVenta__c?.toUpperCase());
            r.SOD_XS_TipoEntrega__c = mapTranslator.get(PRV_WS_TRANS_TE)?.get(r.SOD_XS_TipoEntrega__c?.toUpperCase());
            r.SOD_XS_TipoReserva__c = mapTranslator.get(PRV_WS_TRANS_TR)?.get(r.SOD_XS_TipoReserva__c?.toUpperCase());
            r.SOD_XS_Estado__c = mapTranslator.get(PRV_WS_TRANS_ER)?.get(r.SOD_XS_Estado__c?.toUpperCase());
            r.SOD_XS_Caso__c = caseObject.Id;
            r.SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + r.Name + '_' + r.SOD_XS_Caso__c;
        }
        upsert listReserves SOD_XS_IdExterno__c;
    }

    /**
    *  @Description: Store the SubProject Data to Database Record
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        18/03/2021
    */    
     public void storeSubProjectData() {
        for(SOD_XS_SubproyectoDelCaso__c sp : listSubProject) {
            sp.SOD_XS_NombreCliente__c = accObject.Id;
            sp.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
            sp.SOD_XS_DocumentoAsociado__c = asocDocumentObject.Id;
            sp.CurrencyIsoCode = String.isBlank(sp.CurrencyIsoCode) ? accObject.CurrencyIsoCode : sp.CurrencyIsoCode;
            sp.SOD_XS_Estado__c = mapStateSubProj.get(sp.SOD_XS_Estado__c?.toUpperCase());
            sp.SOD_XS_TipoCanasto__c = mapBasketType.get(sp.SOD_XS_TipoCanasto__c?.toUpperCase());
            sp.SOD_XS_Caso__c = caseObject.Id;
        }
        insert listSubProject;
    } 

    /**
    *  @Description: Store the Product data to Database Record
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    public void storeProductsData() {
        storeProductsFcomData(null);
    }

    /**
    *  @Description: Store the SubProject Product Data to Database Record
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        23/03/2020
    */    
    public void storeSubProjectProductsData() {
        List<SOD_XS_ProductoDelCaso__c> listCaseProducts = new List<SOD_XS_ProductoDelCaso__c>();
        Map<String, Product2> mapNewProduct2 = new Map<String, Product2>();
        if (! (Boolean) mapData.get(PRV_JS_ATT_ISCONSULT)) {
            for(SOD_XS_SubproyectoDelCaso__c r : listSubProject) {
                
                List<SOD_XS_ProductoDelCaso__c> lpcase = mapProducts.get(r.Name);
                Product2 prd;
                Product2 prdReference;
                for(SOD_XS_ProductoDelCaso__c pcase : lpcase) {
                    
                    prdReference = new Product2(SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + pcase.SOD_XS_CodigoProducto__c);
                    pcase.SOD_XS_Producto__r = prdReference;
                    pcase.SOD_XS_NombreCliente__c = accObject?.Id;
                    pcase.SOD_XS_DocumentoDeVenta__c = sellDocumentObject?.Id;
                    pcase.SOD_XS_DocumentoAsociado__c = asocDocumentObject?.Id;
                    pcase.SOD_XS_Country__c = accObject.SOD_XS_Country__c;
                    pcase.CurrencyIsoCode = String.isBlank(pcase.CurrencyIsoCode) ? accObject.CurrencyIsoCode : pcase.CurrencyIsoCode; 
                    pcase.SOD_XS_SubproyectoDelCaso__c = r?.Id;
                    pcase.SOD_XS_Estado__c = mapStateProduct.get(r?.SOD_XS_Estado__c?.toUpperCase()); 
                    pcase.SOD_XS_Caso__c = caseObject.Id;
                    listCaseProducts.add(pcase);
                    
                    prd = new Product2();
                    prd.Name = pcase.SOD_XS_CodigoProducto__c + '-' + pcase.SOD_XS_DescripcionDelProducto__c?.left(230);
                    prd.Description = pcase.SOD_XS_DescripcionDelProducto__c;
                    prd.SOD_XS_IdExterno__c = accObject.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + pcase.SOD_XS_CodigoProducto__c;
                    prd.SOD_XS_Country__c = accObject.SOD_XS_Country__c;
                    prd.CurrencyIsoCode = String.isBlank(pcase.CurrencyIsoCode) ? accObject.CurrencyIsoCode : pcase.CurrencyIsoCode;
                    prd.SOD_XS_CreadoPorIntegracion__c = true;
                    prd.ProductCode = pcase.SOD_XS_CodigoProducto__c;
                    prd.StockKeepingUnit = prd.SOD_XS_IdExterno__c;
                    prd.SOD_XS_BypassIntegracion__c = true;
                    mapNewProduct2.put(pcase.SOD_XS_CodigoProducto__c, prd);
                }
            }
            upsert mapNewProduct2.values() SOD_XS_IdExterno__c;
            insert listCaseProducts;
        }
    }

    /**
    *  @Description: Process the list of values to insert into the multipicklist
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    private String getValuesForMultipicklist(String strParam) {
        if (strParam == null) {
            return null;
        }
        List<String> translatedValues = new List<String>();
        for(String v: strParam?.split(',')) {
            String tmp = mapTranslator.get(PRV_WS_TRANS_MP)?.get(v?.toUpperCase());
            if (tmp != null) {
                translatedValues.add(tmp);
            }
        }
        if(translatedValues.size() > 0) {
            return String.join(translatedValues, ';');
        }
        return null;
    }
}