/*
**********************************************************
Created By: David Palma, 13/04/2021
Class Name: SOD_XS_ConsumeCreateFcom
Comment: Clase creada para invocar servicio de creación de Caso de Fcom
16-06-2021: Se agrega campo para controlar error en la integración
02-07-2021: Se agrega mapeo para Canal de Origen y Medio de Pago
**********************************************************
*/

public class SOD_XS_ConsumeCreateFcom implements Queueable,Database.AllowsCallouts{
    
    public List<Case> cases;
    
    //Clase para generar la respuesta del servicio Get Token
    public class ResponseToken{
        public String access_Token;
        public String instance_URL;
        public String id;
        public String token_Type;
    }
    
    //Clase para generar la respuesta del servicio Create Case
    public class ResponseCase{
        public String caseId;
        public String caseNumber;
        public String errorCode;
        public String message;
        public String sla;
    }
    
    //Constructor
    public SOD_XS_ConsumeCreateFcom(List<Case> casList){
        cases = casList ;        
    }

    //Executable method
    //Connection made using Named Credentials + Auth Provider
    public void execute(QueueableContext qc){
        SOD_XS_ConsumeCreateFcomWrapper request = new SOD_XS_ConsumeCreateFcomWrapper();
        request = createRequest(cases[0].Id);
        try {
            if(request.account != null){
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:F_com_Integration/services/apexrest/Case/v1');
                req.setMethod('POST');
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                Http http = new Http();
                req.setBody(JSON.serialize(request));
                HTTPResponse respCase = http.send(req);
                ResponseCase response = (ResponseCase)JSON.deserialize(respCase.getbody(),ResponseCase.class);
                if(response.errorCode == '0' && String.isNotEmpty(response.caseNumber)){
                    cases[0].SOD_XS_IdExterno__c = response.caseNumber;
                    Update cases;
                }
                if(respCase.getStatusCode() != 200 || String.isEmpty(response.caseNumber)){
                    String errorMessage = String.isEmpty(response.message) ? 'ERROR al enviar caso a Fcorp' : response.message;
                    if(errorMessage.length() > 200){
                        errorMessage = errorMessage.substring(0,199); /* rlvalenciat: modificado para CREC-1168 */
                    }
                    cases[0].SOD_XS_ErrorIntegracion__c = errorMessage;
                    Update cases;
                }
            } 
            else{
                cases[0].SOD_XS_ErrorIntegracion__c = 'Request mal formado - Caso sin cliente';
                Update cases;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            cases[0].SOD_XS_ErrorIntegracion__c = e.getMessage().substring(0,199);
            Update cases;            
        }
    }

    //Método para obtener los datos de conexión hacia F.com
    public static SOD_XS_Service_Case_FCORP__mdt[] getConnectionParam(String name){
        SOD_XS_Service_Case_FCORP__mdt[] mdt = [SELECT MasterLabel,SOD_XS_Method__c, SOD_XS_CKey__c,SOD_XS_CSecret__c,SOD_XS_UName__c,SOD_XS_Pass__c,SOD_XS_EndPoint__c, SOD_XS_FcomCreateEndp__c FROM SOD_XS_Service_Case_FCORP__mdt MasterLabel Where MasterLabel =: name];
        return mdt;
    }
    
    //Method for generate Case
    public static SOD_XS_ConsumeCreateFcomWrapper createRequest(String CaseId){
        
        SOD_XS_ConsumeCreateFcomWrapper request = new SOD_XS_ConsumeCreateFcomWrapper();
        
        SOD_XS_ConsumeCreateFcomWrapper.Account requestAcc = new SOD_XS_ConsumeCreateFcomWrapper.Account();
        SOD_XS_ConsumeCreateFcomWrapper.Contact requestCont = new SOD_XS_ConsumeCreateFcomWrapper.Contact();
        SOD_XS_ConsumeCreateFcomWrapper.Cases requestCase = new SOD_XS_ConsumeCreateFcomWrapper.Cases();
        SOD_XS_ConsumeCreateFcomWrapper.WorkOrderDetails requestWO = new SOD_XS_ConsumeCreateFcomWrapper.WorkOrderDetails();
        SOD_XS_ConsumeCreateFcomWrapper.BankDetails requestBD = new SOD_XS_ConsumeCreateFcomWrapper.BankDetails();
        
        List<Case> caseData = new List<Case>();
        List<Account> accountData = new List<Account>();
        List<Contact> contactData = new List<Contact>();
        
        List<SOD_XS_ProductoDelCaso__c> productData = new List<SOD_XS_ProductoDelCaso__c>();
        List<SOD_XS_DocumentoAsociado__c> docAsocData = new List<SOD_XS_DocumentoAsociado__c>();
        List<SOD_XS_DocumentoDeVenta__c> docVentaData = new List<SOD_XS_DocumentoDeVenta__c>();
        String caseRecordType, country;
        String payment = '';
        String caseOrigin = '';
        SOD_XS_FcomClienteAnonimo__mdt[] clienteAnonimo;
        
        caseData = [SELECT caseNumber, RecordType.DeveloperName, SOD_XS_Area__c, SOD_XS_Motivo__c, Description,
                    Origin, Subject, SOD_XS_FechaDeCompra__c, SOD_XS_TiendaVende__r.Name, AccountId, ContactId, 
                    SOD_XS_FormadePago__c, SOD_XS_Submotivo__c, SOD_XS_DocumentoAsociado__c, 
                    SOD_XS_DocumentoDeVenta__c, SOD_XS_PaisdelCaso__c FROM Case WHERE Id =:CaseId];
        
        if(caseData.size()>0){
            
            if(String.isNotEmpty(caseData[0].SOD_XS_PaisdelCaso__c)){
                SOD_XS_FcomTransformation__mdt[] mdtCountry = [SELECT MasterLabel,SOD_XS_External__c,SOD_XS_FcomValue__c,SOD_XS_SodimacValue__c,SOD_XS_Type__c FROM SOD_XS_FcomTransformation__mdt WHERE SOD_XS_Type__c = 'Pais' AND SOD_XS_External__c = 'Fcom' AND MasterLabel =: 'FCOM_'+caseData[0].SOD_XS_PaisdelCaso__c.replace(' ','_')];
                if(mdtCountry.size()>0){
                    country = mdtCountry[0].SOD_XS_FcomValue__c;
                    
                    if(String.isNotEmpty(caseData[0].AccountId)){
                        accountData = [SELECT Name, FirstName, LastName, SOD_XS_NroDocumento__c, SOD_XS_TipoDocumento__c, RecordType.DeveloperName, 
                                       PersonEmail, PersonMobilePhone, SOD_XS_Country__r.Name, SOD_XS_Country__r.SOD_XS_Codigo__c FROM Account WHERE Id =:caseData[0].AccountId];
                        
                        if(accountData.size()>0){
                            //Account Data
                            
                            if(accountData[0].RecordType.DeveloperName == 'PersonAccount'){
                                //Record Type = PersonAccount
                                requestAcc.recordType = accountData[0].RecordType.DeveloperName;
                                requestAcc.documentType = '';
                                requestAcc.document = '';
                                requestAcc.externalId = '';
                                requestAcc.name = '';
                                requestAcc.phone = '';
                                requestAcc.country = ''; 
                                
                                //Contact Data
                                requestCont.documentType = accountData[0].SOD_XS_TipoDocumento__c;
                                requestCont.document = accountData[0].SOD_XS_NroDocumento__c.replace('-','');
                                requestCont.externalId = '';
                                requestCont.firstName = accountData[0].FirstName;
                                requestCont.middleName = '';
                                requestCont.lastName = accountData[0].LastName;
                                requestCont.mothersFamilyName = '';
                                requestCont.personEmail = accountData[0].PersonEmail;
                                requestCont.phone = accountData[0].PersonMobilePhone;
                                
                                requestCont.country = country;
                                request.account = requestAcc;
                                request.contact = requestCont;
                                
                            }
                            if(accountData[0].RecordType.DeveloperName == 'Business_Account'){
                                //Record Type = Business Account
                                requestAcc.recordType = accountData[0].RecordType.DeveloperName;
                                requestAcc.documentType = accountData[0].SOD_XS_TipoDocumento__c;
                                requestAcc.document = accountData[0].SOD_XS_NroDocumento__c.replace('-','');
                                requestAcc.externalId = '';
                                requestAcc.name = accountData[0].Name;
                                requestAcc.phone = '';
                                
                                requestAcc.country = country;
                                request.account = requestAcc;
                                
                            }
                        }
                        else{
                            //Account no existe
                            //Si cliente no existe 
                            clienteAnonimo = [SELECT MasterLabel, SOD_XS_DocNumber__c, SOD_XS_DocType__c, SOD_XS_Email__c, SOD_XS_FirstName__c, SOD_XS_MiddleName__c, SOD_XS_LastName__c, SOD_XS_Pais__c, SOD_XS_PhoneNumber__c, SOD_XS_RecordType__c, SOD_XS_AccType__c
                                              FROM SOD_XS_FcomClienteAnonimo__mdt WHERE MasterLabel =: 'SOD_XS_ClienteAnon_'+caseData[0].SOD_XS_PaisdelCaso__c];
                            if(clienteAnonimo.size()>0){
                                //Record Type = PersonAccount
                                requestAcc.recordType = clienteAnonimo[0].SOD_XS_RecordType__c;
                                requestAcc.documentType = '';
                                requestAcc.document = '';
                                requestAcc.externalId = '';
                                requestAcc.name = '';
                                requestAcc.phone = '';
                                requestAcc.country = ''; 
                                
                                //Contact Data
                                requestCont.documentType = clienteAnonimo[0].SOD_XS_DocType__c;
                                requestCont.document = clienteAnonimo[0].SOD_XS_DocNumber__c;
                                requestCont.externalId = clienteAnonimo[0].SOD_XS_AccType__c;
                                requestCont.firstName = clienteAnonimo[0].SOD_XS_FirstName__c;
                                requestCont.middleName = clienteAnonimo[0].SOD_XS_MiddleName__c;
                                requestCont.lastName = clienteAnonimo[0].SOD_XS_LastName__c;
                                requestCont.mothersFamilyName = '';
                                requestCont.personEmail = clienteAnonimo[0].SOD_XS_Email__c;
                                requestCont.phone = String.valueOf(clienteAnonimo[0].SOD_XS_PhoneNumber__c);                  
                                requestCont.country = clienteAnonimo[0].SOD_XS_Pais__c;
                                request.account = requestAcc;
                                request.contact = requestCont; 
                            }
                        }
                    }
                    else{
                        //Si cliente no existe 
                        clienteAnonimo = [SELECT MasterLabel, SOD_XS_DocNumber__c, SOD_XS_DocType__c, SOD_XS_Email__c, SOD_XS_FirstName__c, SOD_XS_MiddleName__c, SOD_XS_LastName__c, SOD_XS_Pais__c, SOD_XS_PhoneNumber__c, SOD_XS_RecordType__c, SOD_XS_AccType__c
                                          FROM SOD_XS_FcomClienteAnonimo__mdt WHERE MasterLabel =: 'SOD_XS_ClienteAnon_'+caseData[0].SOD_XS_PaisdelCaso__c];
                        System.debug('clienteAnonimo=>'+clienteAnonimo);
                        if(clienteAnonimo.size()>0){
                            //Record Type = PersonAccount
                            requestAcc.recordType = clienteAnonimo[0].SOD_XS_RecordType__c;
                            requestAcc.documentType = '';
                            requestAcc.document = '';
                            requestAcc.externalId = '';
                            requestAcc.name = '';
                            requestAcc.phone = '';
                            requestAcc.country = ''; 
                            
                            //Contact Data
                            requestCont.documentType = clienteAnonimo[0].SOD_XS_DocType__c;
                            requestCont.document = clienteAnonimo[0].SOD_XS_DocNumber__c;
                            requestCont.externalId = clienteAnonimo[0].SOD_XS_AccType__c;
                            requestCont.firstName = clienteAnonimo[0].SOD_XS_FirstName__c;
                            requestCont.middleName = clienteAnonimo[0].SOD_XS_MiddleName__c;
                            requestCont.lastName = clienteAnonimo[0].SOD_XS_LastName__c;
                            requestCont.mothersFamilyName = '';
                            requestCont.personEmail = clienteAnonimo[0].SOD_XS_Email__c;
                            requestCont.phone = String.valueOf(clienteAnonimo[0].SOD_XS_PhoneNumber__c);                  
                            requestCont.country = clienteAnonimo[0].SOD_XS_Pais__c;
                            request.account = requestAcc;
                            request.contact = requestCont;
                            System.debug('Request=>'+request);
                        }
                    }
                    
                    //Case Data
                    //requestCase.source = Label.SOD_XS_FcomSource /*'External'*/;
                    requestCase.organization = Label.SOD_XS_FcomOrg+' - '+caseData[0].SOD_XS_PaisdelCaso__c /*'Sodimac - Chile'*/;
                    System.debug('Organization=>'+Label.SOD_XS_FcomOrg+' - '+caseData[0].SOD_XS_PaisdelCaso__c);
                    requestCase.channel = Label.SOD_XS_FcomOrg /*'Sodimac'*/;
                    //requestCase.origin = caseData[0].Origin;
                    requestCase.subject = caseData[0].Subject;
                    requestCase.description = caseData[0].Description;
                    requestCase.webEmail = '';
                    
                    if(String.isNotEmpty(caseData[0].Origin)){
                        SOD_XS_FcomTransformation__mdt[] mdpay = [SELECT MasterLabel, SOD_XS_External__c,SOD_XS_FcomValue__c,SOD_XS_SodimacValue__c,SOD_XS_Type__c FROM SOD_XS_FcomTransformation__mdt
                                                                  WHERE SOD_XS_Type__c = 'Origen' AND SOD_XS_External__c = 'Fcom' AND MasterLabel =: 'FCOM_Origen_'+caseData[0].Origin.replace(' ','')];
                        if(mdpay.size()>0){
                            caseOrigin = mdpay[0].SOD_XS_FcomValue__c;
                        }
                    }
                    System.debug('Origin ==>'+caseOrigin);
                    requestCase.origin = caseOrigin;
                    
                    SOD_XS_FcomTransformation__mdt[] mdtRt = [SELECT MasterLabel,SOD_XS_External__c,SOD_XS_FcomValue__c,SOD_XS_SodimacValue__c,SOD_XS_Type__c FROM SOD_XS_FcomTransformation__mdt WHERE SOD_XS_Type__c = 'Record Type' AND SOD_XS_External__c = 'Fcom' AND MasterLabel =: 'FCOM_'+caseData[0].RecordType.DeveloperName];
                    
                    if(mdtRt.size()>0){
                        caseRecordType = mdtRt[0].SOD_XS_FcomValue__c;
                        System.debug('Record Type =>'+mdtRt[0].SOD_XS_FcomValue__c); 
                    }
                    else{
                        caseRecordType = '';
                    }
                    
                    requestCase.level1 = caseRecordType;
                    requestCase.level2 = caseData[0].SOD_XS_Area__c;
                    requestCase.level3 = caseData[0].SOD_XS_Motivo__c;
                    if(String.isNotEmpty(caseData[0].SOD_XS_Submotivo__c)){
                        requestCase.level3 = requestCase.level3+'_'+caseData[0].SOD_XS_Submotivo__c;
                    }
                    requestCase.country = country;
                    requestCase.city = '';
                    requestCase.commerce = Label.SOD_XS_FcomOrg /*'Sodimac'*/;
                    requestCase.text1 = '';
                    requestCase.text2 = '';
                    requestCase.text3 = '';
                    requestCase.boolean1 = false;
                    requestCase.boolean2 = false;
                    requestCase.boolean3 = false;
                    requestCase.customerOrder = '';
                    requestCase.externalId = caseData[0].caseNumber;
                    
                    requestCase.seller = Label.SOD_XS_FcomOrg.toUpperCase() /*'SODIMAC'*/;
                    requestCase.sellerId = Label.SOD_XS_FcomOrg.toUpperCase()+'_'+caseData[0].SOD_XS_PaisdelCaso__c.toUpperCase() /*'SODIMAC_CHILE'*/;
                    requestCase.agentCase = false;
                    requestCase.agentCode = '';
                    requestCase.bigticket = false;
                    
                    if(String.isNotEmpty(caseData[0].SOD_XS_DocumentoAsociado__c)){
                        docAsocData = [SELECT SOD_XS_DocumentoDeVenta__c, SOD_XS_IdExterno__c, Name, SOD_XS_TipoDeDdocumento__c
                                       FROM SOD_XS_DocumentoAsociado__c WHERE Id =:caseData[0].SOD_XS_DocumentoAsociado__c];
                        if(docAsocData.size()>0){
                            if(docAsocData[0].SOD_XS_TipoDeDdocumento__c == Label.SOD_XS_FcomOrder /*'ODC'*/){
                                requestCase.sellerOrder = docAsocData[0].Name;
                            }
                        }
                    }
                    
                    request.cases = requestCase;
                    
                    //WorkOrder Data
                    if(String.isNotEmpty(caseData[0].SOD_XS_DocumentoDeVenta__c)){
                        docVentaData = [SELECT SOD_XS_CodigoTiendaQueVende__c, SOD_XS_FechaDeCompra__c, SOD_XS_IdExterno__c,
                                        SOD_XS_MedioDePago__c, SOD_XS_MontoTotal__c, Name, SOD_XS_TipoDeDdocumento__c
                                        FROM SOD_XS_DocumentoDeVenta__c WHERE Id =:caseData[0].SOD_XS_DocumentoDeVenta__c];
                        if(docVentaData.size()>0){
                            if(docVentaData[0].SOD_XS_TipoDeDdocumento__c == Label.SOD_XS_FcomBoleta /*'boleta'*/){
                                requestWO.invoiceNumber = Integer.valueOf(docVentaData[0].Name);
                            }
                        }
                    }
                    
                    //requestWO.paymentMethod = caseData[0].SOD_XS_FormadePago__c;
                    if(String.isNotEmpty(caseData[0].SOD_XS_FormadePago__c)){
                        System.debug('Param=>'+caseData[0].SOD_XS_FormadePago__c.replace(' ','').replace('/',''));
                        SOD_XS_FcomTransformation__mdt[] mdpay = [SELECT MasterLabel, SOD_XS_External__c,SOD_XS_FcomValue__c,SOD_XS_SodimacValue__c,SOD_XS_Type__c FROM SOD_XS_FcomTransformation__mdt
                                                                  WHERE SOD_XS_Type__c = 'Medio Pago' AND SOD_XS_External__c = 'Fcom' AND MasterLabel =: 'FCOM_mp_'+caseData[0].SOD_XS_FormadePago__c.replace(' ','').replace('/','')];
                        if(mdpay.size()>0){
                            payment = mdpay[0].SOD_XS_FcomValue__c;
                        }
                    }
                    System.debug('Payment==>'+payment);
                    requestWO.paymentMethod = payment;
                    
                    if(caseData[0].SOD_XS_FechaDeCompra__c != null){
                        String purchaseDate = caseData[0].SOD_XS_FechaDeCompra__c.day()+'/'+caseData[0].SOD_XS_FechaDeCompra__c.month()+'/'+caseData[0].SOD_XS_FechaDeCompra__c.year();
                        requestWO.purchaseDate = String.valueOf(purchaseDate);
                    }
                    
                    //requestWO.originStore = caseData[0].SOD_XS_TiendaVende__r.Name;
                    requestWO.originStore = Label.SOD_XS_FcomTienda;
                    requestWO.terminal = '';
                    requestWO.sequence = '';
                    requestWO.reasonProblem = '';
                    requestWO.deliveryStatus = '';
                    
                    request.cases.workOrderDetails = requestWO;
                    
                    //Bank Details
                    requestBD.accountHolder = '';
                    requestBD.accountHolderId = '';
                    requestBD.bank = '';
                    requestBD.accountType = '';
                    requestBD.accountNumber = '';
                    requestBD.grandTotal = 0;
                    
                    request.cases.bankDetails = requestBD;
                    
                    //Buscar campos de Productos del Caso
                    productData = [SELECT SOD_XS_Cantidad__c, Name, SOD_XS_DescripcionDelProducto__c, SOD_XS_CodigoProducto__c, SOD_XS_PrecioUnitario__c FROM SOD_XS_ProductoDelCaso__c WHERE SOD_XS_Caso__c =:CaseId];
                    Integer productSize = productData.size();
                    if(productSize>0){
                        List<SOD_XS_ConsumeCreateFcomWrapper.Asset> lstAsset = new List<SOD_XS_ConsumeCreateFcomWrapper.Asset>();
                        for(Integer i=0; i < productSize; i++){
                            SOD_XS_ConsumeCreateFcomWrapper.Asset asset = new SOD_XS_ConsumeCreateFcomWrapper.Asset();
                            asset.damageDescription = '';
                            asset.erDescription = '';
                            asset.lineId = '';
                            //asset.name = productData[0].Name;
                            asset.name = productData[0].SOD_XS_CodigoProducto__c;
                            asset.packageCondition = '';
                            asset.price = 0;
                            if(productData[0].SOD_XS_PrecioUnitario__c != null){
                                asset.price = Integer.valueOf(productData[0].SOD_XS_PrecioUnitario__c);
                            }
                            
                            asset.productCondition = '';
                            asset.quantity = 1;
                            if(productData[0].SOD_XS_PrecioUnitario__c != null){
                                asset.quantity = Integer.valueOf(productData[0].SOD_XS_Cantidad__c);
                            }
                            
                            asset.quantityOrdered = 0;
                            asset.statusReason = '';
                            asset.stockKeepingUnite = productData[0].SOD_XS_DescripcionDelProducto__c;
                            asset.upc = '';
                            asset.useLevel = '';
                            lstAsset.add(asset);
                            asset = null;
                        }
                        
                        if(lstAsset.size()>0){
                            request.cases.asset = lstAsset;
                        } 
                    }
                }
                
            }

        }
        
        return request;
    }
}