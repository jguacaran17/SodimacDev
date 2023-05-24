/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 16/12/2020
Description  : APEX Controller - Search Products Events
History      : CMRSC-3932
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade Alviárez    EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA            16/12/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_360ViewProductController {

    @AuraEnabled public String dataJson {get;set;}
    @AuraEnabled public List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> prdLabelsTable {get;set;}

    private static final String PRV_WS_PRD;
    private static final String PRV_LBL_PRD;

    static{
        PRV_WS_PRD = Label.SOD_XS_V360PRDProductoCompra;
        PRV_LBL_PRD = Label.SOD_XS_V360PRDHistorialComprasSKU;
    }

    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        18/12/2020
    */
    @AuraEnabled
    public static SOD_XS_360ViewProductController initClass(String reserveNumber, String sku, String countryCode) {
        SOD_XS_360ViewProductController obj = new SOD_XS_360ViewProductController();
        obj.dataJson = webServiceEventSKU(reserveNumber, sku, countryCode);
        obj.prdLabelsTable = SOD_XS_DataTableUtily.setLabelDescriptionFromLabel(PRV_LBL_PRD);
        return obj;
    }

    /**
	*  @Description: Web service that get the event SKU reserve
	*  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
	*  @Date:        18/12/2020
	*/
    public static String webServiceEventSKU(String reserveNumber, String sku, String countryCode) {
        String endpoint;
        String str;
        
        try {
            Map<String, String> pathParam = new Map<String, String>();
            Map<String, String> mapHeader = new Map<String, String>();
            Map<String, String> mapQuery = new Map<String, String>();
            mapHeader.put('X-country', countryCode);
            pathParam.put('reserveNumber',reserveNumber);
            pathParam.put('sku-reserves', 'sku-reserves');
            pathParam.put('sku', sku);
            pathParam.put('events', 'events');
            endpoint = PRV_WS_PRD;
            Map<String, Map<String, String>> setConf = new Map<String, Map<String, String>>();
            setConf.put('header', mapHeader);
            setConf.put('path', pathParam);
            setConf.put('query', mapQuery);
            SOD_XS_JWTRestConnection jwt = new SOD_XS_JWTRestConnection(countryCode, endpoint);
            str = jwt.callService(setConf,'').getBody();
        } catch (SOD_XS_JWTRestConnection.ServiceException e) {
            String logIdentifier = SOD_XS_EnLogger.logError(e, null);
            throwAuraException(e, logIdentifier);
            /*
            system.debug('Message: ' + e.getMessage() + ' Type: ' + e.getTypeName() + ' Cause: ' + e.getCause() + ' Line Number: ' + e.getLineNumber());
            SOD_XS_CustomExceptionData data = new SOD_XS_CustomExceptionData(Label.SOD_XS_TituloBUCYSFCD, e.getMessage(), e.code);
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
    *  @Description: Throw Aura Handled Exception 
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    private static void throwAuraException(Exception e, String logIdentifier){
        throw new AuraHandledException (SOD_XS_EnLogger.getErrorMsg(logIdentifier, e.getMessage()));
    }
}