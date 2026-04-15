public with sharing class FinancialAccountTriggerHandler {

    public static void beforeInsert(List<FinancialAccount__c> newRecords) {
        for (FinancialAccount__c fa : newRecords) {
            if (String.isBlank(fa.Numero_Tarjeta__c)) {
                fa.Numero_Tarjeta__c =
                    FinancialAccountNumberGenerator.generateCardNumber();
            }
        }
    }
}