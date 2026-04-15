// La clase se declara con "with sharing" para respetar
// la seguridad del usuario actual, incluyendo roles,
public with sharing class FinancialAccountController {

    // =========================================================
    // MÉTODO getAccounts
    // Este método será llamado desde un LWC o Aura Component
    // para listar las cuentas financieras existentes.
    // =========================================================
    @AuraEnabled(cacheable=true)
    public static List<FinancialAccount__c> getAccounts() {

        // cacheable=true indica que Salesforce puede guardar
        // temporalmente el resultado para mejorar rendimiento.
        // Se consultan los registros de FinancialAccount__c
        // devolviendo únicamente los campos necesarios
        // para mostrarlos en el componente.
        return [
            SELECT Id,
                   Numero_Tarjeta__c,
                   Linea_Credito__c,
                   Estado__c
            FROM FinancialAccount__c
        ];
    }
    // MÉTODO deleteAccount
    // Este método permite eliminar una cuenta financiera
    // desde el componente LWC.
    @AuraEnabled
    public static void deleteAccount(Id recordId) {

        // Se busca el registro cuyo Id fue recibido
        // desde el componente.
        // Luego se elimina usando DML delete.
        delete [
            SELECT Id
            FROM FinancialAccount__c
            WHERE Id = :recordId
        ];
    }
}