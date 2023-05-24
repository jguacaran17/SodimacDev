/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 08/02/2021
Description  : SOD_XS_CaseApiRestService Class - Custom API REST Service to manage cases
History      : CMRSC-5107
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      Deloitte
Lazaro Quintana 			LQS (lquintanas@deloitte.com)
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LQS			08/02/2021		initial version
********************************************************************************/
@RestResource(urlMapping='/caseUpdateService/*') 
global with sharing class SOD_XS_CaseApiRestService {    

    private final static Integer LIMIT_CASES_RETRIEVED = 1000; // Force max returning records - to be evaluated
        
    /*********************************************************************************************************************
	 * @description Method GET SearchCasesByFilter search cases based on request filter 
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 08/02/2021
     * @return  return JSON response with list of cases, error message, total records     * 
	 *********************************************************************************************************************/
    @HttpGet
    global static ReturnClass SearchCasesByFilter(){
        
        String resultMessage = ''; // message associated to the response
        RestRequest request = RestContext.request;
        
        // get filter values from parameters
        String caseNumber = request.params.get('caseNumber');
        String caseId = request.params.get('id');
        String caseRecordTypeId = request.params.get('recordTypeId');
        String caseStatus = request.params.get('status');
        String caseFechaCompraDesde = request.params.get('fechaCompraDesde');
        String caseFechaCompraHasta = request.params.get('fechaCompraHasta');
        String caseFechaCreacionDesde = request.params.get('fechaCreacionDesde');
        String caseFechaCreacionHasta = request.params.get('fechaCreacionHasta');
        String pais = request.params.get('pais');
        
        // security section - remove spaces and single quotes using method CheckValidateInput
        caseNumber = CheckValidateInput(caseNumber);
        caseId = CheckValidateInput(caseId);
        caseRecordTypeId = CheckValidateInput(caseRecordTypeId);
        caseStatus = CheckValidateInput(caseStatus);
        caseFechaCompraDesde = CheckValidateInput(caseFechaCompraDesde);
        caseFechaCompraHasta = CheckValidateInput(caseFechaCompraHasta);
        caseFechaCreacionDesde = CheckValidateInput(caseFechaCreacionDesde);
        caseFechaCreacionHasta = CheckValidateInput(caseFechaCreacionHasta);     
        pais = CheckValidateInput(pais);              
        
        // query builder
        String whereClause = '';        
        if (caseRecordTypeId != '' && caseRecordTypeId != null){ whereClause = ' RecordTypeId = \'' + caseRecordTypeId+'\''; }
        if (caseRecordTypeId != '' && caseRecordTypeId != null && caseStatus!='' && caseStatus!= null){ whereClause = whereClause + ' AND Status = \'' + caseStatus +'\''; }
        if (caseFechaCompraDesde!=null && caseFechaCompraHasta!=null && caseFechaCompraDesde!='' && caseFechaCompraHasta!='' && caseRecordTypeId != '' && caseRecordTypeId != null){
            whereClause = whereClause + ' AND (SOD_XS_FechaDeCompra__c >= ' + caseFechaCompraDesde + ' AND SOD_XS_FechaDeCompra__c <= ' + caseFechaCompraHasta + ' )';
        }        
        if (caseFechaCreacionDesde!=null && caseFechaCreacionHasta!=null && caseFechaCreacionDesde!='' && caseFechaCreacionHasta!='' && caseRecordTypeId != '' && caseRecordTypeId != null){
            whereClause = whereClause + ' AND (CreatedDate >= ' + caseFechaCreacionDesde + 'T00:00:00Z'+' AND CreatedDate <= ' + caseFechaCreacionHasta + 'T23:00:00Z'+') ';
        }
        if (pais != '' && pais != null){ whereClause = whereClause + ' AND ( Account.SOD_XS_Country__r.SOD_XS_Codigo__c = \'' + pais+'\' OR SOD_XS_CentroCostoResponsable__r.SOD_XS_Country__r.SOD_XS_Codigo__c = \'' + pais+'\')'; } 
        if (caseNumber != '' && caseNumber != null){ whereClause = ' CaseNumber = \'' + caseNumber+'\''; }        
        if (caseId != '' && caseId != null){ whereClause = ' Id = \'' + caseId+'\''; }        
            
       
        // if whereclause is blank  make a default search 
        if (whereClause=='' || whereClause == null){
            DateTime todayDateTime = DateTime.now();
			String today = todayDateTime.format('yyyy-MM-dd');
            whereClause = ' CreatedDate >= ' + today + 'T00:00:00Z'+' AND CreatedDate <= ' + today + 'T23:00:00Z';
        }
        
        // final query
        String caseQuery = ' SELECT Id,'+
                                    'CaseNumber,'+
                                    'CreatedDate,'+
                                    'Status,'+
                                    'Origin,'+
                                    'OwnerId,'+
                                    'Owner.Name,'+
                                    'CreatedById,'+
                                    'CreatedBy.Name,'+
                                    'Description,'+
                                    'SOD_XS_CentroCostoResponsable__c,'+
                                    'SOD_XS_CentroCostoResponsable__r.id,'+
                                    'SOD_XS_CentroCostoResponsable__r.Name,'+
                                    'SOD_XS_CentroCostoResponsable__r.SOD_XS_CentroDeCosto__c,'+
                                    'SOD_XS_TiendaVende__c,'+
                                    'SOD_XS_TiendaVende__r.id,'+
                                    'SOD_XS_TiendaVende__r.Name,'+
                                    'SOD_XS_TiendaVende__r.SOD_XS_CentroDeCosto__c,'+
                                    'SOD_XS_Area__c,'+
                                    'SOD_XS_Motivo__c,'+
                                    'SOD_XS_Submotivo__c,'+
                                    'SOD_XS_PaisDeLaCuenta__c,'+
                                    'SOD_XS_FechaDeCompra__c,'+
                                    'SOD_XS_FechaDeCompraHasta__c,'+
                                    'SOD_XS_Asesor__c, '+
                                    'RecordTypeId,'+
                                    'RecordType.Name,'+
                                    'AccountId,'+
                                    'Account.SOD_XS_TipoDocumento__c,'+
                                    'Account.SOD_XS_NroDocumento__c,'+
                                    'Account.Name,'+
                                    'Account.LastName,'+
                                    'Account.SOD_XS_ContactoNotienecorreo__pc,'+
                                    'Account.PersonEmail'+
                            ' FROM Case '+  
                            ' WHERE ' + whereClause +
                            ' LIMIT ' + LIMIT_CASES_RETRIEVED;
        try {
            // Strip fields that are not readable
            List<Case> returnedCases = database.query(caseQuery);            
            Integer numberOfCases = returnedCases.size();
            resultMessage = numberOfCases > 0 ? 'Búsqueda ejecutada con éxito.' : 'No se encontraron registros, revise los parámetros de búsqueda.';
            return new ReturnClass('true', resultMessage, returnedCases, numberOfCases);
        } catch (Exception e) {
            resultMessage = e.getMessage();
            return new ReturnClass('false',resultMessage,null,0);
        }
    }


	/*********************************************************************************************************************
	 * @description Method updateCaseFields to update the case status based on body request
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 10/02/2021
     * @return  return JSON .
	 *********************************************************************************************************************/
    @HttpPatch
    global static ReturnClassCase updateCaseFields() {
        RestResponse response = RestContext.response; // response to define the status code
        String resultMessage = '';
        String caseUpdateResultMessage = ''; // message associated to the case update result
        String commentCreationResultMessage = ''; // message associated to the comment creation
        String fileCreationResultMessage = ''; // message associated to the file creation result
        
        // get the case Id 
        RestRequest request = RestContext.request;
        String caseId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);        
        String caseComment = ''; // save the value of the requested case comment
        String caseFileBase64 = ''; // save the value of the base64 file string
                
        try {
                // search for the case with this ID
                caseId = CheckValidateInput(caseId);
            	Case thisCase = [SELECT Id,Status FROM Case WHERE Id = :caseId];        // generate QueryException if caseId is invalid
            	String previousStatus = thisCase.Status!= null ? thisCase.Status : ''; // save the previous state of the case
               
                //CA4: Si no viene el Comentario o el Doc se cierra el caso
                Boolean shouldUpdate = false;
                Boolean hasComment = false;
                Boolean hasFile = false;
   
                // Deserialize the JSON string into name-value pairs
                Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());

                // Iterate through each parameter field and value
                for(String fieldName : params.keySet()) {
                    // update status field in case object ONLY if the new status is different 
                    //CA4: Si no viene el Comentario o el Doc se cierra el caso
                    
                    //if (fieldName == 'status' && previousStatus!=(String)params.get(fieldName)){ 
                    //    thisCase.put('status', params.get(fieldName));
                    //    shouldUpdate = true;
                    //}
                    
                    // get and save the comment value
                    if (fieldName == 'caseComment'){ 
                        caseComment = (String) params.get(fieldName);
                        resultMessage = (String) params.get(fieldName);
                        if(caseComment != '' && caseComment != null && caseComment != 'null'){
                            hasComment = true;
                        }
                        

                    }
                    
                    // get and save the base64 file value
                    if (fieldName == 'caseFile'){ 
                    	caseFileBase64 = (String)params.get(fieldName);
                        if (caseFileBase64!=null && caseFileBase64!='' && caseFileBase64!='null' ) {
                            hasFile = true;
                        }
                    }
                } // end loop

                if(hasComment && hasFile){
                    thisCase.put('status', 'Closed');
                    shouldUpdate = true;
                }
            
            	// only update case if we have a new different status for the case
            	if (shouldUpdate && hasComment && hasFile){
                    // security requeriment check if the field STATUS is updateable 
                    if (!Schema.sObjectType.Case.fields.Status.isUpdateable()) {
            			caseUpdateResultMessage = 'no update permission';
                    } else {
                        if(thisCase.Status == 'Closed' || thisCase.Status == 'Cerrado'){
                            thisCase.SOD_XS_ActualizacionPorIntegracion__c = true;
                        }
                    	update thisCase;

                    	caseUpdateResultMessage = 'success';    
                    }
                } else if(!shouldUpdate){
                    caseUpdateResultMessage = 'no case updated, same status value';
                }else if(!hasComment){
                    caseUpdateResultMessage = 'no case updated, same comment value';
                }else if(!hasFile){
                    caseUpdateResultMessage = 'no case updated, same File value';
                }else{
                    caseUpdateResultMessage = 'no case updated';
                }
            
            	// comment object creation 
                if(caseComment != '' && caseComment != null && caseComment != 'null'){
                    CaseComment newComment = new CaseComment();
                    newComment.CommentBody = caseComment;
                    newComment.IsPublished = true;
                    newComment.ParentId = caseId;
                    try { 
                        insert newComment;    
                        commentCreationResultMessage = 'success';
                    } catch(Exception e) {
                        commentCreationResultMessage = e.getMessage();
                    }
                }else{
                    commentCreationResultMessage = 'comment is null or is empty';
                }
            
            	// file object creation
            	if (caseFileBase64!=null && caseFileBase64!='' && caseFileBase64!='null' ) {
                    // creating the contentVersion Object 
                    ContentVersion newFileVersion = new ContentVersion();
                    newFileVersion.Title = 'BOT Attached File - Case Id. '+ caseId; // evaluate if we will use this name.
                    newFileVersion.ContentLocation = 'S';
                    newFileVersion.PathOnClient = caseId + '.pdf'; // name of the file 
                    newFileVersion.VersionData = EncodingUtil.base64Decode(caseFileBase64);
                    // now try to insert the object 
                    try { 
                			insert newFileVersion;
                        	// now with the Id of the contentVersion create a contentLink to the case Id
                        	Id contentVersionDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newFileVersion.Id].ContentDocumentId;
                        	// now we create the File Document asociates to the file version 
                        	ContentDocumentLink newContentDocument = new ContentDocumentLink();
                        	newContentDocument.LinkedEntityId = caseId;
                        	newContentDocument.ContentDocumentId = contentVersionDocId;
                        	newContentDocument.shareType = 'V';
                        	insert newContentDocument;
                        	fileCreationResultMessage = 'success';
                		} catch(Exception e) {
                    		fileCreationResultMessage = e.getMessage();
                		}
                    
            	} // end of file object creation 
                if(shouldUpdate && hasComment && hasFile){
                    resultMessage = 'success'; // the whole transaccion message - no error 
                    List<Case> listCase = new List<Case>(); // to align with service contract
                    listCase.add(thisCase);
                    return new ReturnClassCase('true', resultMessage, caseUpdateResultMessage, commentCreationResultMessage, fileCreationResultMessage, listCase, 1); 
                }else{
                    response.statusCode = 404; // Get a null pointer exception on this line
                    resultMessage = 'not completed';
                    return new ReturnClassCase('false',resultMessage,caseUpdateResultMessage, commentCreationResultMessage, fileCreationResultMessage,null,0);
                }
            	
         } catch (QueryException  e) {
            response.statusCode = 404; // Get a null pointer exception on this line
            resultMessage = 'Invalid caseId parameter: ' + e.getMessage() + ' | Stacktrace: ' + e.getStackTraceString();
            caseUpdateResultMessage = 'error';
            commentCreationResultMessage = 'error';
            fileCreationResultMessage = 'error';
            return new ReturnClassCase('false',resultMessage,caseUpdateResultMessage, commentCreationResultMessage, fileCreationResultMessage,null,0);
        } catch (DmlException  e) {
            response.statusCode = 404; // Get a null pointer exception on this line
            resultMessage = 'DML operation error: ' + e.getMessage() + ' | Stacktrace: ' + e.getStackTraceString();
            caseUpdateResultMessage = 'error';
            commentCreationResultMessage = 'error';
            fileCreationResultMessage = 'error';
            return new ReturnClassCase('false',resultMessage,caseUpdateResultMessage, commentCreationResultMessage, fileCreationResultMessage,null,0);
        } catch (Exception e) {
            response.statusCode = 404; // Get a null pointer exception on this line
            resultMessage = e.getMessage() + ' | Stacktrace: ' + e.getStackTraceString() + ' | Code: ' + e.getLineNumber();
            caseUpdateResultMessage = 'error';
            commentCreationResultMessage = 'error';
            fileCreationResultMessage = 'error';
            return new ReturnClassCase('false',resultMessage,caseUpdateResultMessage, commentCreationResultMessage, fileCreationResultMessage,null,0);
        }
    }
    
    /*********************************************************************************************************************
	 * @description Method CheckValidateInput Utility remove blank space and single quotes from input data 
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 10/02/2021
     * @return  return String con el valor input validado.
	 *********************************************************************************************************************/
    @TestVisible private static String CheckValidateInput(String inputValue){
        String newInputValue = inputValue;
        if (newInputValue != null){
        	String newInputValueTemp = newInputValue.deleteWhitespace();
            // System.debug('Quitar los espacios = ' + newInputValueTemp);
        	newInputValue = String.escapeSingleQuotes(newInputValueTemp);
            return newInputValue;
        } 
        return newInputValue;
    }
    
    /************************************************************************************************************
	 * @description Class ReturnClassCase define json response when update a case 
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 08/02/2021
     * @return  return JSON response with case record, error message and total records
	 ************************************************************************************************************/
    @TestVisible global class ReturnClassCase {
        global String success; // define if response have no errors true/false 
        global String message; // message based on results
        global Integer totalSize; // number of records returned
        global List<Case> record; // Case record updated
        global String caseUpdateResultMessage;
        global String commentCreationResultMessage;
        global String fileCreationResultMessage;
        
        // constructor 
        global ReturnClassCase(String success, String message, String caseUpdateResultMessage, String commentCreationResultMessage, String fileCreationResultMessage, List<Case> recordList,Integer totalRecords) {
          this.success = success;
          this.message = message;
          this.totalSize = totalRecords;
          this.record = recordList;
          this.caseUpdateResultMessage = caseUpdateResultMessage;
          this.commentCreationResultMessage = commentCreationResultMessage;
          this.fileCreationResultMessage = fileCreationResultMessage;
        }
    }
    
    /************************************************************************************************************
	 * @description Class ReturnClass define json response for case search  
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 08/02/2021
     * @return  return JSON response with list of cases, error message and total records
	 ************************************************************************************************************/
    @TestVisible global class ReturnClass {
        global String success;
        global String message;
        global Integer totalSize;
        global List<Case> records;
        
        global ReturnClass(String success, String message, List<Case> records,Integer totalRecords) {
          this.success = success;
          this.message = message;
          this.totalSize = totalRecords;
          this.records = records;
        }
    }
    
    
    
    
}