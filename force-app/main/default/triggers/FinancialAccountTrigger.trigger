trigger FinancialAccountTrigger on FinancialAccount__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        FinancialAccountTriggerHandler.beforeInsert(Trigger.new);
    }
}