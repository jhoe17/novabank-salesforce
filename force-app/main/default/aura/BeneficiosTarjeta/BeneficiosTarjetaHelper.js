({
    initializeColumns: function(component) {
        component.set("v.columns", [
            { label: "Nombre", fieldName: "Name", type: "text" },
            { label: "TEA", fieldName: "TEA__c", type: "percent" },
            { label: "Millas", fieldName: "Millas__c", type: "number" },
            { label: "Cashback", fieldName: "Cashback__c", type: "percent" },
            { label: "Descripción", fieldName: "Descripcion__c", type: "text" },
            { label: "Prioridad", fieldName: "Prioridad__c", type: "number" }
        ]);
    },

    loadBeneficios: function(component) {
        const action = component.get("c.getBeneficios");
        action.setParams({
            productId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.beneficios", response.getReturnValue());
                component.set("v.errorMessage", "");
            } else {
                component.set("v.errorMessage", "No se pudieron cargar los beneficios.");
            }
        });

        $A.enqueueAction(action);
    }
})