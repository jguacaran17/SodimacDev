/*
**************************************************************
Created By: Francisco Gaitan (FTC)
Date: 19/03/2021
Class Name: SOD_XS_FCORP_MockClass
Comments: Class created for APEX SOD_XS_FCORP_TriggerHandlerTest
Last Modified: 24/03/2021 By Francisco Gaitan
**************************************************************
*/
@isTest
global class SOD_XS_FCORP_MockClass implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"caso": {"id":"00394853"}}');
        response.setStatusCode(200);
        return response; 
    }
}