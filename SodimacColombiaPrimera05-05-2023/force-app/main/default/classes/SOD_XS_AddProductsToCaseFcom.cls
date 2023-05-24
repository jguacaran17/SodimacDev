/**
*  @Description: Queueable class used to invoke view 360 integration and get products for ODC
*  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
*  @Date:        30/06/2021
*/    
public class SOD_XS_AddProductsToCaseFcom implements Queueable, Database.AllowsCallouts{
    
    private Case cas;
    private Account acc;
    private String numeroDocumentoAsociado;
    private List<String> productCodes;

    public SOD_XS_AddProductsToCaseFcom (String caseId, String numeroDocumentoAsociado, List<String> productCodes) {
        Case cas = [Select Id, SOD_XS_AuxCompletitudDatosDelCaso__c, AccountId FROM Case WHERE Id =: caseId];
        this.cas = cas;
        this.numeroDocumentoAsociado = numeroDocumentoAsociado;
        this.productCodes = productCodes;
    }

    public SOD_XS_AddProductsToCaseFcom (Case cas, String numeroDocumentoAsociado, List<String> productCodes) {
        this.cas = cas;
        this.numeroDocumentoAsociado = numeroDocumentoAsociado;
        this.productCodes = productCodes;
    }

    public void execute(QueueableContext context) {
        // Retrieve account from Case
        acc = SOD_XS_360ViewPurchasesController.getRecord(cas.AccountId);
        // Instantiate WrapSearchCriteria in order search by purchase order number
        SOD_XS_360ViewPurchasesController.WrapSearchCriteria searchCriteria = new SOD_XS_360ViewPurchasesController.WrapSearchCriteria(acc);
        searchCriteria.is360View = false;
        searchCriteria.isPurchaseOrders = true;
        searchCriteria.orderNumber = numeroDocumentoAsociado;
        // Call webservice and get back purchase data object from response
        Object objData = SOD_XS_360ViewPurchasesController.getPurchaseDataObjectFcom(cas, searchCriteria);
        if(objData != null){
            // Process json response and deserialize back into Sobjects and commit to DB
            SOD_XS_360ViewPurchasesController.processCaseDataFcom(acc, cas, objData, productCodes);
        }
    }
}