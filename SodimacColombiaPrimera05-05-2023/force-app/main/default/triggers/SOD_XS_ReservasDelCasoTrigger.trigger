/**
* Blandon
* @author           Josue Blandon josue.blandon@intellectsystem.net
* Project:          SODIMAC
* Description:      Trigger para el objeto Reservas Del Caso
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description
*           -----   ----------      --------------------    ---------------
* @version  1.0     2021-29-06      Josue Blandon        Definicion inicial de la clase.
***************************************************************************************************/
trigger SOD_XS_ReservasDelCasoTrigger on SOD_XS_ReservasDelCaso__c (before insert, after insert, before update, after update) {
	new SOD_XS_TriggerHandler(SOD_XS_ReservasDelCaso__c.sObjectType).Run();
}