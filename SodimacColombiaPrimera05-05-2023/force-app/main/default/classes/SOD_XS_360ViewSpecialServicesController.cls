/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 18/03/2021
Description  : APEX Controller - Search Purcharses of Special Services
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            18/03/2021      initial version
********************************************************************************/
public with sharing class SOD_XS_360ViewSpecialServicesController extends SOD_XS_360ViewPurchasesUtility{

    @AuraEnabled public SearchSpecialServices searchCriteria {get;set;}
    @AuraEnabled public SOD_XS_DataTableUtily.StaticActionsDescriptionWrapper detailActions {get;set;}

    /**
    *  @Description: Declaration of static variables
    *  @Author:      ATO
    *  @Date:        18/03/2021
    */
    private static final String PRV_WS_360VIEW;
    private static final String PRV_WS_ORD;
    private static final String PRV_OBJ_DOCV;
    private static final String PRV_OBJ_DOCA;
    private static final String PRV_OBJ_SUBP;
    private static final String PRV_OBJ_PRD;
    private static final String PRV_OBJ_CASE;
    private static final String PVR_SFDC_CASE_CON;
    private static final String PVR_SFDC_CASE_FEL;
    private static final String PVR_SFDC_CASE_REC;
    private static final String PVR_SFDC_CASE_SOL;
    private static final String PRV_STR_PCK;
    private static final String PRV_CLM_DOCA;
    private static final String PRV_CLM_DOCV;
    private static final String PRV_CLM_SUBP;
    private static final String PRV_CLM_PRD_SUBP;
    private static final String PRV_CLM_PRD_PMT;
    private static final String PRV_CLM_PRD_RES;
    private static final String PRV_VRB_DOCV;
    private static final String PRV_VRB_DOCA;
    private static final String PRV_VRB_SUBP;
    private static final String PRV_MSG_NOTFOUND;
    private static final String PRV_MSG_ERROR;
	private static final String PRV_CLM_STORE;
    private static final String PRV_OBJ_STORE;
    private static final String PRV_VRB_STORE;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        18/03/2021
    */
    static {
        PRV_WS_360VIEW = Label.SOD_XS_HistorialCompra;
        PRV_WS_ORD = Label.SOD_XS_OrdenCompra;
        PRV_OBJ_SUBP = Schema.SObjectType.SOD_XS_SubproyectoDelCaso__c.getName();
        PRV_OBJ_PRD = Schema.SObjectType.SOD_XS_ProductoDelCaso__c.getName();
        PRV_OBJ_DOCV = Schema.SObjectType.SOD_XS_DocumentoDeVenta__c.getName();
        PRV_OBJ_DOCA = Schema.SObjectType.SOD_XS_DocumentoAsociado__c.getName();
        PRV_OBJ_STORE = Schema.SObjectType.SOD_XS_CentroDeCosto__c.getName();
        PRV_OBJ_CASE = Schema.SObjectType.Case.getName();
        PVR_SFDC_CASE_CON = 'SOD_XS_Consulta';
        PVR_SFDC_CASE_FEL = 'SOD_XS_Felicitacion';
        PVR_SFDC_CASE_REC = 'SOD_XS_Reclamo';
        PVR_SFDC_CASE_SOL = 'SOD_XS_Solicitud';
        PRV_STR_PCK = 'Documento de Venta';
        /* Main table columns */
        PRV_CLM_DOCA = 'Name:3;SOD_XS_MontoProyecto__c:9';
        PRV_CLM_DOCV = 'SOD_XS_FechaDeCompra__c:1;SOD_XS_TipoDeDdocumento__c:7;Name:8';
        PRV_CLM_SUBP = 'SOD_XS_TipoCanasto__c:2;Name:4;SOD_XS_Servicio__c:5;SOD_XS_Estado__c:6;SOD_XS_FechaOrden__c:10;SOD_XS_FechaTrabajo__c:11';
        PRV_CLM_STORE = 'Name:12';
        /* End main table columns */
        PRV_CLM_PRD_SUBP = 'SOD_XS_CantidadAfectada__c:1;SOD_XS_CodigoProducto__c:2;SOD_XS_DescripcionDelProducto__c:3;SOD_XS_Cantidad__c:4;SOD_XS_PrecioUnitario__c:5;SOD_XS_ImporteTotal__c:6;SOD_XS_Pagado__c:7';
        PRV_CLM_PRD_RES = 'SOD_XS_CantidadAfectada__c:1;SOD_XS_CodigoProducto__c:2;SOD_XS_DescripcionDelProducto__c:3;SOD_XS_Cantidad__c:4;SOD_XS_PrecioUnitario__c:5;SOD_XS_ImporteTotal__c:6;SOD_XS_Pagado__c:7';
        PRV_CLM_PRD_PMT = 'SOD_XS_CantidadAfectada__c:1;SOD_XS_CodigoProducto__c:2;SOD_XS_DescripcionDelProducto__c:3;SOD_XS_Cantidad__c:4;SOD_XS_PrecioUnitario__c:5;SOD_XS_Descuento__c:6;SOD_XS_ImporteTotal__c:7';
        PRV_VRB_DOCV = 'objDocV';
        PRV_VRB_DOCA = 'objDocA';
        PRV_VRB_SUBP = 'objSubP';
        PRV_VRB_STORE = 'objShopThatSell';
        PRV_MSG_NOTFOUND = Label.SOD_XS_V360OCNoSeEncontraronResultados;
        PRV_MSG_ERROR = Label.SOD_XS_V360OCErrorIntegracion;        
    }

    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static SOD_XS_360ViewSpecialServicesController initClass(Id rcdId) {
        
        SOD_XS_360ViewSpecialServicesController obj = new SOD_XS_360ViewSpecialServicesController();
        Account acc = getRecord(rcdId);
        obj.isError = false;
        // Loading search criteria
        obj.searchCriteria = new SearchSpecialServices(acc);
        obj.searchCriteria.purchaseDateFilter = new PurchaseDateFilterSpcSrv();
        obj.searchCriteria.purchaseDateFilter.Identification = new Identification(acc);
        // Loading table columns orders
        obj.labelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_DOCV}, PRV_CLM_DOCV, PRV_VRB_DOCV));
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_DOCA}, PRV_CLM_DOCA, PRV_VRB_DOCA));
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_STORE}, PRV_CLM_STORE, PRV_VRB_STORE));
        obj.labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_SUBP}, PRV_CLM_SUBP, PRV_VRB_SUBP));
        obj.labelsTable.sort();
        // Loading detail button of Special Services
        obj.detailActions = setDetailActions();
        try {
            // Consuming web service
            SOD_XS_MAPJSON360ViewClient objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360ViewSpecialServices(obj.searchCriteria), SOD_XS_JSON360ViewClient.class), acc);
            // Purchase Data
            obj.mapPurchases = objClass.mapPurchases; 
            obj.dataTable = objClass.getPurchasesDataTable();
            obj.searchCriteria.totalElements = obj.dataTable.size();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, rcdId);
            obj = getServiceException(obj, e, logIdentifier);
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, rcdId);
            obj = getException(obj, e, logIdentifier);
        }
        return obj;
    }

    /**
    *  @Description: Wrapper used to search for a special service in the web service
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        23/03/2021
    */
    @AuraEnabled
    public static Object getPurchaseDataObject(SearchSpecialServices intPath) {
        Object objPurchase;
        try {
            SOD_XS_MAPJSON360ViewClient objClass;
            objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360ViewSpecialServices(intPath), SOD_XS_JSON360ViewClient.class), intPath.client);
            // Purchase Data
            objPurchase = objClass.getPurchaseObject();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            throwAuraException(e, logIdentifier);
        } catch(Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            throwAuraException(e, logIdentifier);
        }
        return objPurchase;
    }

    /**
    *  @Description: Wrapper used to search for Special Services in the web service
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        23/03/2021
    */
    @AuraEnabled
    public static SOD_XS_360ViewSpecialServicesController getPageData(SearchSpecialServices intPath) {
        SOD_XS_360ViewSpecialServicesController obj = new SOD_XS_360ViewSpecialServicesController();
        obj.isError = false;
        try {
            SOD_XS_MAPJSON360ViewClient objClass = new SOD_XS_MAPJSON360ViewClient((SOD_XS_JSON360ViewClient)JSON.deserialize(webService360ViewSpecialServices(intPath), SOD_XS_JSON360ViewClient.class), intPath.client);
            // Purchase Data  
            obj.mapPurchases = objClass.mapPurchases; 
            obj.dataTable = objClass.getPurchasesDataTable();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            obj = getServiceException(obj, e, logIdentifier);
        } catch (Exception e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, intPath.client.Id);
            obj = getException(obj, e, logIdentifier);
        }
        return obj;
    }

    /**
    *  @Description: Method used to set detail button of Special Services in data table
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/10/2021
    */
    public static SOD_XS_DataTableUtily.StaticActionsDescriptionWrapper setDetailActions () {
        SOD_XS_DataTableUtily.StaticActionsDescriptionWrapper btt = new SOD_XS_DataTableUtily.StaticActionsDescriptionWrapper();
        btt.order = 0; 
        btt.typeAttributes = new SOD_XS_DataTableUtily.ActionsTypeAttributesWrapper();
        btt.typeAttributes.rowActions = new List<SOD_XS_DataTableUtily.ActionsWrapper>();
        SOD_XS_DataTableUtily.ActionsWrapper actions = new SOD_XS_DataTableUtily.ActionsWrapper();
        actions.label = 'Ver Proyecto';
        actions.name = 'view_projectDetail';
        actions.iconName = 'utility:zoomin';
        SOD_XS_DataTableUtily.ActionsWrapper actionsTwo = new SOD_XS_DataTableUtily.ActionsWrapper();
        actionsTwo.label = 'Ver SubProyecto';
        actionsTwo.name = 'view_subProjectDetail';
        actionsTwo.iconName = 'utility:zoomin';
        btt.typeAttributes.rowActions.add(actions);
        btt.typeAttributes.rowActions.add(actionsTwo);
        return btt;
    }

    /**
    *  @Description: Get the Description of object SOD_XS_SubproyectoDelCaso__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static String getDescriptionForSubProject() {
        String accLabels;
        try {
            accLabels = SOD_XS_EnUtility.getDescribedObjects( new List<String>{PRV_OBJ_SUBP} );
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return accLabels;
    }

    /**
    *  @Description: Get the Labels for the table of the object SOD_XD_ProductoDelCaso__c for SubProjects
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> getColumnsForProductsSubProject() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> prdLabelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        try {
            prdLabelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{PRV_OBJ_PRD}, PRV_CLM_PRD_SUBP, null));
            prdLabelsTable.sort();
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return prdLabelsTable;
    }

    /**
    *  @Description: Get the Description of object SOD_XS_DocumentoAsociado__c
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static String getDescriptionForAsocDocument() {
        String accLabels;
        try {
            accLabels = SOD_XS_EnUtility.getDescribedObjects( new List<String>{PRV_OBJ_DOCA} );
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        return accLabels;
    }

    /**
    *  @Description: Get the Labels for the table of the object SOD_XD_ProductoDelCaso__c for Payment Vouchers
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
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
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static String getDescriptionForCaseCreation() {
        String strObjectDesc;
        try {
            List<String> lstObjects = new List<String>();
            lstObjects.add(PRV_OBJ_DOCV);
            lstObjects.add(PRV_OBJ_DOCA);
            lstObjects.add(PRV_OBJ_SUBP);
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
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static Map<String, String> getDescriptionObjectsForCase() {
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();        
        Map<String, String> result = new Map<String,String>();
        List<String> listObjects = new List<String>();
        try {
            listObjects.add(PRV_OBJ_DOCV);
            listObjects.add(PRV_OBJ_DOCA);
            listObjects.add(PRV_OBJ_SUBP);
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
    *  @Description: Process the data collected from the component and store in Salesforce
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */
    @AuraEnabled
    public static String processCaseData(String jsonData) {
        
        SOD_XS_360ViewPurchasesExtension extObject = new SOD_XS_360ViewPurchasesExtension(jsonData);
        try {

            extObject.storeSellDocumentData();
            extObject.storeAsocDocumentData();
            extObject.storeCaseData();

            if( extObject.strObjectType == 'SSP_SUBP' ){
                extObject.storeSubProjectData(); 
                extObject.storeSubProjectProductsData();
            }
        }
        catch(DmlException e) {
            generateAuraException(e);
        }
        catch (Exception e) {
            generateAuraException(e);
        }
        // retornamos el id del registro creado
        return extObject.caseObject.Id;
    }

    /**
    *  @Description: Get the record types for case object for Special Services
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    @AuraEnabled
    public static Map<Id, String> getCaseRecordType(){
        Map<Id, String> resRecordTypes = new Map<Id, String>();
        try {
            List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();    
            for(RecordTypeInfo rt : recordtypes){
                if(rt.getDeveloperName() == PVR_SFDC_CASE_CON || 
                    rt.getDeveloperName() == PVR_SFDC_CASE_FEL || 
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
    *  @Date:        18/03/2021
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
    *  @Description: Process the data collected from the component and store in Salesforce
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    private static void generateAuraException(Exception e) {
        SOD_XS_EnLogger.logError(e, null);
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
	*  @Date:        18/03/2021
	*/
    public static String webService360ViewSpecialServices(SearchSpecialServices intPath) {
        String endpoint;
        Map<String, String> pathParam = new Map<String, String>();
        Map<String, String> mapHeader = new Map<String, String>();
        Map<String, String> mapQuery = new Map<String, String>();
        mapHeader.put('X-country', intPath.client.SOD_XS_Country__r.SOD_XS_Codigo__c);
        mapQuery.put('fields', 'specialServices');
        endpoint = PRV_WS_ORD;        
        if (intPath.isDateRange) {// Set the variables for a search by Date Range
            mapQuery.put('purchaseDateFilter', JSON.serialize(intPath.purchaseDateFilter, true));
        } else if (intPath.isSalesDocument) {// Set the variables for a search by Sales Document
            mapQuery.put('salesDocumentFilter', JSON.serialize(intPath.salesDocumentFilter, true));
        } else if (intPath.isProject) {// Set the variables for a search by Purchase Order Number
            mapQuery.put('purchaseOrderNumber', intPath.projectNumber);
        } else if (intPath.isSubProject) {// Set the variables for a search by Sub Project Number
            mapQuery.put('subProjectNumber', intPath.subProjectNumber);
        }
        Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
        setConf.put('header', mapHeader);
        setConf.put('path', pathParam);
        setConf.put('query', mapQuery);
        SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(intPath.client.SOD_XS_Country__r.SOD_XS_Codigo__c, endpoint);
        String rsp = jwt.callService(setConf,'').getBody();
        return rsp;
    }

    /**
	*  @Description: Gets the exception from the service to display it to the user
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        24/03/2021
	*/
    public static SOD_XS_360ViewSpecialServicesController getServiceException(SOD_XS_360ViewSpecialServicesController obj, SOD_XS_JWTRestConnection.ServiceException e, String logIdentifier) {
        obj.isError = true;
        obj.errorService = new UserMessage(e.getMessage(), e.code);
        obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage());
        /*
        system.debug('Service Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
        obj.isError = true;
        obj.errorService = new UserMessage(e.getMessage(), e.code);
        obj.errorService.showMessage = e.code == 404 
                                        ? PRV_MSG_NOTFOUND 
                                        : PRV_MSG_ERROR;*/
        return obj;
    }

    /**
	*  @Description: Gets the exception to show it to the user
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        24/03/2021
	*/
    public static SOD_XS_360ViewSpecialServicesController getException(SOD_XS_360ViewSpecialServicesController obj, Exception e, String logIdentifier) {
        obj.isError = true;
        obj.errorService = new UserMessage(e.getMessage(), e.getLineNumber());
        obj.errorService.showMessage = SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage());
        /*
        system.debug('Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
        obj.isError = true;
        obj.errorService = new UserMessage(e.getMessage(), e.getLineNumber());
        obj.errorService.showMessage = e.getMessage();*/
        return obj;
    }

    
    /**
	*  @Description: Get throw Service Exception
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        24/03/2021
	*/
    public static void throwAuraException(SOD_XS_JWTRestConnection.ServiceException e, String logIdentifier) {
        throw new AuraHandledException (SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()));
        /*
        system.debug('Service Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
        throw new AuraHandledException (e.code == 404 
                                        ? PRV_MSG_NOTFOUND 
                                        : PRV_MSG_ERROR);*/
    }

    /**
	*  @Description: Get throw Exception
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        24/03/2021
	*/
    public static void throwAuraException(Exception e, String logIdentifier) {
        throw new AuraHandledException (SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()));
        /*
        system.debug('Exception: ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
        throw new AuraHandledException (e.getMessage());*/
    }

}