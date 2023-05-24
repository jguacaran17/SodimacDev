/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 25/01/2020
Description  : Logger class to create a record in Custom Object to track down errors and other informations
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			25/01/2020		Created the file/class
********************************************************************************/

public with sharing class SOD_XS_EnLogger
{
    public  enum SEVERITY_TYPES {ERROR, CONFIRM, FATAL, INFO, WARNING}     // -- Types of log

    public  final static SOD_XS_EnLogger Instance; // -- Default instance of logger

    public  static final Id      DEFAULT_LOG_RECORDTYPE;
    private static final Integer MAX_LENGTH_DESCRIPTION, MAX_LENGTH_STACK_TRACE, MAX_LENGTH_COMMENT;
    private static final Boolean ENABLE_LOGS;
    public  static       Boolean ENABLE_EVENT;
    public  static       SEVERITY_TYPES DEFAULT_LOG_TYPE;
    private static       String  PRJCATEG_GDP, PRJCATEG_CRM, PRJCATEG_DEF, UserProfileName='';

    private List<sObject> lsLogs = new List<sObject>(); // -- Caching for DML
    private Boolean       isFutureBatch { get { return System.isFuture() || System.isBatch(); } }

    static
    {
        DEFAULT_LOG_TYPE = SEVERITY_TYPES.ERROR; // -- Default type of log
        ENABLE_LOGS      = true;  // -- Switch for all logs, can be associate with a custom setting
        ENABLE_EVENT     = false;  // -- When true, logs are push as event

        MAX_LENGTH_DESCRIPTION = 32768; // -- Max length of description
        MAX_LENGTH_STACK_TRACE = 32768; // -- Max length of stack trace
        MAX_LENGTH_COMMENT     = 1000;  // -- Max length of comment

        PRJCATEG_GDP = 'GDP';
        PRJCATEG_CRM = 'CRM';
        PRJCATEG_DEF = 'Default';

        Instance = new SOD_XS_EnLogger();
        DEFAULT_LOG_RECORDTYPE = SOD_XS_EnUtility.getAllRecordTypes(new Set<String>{'EN_Log__c'}).get('Application_Log').Id;
    }

    /**
    *  @Description: Add new log
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(Map<String, Object> keyValues){
        if(keyValues == null) return this;

        Type t = null;
        if(keyValues.containsKey('ClassObject') && keyValues.get('ClassObject') != null){
            t = (Type)keyValues.get('ClassObject');
            keyValues.put('ClassObject', null);
        }

        Exception e = null;
        if(keyValues.containsKey('ExceptionObj') && keyValues.get('ExceptionObj') != null){
            e = (Exception)keyValues.get('ExceptionObj');
            keyValues.put('ExceptionObj', null);
        }

        String jsonStr = JSON.serialize(keyValues);
        Log l = (Log)JSON.deserializeStrict(jsonStr, Log.class);

        //process object which that are not support in JSON
        if(t != null) l.ClassObject  = t;
        if(e != null) l.ExceptionObj = e;
        if(l.Severity == null) l.Severity = l.ExceptionObj == null ? DEFAULT_LOG_TYPE : SEVERITY_TYPES.ERROR;

        lsLogs.add(l.createSystemLog());
        return this;
    }


    /**
    *  @Description: Add new log with Exception parameter
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(Exception e){
        Log l = new Log();
        l.ExceptionObj = e;
        l.Severity = DEFAULT_LOG_TYPE;
        lsLogs.add(l.createSystemLog());
        return this;
    }

    /**
    *  @Description: Log Error message to debug log & log event
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    public static String logError(Exception e, Id recordId){
        String logIdentifier = SOD_XS_LogEventTriggerHandler.generateLogIdentifier();
        System.debug('Exception - ' + logIdentifier + ': ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
        SOD_XS_FeatureToggle__mdt publish = SOD_XS_FeatureToggle__mdt.getInstance('SOD_XS_Publish_Log_Events');
        if(publish.SOD_XS_Active__c){
            publishLogEvent(logIdentifier, null, null, e, recordId);
        }
        return logIdentifier;
    }

    /**
    *  @Description: Log Error message to debug log & log event
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    public static String logError(SOD_XS_JWTRestConnection.ServiceException e, Id recordId){
        String logIdentifier = SOD_XS_LogEventTriggerHandler.generateLogIdentifier();
        System.debug('Exception - ' + logIdentifier + ': ' + e.getLineNumber() + ' - ' + e.getStackTraceString() + ' - ' + e.getMessage());
        SOD_XS_FeatureToggle__mdt publish = SOD_XS_FeatureToggle__mdt.getInstance('SOD_XS_Publish_Log_Events');
        if(publish.SOD_XS_Active__c){
            publishLogEvent(logIdentifier, e.request, e.response, e, recordId);
        }                 
        return logIdentifier;
    }

    /**
    *  @Description: Return Error message String to display to User
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    public static String getErrorMsg(String logIdentifier){
        return ' Ver: ' + logIdentifier;
    }

    /**
    *  @Description: Return Error message String to display to User
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    public static String getErrorMsg(String logIdentifier, String errorMessage){
        if(errorMessage != null && !String.isEmpty(errorMessage)){
            List<SOD_XS_IntegrationErrorMessage__mdt> errorMessages = SOD_XS_IntegrationErrorMessage__mdt.getAll().values();
            for(SOD_XS_IntegrationErrorMessage__mdt msg : errorMessages){
                if(errorMessage.contains(msg.SOD_XS_ExceptionErrorMessage__c)){
                    return msg.SOD_XS_DisplayMessage__c + ' - ' + getErrorMsg(logIdentifier);
                }
            }
        }
        SOD_XS_IntegrationErrorMessage__mdt defaultErrorMessage = SOD_XS_IntegrationErrorMessage__mdt.getInstance('Error_00');
        return defaultErrorMessage.SOD_XS_DisplayMessage__c + ' - ' + getErrorMsg(logIdentifier);
    }

    /**
    *  @Description: Add new log to SOD_XS_RegistroDepuracion__c object (Create Log Event)
    *  @Autor:       Rodolfo Valencia: rlvalencia@falabella.com
    *  @Date:        19/01/2022
    *  HU: 			 CREC-1956
    */
    public static void publishLogEvent(String logIdentifier, HttpRequest request, HttpResponse response, Exception exc, Id recordId){
        SOD_XS_RegistroDepuracion__c outDebugLog = new SOD_XS_RegistroDepuracion__c();   
        SOD_XS_LogEvent__e logEvent = new SOD_XS_LogEvent__e();
        
        outDebugLog.SOD_XS_Identificador__c                     = logIdentifier;                
        outDebugLog.SOD_XS_FechaHoraTransaccion__c 		        = datetime.now();
        outDebugLog.SOD_XS_UsuarioEjecutorTransaccion__c        = userInfo.getUserId();  
        outDebugLog.SOD_XS_MensajeError__c 				        = String.valueOf(exc?.getMessage());       
        outDebugLog.SOD_XS_StackTrace__c 				        = String.valueOf(exc?.getStackTraceString());  
        outDebugLog.SOD_XS_IdRegistroDesencadenador__c          = recordId != null ? String.valueOf(recordId) : '';

        if(request != null){
            outDebugLog.SOD_XS_TipoOperacion__c 				= request?.getMethod();
            outDebugLog.SOD_XS_CodigoIsoPais__c 				= request?.getHeader('X-country');
            outDebugLog.SOD_XS_Guid__c 						    = request?.getHeader('X-txRef');
            outDebugLog.SOD_XS_UrlConsumo__c 				    = request?.getEndpoint();
            outDebugLog.SOD_XS_ParametroTransaccionRequerido__c = request?.getEndpoint().substringAfter('?').substringBefore(', Method');
            if(request.getBody() != null && !String.isEmpty(request.getBody())){
                outDebugLog.SOD_XS_Peticion__c                  = request?.getBody(); 
            }
        }
        if(response != null){
            outDebugLog.SOD_XS_CodigoEstado__c 				    = response?.getStatusCode(); 
            if(response.getBody() != null && !String.isEmpty(response.getBody())){
                outDebugLog.SOD_XS_Respuesta__c                 = response?.getBody();
            }
        }

        logEvent.SOD_XS_Log__c = JSON.serialize(outDebugLog);
        EventBus.publish(logEvent);
    }

	 /**
    *  @Description: Create ContentVersion for request and response from service
    *  @Autor:       NL, Deloitte
    *  @Date:        16/03/2021
    */
    private static ContentVersion createContentVersion(String title, String patch, Blob versData){
        
        ContentVersion file = new ContentVersion();        
        file.Title = title;
        file.PathOnClient = patch;
        file.VersionData = versData;
        file.ContentLocation= 's';
        Insert file;     
        
        return file;
    }
     /**
    *  @Description: Add new ContentDocumentLink related to SOD_XS_RegistroDepuracion__c object
    *  @Autor:       NL, Deloitte
    *  @Date:        16/03/2021
    */
    private static void createContentDocLink(ContentVersion file, SOD_XS_RegistroDepuracion__c debugLog){
        
        ContentDocumentLink contDocList = new ContentDocumentLink();
        contDocList.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: file.Id].ContentDocumentId;
        contDocList.LinkedEntityId = debugLog.id;
        contDocList.ShareType = 'v';
        insert contDocList;
        
    }
    /**
    *  @Description: Add new log with string parameter
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(String comments){
        return log(comments, SEVERITY_TYPES.INFO);
    }

    /**
    *  @Description: Add new String log
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(String comments, SOD_XS_EnLogger.SEVERITY_TYPES severity){
        Log l = new Log();
        l.Comments = comments;
        l.Severity = severity;
        lsLogs.add(l.createSystemLog());
        return this;
    }

    /**
    *  @Description: Add new log with exception and type parameters
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(Exception e, Type t){
        Log l = new Log();
        l.ClassObject = t;
        l.ExceptionObj = e;
        l.Severity = DEFAULT_LOG_TYPE;
        lsLogs.add(l.createSystemLog());
        return this;
    }

    /**
    *  @Description: Add new log with exception, string and type parameters
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(Exception e, String sourceId, Type t){
        Log l = new Log();
        l.ClassObject = t;
        l.ExceptionObj = e;
        l.Severity = DEFAULT_LOG_TYPE;
        l.SourceId = sourceId;
        lsLogs.add(l.createSystemLog());
        return this;
    }

    /**
    *  @Description: Add new log with exception, string category and type parameters
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(Exception e, Type t, String category){
        Log l = new Log();
        l.ClassObject = t;
        l.Severity = DEFAULT_LOG_TYPE;
        l.ExceptionObj = e;
        l.Category = category;
        lsLogs.add(l.createSystemLog());
        return this;
    }
   
    /**
    *  @Description: Add new log with exception, string and type parameters
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(Exception e, Type t, String category, SEVERITY_TYPES type, String sourceId){
        Log l = new Log();
        l.SourceId = sourceId;
        l.ClassObject = t;
        l.Severity = type;
        l.ExceptionObj = e;
        l.Category = category;
        lsLogs.add(l.createSystemLog());
        return this;
    }
 
    /**
    *  @Description: Log Database.SaveResult
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(List<Database.SaveResult> results){
        for (Integer i=0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                String error = String.valueOf(i+1) + '. ';
                for(Database.Error err : results[i].getErrors()) error += err.getMessage() + '; ';
                this.log('Database Error: ' + error, SEVERITY_TYPES.Error);
            }
        }
        return this;
    }
    
    /**
    *  @Description: Log Database.UpsertResult
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public SOD_XS_EnLogger log(List<Database.UpsertResult> results){
        for (Integer i=0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                String error = String.valueOf(i+1) + '. ';
                for(Database.Error err : results[i].getErrors()) error += err.getMessage() + '; ';
                this.log('Database Error: ' + error, SEVERITY_TYPES.Error);
            }
        }
        return this;
    }

    /**
    *  @Description: Save. Commit the logs into database
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public void push(){
        if(ENABLE_LOGS == false || lsLogs.isEmpty()) return;

        if(ENABLE_EVENT) insertLogEvents(getJSONData());
        else { if(!lsLogs.isEmpty()) insert lsLogs; }

        this.flush();
    }
    
    /**
    *  @Description: pushAsync. Save log to Salesforce asynchronously
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public void pushAsync(){
       if(ENABLE_LOGS == false || lsLogs.isEmpty()) return;

        String[] jsonStrs = getJSONData();
        if(ENABLE_EVENT){
            insertLogEventsFuture(jsonStrs);
        }else{
            insertFuture(jsonStrs);
        }
        this.flush();
    }
 
    /**
    *  @Description: getJSONData. convert current log list to a list of json
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    @testVisible
    private List<String> getJSONData(){
        List<String> jsonStrs;
        if(lsLogs.size() > 0){
            jsonStrs = new List<String>();
            for(sObject obj : lsLogs){
                EN_Log__c sLog = (EN_Log__c)obj;
                jsonStrs.add(JSON.serialize(sLog));
            }
        }
        return jsonStrs;
    }

    /**
    *  @Description: flush the cache
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    private void flush(){ lsLogs.clear(); }

    /**
    *  @Description: Insert sobject in asynchronous mode
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    @future
    private static void insertFuture(String jsonStr) { insertFuture(new List<String>{jsonStr}); }

    /**
    *  @Description: Insert list of sobject in asynchronous mode
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    @future
    private static void insertFuture(List<String> jsonStrs)
    {
        List<SObject> toInsert = new List<SObject>();

        for(String j : jsonStrs){
            toInsert.add((SObject)JSON.deserialize(j, sObject.class));
        }
        insert toInsert;
    }

    /**
    *  @Description: insert log as platform events
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    @testVisible
    private static void insertLogEvents(List<String> jsonStrs){
        if(jsonStrs == null || jsonStrs.size() == 0) return;

        List<EN_LogEvent__e> events = new List<EN_LogEvent__e>();
        for(String j : jsonStrs){
            events.add(new EN_LogEvent__e(JSON_Data__c = j));
        }

        EventBus.publish(events);
    }
    
    /**
    *  @Description: insert a new log event
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */
    public static void insertLogEvent(EN_Log__c sLog){
        if(sLog == null) return;

        String jsonData = JSON.serialize(sLog);
        insertLogEvents(new List<String>{jsonData});
    }

    /**
    *  @Description: insert a new log event
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    public static void insertLogEvent(String jsonData){
        if(String.isBlank(jsonData)) return;

        insertLogEvents(new List<String>{jsonData});
    }

    /**
    *  @Description: insert log as platform events, comparing to direct DML, this can avoid rolling back when uncaught exceptions
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @future
    @testVisible
    private static void insertLogEventsFuture(List<String> jsonStrs){
        insertLogEvents(jsonStrs);
    }

    /**
    *  @Description: attach general information for EN logs
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    public static void formatGeneralLogs(EN_Log__c oSL)
    {
        oSL.Application_Id__c = oSL.Source_Id__c; // will be new application object id
        oSL.Is_Logged_In__c   = UserInfo.getUserType() == 'Guest' ? 'No' : 'Yes';
        oSL.Language__c       = UserInfo.getLanguage();
        oSL.Session_Id__c     = UserInfo.getSessionId();
        oSL.Category__c       = String.isEmpty(oSL.Category__c)
            ? getCategoryByUserProfile() : oSL.Category__c;
    }


    /**
    *  @Description: get Application Category
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    private static String getCategoryByUserProfile()
    {
        if(String.isBlank(UserProfileName)){
            Id profId = UserInfo.getProfileId();
            list<Profile> lstProfile = new list<Profile>();
            lstProfile = [Select Name From Profile Where Id = :profId];
            if(lstProfile.size()>0) UserProfileName = lstProfile[0].Name;
        }
        return UserProfileName.containsIgnoreCase(PRJCATEG_GDP)
            ? PRJCATEG_GDP : PRJCATEG_DEF;
    }

    /**
    *  @Description: Warpper class to contain log information
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    private class Log{
        public SEVERITY_TYPES Severity {get;set;}//severity type

        public Type      ClassObject  {get;set;}//class type
        public Exception ExceptionObj {get;set;}//exception instance

        public String SourceId {get;set;}//source record id
        public String Category {get;set;}//category of system log
        public String Comments {get;set;}//comment of the log

        /**
        *  @Description: Create and insert system log
        *  @Autor:       MR, Deloitte, mreisg@deloitte.com
        *  @Date:        21/05/2017
        */
        public EN_Log__c createSystemLog()
        {
            return initializeSystemLog();
        }

        /**
        *  @Description: Extract and generate sobject
        *  @Autor:       MR, Deloitte, mreisg@deloitte.com
        *  @Date:        21/05/2017
        */
        private EN_Log__c initializeSystemLog()
        {
            EN_Log__c oSL = new EN_Log__c(RecordTypeId = DEFAULT_LOG_RECORDTYPE);

            oSL.Severity__c   = String.valueOf(this.Severity);
            oSL.Category__c   = String.isBlank(this.Category) ? 'Default' : this.Category;
            oSL.Source_Id__c  = String.isBlank(this.SourceId) ? '' : this.SourceId;
            oSL.Comment__c    = String.isBlank(this.Comments) ? '' : truncate(this.Comments, MAX_LENGTH_COMMENT);
            oSL.Apex_Class__c = null == this.ClassObject      ? '' : String.valueOf(this.ClassObject).split(':')[0];

            if (this.exceptionObj != null)
            {
                oSL.Description__c = truncate(
                    'Cause: ' + this.exceptionObj.getCause()
                    + '\r\n'  + this.exceptionObj.getMessage(),
                    MAX_LENGTH_DESCRIPTION
                );
                oSL.Exception_Stack_Trace__c = truncate(this.exceptionObj.getStackTraceString(), MAX_LENGTH_STACK_TRACE);
                oSL.Exception_Type__c        = this.exceptionObj.getTypeName();
            }

            SOD_XS_EnLogger.formatGeneralLogs(oSL);

            return oSL;
        }

        /**
        *  @Description: truncate log if oversized
        *  @Autor:       MR, Deloitte, mreisg@deloitte.com
        *  @Date:        21/05/2017
        */        
        private string truncate(String field, Integer length)
        {
            return field == null
                ? field : field.substring(0, Math.Min(field.length(),  length));
        }
    }

    /**
    *  @Description: Exception Class
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        21/05/2017
    */
    public class LoggerException extends Exception{}
}