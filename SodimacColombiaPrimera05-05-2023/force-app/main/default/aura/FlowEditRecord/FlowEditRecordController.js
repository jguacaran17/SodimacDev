({
	invoke : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var createRecordEvent = $A.get("e.force:editRecord");
        var windowRedirect = window.location.href; // Current Page URL
        createRecordEvent.setParams({
            "recordId": recordId,
            "panelOnDestroyCallback": function(event) {
                window.location.href = windowRedirect; // Return to the page where the record was created
            }
        });
        createRecordEvent.fire();
    }
})