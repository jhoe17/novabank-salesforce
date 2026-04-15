@IsTest
private class FinancialAccountControllerTest {

    @testSetup
    static void setupData() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User ejecutivo = new User(
            FirstName = 'Luis',
            LastName = 'Diaz',
            Alias = 'ldiaz',
            Email = 'luis.diaz@test.com',
            Username = 'luis.diaz.' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            LocaleSidKey = 'es_PE',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es'
        );
        insert ejecutivo;

        Account acc = new Account(
            Name = 'Cliente FA',
            DNI__c = '11112222'
        );
        insert acc;

        Product2 producto = new Product2(
            Name = 'Tarjeta FA',
            IsActive = true
        );
        producto.put('Linea_Credito_Max__c', 7000);
        producto.put('Tasa_de_Interes__c', 20);
        insert producto;

        System.runAs(ejecutivo) {
            FinancialAccount__c fa = new FinancialAccount__c(
                Name = 'FA-001',
                Account__c = acc.Id,
                Product__c = producto.Id,
                Numero_Tarjeta__c = '1234567812345678',
                Linea_Credito__c = 5000,
                Fecha_Emision__c = Date.today(),
                Estado__c = 'Activa'
            );
            insert fa;
        }
    }

    // GIVEN: existe una cuenta financiera
    // WHEN: se llama getAccounts()
    // THEN: retorna la lista correctamente
    @IsTest
    static void givenFinancialAccounts_whenGetAccounts_thenReturnsRecords() {
        Test.startTest();
        List<SObject> resultados = FinancialAccountController.getAccounts();
        Test.stopTest();

        System.assertEquals(1, resultados.size());
    }

    // GIVEN: existe una cuenta financiera
    // WHEN: se llama deleteAccount()
    // THEN: el registro es eliminado
    @IsTest
    static void givenFinancialAccount_whenDelete_thenRecordIsRemoved() {
        FinancialAccount__c fa = [
            SELECT Id
            FROM FinancialAccount__c
            LIMIT 1
        ];

        Test.startTest();
        FinancialAccountController.deleteAccount(fa.Id);
        Test.stopTest();

        Integer total = [
            SELECT COUNT()
            FROM FinancialAccount__c
            WHERE Id = :fa.Id
        ];

        System.assertEquals(0, total);
    }
}