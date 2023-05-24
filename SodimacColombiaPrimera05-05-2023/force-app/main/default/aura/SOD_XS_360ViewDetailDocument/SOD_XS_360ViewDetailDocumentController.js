/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 01/02/2021
Description  : Lightning component - 360 view of a client: Detail of a Document
History      : CMRSC-4075
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      RSO			01/02/2021		initial version
********************************************************************************/
({
    
    /**
    *  @Description: Show an Alert in case the reserve has Childs
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        01/02/2021
    */
   doInit: function(component, event, helper) {
       let cmpObject = component.get('v.objDataComponent');
       const localDate = new Date(cmpObject.objSellDoc.SOD_XS_FechaDeCompra__c);
       const localTimeString = localDate.toLocaleTimeString(undefined, {
            hour:   '2-digit',
            minute: '2-digit',
            //second: '2-digit',
        });
        // component.set('v.strTime', localTimeString);
        
        let ms=cmpObject.objSellDoc.SOD_XS_HoraDeEmision__c; 
        var seconds = ms / 1000;
        // 2- Extract hours:
        var hours = parseInt( seconds / 3600 ); // 3,600 seconds in 1 hour
        seconds = seconds % 3600; // seconds remaining after extracting hours
        // 3- Extract minutes:
        var minutes = parseInt( seconds / 60 ); // 60 seconds in 1 minute
        // 4- Keep only seconds not extracted to minutes:
        seconds = seconds % 60;
        let txtHours = hours < 10 ? '0' + String(hours) : String(hours);
        let txtMinutes = minutes < 10 ? '0' + String(minutes) : String(minutes);
        component.set('v.strTime', txtHours+":"+txtMinutes);
   }

})