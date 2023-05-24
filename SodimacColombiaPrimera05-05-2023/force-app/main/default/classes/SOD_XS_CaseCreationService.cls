/*
**************************************************************
Created By: David Palma (FTC)
Date: 18/02/2021
Class Name: SOD_XS_CaseCreationService
Comments: Class created for APEX Rest Case Creation Service
Last Modified: 
15/03/2021 By Francisco Gaitan
02/12/2022 By Johan Martínez: Se añade manejo de excepciones al crear cuenta y al crear caso para evitar UNABLE_TO_LOCK_ROW
17/01/2023 By Johan Martínez: Se añade código para manejar creación de caso para clientes con mas de una cuenta en Salesforce (Crec 10651)
31/01/2023 By Johan Martínez: Ajustes para setear SOD_XS_TiendaVende__c y SOD_XS_CentroCostoResponsable__c
**************************************************************
*/

@RestResource(urlMapping='/Case/*')
global with sharing class SOD_XS_CaseCreationService{
	
    static final String SUCCESS_MSG_RECONTACT_INSERT = 'ReContacto se inserto OK.';
    static final String RECORD_TYPE_NAME_BUSINESS_ACCOUNT = 'Business_Account';

	//Invocable method
	@HttpPost
	global static void doPost(){
         
		RestRequest req = RestContext.request;
		RestResponse resp = RestContext.response;

		Blob body = req.requestBody;
		String bodyString = body.toString();
		
		SOD_XS_CaseCreationRequestWrapper requestObject = SOD_XS_CaseCreationRequestWrapper.parse(bodyString);
		SOD_XS_CaseCreationResponseWrapper responseObject = new SOD_XS_CaseCreationResponseWrapper('','','','');
		
		try{
            //Se llama método de creación de Caso, toda la lógica se encuentra en este método
			responseObject = caseCreationMethod(requestObject);
			if(String.isNotBlank(responseObject.caseId) && String.isNotBlank(responseObject.caseNumber)){
                //Respuesta satisfactoria del servicio
				resp.statusCode = 200;
				resp.addHeader('Content-Type', 'application/json');
				resp.responseBody = Blob.valueOf(JSON.serialize(responseObject));	
			}
			else{
                //Respuesta incorrecta del servicio. En la excepción se formatea la salida
				throw new SOD_XS_CaseCreationServiceException(responseObject.errorCode, responseObject.errorMessage);
			}

		}catch(SOD_XS_CaseCreationServiceException ex){
			resp.statusCode = 400;
			resp.addheader('Content-Type','application/json');
			responseObject.errorCode = ex.errorCode;
			responseObject.errorMessage = ex.errorMessage;
			resp.responseBody = Blob.valueOf(JSON.serialize(responseObject));
		}

	}

    //Método de creación o actualización de cliente
	public static SOD_XS_CaseCreationResponseWrapper accountCreation(SOD_XS_CaseCreationRequestWrapper.Account acc){
		
        //Start Get metadata values to control errors        
        SOD_XS_Case_FCORP__mdt[] mdt = [SELECT MasterLabel,SOD_XS_CodError__c,SOD_XS_Field1__c FROM SOD_XS_Case_FCORP__mdt MasterLabel Where MasterLabel =: 'Record02'];
        //End Get metadata values to control errors 
        
        Account newAccount = new Account();
		SOD_XS_CaseCreationResponseWrapper resp = new SOD_XS_CaseCreationResponseWrapper('','','','');
        
        List<Account> accQueryAux = new List<Account>();

		try{
            //Se obtiene el Id del Record Type de Account
            List<RecordType> accRt = [SELECT Id FROM RecordType WHERE DeveloperName = :acc.recordType];
            newAccount.RecordTypeId = accRt[0].Id;
            
			newAccount.SOD_XS_TipoDocumento__c = acc.documentType;
			newAccount.SOD_XS_NroDocumento__c = acc.documentNumber;
			newAccount.CurrencyIsoCode = acc.currencyName;
			newAccount.SOD_XS_Direccion__c = acc.address;
            if(acc.recordType == 'PersonAccount'){
                newAccount.FirstName = acc.accountName;
            	newAccount.LastName = acc.accountLastName;
                newAccount.PersonEmail = acc.personEmail;
                newAccount.PersonMobilePhone = acc.mobilePhone;
            }
            if(acc.recordType == 'Business_Account'){
                newAccount.Name = acc.companyName;
                newAccount.Phone = acc.mobilePhone;
            }

			List<SOD_XS_Country__c> country = [SELECT id FROM SOD_XS_Country__c WHERE Name =: acc.country];
	        if(country.size() > 0 && String.isNotBlank(Id.valueOf(country[0].id))){
	            newAccount.SOD_XS_Country__c = country[0].id;
	        }

	        List<SOD_XS_AdministrativeArea__c> region = [SELECT id FROM SOD_XS_AdministrativeArea__c WHERE Name =: acc.region AND SOD_XS_Country__c = :newAccount.SOD_XS_Country__c];
	        if(region.size() > 0 && String.isNotBlank(Id.valueOf(region[0].id))){
	            newAccount.SOD_XS_AdministrativeArea__c = region[0].id;
	        }

	        List<SOD_XS_Locality__c> province = [SELECT id FROM SOD_XS_Locality__c WHERE Name =: acc.province AND SOD_XS_AdministrativeArea__c = :newAccount.SOD_XS_AdministrativeArea__c];
	        if(province.size() > 0 && String.isNotBlank(Id.valueOf(province[0].id))){
	            newAccount.SOD_XS_Locality__c = province[0].id;
	        }

	        List<SOD_XS_SubAdministrativeArea__c> commune = [SELECT id FROM SOD_XS_SubAdministrativeArea__c WHERE Name =: acc.commune AND SOD_XS_Locality__c = :newAccount.SOD_XS_Locality__c];
	        if(commune.size() > 0 && String.isNotBlank(Id.valueOf(commune[0].id))){
	            newAccount.SOD_XS_SubAdministrativeArea__c = commune[0].id;
	        }

            //Obtener el Id del Account en caso de que existe
            List<Account> accQuery = [SELECT Id, RecordType.DeveloperName FROM Account WHERE SOD_XS_TipoDocumento__c =:acc.documentType AND SOD_XS_NroDocumento__c =:acc.documentNumber AND SOD_XS_Country__r.Name =: acc.country];
            
            //Cliente existe con más de una cuenta
            if(accQuery.size() > 1)
            {
                Boolean flgBA = false;

                for(Integer i = 0; i < accQuery.size(); i++){
                    //Si cliente tiene más de una cuenta, seleccionar la cuenta Empresa
                    if(accQuery[i].RecordType.DeveloperName == RECORD_TYPE_NAME_BUSINESS_ACCOUNT){
                        accQueryAux.add(accQuery[i]);
                        flgBA = true;
                        break;
                    }
                }

                if(flgBA){
                    accQuery.clear();
                    accQuery = accQueryAux;
                }
                else{
                    accQueryAux.add(accQuery[0]);
                    accQuery.clear();
                    accQuery = accQueryAux;
                }
            }
            
            if(accQuery.size() > 0 && String.isNotBlank(Id.valueOf(accQuery[0].Id))){
                resp.caseId = accQuery[0].Id;
            } else {
                // rvalenciat: Modificamos el upsert de los clientes para hacerlo mediante el campo id externo unico
                List<SOD_XS_Tipo_de_documento_BUC__mdt> tddList = SOD_XS_Tipo_de_documento_BUC__mdt.getAll().values();
                if(Boolean.valueOf(Label.SOD_XS_UpsertClientePorIdExternoUnico)){
                    for(SOD_XS_Tipo_de_documento_BUC__mdt tdd : tddList){
                        if(tdd.SOD_XS_Pais__c == acc.country && tdd.Label == acc.documentType){
                            newAccount.SOD_XS_IdExternoUnico__c = tdd.SOD_XS_CodigoPais__c + '_' + tdd.SOD_XS_CodigoDocumento__c + '_' + acc.documentNumber.trim();
                            break;
                        }
                    }
                    try{
                        upsert newAccount SOD_XS_IdExternoUnico__c;
                    }
                    catch(System.DmlException de){
                        boolean repeat = true; 
                        integer cnt = 0;
                        while (repeat && cnt < 15)
                        {
                            try
                            {  
                                repeat = false;
                                accQuery = [SELECT Id FROM Account WHERE SOD_XS_IdExternoUnico__c =: newAccount.SOD_XS_IdExternoUnico__c FOR UPDATE];
                                if(!accQuery.isEmpty()){
                                    newAccount.Id = accQuery[0].Id;
                                }
                                else
                                {
                                    resp.errorCode = mdt[0].SOD_XS_CodError__c;
			                        resp.errorMessage = mdt[0].SOD_XS_Field1__c+' '+de.getMessage();
                                    return resp;
                                }
                            }
                            catch (System.DmlException e)
                            {
                                repeat = true; cnt++;
                            }
                            catch(System.QueryException qe){
                                repeat = true; cnt++;
                            }
                        }
                    }
                    
                } else {
                    upsert newAccount;
                }
                resp.caseId = newAccount.Id;
            }

			return resp;

		}catch(Exception a){
            //En caso de Excepción, el objeto de salida devuelve solo errores
			resp.errorCode = mdt[0].SOD_XS_CodError__c;
			resp.errorMessage = mdt[0].SOD_XS_Field1__c+' '+a.getMessage();
            return resp;
		}
	}
    
    //Método para buscar el Contacto de un Person Account
    public static Id getContact(Id accountId){
        List<Contact> ctc = [SELECT Id FROM Contact WHERE AccountId = :accountId];
        Id contactId;
        if(ctc.size()>0 && String.isNotBlank(Id.valueOf(ctc[0].id))){
            contactId = ctc[0].id;
        }
        return contactId;
    }

    //Método para la creación de un contacto en el caso de Cliente Empresa
	public static SOD_XS_CaseCreationResponseWrapper contactCreation(SOD_XS_CaseCreationRequestWrapper.Contact ctc, Id accountId){
        
        //Start Get metadata values to control errors        
        SOD_XS_Case_FCORP__mdt[] mdt = [SELECT MasterLabel,SOD_XS_CodError__c,SOD_XS_Field1__c FROM SOD_XS_Case_FCORP__mdt MasterLabel Where MasterLabel =: 'Record03'];
        //End Get metadata values to control errors
        
		Contact newContact = new Contact();
		SOD_XS_CaseCreationResponseWrapper resp = new SOD_XS_CaseCreationResponseWrapper('','','','');
		try{
			newContact.FirstName = ctc.contactName;
            newContact.LastName = ctc.contactLastName;
			newContact.Email = ctc.email;
			newContact.MobilePhone = ctc.phone;
			newContact.AccountId = accountId;
			
            //Obtener el Id del Contact en caso de que existe
            List<Contact> ctcQuery = [SELECT Id FROM Contact WHERE FirstName = :ctc.contactName AND LastName = :ctc.contactLastName AND AccountId  = :accountId];
            if(ctcQuery.size() > 0 && String.isNotBlank(Id.valueOf(ctcQuery[0].Id))){
                newContact.Id = ctcQuery[0].Id;
            }
            
			upsert newContact;
			resp.caseId = newContact.Id;
			return resp;
		}catch(Exception b){
			resp.errorCode = mdt[0].SOD_XS_CodError__c;
			resp.errorMessage = mdt[0].SOD_XS_Field1__c+' '+b.getMessage();
            return resp;
		}
	}

    //Método que permite validación de campos obligatorios
	public static Map<String,String> validationMethod(SOD_XS_CaseCreationRequestWrapper req){
        
        //Start Get metadata values to control errors        
        Integer codError;
        SOD_XS_Case_FCORP__mdt[] mdt = [SELECT MasterLabel,SOD_XS_CodError__c,SOD_XS_Field1__c FROM SOD_XS_Case_FCORP__mdt MasterLabel];
        Map<String, String> m = new Map<String, String>();
        Map<String, String> m2 = new Map<String, String>();
        for(integer i=0; i<mdt.size(); i++) {
            m.put(mdt[i].SOD_XS_CodError__c,mdt[i].SOD_XS_CodError__c);
            m2.put(mdt[i].SOD_XS_CodError__c,mdt[i].SOD_XS_Field1__c);
        }          
        Integer Error;
        String field1;
        //End Get metadata values to control errors
        
		Map<String,String> valid = new Map<String,String>();
		Boolean flag = true;
        
		if(String.isBlank(req.Cases.area) && flag == true){
			flag = false;
            Error = m.containsKey('4') ? Integer.valueOf(m.get('4')) : 0;
            field1 = m2.containsKey('4') ? m2.get('4') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
		}

		if(String.isBlank(req.Cases.reason) && flag == true){
			flag = false;
            Error = m.containsKey('5') ? Integer.valueOf(m.get('5')) : 0;
            field1 = m2.containsKey('5') ? m2.get('5') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
		}

		if(String.isBlank(req.Cases.recordType) && flag == true){
			flag = false;
            Error = m.containsKey('6') ? Integer.valueOf(m.get('6')) : 0;
            field1 = m2.containsKey('6') ? m2.get('6') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
		}

		if(String.isBlank(req.Cases.store) && flag == true){
			flag = false;
            Error = m.containsKey('7') ? Integer.valueOf(m.get('7')) : 0;
            field1 = m2.containsKey('7') ? m2.get('7') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
		}

		if(String.isBlank(req.Cases.origin) && flag == true){
			flag = false;
            Error = m.containsKey('8') ? Integer.valueOf(m.get('8')) : 0;
            field1 = m2.containsKey('8') ? m2.get('8') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
		}

		if(String.isBlank(req.Cases.description) && flag == true){
			flag = false;
            Error = m.containsKey('9') ? Integer.valueOf(m.get('9')) : 0;
            field1 = m2.containsKey('9') ? m2.get('9') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
		}
        
        if(String.isBlank(req.Account.recordType) && flag == true){
            flag = false;
            Error = m.containsKey('10') ? Integer.valueOf(m.get('10')) : 0;
            field1 = m2.containsKey('10') ? m2.get('10') : '';
            codError = Error;            
			valid.put(String.valueOf(Error), field1);
        }
        else{
            if(flag == true){
                List<RecordType> accRt = [SELECT Id FROM RecordType WHERE DeveloperName = :req.Account.recordType AND SobjectType = 'Account'];
                if(accRt.size() <= 0){
                    flag = false;
                    Error = m.containsKey('11') ? Integer.valueOf(m.get('11')) : 0;
                    field1 = m2.containsKey('11') ? m2.get('11') : '';
                    codError = Error;            
                    valid.put(String.valueOf(Error), field1);
                }
                else{
                    if(req.Account.recordType == 'PersonAccount' && (String.isBlank(req.Account.accountName) || String.isBlank(req.Account.accountLastName) /*|| String.isBlank(req.Account.documentType) || String.isBlank(req.Account.documentNumber)*/)){
                        flag = false;
                        Error = m.containsKey('12') ? Integer.valueOf(m.get('12')) : 0;
                        field1 = m2.containsKey('12') ? m2.get('12') : '';
                        codError = Error;            
                        valid.put(String.valueOf(Error), field1);
                    }
                    
                    if(req.Account.recordType == 'Business_Account' && (String.isBlank(req.Account.companyName) || String.isBlank(req.Account.documentType) || String.isBlank(req.Account.documentNumber))){
                    	flag = false;
                        Error = m.containsKey('13') ? Integer.valueOf(m.get('13')) : 0;
                        field1 = m2.containsKey('13') ? m2.get('13') : '';
                        codError = Error;            
                        valid.put(String.valueOf(Error), field1);
                    }
                }
            }
        }

        //Si el request cumple con todas las validaciones se retorna código error 0
		if(flag == true){ 
            //Start Get metadata values to control errors        
            SOD_XS_Case_FCORP__mdt[] mdt2 = [SELECT MasterLabel,SOD_XS_CodError__c,SOD_XS_Field1__c FROM SOD_XS_Case_FCORP__mdt MasterLabel Where MasterLabel =: 'Record00'];
            //End Get metadata values to control errors
			valid.put(mdt2[0].SOD_XS_CodError__c, mdt2[0].SOD_XS_Field1__c);
		}

		return valid;
	}
    
    //Método para la creación de un caso
	public static SOD_XS_CaseCreationResponseWrapper caseCreationMethod(SOD_XS_CaseCreationRequestWrapper req) {
        
        //Start Get metadata values to control errors        
        Integer codError;
        SOD_XS_Case_FCORP__mdt[] mdt = [SELECT MasterLabel,SOD_XS_CodError__c,SOD_XS_Field1__c FROM SOD_XS_Case_FCORP__mdt MasterLabel];
        Map<String, String> m = new Map<String, String>();
        Map<String, String> m2 = new Map<String, String>();
        for(integer i=0; i<mdt.size(); i++) {
            m.put(mdt[i].SOD_XS_CodError__c,mdt[i].SOD_XS_CodError__c);
            m2.put(mdt[i].SOD_XS_CodError__c,mdt[i].SOD_XS_Field1__c);
        }          
        Integer Error;
        String field1;
        //End Get metadata values to control errors
        
		Case c = new Case();
		SOD_XS_CaseCreationResponseWrapper ccrp = new SOD_XS_CaseCreationResponseWrapper('','','','');
		SOD_XS_CaseCreationResponseWrapper ctrp;
		SOD_XS_CaseCreationResponseWrapper acrp;
		Map<String,String> mp = new Map<String, String>();
        List<SOD_XS_ProductoDelCaso__c> productList;

		Id accountId, contactId;
		String errorCode, errorMessage, countryStoreId;
        
		try{
            //Se invoca el método para validación de datos obligatorios
            mp = validationMethod(req);
            for(String st : mp.keySet()){
                errorCode = st;
                errorMessage = mp.get(st);
            }
            
            //Se valida que el código de error de verificación sea 0 (Sin errores)
            if(String.isNotBlank(mp.get('0'))){
                if(req.Cases.Recontacts != null && req.Cases.Recontacts.size() > 0 && SOD_XS_EnUtility.isFeatureAvailable('SOD_XS_Integracion_Fcom_Recontactos')){
                    // rvalenciat: CREC-4024 Recontacto F.com --> Sodimac
                    // Caso tiene uno o mas Recontactos
                    List<SOD_XS_CaseCreationRequestWrapper.Recontact> caseRecontactos = req.Cases.Recontacts;
                    List<Case> caseList = [SELECT Id, CaseNumber, Status, OwnerId, LastModifiedById, SOD_XS_IdExterno__c, SOD_XS_ActualizacionPorIntegracion__c FROM Case WHERE SOD_XS_IdExterno__c = :req.Cases.externalNumber];
                    if(caseList != null && caseList.size() > 0) {
                        Integer i = 0;
                        if(Test.isRunningTest()){
                            Case cas = caseList[0];
                            cas.SOD_XS_ActualizacionPorIntegracion__c = true;
                            cas.Status = 'Closed';
                            update cas;
                        }

                        // Determinar cual es Recontacto mas reciente en el llamado
                        if(caseRecontactos.size() > 1){
                            i = getNewestRecontacto(caseRecontactos);
                        } 
                        SOD_XS_CaseCreationRequestWrapper.Recontact recontacto = caseRecontactos[i];
                        // Insertar el Recontacto mas reciente
                        List<SOD_XS_ReContacto__c> recontactoList = new List<SOD_XS_ReContacto__c>();
                            SOD_XS_ReContacto__c r = new SOD_XS_ReContacto__c();
                            r.SOD_XS_Caso__c = caseList[0].Id;
                            r.SOD_XS_Comentario__c = recontacto.comments;
                            r.SOD_XS_CanalDeOrigen__c = recontacto.origin;
                            r.RecordTypeId = SOD_XS_EnUtility.getRecordTypeID('SOD_XS_ReContacto__c', recontacto.type); // convert to RecordType Id
                            recontactoList.add(r);
                        //insert recontactoList;
                        Database.SaveResult[] srList = Database.insert(recontactoList, true);
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                                // Actualizar Caso para Reaperturas
                                if(recontacto.type != null && recontacto.type == 'SOD_XS_Inconformidad'){
                                    Case cas = caseList[0];
                                    cas.Status = 'New';
                                    update cas;
                                }
                            }
                        }
                        //Se genera la salida del servicio            
                        ccrp.caseId = caseList[0].Id;
                        ccrp.caseNumber = caseList[0].CaseNumber;
                        ccrp.errorCode = '0';
                        ccrp.errorMessage = SUCCESS_MSG_RECONTACT_INSERT;
                    }
                } else {
                    //Se invoca método para crear o actualizar un cliente
                    acrp =  accountCreation(req.Account); 
                    //Se valida que el Id del cliente no sea nulo
                    if(acrp != null && String.isNotBlank(acrp.caseId)){
                        accountId = acrp.caseId;
                        
                        if(req.Account.recordType == 'PersonAccount'){
                            //Se obtiene el Id del Contacto para el cliente insertado
                            contactId = getContact(accountId);
                        }
                        
                        if(req.Account.recordType == 'Business_Account'){
                            //Si es cliente Empresa, se procede a crear el contacto
                            ctrp = contactCreation(req.Contact, accountId);
                            if(String.isNotBlank(ctrp.caseId)){
                                contactId = ctrp.caseId;
                            }
                        }
                        //Se valida que el Id del Contacto no sea nulo
                        if(String.isNotBlank(contactId)){
                            c.SOD_XS_Area__c = req.Cases.area;
                            c.SOD_XS_Motivo__c = req.Cases.reason;
                            c.SOD_XS_Submotivo__c = req.Cases.secondReason;
                            c.Origin = req.Cases.origin;
                            c.Priority = req.Cases.priority;
                            c.Subject = req.Cases.subject;
                            c.Description = req.Cases.description;
                            c.SOD_XS_FormadePago__c = req.Cases.paymentMethod;
                            c.SOD_XS_FechaDelIncidente__c = Date.valueOf(req.Cases.issueDate);
                            if(String.isNotEmpty(req.Cases.purchaseDate)){
                                c.SOD_XS_FechaDeCompra__c = Date.valueOf(req.Cases.purchaseDate);
                            }
                            c.SOD_XS_IdExterno__c = req.Cases.externalNumber;
                            c.SOD_XS_IdRegulatorio__c = req.Cases.regulatoryId;  // rvalenciat: CREC-4971 Id Regulatorio F.com --> Sodimac
                            c.AccountId = accountId;
                            c.ContactId = contactId;
                            c.SOD_XS_OrdenDeCompraFcom__c = req.Cases.AssociateDocument?.docNumber; // rvalenciat: Se agrega ODC de Fcom al Caso Sodimac
                            c.SOD_XS_AuxOrdenDeCompra__c = req.Cases.AssociateDocument?.docNumber;
                            c.SOD_XS_AuxCodigoDelProductoAfectado__c = SOD_XS_EnUtility.getStringFromList(getProductCodes(req.Cases.Product), ',');
                            c.CurrencyIsoCode = req.Account.currencyName; // rvalenciat: CREC-5256 Fix divisa del Caso

                            //List<SOD_XS_CentroDeCosto__c> stores = [SELECT id FROM SOD_XS_CentroDeCosto__c WHERE Name =: req.Cases.store];
                            List<SOD_XS_CentroDeCosto__c> stores = Test.isRunningTest() ? [SELECT id FROM SOD_XS_CentroDeCosto__c WHERE Name =: req.Cases.store] : [SELECT id FROM SOD_XS_CentroDeCosto__c WHERE SOD_XS_IdExterno__c =: req.Cases.store];
                            if(stores.size() > 0){
                                if(String.isNotBlank(Id.valueOf(stores[0].id))){
                                    c.SOD_XS_TiendaVende__c = stores[0].id;
                                    //c.SOD_XS_CentroCostoResponsable__c = stores[0].id;
                                }
                            }

                            //List<SOD_XS_CentroDeCosto__c> retailStore = [SELECT id, SOD_XS_Country__c FROM SOD_XS_CentroDeCosto__c WHERE Name =: req.Cases.retailStore];
                            List<SOD_XS_CentroDeCosto__c> retailStore = Test.isRunningTest() ? [SELECT id, SOD_XS_Country__c FROM SOD_XS_CentroDeCosto__c WHERE Name =: req.Cases.retailStore] : [SELECT id, SOD_XS_Country__c FROM SOD_XS_CentroDeCosto__c WHERE SOD_XS_IdExterno__c =: req.Cases.retailStore];
                            if(retailStore.size() > 0){
                                if(String.isNotBlank(Id.valueOf(retailStore[0].id))){
                                    c.SOD_XS_CentroCostoResponsable__c = retailStore[0].id;
                                    countryStoreId = retailStore[0].SOD_XS_Country__c;
                                }
                            }
                            
                            List<RecordType> caseRecordType = [SELECT id FROM RecordType WHERE Name =: req.Cases.recordType];
                            if(caseRecordType.size() > 0){
                                if(String.isNotBlank(Id.valueOf(caseRecordType[0].id))){
                                    c.RecordTypeId = caseRecordType[0].id;
                                }
                            }

                            c.SOD_XS_AuxCompletitudDatosDelCaso__c = 'Inicial';
                            
                            try{
                                insert c;
                            }
                            catch(System.DmlException de){
                                Error = m.containsKey('1') ? Integer.valueOf(m.get('1')) : 0;
                                codError = Error;
                                ccrp.errorCode = String.valueOf(codError);
                                ccrp.errorMessage = de.getMessage();
                                boolean repeat = true; 
                                integer cnt = 0;
                                while (repeat && cnt < 15)
                                {
                                    try
                                    {  
                                        repeat = false;
                                        List<Account> accQuery = [SELECT Id FROM Account WHERE Id =: accountId FOR UPDATE];
                                        if(!accQuery.isEmpty()){
                                            insert c;
                                        }                                        
                                    }
                                    catch (System.DmlException e)
                                    {
                                        repeat = true; cnt++;
                                    }
                                    catch (System.QueryException qe)
                                    {
                                        repeat = true; cnt++;
                                    }
                                }
                            }                            
                            
                            List<Case> newCase = [SELECT caseNumber, SOD_XS_AuxCompletitudDatosDelCaso__c, AccountId FROM Case WHERE Id = :c.Id];
                            // Crear productos y asociarlos al Caso
                            if(newCase.size() > 0 && String.isNotBlank(newCase[0].caseNumber)){
                                // Caso se completa con datos Fcom
                                if(stores.size() > 0){
                                    processOrderAndProductDataFcom(newCase[0], stores[0], req);
                                }

                                // Se llama integracion backend por numero Orden de Compra para obtener los Productos del Caso
                                List<String> productCodes = getProductCodes(req.Cases.Product);
                                String numeroDocumentoAsociado = req.Cases.AssociateDocument?.docNumber;
                                if(numeroDocumentoAsociado != null && !String.isEmpty(numeroDocumentoAsociado)){
                                    SOD_XS_AddProductsToCaseFcom updateJob = new SOD_XS_AddProductsToCaseFcom(newCase[0], numeroDocumentoAsociado, productCodes);
                                    System.enqueueJob(updateJob);
                                }

                                //Se genera la salida del servicio
                                Error = m.containsKey('0') ? Integer.valueOf(m.get('0')) : 0;
                                field1 = m2.containsKey('0') ? m2.get('0') : '';
                                codError = Error;            
                                
                                ccrp.caseId = c.Id;
                                ccrp.caseNumber = newCase[0].caseNumber;
                                ccrp.errorCode = String.valueOf(Error);
                                ccrp.errorMessage = field1;
                            }
                        }
                        else{
                            ccrp.errorCode = ctrp.errorCode;
                            ccrp.errorMessage = ctrp.errorMessage;
                        }
                    }
                    else{
                        ccrp.errorCode = acrp.errorCode;
                        ccrp.errorMessage = acrp.errorMessage;
                    }
                }
            }
            else{
                ccrp.errorCode = errorCode;
                ccrp.errorMessage = errorMessage;
            }
            
            return ccrp;

		}catch(Exception e){
            Error = m.containsKey('1') ? Integer.valueOf(m.get('1')) : 0;
            codError = Error;
			ccrp.errorCode = String.valueOf(codError);
			ccrp.errorMessage = e.getMessage();
			return ccrp;
		}
	}

    // rvalenciat: CREC-4024 Recontacto F.com --> Sodimac
    public static Integer getNewestRecontacto(List<SOD_XS_CaseCreationRequestWrapper.Recontact> caseRecontactos){
        Integer i = 0;
        Datetime newestRecontacto = datetime.valueOf(caseRecontactos[0].createdDate);
            for(Integer j = 0; j < caseRecontactos.size(); j++){
                Datetime recontactoCreatedDate = datetime.valueOf(caseRecontactos[j].createdDate);
                if(newestRecontacto < recontactoCreatedDate){
                    i = j;
                }
            }
        return i;
    }

    // rvalenciat: Obtener Codigos del Producto del Request
    public static List<String> getProductCodes(List<SOD_XS_CaseCreationRequestWrapper.Product> reqProducts){
        List<String> productCodes = new List<String>();
        if(reqProducts != null && !reqProducts.isEmpty()){
            for(Integer i=0; i <= reqProducts.size()-1; i++){
                productCodes.add(String.valueOf(reqProducts[i].productCode));
            }
        }
        return productCodes;
    }

    /**
    *  @Description: Upsert Documento De Venta using data from the Integration request from F.com
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        10/10/2022
    */
    private static SOD_XS_DocumentoDeVenta__c upsertDocumentoDeVenta(Account acc, SOD_XS_CentroDeCosto__c tqv, SOD_XS_CaseCreationRequestWrapper ccrw){
        // Documento De Venta
        SOD_XS_DocumentoDeVenta__c dv = new SOD_XS_DocumentoDeVenta__c();
        if(ccrw.cases.SalesDocument != null && !ccrw.cases.SalesDocument.docNumber.equals('0')){
            dv.SOD_XS_NombreCliente__c = acc.Id;
            dv.Name = ccrw.cases.SalesDocument.docNumber;
            dv.SOD_XS_TipoDeDdocumento__c = ccrw.cases.SalesDocument.docType;
            dv.SOD_XS_CreadoPorIntegracion__c = true;
            dv.SOD_XS_TiendaQueVende__c = tqv.Id;
            dv.CurrencyIsoCode = acc.CurrencyIsoCode;
            dv.SOD_XS_PaisDocumento__c = acc.SOD_XS_Country__r.SOD_XS_Codigo__c;
            dv.SOD_XS_IdExterno__c = acc.SOD_XS_Country__r.SOD_XS_Codigo__c.toUpperCase() + '_' + dv.SOD_XS_TipoDeDdocumento__c.toUpperCase() + '_' + dv.Name;
            upsert dv SOD_XS_IdExterno__c;
        }
        return dv;
    }

    /**
    *  @Description: Upsert Documento Asociado using data from the Integration request from F.com
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        10/10/2022
    */
    private static SOD_XS_DocumentoAsociado__c upsertDocumentoAsociado(Account acc, SOD_XS_DocumentoDeVenta__c dv, SOD_XS_CaseCreationRequestWrapper ccrw){
        // Documento Asociado
        SOD_XS_DocumentoAsociado__c da = new SOD_XS_DocumentoAsociado__c();
        if(ccrw.cases.AssociateDocument != null){
            da.SOD_XS_NombreCliente__c = acc.Id;
            da.Name = ccrw.cases.AssociateDocument.docNumber;
            da.SOD_XS_TipoDeDdocumento__c = ccrw.cases.AssociateDocument.docType;
            da.RecordTypeId = SOD_XS_EnUtility.getRecordTypeID('SOD_XS_DocumentoAsociado__c', 'SOD_XS_' + da.SOD_XS_TipoDeDdocumento__c);
            da.SOD_XS_DocumentoDeVenta__c = dv?.Id;
            da.SOD_XS_CreadoPorIntegracion__c = true;
            da.CurrencyIsoCode = acc.CurrencyIsoCode;
            da.SOD_XS_PaisDocumento__c = acc.SOD_XS_Country__r.SOD_XS_Codigo__c;
            da.SOD_XS_IdExterno__c = acc.SOD_XS_Country__r.SOD_XS_Codigo__c.toUpperCase() + '_' + da.SOD_XS_TipoDeDdocumento__c.toUpperCase() + '_' + da.Name;
            upsert da SOD_XS_IdExterno__c;
        }
        return da;
    }

    /**
    *  @Description: Upsert Product 2 using data from the Integration request from F.com
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        10/10/2022
    */
    public static Map<String, Product2> upsertProductos(Account acc, SOD_XS_CaseCreationRequestWrapper ccrw){
        Map<String, Product2> mapNewProduct2 = new Map<String, Product2>();
        List<SOD_XS_CaseCreationRequestWrapper.Product> productos = ccrw.Cases.Product;
        if(productos!= null && !productos.isEmpty()){
            for(SOD_XS_CaseCreationRequestWrapper.Product p : productos){
                // Product 2
                Product2 prd = new Product2();
                prd.Name = p.productCode + '-' + p.productDescription?.left(230);
                prd.Name = prd.Name?.toUpperCase();
                prd.Description = p.productDescription?.toUpperCase();
                prd.SOD_XS_IdExterno__c = acc.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + p.productCode;
                prd.SOD_XS_Country__c = acc.SOD_XS_Country__c;
                prd.CurrencyIsoCode = acc.CurrencyIsoCode;
                prd.SOD_XS_CreadoPorIntegracion__c = true;
                prd.ProductCode = p.productCode;
                prd.StockKeepingUnit = prd.SOD_XS_IdExterno__c;
                prd.SOD_XS_BypassIntegracion__c = true;
                mapNewProduct2.put(p.productCode, prd);                
            }
            upsert mapNewProduct2.values() SOD_XS_IdExterno__c;
        }
        return mapNewProduct2;
    }

    /**
    *  @Description: Upsert Productos Del Caso using data from the Integration request from F.com
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        10/10/2022
    */
    public static void upsertProductosDelCaso(Account acc, Case cas, SOD_XS_DocumentoDeVenta__c dv, SOD_XS_DocumentoAsociado__c da, Map<String, Product2> mapNewProduct2, SOD_XS_CaseCreationRequestWrapper ccrw){
        if(!mapNewProduct2.isEmpty()){
            List<SOD_XS_ProductoDelCaso__c> listCaseProducts = new List<SOD_XS_ProductoDelCaso__c>();
            List<SOD_XS_CaseCreationRequestWrapper.Product> productos = ccrw.Cases.Product;
            for(SOD_XS_CaseCreationRequestWrapper.Product p : productos){
                if(mapNewProduct2.containsKey(p.productCode)){
                    // Producto Del Caso
                    SOD_XS_ProductoDelCaso__c pcase = new SOD_XS_ProductoDelCaso__c();
                    if(Test.isRunningTest()){
                        pcase.SOD_XS_CreadoPorIntegracion__c = true;
                    }
                    pcase.SOD_XS_Producto__c = mapNewProduct2.get(p.productCode).Id;
                    pcase.SOD_XS_CodigoProducto__c = p.productCode;
                    pcase.SOD_XS_NombreCliente__c = acc.Id;
                    pcase.SOD_XS_DocumentoDeVenta__c = dv?.Id;
                    pcase.SOD_XS_DocumentoAsociado__c = da?.Id;
                    pcase.SOD_XS_Country__c = acc.SOD_XS_Country__c;
                    pcase.CurrencyIsoCode = acc.CurrencyIsoCode;
                    pcase.SOD_XS_Cantidad__c = (p.quantity == null || String.isEmpty(p.quantity)) ? null : Decimal.valueOf(p.quantity);
                    pcase.SOD_XS_CantidadAfectada__c = (p.affectedQuantity == null || String.isEmpty(p.affectedQuantity)) ? null : Decimal.valueOf(p.affectedQuantity);
                    pcase.SOD_XS_PrecioUnitario__c = (p.price == null || String.isEmpty(p.price)) ? null : Decimal.valueOf(p.price);
                    pcase.SOD_XS_Caso__c = cas.Id;
                    pcase.SOD_XS_KeepIt__c = false;
                    pcase.SOD_XS_IdExterno__c = acc.SOD_XS_Country__r?.SOD_XS_Codigo__c?.toUpperCase() + '_' + p.productCode + '_' + pcase.SOD_XS_Caso__c;
                    listCaseProducts.add(pcase);
                }
            }
            upsert listCaseProducts SOD_XS_IdExterno__c;
        }
    }

    /**
    *  @Description: Process and save to records the Order and Products linked to the Case using data from the Integration request from F.com
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        10/10/2022
    */
    public static void processOrderAndProductDataFcom(Case cas, SOD_XS_CentroDeCosto__c tqv, SOD_XS_CaseCreationRequestWrapper ccrw) {
        if(cas != null){
            // Retrieve account from Case
            Account acc = SOD_XS_360ViewPurchasesController.getRecord(cas.AccountId);
            if(acc != null){
                if(tqv != null){
                    // Documento De Venta
                    SOD_XS_DocumentoDeVenta__c dv = upsertDocumentoDeVenta(acc, tqv, ccrw);
                    // Documento Asociado
                    SOD_XS_DocumentoAsociado__c da = upsertDocumentoAsociado(acc, dv, ccrw);
                    cas.SOD_XS_DocumentoDeVenta__c = dv?.Id;
                    cas.SOD_XS_DocumentoAsociado__c = da?.Id;
                    cas.SOD_XS_AuxCompletitudDatosDelCaso__c = 'Parcial';
                    update cas;
                    // Product 2
                    Map<String, Product2> mapNewProduct2 = upsertProductos(acc, ccrw);
                    if(!mapNewProduct2.isEmpty()){
                        // Productos del Caso
                        upsertProductosDelCaso(acc, cas, dv, da, mapNewProduct2, ccrw);
                    }
                }
            }
        }
    }
}