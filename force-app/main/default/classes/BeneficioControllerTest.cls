// GIVEN: existe un producto pero no tiene beneficios asociados
// WHEN: se llama getBeneficios(productId)
// THEN: retorna una lista vacía
@IsTest
private class BeneficioControllerTest {

    @testSetup
    static void setupData() {
            // GIVEN: Existe un producto activo en Product2
            // que será utilizado para asociar beneficios.
            Product2 producto = new Product2(
                Name = 'Tarjeta Beneficio',
                IsActive = true
            );
            // Completo campos obligatorios del producto
            producto.put('Linea_Credito_Max__c', 9000);
            producto.put('Tasa_de_Interes__c', 19);
            insert producto;
            // GIVEN: Existe un beneficio asociado al producto.
            Beneficio__c beneficio = new Beneficio__c(
                Name = 'Cashback 5%'
            );

            // Relaciono el beneficio con el producto creado
            beneficio.put('Producto__c', producto.Id);
            // Completo los datos del beneficio
            beneficio.put('TEA__c', 19);
            beneficio.put('Millas__c', 1000);
            beneficio.put('Cashback__c', 5);
            beneficio.put('Descripcion__c', 'Beneficio de prueba');
            beneficio.put('Prioridad__c', 1);

            insert beneficio;
        }

        // =========================================================
        // ESCENARIO 1
        // GIVEN: Existe un producto con beneficios asociados
        // WHEN: Se llama al método getBeneficios(productId)
        // THEN: Se retorna la lista de beneficios del producto
        // =========================================================
        @IsTest
        static void givenProductWithBenefits_whenGetBeneficios_thenReturnsRecords() {

            // GIVEN
            // Obtengo el producto creado en el test setup
            Product2 producto = [
                SELECT Id
                FROM Product2
                LIMIT 1
            ];
            Test.startTest();
            // WHEN
            // Invoco el método enviando el Id del producto
            List<Beneficio__c> beneficios =
                BeneficioController.getBeneficios(producto.Id);
            Test.stopTest();
            // THEN
            // Verifico que la lista tenga exactamente 1 beneficio
            System.assertEquals(1, beneficios.size());
            // THEN
            // Verifico que el nombre del beneficio sea el esperado
            System.assertEquals('Cashback 5%', beneficios[0].Name);
        }

        // =========================================================
        // ESCENARIO 2
        // GIVEN: El parámetro productId es null
        // WHEN: Se llama al método getBeneficios(null)
        // THEN: El método retorna una lista vacía
        // =========================================================
        @IsTest
        static void givenNullProductId_whenGetBeneficios_thenReturnsEmptyList() {

            Test.startTest();
            // WHEN
            // Invoco el método enviando null como productId
            List<Beneficio__c> beneficios =
                BeneficioController.getBeneficios(null);
            Test.stopTest();
            // THEN
            // Verifico que la lista retornada esté vacía
            System.assertEquals(0, beneficios.size());
    }
}