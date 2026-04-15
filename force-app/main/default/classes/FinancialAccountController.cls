public with sharing class FinancialAccountController {

    @AuraEnabled(cacheable=true)
    public static List<FinancialAccount__c> getAccounts() {
        return [
            SELECT Id, Numero_Tarjeta__c, Linea_Credito__c, Estado__c
            FROM FinancialAccount__c
        ];
    }

    @AuraEnabled
    public static void deleteAccount(Id recordId) {
        delete [SELECT Id FROM FinancialAccount__c WHERE Id = :recordId];
    }
}