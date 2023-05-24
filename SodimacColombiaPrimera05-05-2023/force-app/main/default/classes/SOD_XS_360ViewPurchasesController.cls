/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 02/10/2020
Description  : APEX Controller - Search Purcharses
History      : CMRSC-4310
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            02/10/2020      initial version
********************************************************************************/
public class SOD_XS_360ViewPurchasesController {
    
    @AuraEnabled public WrapSearchCriteria searchCriteria {get;set;}
    @AuraEnabled public List<SOD_XS_MAPJSON360ViewClient.DataTableWrapper> dataTable {get;set;}
    @AuraEnabled public List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> labelsTable {get;set;}
    @AuraEnabled public List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> rsvLabelsTable {get;set;}
    @AuraEnabled public Map<String, Object> mapPurchases {get;set;}
    @AuraEnabled public SOD_XS_DataTableUtily.ButtonDescriptionWrapper rsvButton {get;set;}
    @AuraEnabled public Boolean isError {get;set;}
    @AuraEnabled public UserMessage errorService {get;set;}

    /**
    *  @Description: Declaration of static variables
    *  @Author:      ATO
    *  @Date:        02/10/2020
    */
    private static final String PRV_WS_360VIEW;
    private static final String PRV_WS_ORD;
    private static final String PRV_OBJ_DOCV;
    private static final String PRV_OBJ_DOCA;
    private static final String PRV_OBJ_RSV;
    private static final String PRV_OBJ_PRD;
    private static final String PRV_OBJ_CASE;
    private static final String PVR_SFDC_CASE_CON;
    private static final String PVR_SFDC_CASE_REC;
    private static final String PVR_SFDC_CASE_SOL;
    private static final String PRV_STR_PCK;
    private static final String PRV_CLM_DOCA;
    private static final String PRV_CLM_DOCV;
    private static final String PRV_CLM_RSV;
    private static final String PRV_CLM_PRD_PRC;
    private static final String PRV_CLM_PRD_PMT;
    private static final String PRV_CLM_PRD_RES;
    private static final String PRV_VRB_DOCV;
    private static final String PRV_VRB_DOCA;
    private static final String PRV_MSG_NOTFOUND;
    private static final String PRV_MSG_ERROR;
    private static final String PRV_CLM_STORE;
    private static final String PRV_OBJ_STORE;
    private static final String PRV_VRB_STORE;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    static {
        PRV_WS_360VIEW = Label.SOD_XS_HistorialCompra;
        PRV_WS_ORD = Label.SOD_XS_OrdenCompra;
        PRV_OBJ_DOCV = Schema.SObjectType.SOD_XS_DocumentoDeVenta__c.getName();
        PRV_OBJ_DOCA = Schema.SObjectType.SOD_XS_DocumentoAsociado__c.getName();
        PRV_OBJ_RSV = Schema.SObjectType.SOD_XS_ReservasDelCaso__c.getName();
        PRV_OBJ_PRD = Schema.SObjectType.SOD_XS_ProductoDelCaso__c.getName();
        PRV_OBJ_CASE = Schema.SObjectType.Case.getName();
        PVR_SFDC_CASE_CON = 'SOD_XS_Consulta';
        PVR_SFDC_CASE_REC = 'SOD_XS_Reclamo';
        PVR_SFDC_CASE_SOL = 'SOD_XS_Solicitud';
        PRV_STR_PCK = 'Documento de Venta';
        PRV_CLM_DOCA = 'Name:4';
        PRV_CLM_DOCV = 'SOD_XS_FechaDeCompra__c:1;SOD_XS_TipoDeDdocumento__c:2;Name:3;SOD_XS_MontoTotal__c:5;SOD_XS_MedioDePago__c:6';        
        PRV_CLM_RSV = 'Name:1;SOD_XS_ReservaMadre__c:2;SOD_XS_TipoEntrega__c:3;SOD_XS_TipoReserva__c:4;SOD_XS_Estado__c:5';
        PRV_CLM_PRD_PRC = 'SOD_XS_CantidadAfectada__c:1;SOD_XS_KeepIt__c:2;SOD_XS_Bloqueo__c:3;SOD_XS_CodigoProducto__c:4;SOD_XS_DescripcionDelProducto__c:5;SOD_XS_Cantidad__c:6;SOD_XS_PrecioUnitario__c:7;SOD_XS_Estado__c:8;SOD_XS_FechaEntregaOriginal__c:9;SOD_XS_RangoHorario__c:10;SOD_XS_FechaDespacho__c:11;SOD_XS_FechaEntrega__c:12;SOD_XS_CodigoOrigen__c:13;SOD_XS_CodigoDespacho__c:14;SOD_XS_MotivoDevolucion__c:15;SOD_XS_NumeroGuia__c:16;SOD_XS_AuxTipoDePostventa__c:17;SOD_XS_AuxTipoDeProducto__c:18;SOD_XS_AuxEncargadoComercial__c:19;SOD_XS_AuxGerenteDeLinea__c:20';
        PRV_CLM_PRD_PMT = 'SOD_XS_CantidadAfectada__c:1;SOD_XS_CodigoProducto__c:2;SOD_XS_DescripcionDelProducto__c:3;SOD_XS_Cantidad__c:4;SOD_XS_PrecioUnitario__c:5;SOD_XS_Descuento__c:6;SOD_XS_ImporteTotal__c:7';
        PRV_CLM_PRD_RES = 'SOD_XS_CodigoProducto__c:1;SOD_XS_DescripcionDelProducto__c:2;SOD_XS_Cantidad__c:3;SOD_XS_CantidadAfectada__c:4;SOD_XS_TipoDespacho__c:5;SOD_XS_Estado__c:6;SOD_XS_NumeroGuia__c:7;SOD_XS_CCDespacho__c:8;SOD_XS_KeepIt__c:9';
        PRV_VRB_DOCV = 'objDocV';
        PRV_VRB_DOCA = 'objDocA';
        PRV_MSG_NOTFOUND = Label.SOD_XS_V360OCNoSeEncontraronResultados;
        PRV_MSG_ERROR = Label.SOD_XS_V360OCErrorIntegracion;
        PRV_CLM_STORE = 'Name:7';
        PRV_VRB_STORE = 'objShopThatSell';
        PRV_OBJ_STORE = Schema.SObjectType.SOD_XS_CentroDeCosto__c.getName();
    }

