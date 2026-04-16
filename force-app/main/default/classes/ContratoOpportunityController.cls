public with sharing class ContratoOpportunityController {

    public Opportunity opportunity { get; set; }
    public String productName { get; set; }
    public Decimal interestRate { get; set; }
    public String dniCliente { get; set; }

    public ContratoOpportunityController(ApexPages.StandardController stdController) {
        Id oppId = stdController.getId();

        opportunity = [
            SELECT Id,
                   Name,
                   StageName,
                   Account.Id,
                   Account.Name,
                   Account.DNI__c,
                   Linea_Credito__c,
                   Fecha_de_Pago__c,
                   Disponibilidad_Retiro__c,
                   Product__r.Name,
                   Product__r.Tasa_de_Interes__c
            FROM Opportunity
            WHERE Id = :oppId
            LIMIT 1
        ];

        productName = opportunity.Product__r != null ? opportunity.Product__r.Name : null;
        interestRate = opportunity.Product__r != null ? opportunity.Product__r.Tasa_de_Interes__c : null;
        dniCliente = opportunity.Account != null ? opportunity.Account.DNI__c : null;
    }
}