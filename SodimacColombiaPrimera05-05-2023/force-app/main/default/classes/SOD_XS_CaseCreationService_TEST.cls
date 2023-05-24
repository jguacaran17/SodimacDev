/*
****************************************************************
Created By: David Palma (FTC)
Date: 02/03/2021
Class Name: SOD_XS_CaseCreationServiceTest
Comments: Class created for APEX Rest Case Creation Service Test
Last Modified: 
03/02/2023 By Johan Martínez: Ajustes para cobertura de código
****************************************************************
*/

@isTest
public class SOD_XS_CaseCreationService_TEST {
    //Caso exitoso Cliente Persona
    static testMethod void ExecutePA(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createPersonAccount(0);
                obj.Cases = createCase(0);

                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                
                createStore(obj.Cases.store, country);
                createStore(obj.Cases.retailStore, country);
                createProduct2('101', 'Producto 101', country);
                createProduct2('102', 'Producto 102', country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.debug(json.substring(1000));
                System.assertEquals(200, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }

    private static RestResponse callService(Integer accParam, Integer casParam){
        Id country, region, province, commune;
        SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
        obj.Account = createPersonAccount(accParam);
        obj.Cases = createCase(casParam);

        country = createCountry(obj.Account.country);
        region = createRegion(obj.Account.region, country);
        province = createProvince(obj.Account.province, region);
        commune = createCommune(obj.Account.commune, province);
        
        createStore(obj.Cases.store, country);
		createProduct2('101', 'Producto 101', country);

        String json = JSON.serialize(obj);
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();
        req.requestURI = '/services/apexrest/Case/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
        RestContext.request = req;
        RestContext.response = resp;

        SOD_XS_CaseCreationService.doPost();

        return resp;
    }
    static testMethod void ExecutePACaseWithRecontact(){
        //Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                callService(0, 0);
                RestResponse resp = callService(0, -1);
                //System.debug(json.substring(1000));
                System.assertEquals(200, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }

    //Caso con error - Area faltante
    static testMethod void ExecuteErrorArea(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(3);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
        
    }
    
    //Caso con error - Reason faltante
    static testMethod void ExecuteErrorReason(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(4);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Caso con error - Record Type faltante
    static testMethod void ExecuteErrorRT(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(5);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Caso con error - Store faltante
    static testMethod void ExecuteErrorStore(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(6);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                //createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Caso sin error y con tienda
    static testMethod void ExecuteSuccessStore(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(6);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                obj.Cases.store = 'SHC 023 - San Bernardo';
                createStore(obj.Cases.store, country);
                createProduct2('101', 'Producto 101', country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(200, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Caso con error - Origin faltante
    static testMethod void ExecuteErrorOrigin(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(7);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Caso con error - Description faltante
    static testMethod void ExecuteErrorDesc(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(0);
                obj.Contact = createContact();
                obj.Cases = createCase(8);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }

    //Caso con error - Sin Cuenta ni contacto
    static testMethod void ExecuteErrorNoAccCont(){
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Cases = createCase(0);
                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }

    //Account con error - Datos obligatorios Person Account
    static testMethod void ExecuteErrorDatosPA(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createPersonAccount(11);
                obj.Contact = createContact();
                obj.Cases = createCase(0);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Account con error - Datos obligatorios Business Account
    static testMethod void ExecuteErrorDatosBA(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(12);
                obj.Contact = createContact();
                obj.Cases = createCase(0);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Account con error - Error en Record Type
    static testMethod void ExecuteErrorRTAccount(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createBusinessAccount(10);
                System.debug(obj);
                obj.Contact = createContact();
                obj.Cases = createCase(0);
                //createStore(obj.Cases.store);
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                createStore(obj.Cases.store, country);
                
                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Account con error - Record Type Vacío
    static testMethod void ExecuteErrorRTAccountEmpty(){
        Id country, region, province, commune;
        User u1 = createUser();
        System.runAs(u1){
            try{
                Test.startTest();
                SOD_XS_CaseCreationRequestWrapper obj = new SOD_XS_CaseCreationRequestWrapper();
                obj.Account = createPersonAccount(15);
                obj.Contact = createContact();
                obj.Cases = createCase(0);
                
                country = createCountry(obj.Account.country);
                region = createRegion(obj.Account.region, country);
                province = createProvince(obj.Account.province, region);
                commune = createCommune(obj.Account.commune, province);
                
                createStore(obj.Cases.store, country);

                String json = JSON.serialize(obj);
                RestRequest req = new RestRequest();
                RestResponse resp = new RestResponse();
                req.requestURI = '/services/apexrest/Case/';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueOf(json);
                RestContext.request = req;
                RestContext.response= resp;
    
                SOD_XS_CaseCreationService.doPost();
                System.assertEquals(400, resp.statusCode);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba: '+e.getMessage());
            }
        }
    }
    
    //Método para crear el request de un PersonAccount
    public static SOD_XS_CaseCreationRequestWrapper.Account createPersonAccount(Integer option){
        SOD_XS_CaseCreationRequestWrapper.Account acc = new SOD_XS_CaseCreationRequestWrapper.Account();
        if(option != 11){
            acc.accountName = 'Person';
            acc.accountLastName = 'Account';
        }
        
        if(option != 10){
            if(option == 15){
                acc.recordType = '';
            }
            else{
                acc.recordType = 'PersonAccount';
            }
        }
        else{
            acc.recordType = 'PersonAccount1';
        }
        
        acc.documentType = 'RUT';
        acc.documentNumber = '11111111-1';
        acc.currencyName = 'CLP';
        acc.country = 'Chile';
        acc.region = 'Region Metropolitana';
        acc.province = 'Santiago';
        acc.commune = 'Santiago';
        acc.address = 'Dirección Prueba 123';
        acc.personEmail = 'prueba@prueba.com';
        acc.mobilePhone = '123456789';
        return acc;
    }
    
    //Método para insertar un Person Account
    public static void insertPersonAccount(){
        Id country, region, province, commune;
        List<RecordType> a = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount'];
        Account newAccount = new Account();
        newAccount.FirstName = 'Person';
        newAccount.LastName = 'Account';
        newAccount.RecordTypeId = a[0].Id;
        newAccount.SOD_XS_TipoDocumento__c = 'RUT';
        newAccount.SOD_XS_NroDocumento__c = '11111111-1';
        newAccount.CurrencyIsoCode = 'CLP';
        newAccount.SOD_XS_Country__c = createCountry('Chile');
        newAccount.SOD_XS_AdministrativeArea__c = createRegion('Region Metropolitana',newAccount.SOD_XS_Country__c);
        newAccount.SOD_XS_Locality__c = createProvince('Santiago',newAccount.SOD_XS_AdministrativeArea__c);
        newAccount.SOD_XS_SubAdministrativeArea__c = createCommune('Santiago',newAccount.SOD_XS_Locality__c);
        newAccount.SOD_XS_Direccion__c = 'Dirección Prueba 123';
        newAccount.PersonEmail = 'prueba@prueba.com';
        newAccount.PersonMobilePhone = '123456789';
        insert newAccount;
    }
    
    //Método para crear el request de un Business Account
    public static SOD_XS_CaseCreationRequestWrapper.Account createBusinessAccount(Integer option){
        SOD_XS_CaseCreationRequestWrapper.Account acc = new SOD_XS_CaseCreationRequestWrapper.Account();
        if(option != 12){
            acc.companyName = 'Compania SA';
        }
        if(option != 10){
            acc.recordType = 'Business_Account';
        }
        else{
            acc.recordType = 'Business_Account1';
        }
        
        acc.documentType = 'RUT';
        acc.documentNumber = '96060859-3';
        acc.currencyName = 'CLP';
        acc.country = 'Chile';
        acc.region = 'Region Metropolitana';
        acc.province = 'Santiago';
        acc.commune = 'Santiago';
        acc.address = 'Dirección Prueba 123';
        acc.personEmail = 'pruebasa@prueba.com';
        acc.mobilePhone = '123456789';
        return acc;
    }
    
    //Método para crear un Contacto
    public static SOD_XS_CaseCreationRequestWrapper.Contact createContact(){
        SOD_XS_CaseCreationRequestWrapper.Contact ctc = new SOD_XS_CaseCreationRequestWrapper.Contact();
        ctc.contactName = 'Contacto';
        ctc.contactLastName = 'Prueba';
        ctc.email = 'contactTest@prueba.com';
        ctc.phone = '124554353';
        return ctc;
    }
    
    //Método para creación de request de Caso
    public static SOD_XS_CaseCreationRequestWrapper.Cases createCase(Integer option){
        SOD_XS_CaseCreationRequestWrapper.Cases c = new SOD_XS_CaseCreationRequestWrapper.Cases();
        SOD_XS_CaseCreationRequestWrapper.AssociateDocument asDoc = new SOD_XS_CaseCreationRequestWrapper.AssociateDocument();
        SOD_XS_CaseCreationRequestWrapper.SalesDocument salesDoc = new SOD_XS_CaseCreationRequestWrapper.SalesDocument();
        List<SOD_XS_CaseCreationRequestWrapper.Product> product = new List<SOD_XS_CaseCreationRequestWrapper.Product>();
        List<SOD_XS_CaseCreationRequestWrapper.Recontact> recontacts = new List<SOD_XS_CaseCreationRequestWrapper.Recontact>();

        if(option != 3){
            c.area = 'Cajas';
        }
        if(option != 4){
            c.reason = 'Mal Registro Pago de Deuda CMR';
        }
        
        c.secondReason = '';
        if(option != 5){
            c.recordType = 'Reclamo';
        }

        if(option != 6){
            c.store = 'SHC 023 - San Bernardo';
        }
        
        if(option != 7){
            c.origin = 'Web';
        }
        
        c.priority = 'Medium';
        c.subject = 'Asunto de prueba';
        
        if(option != 8){
            c.description = 'Caso de prueba API';
        }

        // rvalenciat: CREC-4024 Recontacto F.com --> Sodimac
        if(option == -1){
            for(Integer i=0; i<2; i++){
                SOD_XS_CaseCreationRequestWrapper.Recontact r = new SOD_XS_CaseCreationRequestWrapper.Recontact();
                r.comments = 'Recontacto de Prueba #'+(i+1);
                r.type = 'SOD_XS_Inconformidad';
                r.origin = 'Web';
                r.createdDate = date.today();
                recontacts.add(r);
            }
            c.Recontacts = recontacts;
        }
        c.externalNumber = '01010122';
        // end

        c.paymentMethod = '';
        c.retailStore = 'F.COM';
        //c.store = 'SHC 023 - San Bernardo';
        c.issueDate = '2021-02-23';
        c.purchaseDate = '2021-02-22';
        asDoc.docNumber = '123456';
        asDoc.docType = 'ODC';
        salesDoc.docNumber = '986373';
        salesDoc.docType = 'boleta';
        c.SalesDocument = salesDoc;
        c.AssociateDocument = asDoc;
        
        for(Integer i=1; i<=2; i++){
            SOD_XS_CaseCreationRequestWrapper.Product prod = new SOD_XS_CaseCreationRequestWrapper.Product();
            prod.productCode = String.valueOf(100+i);
            prod.productDescription = 'Producto '+i;
            prod.quantity = String.valueOf(1);
            prod.affectedQuantity = String.valueOf(1);
            prod.price = String.valueOf(100.0);
            prod.deliveryDate = null;
            prod.deliveryType = null;
            prod.guideNumber = null;
            prod.hours = null;
            prod.lock = null;
            prod.ncr = null;
            prod.originalDeliveryDate = null;
            prod.productStatus = null;
            prod.provider = null;
            prod.reserveAmount = null;
            prod.returnReason = null;
            prod.shipmentDate = null;
            product.add(prod);
        }
        c.Product = product;
        return c;
    }
    
    //Método para insertar un Product2
    public static Id createProduct2(String code, String name, Id country){
        Product2 p = new Product2();
        p.ProductCode = code;
        p.Name = name;
        p.SOD_XS_Country__c = country;
        p.CurrencyIsoCode = 'CLP';
        p.SOD_XS_IdExterno__c = 'CL_' + p.ProductCode;
        p.SOD_XS_CreadoPorIntegracion__c = true;
        p.SOD_XS_BypassIntegracion__c = true;         
        upsert p SOD_XS_IdExterno__c;
        return p.Id;
    }

    //Método para insertar un País
    public static Id createCountry(String country){
        List <SOD_XS_Country__c> p = new List <SOD_XS_Country__c>();
        p = [SELECT Id FROM SOD_XS_Country__c WHERE Name =: country];
        if(p.size() <= 0)
        {
            SOD_XS_Country__c pais = new SOD_XS_Country__c();
            pais.Name = country;
        	if(country == 'Chile'){
           		pais.SOD_XS_Codigo__c = 'CL';
        	}
            insert pais;
            p.add(pais);
        }
        return p[0].Id;
    }
    
    //Método para insertar una Región
    public static Id createRegion(String region, Id country){
        SOD_XS_AdministrativeArea__c r = new SOD_XS_AdministrativeArea__c();
        r.Name = region;
        r.SOD_XS_Country__c = country;
        insert r;
        return r.Id;
    }
    
    //Método para insertar una Provincia
    public static Id createProvince(String province, Id region){
        SOD_XS_Locality__c pr = new SOD_XS_Locality__c();
        pr.Name = province;
        pr.SOD_XS_AdministrativeArea__c = region;
        insert pr;
        return pr.Id;
    }
    
    //Método para insertar una Comuna
    public static Id createCommune(String commune, Id province){
        SOD_XS_SubAdministrativeArea__c cm = new SOD_XS_SubAdministrativeArea__c();
        cm.Name = commune;
        cm.SOD_XS_Locality__c = province;
        insert cm;
        return cm.Id;
    }
    
    //Método para insertar una Tienda
    public static void createStore(String store, Id country){
        if(String.isNotBlank(store)){
            SOD_XS_CentroDeCosto__c tienda = new SOD_XS_CentroDeCosto__c();
            tienda.SOD_XS_NombreCompleto__c = store;
            tienda.Name = store;
            tienda.SOD_XS_Country__c = country;
            if(store.length()>=20){
                store = store.substring(0,19);
            }
            tienda.SOD_XS_NombreCorto__c = store;
            tienda.SOD_XS_TipoDeCC__c = 'TDA';
            insert tienda;
         }
    }
    
    //Método para crear usuario
    public static User createUser() {
        //Se cambia el perfil a System Administrator, ya que el Usuario de Integración tiene este perfil
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  FirstName = 'Test',
                              LastName = 'Test',
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              UserRoleId = portalRole.Id,
                              XS_AreaDelUsuario__c = 'XS_Administracion',
                              XS_CentroDeCosto__c = '123',
                              Country = 'Chile',
                              ProfileId = profile1.Id);
        
        insert tuser;
        User u1 = [SELECT id from User WHERE Id=: tuser.Id LIMIT 1]; 
        return u1;
    }
}