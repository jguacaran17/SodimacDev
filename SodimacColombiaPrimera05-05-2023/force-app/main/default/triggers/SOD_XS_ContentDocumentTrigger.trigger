/**
* Deloitte
* @author           Pablo L�pez / Nelson Lepiqueo
* Project:          SODIMAC
* Description:      Trigger para el objeto ContentDocument
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     16-02-2021      Pablo L�pez        Definicion inicial de la clase.
***************************************************************************************************/
trigger SOD_XS_ContentDocumentTrigger on ContentDocument (before insert, after insert, before update, after update, before delete, after delete) {
    if(SOD_XS_Bypass__c.getInstance().SOD_XS_DesactivarTriggers__c) {
            System.debug('Bypassing trigger due to custom setting');
            return;
        } else { 
        new SOD_XS_TriggerHandler(ContentDocument.sObjectType).Run();
    }
}