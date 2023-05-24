/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Blandon
Created Date : 29/06/2021
Description  : Trigger Handler class for SOD_XS_ReservasDelCaso__c object
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Josue Blandon		        Blandon
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      Blandon		29/06/2021		Initial definition of the class.
********************************************************************************/

public class SOD_XS_ReservasDelCasoTriggerHandler extends SOD_XS_AbstractTriggerHandler {
    
    private List<Case> casesToAssign = new List<Case>();
    private List<Case> updateCase = new List<Case>();
    private List<SOD_XS_DocumentoDeVenta__c> updateDocVenta = new List<SOD_XS_DocumentoDeVenta__c>();

    public override void afterInsert() {
        List<SOD_XS_ReservasDelCaso__c> res = Trigger.new;
        List<SOD_XS_ReservasDelCaso__c> resFcomChile = new List<SOD_XS_ReservasDelCaso__c>();
        List<SOD_XS_ReservasDelCaso__c> resFcomPeru = new List<SOD_XS_ReservasDelCaso__c>();
        Set<Id> caseIdResFcomChile = new Set<Id>();
        Set<Id> caseIdResFcomPeru = new Set<Id>();
        Set<Id> docsVentaIdsFcomPeru = new Set<Id>();
        for(SOD_XS_ReservasDelCaso__c r : res) {
            if(esReservaFcomPeru(r)){
                if(r.SOD_XS_CanalDeVenta__c == 'F.COM'){
                    resFcomPeru.add(r);
                    caseIdResFcomPeru.add(r.SOD_XS_Caso__c);
                    docsVentaIdsFcomPeru.add(r.SOD_XS_DocumentoDeVenta__c);
                }
            } else if(esReservaFcomChile(r)){
                caseIdResFcomChile.add(r.SOD_XS_Caso__c);
            }
        }
        if(caseIdResFcomPeru <> Null) {
            List<SOD_XS_CentroDeCosto__c> ccFcomPeru = [Select Id,Name From SOD_XS_CentroDeCosto__c Where Name = 'F.COM PE'];
            if(!ccFcomPeru.isEmpty()) {
                List<Case> csList = [Select Id,SOD_XS_TiendaVende__c From Case Where Id =: caseIdResFcomPeru];
                List<SOD_XS_DocumentoDeVenta__c> docsVentaFcomPeru = [Select Id,SOD_XS_TiendaQueVende__c From SOD_XS_DocumentoDeVenta__c Where Id =: docsVentaIdsFcomPeru]; 
                for(Case c: csList) {
                    if(c.SOD_XS_TiendaVende__c <> ccFcomPeru[0].Id) {
                        c.SOD_XS_TiendaVende__c = ccFcomPeru[0].Id;
                        updateCase.add(c);
                    }    
                }
                for(SOD_XS_DocumentoDeVenta__c d: docsVentaFcomPeru) {
                    if(d.SOD_XS_TiendaQueVende__c <> ccFcomPeru[0].Id) {
                        d.SOD_XS_TiendaQueVende__c = ccFcomPeru[0].Id;
                        updateDocVenta.add(d);
                    }    
                }
            }
        }
        if(caseIdResFcomChile <> Null) {
            List<SOD_XS_CentroDeCosto__c> ccFcomChile = [Select Id,Name From SOD_XS_CentroDeCosto__c Where Name = 'F.COM'];
            if(!ccFcomChile.isEmpty()) {
                List<Case> csList = [Select Id,SOD_XS_CentroCostoResponsable__c From Case Where Id =: caseIdResFcomChile];                    
                for(Case c: csList) {
                    if(c.SOD_XS_CentroCostoResponsable__c <> ccFcomChile[0].Id) {
                        c.SOD_XS_CentroCostoResponsable__c = ccFcomChile[0].Id;
                        updateCase.add(c);
                    }    
                }
            } 
        }
        /* Update Cases */
        if(!updateCase.isEmpty()) {
            update updateCase;
        }
        /* Update Documentos de Venta */
        if(!updateDocVenta.isEmpty()) {
            update updateDocVenta;
        }
    }

    public override void afterUpdate() {
    	afterInsert();
        actualizarCasosDeReservasFcom();     
    }

