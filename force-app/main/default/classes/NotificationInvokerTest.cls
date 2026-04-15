@IsTest
private class NotificationInvokerTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(
            Name = 'Pedro Ramirez',
            DNI__c = '87654321'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Pedro',
            LastName = 'Ramirez',
            AccountId = acc.Id,
            Email = 'pedro@test.com'
        );
        insert con;

        Product2 producto = new Product2(
            Name = 'Tarjeta Platinum',
            IsActive = true
        );
        producto.put('Linea_Credito_Max__c', 10000);
        producto.put('Tasa_de_Interes__c', 18);
        insert producto;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidad Platinum',
            AccountId = acc.Id,
            StageName = 'Cerrado Ganado',
            CloseDate = Date.today(),
            Amount = 10000
        );
        opp.put('Linea_Credito__c', 10000);
        opp.put('Canal_Origen__c', 'web');
        opp.put('Product__c', producto.Id);
        insert opp;
    }

    // GIVEN: existe una oportunidad válida
    // WHEN: el invocable recibe una solicitud
    // THEN: encola un Queueable
    @IsTest
    static void givenValidRequest_whenInvoke_thenQueueableIsCreated() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        NotificationInvoker.Request req = new NotificationInvoker.Request();
        req.recordId = opp.Id;
        req.recordTypeName = 'Opportunity';

        Test.startTest();
        NotificationInvoker.enqueueNotifications(
            new List<NotificationInvoker.Request>{ req }
        );
        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id, Status, JobType
            FROM AsyncApexJob
            WHERE JobType = 'Queueable'
        ];

        System.assert(jobs.size() > 0, 'Debió crearse al menos un Queueable');
        System.assertEquals('Completed', jobs[0].Status);
    }
}