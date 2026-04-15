// Se usa with sharing para respetar los permisos y reglas de visibilidad del usuario actual.
public with sharing class BeneficioController {

    // @AuraEnabled permite que este método pueda ser llamado
    // desde un Aura Component o un LWC.
    // cacheable=true indica que Salesforce puede almacenar
    // temporalmente la respuesta para mejorar el rendimiento.
    @AuraEnabled(cacheable=true)
    public static List<Beneficio__c> getBeneficios(Id productId) {

        // Si el Id del producto viene vacío o null,
        // se retorna una lista vacía para evitar errores
        // y no ejecutar la consulta innecesariamente.
        if (productId == null) {
            return new List<Beneficio__c>();
        }
        // Se consulta el objeto Beneficio__c filtrando
        // únicamente los beneficios asociados al producto recibido.
        return [
            SELECT Id,
                   Name,
                   Producto__c,
                   TEA__c,
                   Millas__c,
                   Cashback__c,
                   Descripcion__c,
                   Prioridad__c
            FROM Beneficio__c
            // Solo trae los beneficios del producto seleccionado
            WHERE Producto__c = :productId
            ORDER BY Prioridad__c ASC, Name ASC
        ];
    }
}