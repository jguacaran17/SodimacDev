/**
* Deloitte
* @author           Jessica Gómez jgomezr@deloitte.com
* Project:          SODIMAC
* Description:      Trigger para el objeto Casos (Asignación de entitlement)
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2020-14-07      Jessica Gómez        Definicion inicial de la clase.
***************************************************************************************************/
trigger SOD_XS_CaseTrigger on Case (before insert, after insert, before update, after update) {
    if(SOD_XS_Bypass__c.getInstance().SOD_XS_DesactivarTriggers__c) {
            System.debug('Bypassing trigger due to custom setting');
            return;
   		} else { 
        new SOD_XS_TriggerHandler(Case.sObjectType).Run();
	}
}