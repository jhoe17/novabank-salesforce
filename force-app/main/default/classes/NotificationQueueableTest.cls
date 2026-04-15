@IsTest
private class NotificationQueueableTest {

    @testSetup
    static void setupData() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User ejecutivo = new User(
            FirstName = 'Maria',
            LastName = 'Lopez',
            Alias = 'mloq',
            Email = 'maria.queue@test.com',
            Username = 'maria.queue.' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            LocaleSidKey = 'es_PE',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es'
        );
        insert ejecutivo;

        Account acc = new Account(
            Name = 'Juan Perez',
            DNI__c = '12345678'
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Juan',
            LastName = 'Perez',
            AccountId = acc.Id,
            Email = 'cliente@test.com'
        );
        insert con;

        Product2 producto = new Product2(
            Name = 'Tarjeta Visa Gold',
            IsActive = true
        );
        producto.put('Linea_Credito_Max__c', 5000);
        producto.put('Tasa_de_Interes__c', 24.5);
        insert producto;

        System.runAs(ejecutivo) {
            Opportunity opp = new Opportunity(
                Name = 'Oportunidad Gold',
                AccountId = acc.Id,
                StageName = 'Cerrado Ganado',
                CloseDate = Date.today(),
                Amount = 15000
            );
            opp.put('Linea_Credito__c', 20000);
            opp.put('Canal_Origen__c', 'web');
            opp.put('Product__c', producto.Id);
            insert opp;

            Case cs = new Case(
                Subject = 'Reclamo tarjeta',
                Status = 'Closed',
                AccountId = acc.Id,
                Origin = 'Web',
                Priority = 'Medium'
            );
            insert cs;
        }
    }

    // GIVEN: existe una oportunidad ganada con cuenta y contacto con email
    // WHEN: se encola NotificationQueueable para Opportunity
    // THEN: el job se ejecuta correctamente
    @IsTest
    static void givenOpportunityWon_whenQueueableRuns_thenCompletesSuccessfully() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Test.startTest();
        Id jobId = System.enqueueJob(new NotificationQueueable(opp.Id, 'Opportunity'));
        Test.stopTest();

        AsyncApexJob job = [
            SELECT Id, Status, JobType
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];

        System.assertEquals('Completed', job.Status);
        System.assertEquals('Queueable', job.JobType);
    }

    // GIVEN: existe un caso cerrado con cuenta y contacto con email
    // WHEN: se encola NotificationQueueable para Case
    // THEN: el job se ejecuta correctamente
    @IsTest
    static void givenClosedCase_whenQueueableRuns_thenCompletesSuccessfully() {
        Case cs = [
            SELECT Id
            FROM Case
            LIMIT 1
        ];

        Test.startTest();
        Id jobId = System.enqueueJob(new NotificationQueueable(cs.Id, 'Case'));
        Test.stopTest();

        AsyncApexJob job = [
            SELECT Id, Status, JobType
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];

        System.assertEquals('Completed', job.Status);
        System.assertEquals('Queueable', job.JobType);
    }
}