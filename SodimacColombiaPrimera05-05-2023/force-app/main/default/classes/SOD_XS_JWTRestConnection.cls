/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 02/01/2020
Description  : Class responsible to the Rest Connection
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			02/01/2020		   Created Class
********************************************************************************/

public with sharing class SOD_XS_JWTRestConnection {

    private String serviceName {get;set;}
    @testVisible private SOD_XS_ServicioIntegracion__mdt servicio {set; get;}
    @testVisible private SOD_XS_RutaIntegracion__mdt path {set; get;}
    private AccessToken token { set; get {
        token = token == null || token.expirationTime <=  (dateTime.now().getTime()/1000)+1 ? this.getToken() : token;
        return token;
    }}
    private Map<String, String> mapClaims {get;set;}

    private static final String PVR_STR_COLON = ':';
    private static final String PVR_STR_SMCOLON = ';';
    private static final String PVR_PATH_SEARCHCLIENT = Label.SOD_XS_Buscar_Clientes;
    private static final String PVR_STR_HEADER = 'header';
    private static final String PVR_STR_QUERY = 'query';
    private static final String PVR_STR_PATH = 'path';
    private static final String PVR_STR_AUTH = 'Authorization';
    private static final String PVR_STR_RHSHEADER = 'X-rhsRef';
    private static final String PVR_STR_USRHEADER = 'X-usrTx';
    private static final String PVR_STR_TXHEADER = 'X-txRef';
    
    /**
    *  @Description: Fill map claims, custom claim used to add transaction user
    *  @Autor:       Abd�n Tejos, atejoso@deloitte.com
    *  @Date:        02/01/2020
    */    
    public Map<String, String> fillMapClaims() {
        
        User u = [Select FederationIdentifier FROM user Where id =: UserInfo.getUserId()];
        String fdId = u.FederationIdentifier != null ? u.FederationIdentifier : UserInfo.getUsereMail();
        Map<String, String> str = new Map<String, String>();
        str.put('username', fdId);
        return str;
    }

    /**
    *  @Description: Fill map services, URL map associated with countries
    *  @Autor:       Abd�n Tejos, atejoso@deloitte.com
    *  @Date:        02/01/2020
    */    
    public Map<String, String> fillMapServices() {
        Map<String, String>  str = new Map<String, String>();
        if (!String.isEmpty(Label.SOD_XS_URL_Base)) {
            String[] splitStr = Label.SOD_XS_URL_Base.Split(PVR_STR_SMCOLON);
            for (String c : splitStr) {
                str.put(c.Split(PVR_STR_COLON)[0], c.Split(PVR_STR_COLON)[1]);
            }
        }
        return str;
    }

    /**
    *  @Description: Fill map header, headers used in the integration
    *  @Autor:       Abd�n Tejos, atejoso@deloitte.com
    *  @Date:        02/01/2020
    */    
    public Map<String, String> fillMapHeader(String vrb) {
        Map<String, String>  str = new Map<String, String>();
        Map<String, String>  stcMap = new Map<String, String>{
            PVR_STR_RHSHEADER => SOD_XS_JWTAuthentication.getHost(),
            PVR_STR_TXHEADER => SOD_XS_JWTAuthentication.getGUID(),
            PVR_STR_USRHEADER => UserInfo.getUserName()};
        if (!String.isEmpty(vrb)) {
            String[] splitStr = vrb.Split(PVR_STR_SMCOLON);
            for (String c : splitStr) {
                if (stcMap.containsKey(c.Split(PVR_STR_COLON)[0])) {
                	str.put(c.Split(PVR_STR_COLON)[0], stcMap.get(c.Split(PVR_STR_COLON)[0])); 
                } else {
                    str.put(c.Split(PVR_STR_COLON)[0], c.Split(PVR_STR_COLON)[1]);
                }
            }
            str.put(PVR_STR_AUTH, '');
        }        
        return str;
    }

    /**
    *  @Description: Constructor to initialize the class
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    public SOD_XS_JWTRestConnection(String countryCode, String namePath) {
        
        namePath = countryCode + ' ' + namePath;        
        this.servicio = [SELECT SOD_XS_Editor_ISS__c, SOD_XS_Llave_Secreta__c, SOD_XS_URLBase__c, MasterLabel FROM SOD_XS_ServicioIntegracion__mdt WHERE MasterLabel =: fillMapServices().get(countryCode) LIMIT 1];        
        this.path = [SELECT SOD_XS_RutaURL__c, SOD_XS_Metodo__c, SOD_XS_Cabeceras__c, MasterLabel FROM SOD_XS_RutaIntegracion__mdt WHERE MasterLabel =: namePath LIMIT 1];
        this.mapClaims = fillMapClaims();
        
    }

    /**
    *  @Description: Call service, centralization of rest calls
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    public HttpResponse callService (Map <String, Map<String,String>> connSetting, String body){
        
        String endpoint = servicio.SOD_XS_URLBase__c + path.SOD_XS_RutaURL__c;
        String country;
        HttpRequest request = new HttpRequest();
        if (connSetting.containsKey(PVR_STR_PATH)) {            
            for (String param : connSetting.get(PVR_STR_PATH).keyset()) {
                endpoint = endpoint + '/' + connSetting.get(PVR_STR_PATH).get(param);
            }
        }

        if (connSetting.containsKey(PVR_STR_QUERY)) {
            Integer i = 0;
            endpoint += !connSetting.get(PVR_STR_QUERY).isEmpty() ? '?' : '';
            for (String param : connSetting.get(PVR_STR_QUERY).keyset()) {
                endpoint += param + '=' + connSetting.get(PVR_STR_QUERY).get(param);
                endpoint += ++i == connSetting.get(PVR_STR_QUERY).size() ? '' : '&';
            }
        }

        if (connSetting.containsKey(PVR_STR_HEADER)) {
            connSetting.get(PVR_STR_HEADER).putAll(fillMapHeader(path.SOD_XS_Cabeceras__c));
            for (String param : connSetting.get(PVR_STR_HEADER).keySet()) {
                if (param == PVR_STR_AUTH) {                    
                    request.setHeader(param, 'Bearer ' + token.accessToken);
                } else {                    
                    request.setHeader(param, connSetting.get(PVR_STR_HEADER).get(param));
                    if(param == 'X-country') {country = connSetting.get(PVR_STR_HEADER).get(param);}
                }
            }
        }
        
        request.setEndpoint(endpoint);
        request.setMethod(path.SOD_XS_Metodo__c);
        request.setTimeout(120000); 
        if (String.isNotBlank(body)) {
            request.setBody(body);
        }

        HttpResponse response;
        
        try {
            
            response = new Http().send(request); 
            
            //Temp code for catch evidence FIX-BUG 5164
            if(path.MasterLabel == country + ' ' + PVR_PATH_SEARCHCLIENT || path.MasterLabel == country + ' ' + Label.SOD_XS_Actualizar_Cliente ){
                System.debug('body: '+body);
                System.debug('request: '+request);
                System.debug('response: '+response);
            } 

            if ((response.getStatusCode() != 200 && response.getStatusCode() != 201 && response.getStatusCode() != 500 && path.MasterLabel != PVR_PATH_SEARCHCLIENT)
                || (path.MasterLabel == PVR_PATH_SEARCHCLIENT && response.getStatusCode() != 200 && response.getStatusCode() != 201)) {
                createErrorService(request, response);                    
            } else if(response.getStatusCode() == 500) {
                ServiceError error = (ServiceError) Json.deserialize(response.getBody(), ServiceError.class);
                new SOD_XS_EnLogger().log(new ServiceException('User Message: ' + error.userMessage + ' | Internal Message: ' + error.internalMessage + ' | More Info: ' + error.moreInfo)).push();
                //throw new  ServiceException(error.userMessage);
                throw new ServiceException(request, response, error.userMessage, response.getStatusCode());
            }
            
        } catch(CalloutException ex) {
            //CREC-1956
            new SOD_XS_EnLogger().log(ex).push();
            //throw new ServiceException(ex.getMessage(), ex);
            throw new ServiceException(request, response, ex.getMessage(), response.getStatusCode());
            
        } catch(JSONException ex) {
            //CREC-1956
            new SOD_XS_EnLogger().log(ex).push();
            //throw new ServiceException(ex.getMessage());
            throw new ServiceException(request, response, ex.getMessage(), response.getStatusCode());
        }
        return response;
        
    }
    
    /**
    *  @Description: Get token, get the JWT Token for the integration
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    private AccessToken getToken() {
        SOD_XS_JWTAuthentication jw = new SOD_XS_JWTAuthentication('HS256');
        jw.iss= this.servicio.SOD_XS_Editor_ISS__c;
        jw.privateKey = this.servicio.SOD_XS_Llave_Secreta__c;
        if (!mapClaims.isEmpty()){jw.claims= mapclaims;}
        String key = jw.issue();
        AccessToken token = new AccessToken( key, jw.validFor);
        return token;
    }
    
    /**
    *  @Description: Access Token, wrapper class used to send the integration token
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    private class AccessToken {
        public String  accessToken    {get; private set;}
        public Long    expirationTime {get; private set;}
        
        public AccessToken(String  accessToken, Integer expirationTime ) {            
            this.accessToken    = accessToken;
            this.expirationTime = expirationTime;
        }
        
        public override String toString() {
            return this.accessToken;
        }
    }

    /**
    *  @Description: Service Error, wrapper class used to set a service error
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    private class ServiceError{
        public String  userMessage {get; private set;}
        public String  internalMessage {get; private set;}
        public String  moreInfo {get; private set;}
        
        public ServiceError (String  userMessage,String  internalMessage,String  moreInfo){
            this.userMessage =userMessage;
            this.internalMessage = internalMessage;
            this.moreInfo =moreInfo;
        }
        
    }

    /**
    *  @Description: Create error service, used to create and throw a service error
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    private void createErrorService (HttpRequest request, HttpResponse response){
        Integer code = response.getStatusCode();
        switch on code {
            when  204 {
                throw new ServiceException(request, response, Label.SOD_XS_ERROR204, code);
            }
            when  400 {
                throw new ServiceException(request, response, Label.SOD_XS_ERROR400, code);
            }
            when  401 {
                throw new ServiceException(request, response, Label.SOD_XS_ERROR401, code);
            }
            when  404 {
                throw new ServiceException(request, response, Label.SOD_XS_ERROR404, code);
            }
            when  500 {
                throw new ServiceException(request, response, Label.SOD_XS_ERROR500, code);
            }
            when  503 {
                throw new ServiceException(request, response, Label.SOD_XS_ERROR503, code);
            }
            when else {
                throw new ServiceException(request, response, Label.SOD_XS_ERRORDEFAULT, code);
            }
            
        }
        
    }

    /**
    *  @Description: Service exception, wrapper class used to set a service exception
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        02/01/2020
    */    
    public class ServiceException extends Exception {
        public HttpRequest request;
        public HttpResponse response;
        public Integer code;
        public ServiceException(String message, Integer code)
        {
            this(message);
            this.code = code;            
        }
        public ServiceException(HttpRequest request, HttpResponse response, String message, Integer code)
        {
            this(message);
            this.code = code;
            this.request = request;
            this.response = response;           
        }
    }

}