    /**
    *  @Description: Wrapper used to set path parameters
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public class WrapSearchCriteria {
        @AuraEnabled public Account client {get;set;}
        @AuraEnabled public String path360View {get;set;} 
        @AuraEnabled public List<OptionDocType> docType {get; set;}
        @AuraEnabled public Boolean is360View {get;set;}
        @AuraEnabled public Boolean isDateRange {get;set;}
        @AuraEnabled public Boolean isPurchaseOrders {get;set;}
        @AuraEnabled public Boolean isSalesDocument {get;set;}
        @AuraEnabled public Boolean isReserve {get;set;}
        @AuraEnabled public String orderNumber {get;set;}
        @AuraEnabled public String reserveNumber {get;set;}
        @AuraEnabled public PurchaseDateFilter purchaseDateFilter {get; set;}
        @AuraEnabled public SalesDocumentFilter salesDocumentFilter {get; set;}
        //Pagination
        @AuraEnabled public Integer pageNumber {get; set;}
        @AuraEnabled public Integer pageSize {get; set;}
        @AuraEnabled public Integer numberOfPages {get; set;}
        @AuraEnabled public Integer totalElements {get; set;}
        //Constructor used to initialize the search criteria in the 360 ​​view
        public wrapSearchCriteria(Account client) {
            this.client = client;
            this.path360View = '360View';
            this.docType = optionDocType(client.SOD_XS_Country__r.SOD_XS_Codigo__c);
            this.is360View = true;
            this.isDateRange = false;
            this.isPurchaseOrders = false;
            this.isSalesDocument = false;
            this.isReserve = false;
            this.pageNumber = 1;
            this.pageSize = 10;
        }
        public wrapSearchCriteria() {}
    }

    /**
    *  @Description: Wrapper used to set a selection list
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public class OptionDocType{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}        
    }
    /**
    *  @Description: Wrapper used to set the purchase date filters
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public class PurchaseDateFilter {
        @AuraEnabled public String dateFrom {get; set;}
        @AuraEnabled public String dateTo {get; set;}
        
        public purchaseDateFilter() {
            DateTime df = Date.Today() - 90;
            DateTime dt = Date.Today();
            this.dateFrom = df.format('dd/MM/yyyy');
            this.dateTo = dt.format('dd/MM/yyyy');
        }
    }

    /**
    *  @Description: Wrapper used to set the sales document filter
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public class SalesDocumentFilter {
        @AuraEnabled public String salesDocumentNumber {get; set;}
        @AuraEnabled public String salesDocumentType {get; set;}
    }
    
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    @AuraEnabled
    public static SOD_XS_360ViewPurchasesController initClass(Id rcdId) {
        
        SOD_XS_360ViewPurchasesController obj = new SOD_XS_360ViewPurchasesController();
        Account acc = getRecord(rcdId);
        obj.isError = false;
        // Loading search criteria
        obj.searchCriteria = new WrapSearchCriteria(acc);
        obj.searchCriteria.purchaseDateFilter = new PurchaseDateFilter();
        // Loading table columns orders
        obj.labelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_DOCV}, PRV_CLM_DOCV, PRV_VRB_DOCV));
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_DOCA}, PRV_CLM_DOCA, PRV_VRB_DOCA));
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_STORE}, PRV_CLM_STORE, PRV_VRB_STORE));
        obj.labelsTable.sort();
        // Loading table columns reservations
        obj.rsvLabelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        obj.rsvLabelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_RSV}, PRV_CLM_RSV, null));
        obj.rsvLabelsTable.sort();
        // Loading reservation button
        obj.rsvButton = setRsvButton();
        try {
            // Consuming web service
            SOD_XS_MAPJSON360ViewClient objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360View(obj.searchCriteria), SOD_XS_JSON360ViewClient.class), acc);
            obj.searchCriteria.numberOfPages = objClass.obj.threeHundredAndSixtyView.pagination.numberOfPages;
            obj.searchCriteria.totalElements = objClass.obj.threeHundredAndSixtyView.pagination.totalElements;
            // Purchase Data
            obj.mapPurchases = objClass.mapPurchases; 
            obj.dataTable = objClass.getPurchasesDataTable();

        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, rcdId);
            obj = getServiceException(obj, e, logIdentifier);
            /*
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.code);
            obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()); 
            */
            /*
            system.debug('Service Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.code);
            obj.errorService.showMessage = e.code == 404 
                                           ? PRV_MSG_NOTFOUND 
                                           : PRV_MSG_ERROR; */
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, rcdId);
            obj = getServiceException(obj, e, logIdentifier);
            /*
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.code);
            obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()); 
            */
            /*
            system.debug('Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.getLineNumber());
            obj.errorService.showMessage = e.getMessage();*/
        }
        return obj;
    }
    
    /**
    *  @Description: Wrapper used to search for a purchase order in the web service
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    @AuraEnabled
    public static Object getPurchaseDataObject(WrapSearchCriteria intPath) {
        Object objPurchase;
        try {
            SOD_XS_MAPJSON360ViewClient objClass;
            objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360View(intPath), SOD_XS_JSON360ViewClient.class), intPath.client);
            // Purchase Data
            objPurchase = objClass.getPurchaseObject();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Service Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            throw new AuraHandledException (e.code == 404 
                                            ? PRV_MSG_NOTFOUND 
                                            : PRV_MSG_ERROR);*/
        } catch(Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            throw new AuraHandledException (e.getMessage());*/
        }
        return objPurchase;
    }

    /**
    *  @Description: Wrapper used to search for a purchase order by pagination in the web service
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    @AuraEnabled
    public static SOD_XS_360ViewPurchasesController getPageOrdersAsPerPagination(WrapSearchCriteria intPath) {
        SOD_XS_360ViewPurchasesController obj = new SOD_XS_360ViewPurchasesController();
        obj.isError = false;
        try {
            obj.searchCriteria = new WrapSearchCriteria();
            SOD_XS_MAPJSON360ViewClient objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360View(intPath), SOD_XS_JSON360ViewClient.class), intPath.client);
            obj.searchCriteria.numberOfPages = objClass.obj.threeHundredAndSixtyView.pagination.numberOfPages;
            obj.searchCriteria.totalElements = objClass.obj.threeHundredAndSixtyView.pagination.totalElements;
            // Purchase Data  
            obj.mapPurchases = objClass.mapPurchases; 
            obj.dataTable = objClass.getPurchasesDataTable();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            obj = getServiceException(obj, e, logIdentifier);
            /*
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.code);
            obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()); 
            */
            /*
            system.debug('Service Exception: ' + e);
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.code);
            obj.errorService.showMessage = e.code == 404 
                                           ? PRV_MSG_NOTFOUND 
                                           : PRV_MSG_ERROR;*/
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            obj = getServiceException(obj, e, logIdentifier);
            /*
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.code);
            obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()); 
            */
            /*
            system.debug('Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            obj.isError = true;
            obj.errorService = new UserMessage(e.getMessage(), e.getLineNumber());
            obj.errorService.showMessage = e.getMessage();*/
        }
        return obj;
    }

    /**
    *  @Description: Method used to set product button in data table
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        04/01/2021
    */
    @AuraEnabled
    public static SOD_XS_DataTableUtily.ButtonDescriptionWrapper setPrdButton () {
        SOD_XS_DataTableUtily.ButtonDescriptionWrapper btt = new SOD_XS_DataTableUtily.ButtonDescriptionWrapper();
        btt.label = 'Acción';
        btt.order = 0; 
        btt.typeAttributes = new SOD_XS_DataTableUtily.ButtonTypeAttributesWrapper();
        btt.typeAttributes.label = 'Ver';
        btt.typeAttributes.name =  'view_product';
        btt.typeAttributes.title = 'Click para ver el detalle de un producto';
        return btt;
    }

    /**
    *  @Description: Method used to set the values ​​of the document types
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public static List<OptionDocType> optionDocType(String country) {
        List<OptionDocType> options = new List<OptionDocType>();
        
        Map<String, SOD_XS_WS_Translator_Catalog__mdt> mpTd = new Map<String, SOD_XS_WS_Translator_Catalog__mdt>();
        for (SOD_XS_WS_Translator_Catalog__mdt tcm : [SELECT Id, SOD_XS_WS_CorporateCode__c, SOD_XS_WS_CorporateName__c 
                                                      FROM SOD_XS_WS_Translator_Catalog__mdt
                                                      WHERE SOD_XS_WS_PickListTypeName__c =: PRV_STR_PCK 
                                                      AND SOD_XS_WS_CountryISOCode__c =:country order by SOD_XS_WS_CorporateName__c asc]) {

			mpTd.put(tcm.SOD_XS_WS_CorporateName__c, tcm);
        }
           
        SOD_XS_WS_Translator_Catalog__mdt tCmdt = new SOD_XS_WS_Translator_Catalog__mdt();
        OptionDocType opt = new OptionDocType();
        
        for (String tpDoc : mpTd.keySet()){
            opt = new OptionDocType();
            tCmdt = mpTd.get(tpDoc);
            opt.label = tCmdt.SOD_XS_WS_CorporateName__c;
            opt.value = tCmdt.SOD_XS_WS_CorporateCode__c.toUpperCase();
            options.add(opt);
        }
        
        return options;
    }
    
    /**
    *  @Description: Method used to set reserve button in data table
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public static SOD_XS_DataTableUtily.ButtonDescriptionWrapper setRsvButton () {
        SOD_XS_DataTableUtily.ButtonDescriptionWrapper btt = new SOD_XS_DataTableUtily.ButtonDescriptionWrapper();
        btt.label = 'Reserva';
        btt.order = 0; 
        btt.typeAttributes = new SOD_XS_DataTableUtily.ButtonTypeAttributesWrapper();
        btt.typeAttributes.label = 'Ver cabecera';
        btt.typeAttributes.name =  'view_headers';
        btt.typeAttributes.title = 'Click para ver la cebecera de la reserva';
        return btt;
    }
    
    /**
    *  @Description: Query the database to obtain the information of the customer consulted in the 360 ​​view
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public static account getRecord(Id rcdId) {
        return [SELECT Id, FirstName, LastName, Name, SOD_XS_TipoDocumento__c, SOD_XS_NroDocumento__c, SOD_XS_IdExterno__c, SOD_XS_Country__c, 
        isPersonAccount, RecordTypeId, CreatedById, CurrencyIsoCode, SOD_XS_Country__r.SOD_XS_Codigo__c, PersonContactId FROM Account WHERE Id = :rcdId];
    }

    /**
    *  @Description: Get the types of documents
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public static Map<String, String> getDocTypeMap() {
        Map<String, String> str = new Map<String, String>();
        for (SOD_XS_Tipo_de_documento_BUC__mdt tdp : SOD_XS_ClientsConstant.PBC_MAP_DOCTYPEBYCOUNTRY) {
            str.put(tdp.Label, tdp.SOD_XD_Parametro_BUC__c);
        }
        return str;
    }

    /**
    *  @Description: Get the Description of object SOD_XD_ReservaDelCaso__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        13/11/2020
    */
    @AuraEnabled
    public static String getDescriptionForReserve() {
        String accLabels;
        try {
            accLabels = SOD_XS_EnUtility.getDescribedObjects( new List<String>{PRV_OBJ_RSV} );
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return accLabels;
    }

    /**
    *  @Description: Get the Labels for the table of the object SOD_XD_ProductoDelCaso__c for Purchase Orders
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        13/11/2020
    */
    @AuraEnabled
    public static List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> getColumnsForProductsPurchaseOrders() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> prdLabelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        try {
            prdLabelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_PRD}, PRV_CLM_PRD_PRC, null));
            prdLabelsTable.sort();
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return prdLabelsTable;
    }

    /**
    *  @Description: Get the Description of object SOD_XD_ReservaDelCaso__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        01/02/2020
    */
    @AuraEnabled
    public static String getDescriptionForSellDocument() {
        String accLabels;
        try {
            accLabels = SOD_XS_EnUtility.getDescribedObjects( new List<String>{PRV_OBJ_DOCV} );
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return accLabels;
    }

    /**
    *  @Description: Get the Labels for the table of the object SOD_XD_ProductoDelCaso__c for Payment Vouchers
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        01/02/2020
    */
    @AuraEnabled
    public static List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> getColumnsForProductsPaymentVouchers() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> prdLabelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        try {
            prdLabelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_PRD}, PRV_CLM_PRD_PMT, null));
            prdLabelsTable.sort();
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return prdLabelsTable;
    }

    /**
    *  @Description: Get the Description of required objects for Case Creation
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        10/12/2020
    */
    @AuraEnabled
    public static String getDescriptionForCaseCreation() {
        String strObjectDesc;
        try {
            List<String> lstObjects = new List<String>();
            lstObjects.add(PRV_OBJ_DOCV);
            lstObjects.add(PRV_OBJ_DOCA);
            lstObjects.add(PRV_OBJ_RSV);
            lstObjects.add(PRV_OBJ_PRD);
            lstObjects.add(PRV_OBJ_CASE);
            strObjectDesc = SOD_XS_EnUtility.getDescribedObjects( lstObjects );
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return strObjectDesc;
    }

    /**
    *  @Description: Get the Description of required objects for Case Creation
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        10/12/2020
    */
    @AuraEnabled
    public static Map<String, String> getDescriptionObjectsForCase() {
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();        
        Map<String, String> result = new Map<String,String>();
        List<String> listObjects = new List<String>();
        try {
            listObjects.add(PRV_OBJ_DOCV);
            listObjects.add(PRV_OBJ_DOCA);
            listObjects.add(PRV_OBJ_RSV);
            listObjects.add(PRV_OBJ_PRD);
            listObjects.add(PRV_OBJ_CASE);    
            // Iterate over the list of objects and describe each object  
            for( String sObjectType : listObjects ) {
                DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
                result.put(sObjectType, describeResult.getLabel());
            }
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return result;
    }

    /**
    *  @Description: Get the record types for case object
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        10/12/2020
    */
    @AuraEnabled
    public static Map<Id, String> getCaseRecordType(){
        Map<Id, String> resRecordTypes = new Map<Id, String>();
        try {
            List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();    
            for(RecordTypeInfo rt : recordtypes){
                if(rt.getDeveloperName() == PVR_SFDC_CASE_CON || 
                    rt.getDeveloperName() == PVR_SFDC_CASE_REC || 
                    rt.getDeveloperName() == PVR_SFDC_CASE_SOL) {
                    
                    resRecordTypes.put(rt.getRecordTypeId(), rt.getName());
                }
            }        
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return resRecordTypes;
    }

    /**
    *  @Description: Get the Labels for the table of the object SOD_XD_ProductoDelCaso__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        13/11/2020
    */
    @AuraEnabled
    public static List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> getProductColumnsForResume() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> prdLabelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        try {
            prdLabelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_PRD}, PRV_CLM_PRD_RES, null));
            prdLabelsTable.sort();
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return prdLabelsTable;
    }

    /**
    *  @Description: Get the Labels for the table of the object SOD_XD_ProductoDelCaso__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static SOD_XS_CentroDeCosto__c getCostCenterById(String paramId) {
        SOD_XS_CentroDeCosto__c cc = [SELECT Id, Name, SOD_XS_CentroDeCosto__c
                                        FROM SOD_XS_CentroDeCosto__c 
                                        WHERE Id = :paramId
                                        LIMIT 1];
        return cc;
    }

    /**
    *  @Description: For Keep It Campaign: Return whether the Purchase' Sales Channel is excempted from Keep It or not. 
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */    
    @AuraEnabled
    public static Boolean isKeepItCanalDeVentaException(String canalDeVenta) {
        String canalDeVentasExceptions = System.Label.SOD_XS_V360CASE_CasoKeepItCanalDeVentasExceptions;
        List<String> listCanalDeVentasExceptions = SOD_XS_EnUtility.getListFromString(canalDeVentasExceptions, ',');
        return listCanalDeVentasExceptions.contains(canalDeVenta);
    }

    /**
    *  @Description: Process the data returned from webservice call for F.com integration and store in Salesforce
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */
    public static void processCaseDataFcom(Account acc, Case cas, Object objData, List<String> productCodes){
        try {
            String jsonData = JSON.serialize(objData, true);
            SOD_XS_360ViewPurchasesExtension extObject = new SOD_XS_360ViewPurchasesExtension(jsonData, acc, cas);
            extObject.storeSellDocumentData();
            // For purchases of type PRC
            if(extObject.strObjectType == SOD_XS_MAPJSON360ViewOrders.PRV_OBJ_PRC) {
                extObject.storeAsocDocumentData();
                extObject.storeReserveData();
                cas.SOD_XS_AuxCompletitudDatosDelCaso__c = 'Total';
                update cas;
            }
            extObject.storeProductsFcomData(productCodes);
            extObject.storeCaseFcomData();
        } catch (Exception ex){
            System.debug('DEBUG: ' + ex.getStackTraceString());
            String exMsg = (ex.getMessage().length() > 200) ? ex.getMessage().left(200) : ex.getMessage();
            cas.SOD_XS_ErrorIntegracion__c = exMsg;
            update cas;
        }
    }

    /**
    *  @Description: Wrapper used for F.com integration to search for a purchase order in the web service
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        24/06/2021
    */
    public static Object getPurchaseDataObjectFcom(Case cas, WrapSearchCriteria intPath){
        Object objPurchase;
        try {
            SOD_XS_MAPJSON360ViewClient objClass;
            objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360View(intPath), SOD_XS_JSON360ViewClient.class), intPath.client);
            // Purchase Data
            objPurchase = objClass.getPurchaseObject();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            System.debug('Service Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            if(e.code == 404){
                cas.SOD_XS_ErrorIntegracion__c = PRV_MSG_NOTFOUND;
            } else {
                cas.SOD_XS_ErrorIntegracion__c = PRV_MSG_ERROR;
            }
            update cas;
        } catch(Exception e) {
            System.debug('Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
            cas.SOD_XS_ErrorIntegracion__c = e.getMessage();
            update cas;
        }
        return objPurchase;
    }

    /**
    *  @Description: Process the data collected from the component and store in Salesforce
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */
    @AuraEnabled
    public static String processCaseData(String jsonData) {
        SOD_XS_360ViewPurchasesExtension extObject = new SOD_XS_360ViewPurchasesExtension(jsonData);
        try {
            extObject.storeSellDocumentData();
            // for purchases of type PRC
            if(extObject.strObjectType == SOD_XS_MAPJSON360ViewOrders.PRV_OBJ_PRC) {
                extObject.storeAsocDocumentData();
            }
            extObject.storeCaseData();
            // for purchases of type PRC
            if(extObject.strObjectType == SOD_XS_MAPJSON360ViewOrders.PRV_OBJ_PRC) {
                extObject.storeReserveData();
            }
            extObject.storeProductsData();
            
        }
        catch(DmlException e) {
            generateAuraException(e, extObject.accObject.Id);
        }
        catch (Exception e) {
            generateAuraException(e, extObject.accObject.Id);
        }
        // retornamos el id del registro creado
        return extObject.caseObject.Id;
    }

    /**
    *  @Description: Gets the exception from the service to display it to the user
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    private static SOD_XS_360ViewPurchasesController getServiceException(SOD_XS_360ViewPurchasesController obj, Exception e, String logIdentifier){
        obj.isError = true;
        obj.errorService = new UserMessage(e.getMessage(), e.getLineNumber());
        obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage());
        return obj;
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

    /**
    *  @Description: Process the data collected from the component and store in Salesforce
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */    
    private static void generateAuraException(Exception e) {
        generateAuraException(e, null);
    }
    private static void generateAuraException(Exception e, Id accountId) {
        String logIdentifier = SOD_XS_EnLogger.logError(e, accountId);
        String errorMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage());
        if (e.getTypeName() == 'System.DmlException') {
            errorMessage = e.getDmlMessage(0) + ' (' + e.getDmlType(0) + ')';
        }
        SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_V360CASE_MensajeErrorTitulo, 
                                                                            errorMessage,  
                                                                            e.getLineNumber());
        throw new AuraHandledException (JSON.serialize(data));
        /*
        system.debug('Message: ' + e.getMessage() + 
        ' Type: ' + e.getTypeName() + 
        ' Cause: ' + e.getCause() + 
        ' Line Number: ' + e.getLineNumber() +
        ' StackTrace: ' + e.getStackTraceString()); 

        String errorMessage = Label.SOD_XS_V360CASE_MensajeError;
        if (e.getTypeName() == 'System.DmlException') {
            errorMessage = e.getDmlMessage(0) + ' (' + e.getDmlType(0) + ')';
        }

        SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_V360CASE_MensajeErrorTitulo, 
                                                                            errorMessage,  
                                                                            e.getLineNumber());
        throw new AuraHandledException (JSON.serialize(data));*/
    }

    /**
	*  @Description: Web service that get the 360 view of a customer
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        02/10/2020
	*/
    public static String webService360View(WrapSearchCriteria intPath) {
        String endpoint;
        Map<String, String> pathParam = new Map<String, String>();
        Map<String, String> mapHeader = new Map<String, String>();
        Map<String, String> mapQuery = new Map<String, String>();
        mapHeader.put('X-country', intPath.client.SOD_XS_Country__r.SOD_XS_Codigo__c);
        String fields= 'purchaseOrders,paymentVouchers';
        if (intPath.is360View) {// Set the variables for a search by date range or the last ten orders
            endpoint = PRV_WS_360VIEW;
            pathParam.put('identificationCountry', intPath.client.SOD_XS_Country__r.SOD_XS_Codigo__c);
            pathParam.put('identificationType', getDocTypeMap().get(intPath.client.SOD_XS_TipoDocumento__c));
            pathParam.put('value', intPath.client.SOD_XS_NroDocumento__c);
            pathParam.put('360View', intPath.path360View);
            mapQuery.put('pageNumber', String.valueOf(intPath.pageNumber));
            mapQuery.put('pageSize', String.valueOf(intPath.pageSize));
            if (intPath.isDateRange) {// Set the variables for a search by date range
                String dt = '{"dateFrom":"' + intPath.purchaseDateFilter.dateFrom + '","dateTo":"'+ intPath.purchaseDateFilter.dateTo + '"}';
                mapQuery.put('purchaseDateFilter', dt);
            }
        } else if (intPath.isSalesDocument) {// Set the variables for a search by sales document
            endpoint = PRV_WS_ORD;
            mapQuery.put('salesDocumentFilter', JSON.serialize(intPath.salesDocumentFilter, true));
        } else if (intPath.isPurchaseOrders) { // Set the variables for a search by order number
            endpoint = PRV_WS_ORD;
            mapQuery.put('purchaseOrderNumber', intPath.orderNumber);
            fields = 'purchaseOrders';
        } else if (intPath.isReserve) { // Set the variables for a search by reserve number
            endpoint = PRV_WS_ORD;
            mapQuery.put('reserveNumber', intPath.reserveNumber);
            fields = 'purchaseOrders';
        }
        mapQuery.put('fields', fields);
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put('header', mapHeader);
        setConf.put('path', pathParam);
        setConf.put('query', mapQuery);
        SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(intPath.client.SOD_XS_Country__r.SOD_XS_Codigo__c, endpoint);
        return jwt.callService(setConf,'').getBody();
    }

    /**
    *  @Description: Service exception, wrapper class used to set a service exception
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        02/10/2020
    */    
    public class UserMessage {
        @AuraEnabled public Integer code;
        @AuraEnabled public String internalMessage;
        @AuraEnabled public String showMessage;
        public UserMessage(String internalMessage, Integer code) {
            this.internalMessage = internalMessage;
            this.code = code;            
        }
    }
}