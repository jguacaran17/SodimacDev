import { LightningElement, api, wire } from 'lwc';

import MOTIVO_FIELD from '@salesforce/schema/Case.SOD_XS_AuxMotivoDelCaso__c';
import NOMBRESCLIENTE_FIELD from '@salesforce/schema/Case.SOD_XS_AuxNombresDelCliente__c';
import APELLIDOSCLIENTE_FIELD from '@salesforce/schema/Case.SOD_XS_AuxApellidosDelCliente__c';
import NRODOCUMENTO_FIELD from '@salesforce/schema/Case.SOD_XS_AuxNumeroDeDocumentoDelCliente__c';
import TIPODOCUMENTO_FIELD from '@salesforce/schema/Case.SOD_XS_AuxTipoDeDocumentoDelCliente__c';
import TELEFONO_FIELD from '@salesforce/schema/Case.SOD_XS_AuxTelefonoDelCliente__c';
import EMAIL_FIELD from '@salesforce/schema/Case.SOD_XS_AuxEmailDelCliente__c';
import DIRECCION_FIELD from '@salesforce/schema/Case.SOD_XS_AuxDireccionDelCliente__c';
import PRODUCTOAFECTADO_FIELD from '@salesforce/schema/Case.SOD_XS_AuxCodigoDelProductoAfectado__c';
import TIENDAQUEVENDE_FIELD from '@salesforce/schema/Case.SOD_XS_AuxTiendaQueVende__c';
import TIPODOCUMENTOVENTA_FIELD from '@salesforce/schema/Case.SOD_XS_AuxTipoDeDocumentoDeVenta__c';
import NRODOCUMENTOVENTA_FIELD from '@salesforce/schema/Case.SOD_XS_AuxNumeroDeDocumentoDeVenta__c';
import ORDENDECOMPRA_FIELD from '@salesforce/schema/Case.SOD_XS_AuxOrdenDeCompra__c';
import NOMBRECOMPLETOCLIENTE_FIELD from '@salesforce/schema/Case.SOD_XS_AuxNombreCompletoDelCliente__c';
import DOCUMENTOVENTAFECHAINICIO_FIELD from '@salesforce/schema/Case.SOD_XS_AuxFechaInicio__c';
import DOCUMENTOVENTAFECHAFIN_FIELD from '@salesforce/schema/Case.SOD_XS_AuxFechaFin__c';

export default class DisplayCaseAuxFieldsLWC extends LightningElement {
    // Expose a field to make it available in the template
    fields = [NOMBRESCLIENTE_FIELD, 
        APELLIDOSCLIENTE_FIELD, 
        TIPODOCUMENTO_FIELD, 
        NRODOCUMENTO_FIELD, 
        TELEFONO_FIELD, 
        EMAIL_FIELD, 
        DIRECCION_FIELD, 
        MOTIVO_FIELD, 
        PRODUCTOAFECTADO_FIELD, 
        TIENDAQUEVENDE_FIELD, 
        TIPODOCUMENTOVENTA_FIELD, 
        NRODOCUMENTOVENTA_FIELD,
        DOCUMENTOVENTAFECHAINICIO_FIELD,
        DOCUMENTOVENTAFECHAFIN_FIELD,
        ORDENDECOMPRA_FIELD,
    	NOMBRECOMPLETOCLIENTE_FIELD];

    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
}