    /**
    *  @Description: Actualizar Casos creados por integracion Fcom con el Centro De Costo Responsable que proviene de la Reserva
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        15/11/2021
    */
    public void actualizarCasosDeReservasFcom(){
        Set<Id> listaIdsCasos = new Set<Id>();
        Set<Id> listaIdsReservas = new Set<Id>();
        List<SOD_XS_ReservasDelCaso__c> res = Trigger.new;
        Map<Id,List<SOD_XS_ProductoDelCaso__c>> mapaReservaYProductos = new Map<Id,List<SOD_XS_ProductoDelCaso__c>>();
        Map<Id,Id> mapaCasoYReserva = new Map<Id,Id>();
        for(SOD_XS_ReservasDelCaso__c r : res) {
            if(esReservaFcomPeru(r) || esReservaFcomChile(r)) {
                listaIdsCasos.add(r.SOD_XS_Caso__c); 
                listaIdsReservas.add(r.Id);
                mapaReservaYProductos.put(r.Id, null);
                mapaCasoYReserva.put(r.SOD_XS_Caso__c, r.Id);
            }
        }
        List<SOD_XS_ProductoDelCaso__c> productos = [SELECT Id, SOD_XS_ReservaDelCaso__c, SOD_XS_Despacho__c FROM SOD_XS_ProductoDelCaso__c WHERE SOD_XS_ReservaDelCaso__c =: listaIdsReservas];
        for(Id idReserva : mapaReservaYProductos.keySet()){
            List<SOD_XS_ProductoDelCaso__c> listaProductosDeLaReserva = new List<SOD_XS_ProductoDelCaso__c>();
            for(SOD_XS_ProductoDelCaso__c p : productos){
                if(p.SOD_XS_ReservaDelCaso__c == idReserva){
                    listaProductosDeLaReserva.add(p);
                }
            }
            mapaReservaYProductos.put(idReserva, listaProductosDeLaReserva);
        }
        List<Case> listaCasos = [SELECT Id, SOD_XS_CentroCostoResponsable__c FROM Case WHERE Id =: listaIdsCasos];
        List<Case> listaCasosActualizar = new List<Case>();
        for(Case c : listaCasos) {
            Id ccResponsable = regresaCCResponsable(mapaReservaYProductos.get(mapaCasoYReserva.get(c.Id)));
            if(ccResponsable != null){
                c.SOD_XS_CentroCostoResponsable__c = ccResponsable;
                listaCasosActualizar.add(c);
            }
        }
        if(!listaCasosActualizar.isEmpty()){
            update listaCasosActualizar;
        }
    }

    /**
    *  @Description: Regresa verdadero si la reserva es de Peru
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        15/11/2021
    */
    public Boolean esReservaFcomPeru(SOD_XS_ReservasDelCaso__c r) {
        return (r.SOD_XS_CreadoPorFcom__c == true && r.SOD_XS_ReservaMadre__c == null && r.SOD_XS_DireccionPais__c == 'PE');
    }

    /**
    *  @Description: Regresa verdadero si la reserva es de Chile
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        15/11/2021
    */
    public Boolean esReservaFcomChile(SOD_XS_ReservasDelCaso__c r) {
        return (r.SOD_XS_CreadoPorFcom__c == true && r.SOD_XS_DireccionPais__c == 'CL');
    }

    /**
    *  @Description: Regresa el Centro de Costo Responsable determinado en base a los Productos del Caso
    *  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @Date:        15/11/2021
    */
    public Id regresaCCResponsable(List<SOD_XS_ProductoDelCaso__c> productos){
        Id ccResponsable = null;
        if(!productos.isEmpty()){
            ccResponsable = productos[0].SOD_XS_Despacho__c;
        }
        return ccResponsable;
    }

    public Map<Id, String> abbCountry() {
        casesToAssign = updateCase;        
        List<String> accId = new List<String>();
        Map<Id, String> country = new Map<Id, String>();
        
        for (case c : casesToAssign) { accId.add(c.AccountId);
        }
        
        for (Account ac : [SELECT Id, SOD_XS_Country__c, SOD_XS_Country__r.SOD_XS_Codigo__c FROM Account WHERE Id IN :accId]) {
            country.put(ac.Id , ac.SOD_XS_Country__r.SOD_XS_Codigo__c); 
        }     
        return country; 
    }
    
    public void activateAssignmentRule() {        
        Map<Id, String> country = AbbCountry();
        // assign the cases we need to assing
        casesToAssign = updateCase; 

        List<Id> caseIds = new List<Id>{};
        Map<String, Id> asrMap = new Map<String, Id>();
        
        for(AssignmentRule  asr : [select Id, Name from AssignmentRule where SobjectType = 'Case']) {
            asrMap.put(asr.Name.SubString(4,6), asr.Id);
        }
        
        for (Case theCase : casesToAssign) { caseIds.add(theCase.Id);
        }    
        
        List<Case> casesList = new List<Case>{}; 
        for(Case c : [Select Id, AccountId from Case where Id in :caseIds]) {            
            Database.DMLOptions dmo = new Database.DMLOptions();
              
            dmo.assignmentRuleHeader.assignmentRuleId = asrMap.get(country.get(c.AccountId));  
            c.setOptions(dmo);
            
            casesList.add(c);
        }
        
        Database.upsert(casesList);    
    }
}