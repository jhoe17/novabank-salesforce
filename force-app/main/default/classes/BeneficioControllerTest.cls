@IsTest
private class BeneficioControllerTest {

    @testSetup
    static void setupData() {
        Product2 producto = new Product2(
            Name = 'Tarjeta Beneficio',
            IsActive = true
        );
        producto.put('Linea_Credito_Max__c', 9000);
        producto.put('Tasa_de_Interes__c', 19);
        insert producto;

        Beneficio__c beneficio = new Beneficio__c(
            Name = 'Cashback 5%'
        );
        beneficio.put('Producto__c', producto.Id);
        beneficio.put('TEA__c', 19);
        beneficio.put('Millas__c', 1000);
        beneficio.put('Cashback__c', 5);
        beneficio.put('Descripcion__c', 'Beneficio de prueba');
        beneficio.put('Prioridad__c', 1);

        insert beneficio;
    }

    // GIVEN: existe un producto con beneficios
    // WHEN: se llama getBeneficios(productId)
    // THEN: retorna la lista correspondiente
    @IsTest
    static void givenProductWithBenefits_whenGetBeneficios_thenReturnsRecords() {
        Product2 producto = [
            SELECT Id
            FROM Product2
            LIMIT 1
        ];

        Test.startTest();
        List<Beneficio__c> beneficios = BeneficioController.getBeneficios(producto.Id);
        Test.stopTest();

        System.assertEquals(1, beneficios.size());
        System.assertEquals('Cashback 5%', beneficios[0].Name);
    }

    // GIVEN: el productId es null
    // WHEN: se llama getBeneficios(null)
    // THEN: retorna una lista vacía
    @IsTest
    static void givenNullProductId_whenGetBeneficios_thenReturnsEmptyList() {
        Test.startTest();
        List<Beneficio__c> beneficios = BeneficioController.getBeneficios(null);
        Test.stopTest();

        System.assertEquals(0, beneficios.size());
    }
}