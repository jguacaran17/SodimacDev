/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 02/01/2020
Description  : Class responsible to the Rest Connection Test
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			02/01/2020		   Created Class
1.1      LMG        28/01/2021         Optimize test class
********************************************************************************/

@isTest
public class SOD_XS_JWTRestConnection_TEST {
    
    public static SOD_XS_JWTRestConnection conn {get; set;}
    public static String body {get; set;}
    public static Map<String, Map<String, String>> setConf {get; set;}
    public static final string APP_JSON = SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON;
    public static final string BUSCAR_CLIENTES = Label.SOD_XS_Buscar_Clientes;
    public static final string ContryCode = 'PE';
    
    @testSetup static void setup(){

    }
    
    /**
*  @Description: create JWT Rest Connection
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    public static void createJWTRestConnection() {
        body ='{"Test": "Test"}';
        Map<String, String> mapClaims = new Map<String, String>();
        mapClaims.put('Param1', 'Test');       
        Map<String, String> headerParam = new Map<String, String>();
        headerParam.put('X-country','PE');
        headerParam.put('X-commerce','1');
        headerParam.put('X-chRef','WEB');
        headerParam.put('X-rhsRef','1');
        headerParam.put('X-cmRef','1');
        headerParam.put('X-txRef','1');
        headerParam.put('X-prRef','1');
        headerParam.put('X-usrTx','1');
        headerParam.put('content-type',APP_JSON);
        headerParam.put('Authorization','');
        
        Map<String, String> pathParam = new Map<String, String>();
        pathParam.put('customerId','40330507');
        pathParam.put('360View','360View');
        
        Map<String, String> queryParam = new Map<String, String>();
        queryParam.put('fields','id,reservations');
        queryParam.put('pageSize','3');
        queryParam.put('pageNumber','1');
        
        setConf = new Map<String, Map<String, String>>();
        setConf.put('header',headerParam);
        setConf.put('path',pathParam);
        setConf.put('query',queryParam);
    }
    /**
*  @Description: Test 200 response
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test200() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(BUSCAR_CLIENTES,APP_JSON, 200, 'It Worked'));
        Test.startTest();

        HTTPResponse response= conn.callService (setConf, body);
        System.assertEquals(response.getBody(), 'It Worked');
        Test.stopTest();
    }
    
    /**
*  @Description: Test 500 response
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test500() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(BUSCAR_CLIENTES,APP_JSON, 500, 'Unexpected error...'));
        Test.startTest();
        try {
            HTTPResponse response = conn.callService (setConf, body);
        } catch(Exception e) {

        }
        Test.stopTest();
    }
    /**
*  @Description: Test 2 500 response
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test500_2() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(Label.SOD_XS_Actualizar_Cliente, APP_JSON, 500, 'Unexpected error...'));
        Test.startTest();
        try {
            HTTPResponse response = conn.callService (setConf, body);
        } catch(Exception e) {
            
        }
        Test.stopTest();
    }
    /**
*  @Description: Test 204 response
*  @Autor:       MR, Deloitte, mreisg@de
loitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test204() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(BUSCAR_CLIENTES,APP_JSON, 204, Label.SOD_XS_ERROR204));
        Test.startTest();
        try {
            HTTPResponse response = conn.callService (setConf, body);
        } catch(Exception e) {
            System.assertEquals(e.getMessage(),  Label.SOD_XS_ERROR204);
        }
        Test.stopTest();
    }
    /**
*  @Description: Test 400 response
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test400() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(BUSCAR_CLIENTES,APP_JSON, 400, Label.SOD_XS_ERROR400));
        Test.startTest();
        try {
            HTTPResponse response = conn.callService (setConf, body);
        } catch(Exception e) {
            System.assertEquals(e.getMessage(),  Label.SOD_XS_ERROR400);
        }
        Test.stopTest();
    }
    /**
*  @Description: Test 401 response
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test401() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(BUSCAR_CLIENTES,APP_JSON, 401, Label.SOD_XS_ERROR401));
        Test.startTest();
        try {
            HTTPResponse response = conn.callService (setConf, body);
        } catch(Exception e) {
            System.assertEquals(e.getMessage(),  Label.SOD_XS_ERROR401);
        }
        Test.stopTest();
    }
    /**
*  @Description: Test 404 response
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void test404() {
        createJWTRestConnection();
        conn = new SOD_XS_JWTRestConnection(ContryCode,BUSCAR_CLIENTES);
        Test.setMock(httpcalloutmock.class, new SOD_XS_JWTRestMock_TEST(BUSCAR_CLIENTES,APP_JSON, 404, Label.SOD_XS_ERROR404));
        Test.startTest();
        try {
            HTTPResponse response = conn.callService (setConf, body);
        } catch(Exception e) {
            System.assertEquals(e.getMessage(),  Label.SOD_XS_ERROR404);
        }
        Test.stopTest();
    }
    /**
*  @Description: Test JWT Auth HS256
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void jWTAuthHS256 (){
        Test.startTest();
        SOD_XS_JWTAuthentication jwt= new SOD_XS_JWTAuthentication('HS256');
        jwt.sub='1';
        jwt.aud ='1';
        jwt.exp ='1';
        jwt.pkcs8 ='VGVzdGluZyBTZXJ2aWNlIDEyMw==';
        jwt.iss='VGVzdGluZyBTZXJ2aWNlIDEyMw==';
        jwt.privateKey='VGVzdGluZyBTZXJ2aWNlIDEyMw==';
        jwt.iat ='10';
        Map<String,String> claims =new Map<String, String> {'name'=>'name'};
            jwt.claims =claims;
        jwt.issue();
        Test.stopTest();
    }
    /**
*  @Description: Test JWT Auth RS256
*  @Autor:       MR, Deloitte, mreisg@deloitte.com
*  @Date:        02/01/2020
*/    
    @isTest static void jWTAuthRS256 (){
        Test.startTest();
        try{
            SOD_XS_JWTAuthentication jwt= new SOD_XS_JWTAuthentication('RS256');
            jwt.sub='1';
            jwt.aud ='1';
            jwt.exp ='1';
            jwt.cert='MIICWwIBAAKBgQDSGCsr4MYyEtIXteD7iqq0Bdkbu4oE2IcBpP9XwkMoeSmTY2Su'
                +'kpzDjXuNQhAPFcPe1i+um2uafjmLE/mvxkkIvKmAboB5KfTFSk48mtg3hF09Xokb'
                +'1/upNmyl3qGaL/D9WZYDpIE5JydFrQ2oayvIrrHHrArp4Qk+Ugageq6LAwIDAQAB'
                +'AoGAAiDsjw0/9NHr/wGAvguxnxFQGc/UnifzdjjNvX3iYE6Z9TxUkNA7dl/AmLXK'
                +'o9x8l41j/kjk1jPhMV+KcBV6N++6roGQlf+rJxGB/swwyLBTPJsxS6pq6XajxnTO'
                +'GlgWjE0NJtJOciC/13u/XASfhVn979UJompCD9LnWouL3gECQQD6v879cgDzDRYA'
                +'coMGaQHLzBoM9OTnW/8qWx5kl4WHCCVzfKuU6DVYI3LCKTAdFDIa+VD9var5icx9'
                +'JxcvDmkjAkEA1n5r8vLg+9vVlo5/rUU7dkhMBUeL3qqBWj3UXIXIP7K3qu/BIyhE'
                +'49iNrabfoxbTrjY32OrCB7MTYxHeieykoQJAMDdV3BJh8Fqh0nAylbb3a3LRx5AH'
                +'vB1KkaB31av1NyPv36cnbzi/mTUnygIViGHryJgMZN5l1BoVQjOUF65TtQJAIjYV'
                +'17E/i0xb++CMosFZI5uSbIEl4QUHDrKv7XX1I5vIyb3l60qf+ktvBZSJNQUODEpf'
                +'i/ydqAa6/+E4wnz5IQJANP9smh+OGgF5l+/VXJ74dMH2RMB9ZumjzCt2tnG4a6w+'
                +'OLJQ76H/xaejS8pdrKiiKPdIRKOadyV/fCPyoE37kg==';
            jwt.pkcs8 ='VGVzdGluZyBTZXJ2aWNlIDEyMw==';
            jwt.iss='VGVzdGluZyBTZXJ2aWNlIDEyMw==';
            jwt.privateKey='VGVzdGluZyBTZXJ2aWNlIDEyMw==';
            jwt.iat ='10';
            Map<String,String> claims =new Map<String, String> {'name'=>'name'};
            jwt.claims =claims;
            jwt.issue();
        }catch (Exception e){
            System.assert(e.getMessage().contains('Error retrieving certificate details from cert name: '));
        }
        Test.stopTest();
    }
}