/*
**********************************************************
Created By: David Palma, 13/04/2021
Class Name: SOD_XS_ApexCalloutFcomCreation
Comment: Clase creada para invocar método que realiza llamado al servicio de creacion de Caso de servicio en Fcom
**********************************************************
*/

public class SOD_XS_ApexCalloutFcomCreation {
	@InvocableMethod
    public static void SOD_XS_ApexCalloutFcomCreation(List<Id> caseList){
        List<Case> c = [SELECT Id FROM Case WHERE Id =:caseList];
        Id jobId = System.enqueueJob(new SOD_XS_ConsumeCreateFcom(c));
    }
}