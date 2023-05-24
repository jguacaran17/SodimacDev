/*
**********************************************************
Created By: David Palma, 13/04/2021
Class Name: SOD_XS_ConsumeUpdateFcom
Comment: Clase creada para invocar servicio de actualización de Caso de Fcom
25-06-2021: Se modifica el servicio que se consume a API Custom de Salesforce Fcorp
01-07-2021: Se obtiene valor de Procede desde Aplicación
**********************************************************
*/

public class SOD_XS_ConsumeUpdateFcom implements Queueable,Database.AllowsCallouts{
	
    public List<Case> cases;
    //Constructor
    public SOD_XS_ConsumeUpdateFcom(List<Case> casList){
        cases = casList ;        
    }
    
    //Clase para generar la respuesta del servicio Get Token
	public class ResponseToken{
		public String access_Token;
		public String instance_URL;
		public String id;
		public String token_Type;
	}
    
    //Executable method
    //Connection made using Named Credentials + Auth Provider
    public void execute(QueueableContext qc){
    	List<Case> c = new List<Case>();
        String accToken, trimmedResponse, descripcionCierre, fechaCierre, tipoCierre;
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        if(cases.size() > 0){
            for(Integer i = 0; i < cases.size(); i++){
                c = [SELECT Id,CaseNumber,Status,SOD_XS_IdExterno__c,SOD_XS_DescripcionCierre__c,ClosedDate, Description, Origin, SOD_XS_PaisdelCaso__c, SOD_XS_ProcedeRequerimiento__c, SOD_XS_ErrorIntegracion__c 
                     FROM Case WHERE Id =: cases[i].Id];
                
                descripcionCierre = c[i].SOD_XS_DescripcionCierre__c != null ? c[i].SOD_XS_DescripcionCierre__c : '';
                if(c[i].ClosedDate != null){
                    String fechaCierreFormat = c[i].ClosedDate.year()+'-'+ c[i].ClosedDate.month() +'-'+ c[i].ClosedDate.day();
                    fechaCierre = String.valueOf(c[i].ClosedDate) != null ? fechaCierreFormat : '';
                    System.debug('Fecha Cierre =>'+fechaCierreFormat);
                }
                
                if(String.isNotEmpty(c[i].SOD_XS_ProcedeRequerimiento__c)){
                    SOD_XS_FcomTransformation__mdt[] mdpr = [SELECT MasterLabel,SOD_XS_FcomValue__c FROM SOD_XS_FcomTransformation__mdt MasterLabel WHERE MasterLabel =: 'FCOM_Pr_'+c[i].SOD_XS_ProcedeRequerimiento__c];
                    if(mdpr.size()>0){
                        tipoCierre = mdpr[0].SOD_XS_FcomValue__c;
                    }
                }
                if(String.isEmpty(tipoCierre)){
                    SOD_XS_FcomTransformation__mdt[] mdpr = [SELECT MasterLabel,SOD_XS_FcomValue__c FROM SOD_XS_FcomTransformation__mdt MasterLabel WHERE MasterLabel =: 'FCOM_Pr_Sí'];
                    tipoCierre = mdpr[0].SOD_XS_FcomValue__c;
                }

                gen.writeStringField('channel', Label.SOD_XS_FcomOrg);
                gen.writeStringField('source', Label.SOD_XS_FcomSource);
                gen.writeStringField('closureComment', descripcionCierre);
                gen.writeStringField('closureTypeDate', tipoCierre);
                gen.writeStringField('description', c[i].Description);
                if(String.isNotEmpty(fechaCierre)){
                    gen.writeStringField('legacyClosureDate', fechaCierre);
                }
                gen.writeStringField('organization', Label.SOD_XS_FcomOrg+' - '+c[i].SOD_XS_PaisdelCaso__c);
                gen.writeStringField('status', c[i].Status);
                gen.writeStringField('type', '');
                gen.writeStringField('reason', '');
                gen.writeStringField('subject', '');
				gen.writeEndObject();

                //Start Get metadata values to Connection FCORP
                String values = gen.getAsString();        
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:F_com_Integration/services/apexrest/Case/v1/CaseNumber/'+c[i].SOD_XS_IdExterno__c);
                req.setMethod('PATCH');
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setBody(values);                      
                HttpResponse res = http.send(req);                        
                trimmedResponse = res.getBody();
                if(res.getStatusCode() != 200){
                    System.debug(Label.SOD_XS_FcomErrorRespuesta + ': '+res.getStatusCode());
                    System.debug(Label.SOD_XS_FcomErrorRespuesta + ': '+res.getBody());
                }
            }
        }    
    }
}