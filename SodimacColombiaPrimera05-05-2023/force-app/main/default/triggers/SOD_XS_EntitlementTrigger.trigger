trigger SOD_XS_EntitlementTrigger on Entitlement (before insert, after insert, before update, after update) {
    new SOD_XS_TriggerHandler(Entitlement.sObjectType).Run();
}