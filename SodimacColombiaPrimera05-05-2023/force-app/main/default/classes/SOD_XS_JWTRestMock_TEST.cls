/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 02/01/2020
Description  : Class responsible to the Rest Mock
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
Abdon Tejos O.              ATO
Eilhert Andrade A.          EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			02/01/2020		   Created Class
1.1      ATO                           Mock & MultiMock
1.2      ATO        22/04/2020         Dynamic endpoints
1.3      EAA        06/10/2020         Update endpoint
1.4      EAA        07/01/2021         Update endpoint
********************************************************************************/

@isTest
global class SOD_XS_JWTRestMock_TEST implements HttpCalloutMock {
    
    public String service;
    public String contentType;
    public Integer statusCode;
    public String json;
    public static final String PBC_STR_PATH_UPDATE;
    public static final String PBC_STR_PATH_SEARCH;
    public static final String PBC_STR_PATH_CREATE;
    public static final String PBC_STR_PATH_DELETE;
    public static final String PBC_STR_PATH_RESERVE;
    public static final String PBC_STR_PATH_PURCHASEORDERS;
    public static final String PBC_STR_PATH_360VIEW;
    public static final String PBC_STR_PATH_VIEWPRODUCTS;
    public static final String PBC_STR_JSON_SEARCHPERSON_CL;
    public static final String PBC_STR_JSON_SEARCHPERSON_MX;
    public static final String PBC_STR_JSON_SEARCHPERSON_PE;
    public static final String PBC_STR_JSON_SEARCHPERSON_CO;
    public static final String PBC_STR_JSON_CREATEPERSON_CL;
    public static final String PBC_STR_JSON_CREATEPERSON_CO;
    public static final String PBC_STR_JSON_360VIEWLAST10_CL;
    public static final String PBC_STR_JSON_360VIEWLAST1_CL;
    public static final String PBC_STR_JSON_PURCHARSEORDERBYORDERNUM_CL;
    public static final String PBC_STR_JSON_PURCHARSEORDERBYSLSDOC_CL;
    public static final String PBC_STR_JSON_PURCHARSEORDERBYRSVNUM_CL;
    public static final String PBC_STR_JSON_360VIEW_CASE_CL;
    public static final String PBC_STR_JSON_VIEW_PRODUCT_CL;
    public static final String PBC_STR_JSON_SPS_DATERANGE_CL;
    public static final String PBC_STR_JSON_SPS_PROJECTNUMBER_CL;
    public static final String PBC_STR_JSON_SPS_SUBPROJECTNUMBER_CL;
    public static final String PBC_STR_JSON_SPS_SALESDOCUMENT_CL;
    public static final String PBC_STR_JSON_SPS_STOREPROJECT_CL;
    public static final String PBC_STR_CONTENTTYPE;
    public static final String PBC_STR_APPJSON;
    public static final String MAPCOUNTRY;
    
    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    static {
        PBC_STR_PATH_UPDATE = Label.SOD_XS_Actualizar_Cliente;
        PBC_STR_PATH_SEARCH = Label.SOD_XS_Buscar_Clientes;
        PBC_STR_PATH_CREATE = Label.SOD_XS_Crear_Cliente;
        PBC_STR_PATH_DELETE = Label.SOD_XS_Eliminar_Campo;
        PBC_STR_PATH_RESERVE = Label.SOD_XS_Reserva_Cliente;
        PBC_STR_PATH_PURCHASEORDERS = Label.SOD_XS_OrdenCompra;
        PBC_STR_PATH_360VIEW = Label.SOD_XS_HistorialCompra;
        PBC_STR_PATH_VIEWPRODUCTS = Label.SOD_XS_V360PRDProductoCompra;
        MAPCOUNTRY = Label.SOD_XS_URL_Base;
        PBC_STR_JSON_SEARCHPERSON_CL = 'SOD_XS_BuscarClientePersonaCL';
        PBC_STR_JSON_SEARCHPERSON_MX = 'SOD_XS_BuscarClientePersonaMX';
        PBC_STR_JSON_SEARCHPERSON_PE = 'SOD_XS_BuscarClientePersonaPE';
        PBC_STR_JSON_SEARCHPERSON_CO = 'SOD_XS_BuscarClientePersonaCO';
        PBC_STR_JSON_CREATEPERSON_CL = 'SOD_XS_CrearClientePersonaCL';
        PBC_STR_JSON_CREATEPERSON_CO = 'SOD_XS_CrearClientePersonaCO';
        PBC_STR_JSON_360VIEWLAST10_CL = 'SOD_XS_HistorialCompra10CL';
        PBC_STR_JSON_360VIEWLAST1_CL = 'SOD_XS_HistorialCompra1CL';
        PBC_STR_JSON_PURCHARSEORDERBYORDERNUM_CL = 'SOD_XS_OrdenCompraCL';
        PBC_STR_JSON_PURCHARSEORDERBYSLSDOC_CL = 'SOD_XS_OrdenCompraTipoDoc';
        PBC_STR_JSON_PURCHARSEORDERBYRSVNUM_CL = 'SOD_XS_OrdenesCompraNumRsv';
        PBC_STR_JSON_360VIEW_CASE_CL = 'SOD_XS_360View_CasoCLReclamo';
        PBC_STR_JSON_VIEW_PRODUCT_CL = 'SOD_XS_ViewProduct';
        PBC_STR_CONTENTTYPE = 'Content-Type';
        PBC_STR_APPJSON = 'application/json';
        PBC_STR_JSON_SPS_DATERANGE_CL = 'SOD_XS_SPS_RangoDeFecha';
        PBC_STR_JSON_SPS_PROJECTNUMBER_CL = 'SOD_XS_SPS_NumeroProyecto';
        PBC_STR_JSON_SPS_SUBPROJECTNUMBER_CL = 'SOD_XS_SPS_NumeroSubPoyecto';
        PBC_STR_JSON_SPS_SALESDOCUMENT_CL = 'SOD_XS_SPS_DocumentoVenta';
        PBC_STR_JSON_SPS_STOREPROJECT_CL = 'SOD_XS_SPS_GuardarDatosProyecto';
    }
    
    /**
    *  @Description: Constructor for a rest mock 
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/04/2020
    */
    global SOD_XS_JWTRestMock_TEST(final String service, final String contentType, final Integer statusCode, final String json) {
        this.service = service;
        this.contentType = contentType;
        this.statusCode = statusCode;
        this.json = json;
    }
    
    /**
    *  @Description: Consult the parameters of the services
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/04/2020
    */
    public static String endPointJWTRestMockTest(String countryCode, String namePath) {
        namePath = countryCode + ' ' + namePath;        
        SOD_XS_ServicioIntegracion__mdt servicio = [SELECT SOD_XS_Editor_ISS__c, SOD_XS_Llave_Secreta__c, SOD_XS_URLBase__c, MasterLabel FROM SOD_XS_ServicioIntegracion__mdt WHERE MasterLabel =: fillMapServices().get(countryCode) LIMIT 1];
        SOD_XS_RutaIntegracion__mdt path = [SELECT SOD_XS_RutaURL__c, SOD_XS_Metodo__c, SOD_XS_Cabeceras__c, MasterLabel FROM SOD_XS_RutaIntegracion__mdt WHERE MasterLabel =: namePath LIMIT 1];
        
        return servicio.SOD_XS_URLBase__c + path.SOD_XS_RutaURL__c;
    }
    
    /**
    *  @Description: Raises the response to a single service call
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/04/2020
    */
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader(PBC_STR_CONTENTTYPE, contentType);
        response.setBody(json);
        response.setStatusCode(statusCode);
        return response; 
    }
    
    /**
    *  @Description: Raise the answer to several service calls
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/04/2020
    */
    global static void getMultimock(List<String> listEndpoints,List<String> listBody, Integer statusCode) {
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        
        for(Integer i = 0; i<listEndpoints.size() ; i++){
            multimock.setStaticResource(listEndpoints[i], listBody[i]);           
        }
        multimock.setStatusCode(statusCode);
        multimock.setHeader(PBC_STR_CONTENTTYPE, PBC_STR_APPJSON);
        Test.setMock(HttpCalloutMock.class, multimock);
    }
    
    /**
    *  @Description: Get the URL of the services by country
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/04/2020
    */
    public static Map<String, String> fillMapServices() {
        Map<String, String>  str = new Map<String, String>();
        
            String[] splitStr = MAPCOUNTRY.Split(';');
            for (String c : splitStr) {
                str.put(c.Split(':')[0], c.Split(':')[1]);
            }
        
        return str;
    }
    
}