@IsTest
private class NotificationInvokerTest {
    // TEST SETUP
    // Este método crea la data base común que será utilizada
    // en los escenarios de prueba del NotificationInvoker.
    @testSetup
    static void setupData() {
        // GIVEN: Existe una cuenta que representará al cliente
        // sobre el cual se trabajará la oportunidad.
        Account acc = new Account(
            Name = 'Pedro Ramirez',
            DNI__c = '87654321'
        );
        insert acc;
        // GIVEN: Existe un contacto relacionado a la cuenta.
        // Este contacto contiene el email que se usará
        // posteriormente para el envío de la notificación.
        Contact con = new Contact(
            FirstName = 'Pedro',
            LastName = 'Ramirez',
            AccountId = acc.Id,
            Email = 'pedro@test.com'
        );
        insert con;
        // GIVEN: Existe un producto activo que será asociado
        // a la oportunidad ganada.
        Product2 producto = new Product2(
            Name = 'Tarjeta Platinum',
            IsActive = true
        );
        // Completo campos obligatorios del producto
        producto.put('Linea_Credito_Max__c', 10000);
        producto.put('Tasa_de_Interes__c', 18);

        insert producto;
        // GIVEN: Existe una oportunidad ganada asociada a la
        // cuenta y al producto.
        Opportunity opp = new Opportunity(
            Name = 'Oportunidad Platinum',
            AccountId = acc.Id,
            StageName = 'Cerrado Ganado',
            CloseDate = Date.today(),
            Amount = 10000
        );

        // Completo campos personalizados de la oportunidad
        opp.put('Linea_Credito__c', 10000);
        opp.put('Canal_Origen__c', 'web');
        opp.put('Product__c', producto.Id);

        insert opp;
    }
    // ESCENARIO 1
    // GIVEN: Existe una oportunidad válida
    // WHEN: El invocable recibe una solicitud
    // THEN: Se encola y ejecuta un Queueable correctamente
    @IsTest
    static void givenValidRequest_whenInvoke_thenQueueableIsCreated() {
        // GIVEN
        // Obtengo la oportunidad creada en el test setup
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        // GIVEN
        // Creo el objeto Request que simula los datos enviados
        // por el Flow al método invocable
        NotificationInvoker.Request req = new NotificationInvoker.Request();
        req.recordId = opp.Id;
        req.recordTypeName = 'Opportunity';
        Test.startTest();

        // WHEN
        // Invoco el método que encola el Queueable
        NotificationInvoker.enqueueNotifications(
            new List<NotificationInvoker.Request>{ req }
        );

        Test.stopTest();

        // THEN
        // Consulto los jobs asíncronos Queueable creados
        List<AsyncApexJob> jobs = [
            SELECT Id, Status, JobType
            FROM AsyncApexJob
            WHERE JobType = 'Queueable'
        ];

        // THEN
        // Verifico que al menos se haya creado un Queueable
        System.assert(
            jobs.size() > 0,
            'Debió crearse al menos un Queueable'
        );

        // THEN
        // Verifico que el Queueable haya terminado correctamente
        System.assertEquals('Completed', jobs[0].Status);
    }
}