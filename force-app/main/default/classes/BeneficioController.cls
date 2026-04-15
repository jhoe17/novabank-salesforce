public with sharing class BeneficioController {

    @AuraEnabled(cacheable=true)
    public static List<Beneficio__c> getBeneficios(Id productId) {

        if (productId == null) {
            return new List<Beneficio__c>();
        }

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
            WHERE Producto__c = :productId
            ORDER BY Prioridad__c ASC, Name ASC
        ];
    }
}