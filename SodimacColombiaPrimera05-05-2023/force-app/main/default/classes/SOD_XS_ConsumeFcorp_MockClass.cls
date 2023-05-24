/*
**********************************************************
Created By: David Palma, 07/06/2021
Class Name: SOD_XS_ConsumeFcorp_MockClass
Comment: Mock Class for Fcorp Apex Callout
**********************************************************
*/

@isTest
global class SOD_XS_ConsumeFcorp_MockClass implements HttpCalloutMock{
	String option;
    
    public class responseToken{
        public String access_token;      
    }
    
    public class responseCase{
        public String errorMessage;
        public String errorCode;
        public String caseNumber;
        public String caseId;     
    }
    
    public class responseUpdateCase{
        public String errorMessage;
        public String errorCode;
        public String caseId;     
    }
    
    public SOD_XS_ConsumeFcorp_MockClass(String op){
        option = op;
    }
    
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        
        if(request.getEndpoint().endsWith('/token') && option == '0'){
            SOD_XS_ConsumeFcorp_MockClass.responseToken rt = new SOD_XS_ConsumeFcorp_MockClass.responseToken();
            rt.access_token = '12345678';
            String json = JSON.serialize(rt);
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
        }
        else{
            SOD_XS_ConsumeFcorp_MockClass.responseToken rt = new SOD_XS_ConsumeFcorp_MockClass.responseToken();
            rt.access_token = '';
            String json = JSON.serialize(rt);
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(400);
        }
        
        if(request.getEndpoint().endsWith('/Case/v1') && option == '0'){
            SOD_XS_ConsumeFcorp_MockClass.responseCase rc = new SOD_XS_ConsumeFcorp_MockClass.responseCase();
            rc.caseNumber = '001244';
            rc.caseId = '738392002044';
            rc.errorCode = '0';
            
            String json2 = JSON.serialize(rc);
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json2);
            response.setStatusCode(200);
        }
        
        if(request.getEndpoint().endsWith('/Case/CaseNumber/') && option == '0'){
            SOD_XS_ConsumeFcorp_MockClass.responseUpdateCase ru = new SOD_XS_ConsumeFcorp_MockClass.responseUpdateCase();
            ru.caseId = '738392002044';
            ru.errorCode = '0';
            
            String json2 = JSON.serialize(ru);
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json2);
            response.setStatusCode(200);
        }
        
        return response;
    }
}