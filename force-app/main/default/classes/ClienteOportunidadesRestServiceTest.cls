@IsTest
private class ClienteOportunidadesRestServiceTest {

    // =========================================================
    // TEST SETUP
    // Este método se ejecuta una sola vez antes de todos los tests.
    // Aquí creamos toda la data base que reutilizarán los escenarios.
    // =========================================================
    @testSetup
    static void setupData() {

        // -----------------------------------------------------
        // GIVEN: Existe un perfil estándar para crear un usuario
        // -----------------------------------------------------
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        // -----------------------------------------------------
        // GIVEN: Creo un usuario que representará al ejecutivo
        // que trabaja las oportunidades.
        // -----------------------------------------------------
        User ejecutivo = new User(
            FirstName = 'Maria',
            LastName = 'Lopez',
            Alias = 'mlopez',
            Email = 'maria.lopez@test.com',
            Username = 'maria.lopez.' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Lima',
            LocaleSidKey = 'es_PE',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es'
        );
        insert ejecutivo;

        // -----------------------------------------------------
        // GIVEN: Creo el cliente que será consultado por la API
        // El DNI es importante porque será el valor que llegará
        // en la URL del endpoint REST.
        // -----------------------------------------------------
        Account cliente = new Account(
            Name = 'Juan Perez',
            DNI__c = '12345678'
        );
        insert cliente;

        // -----------------------------------------------------
        // GIVEN: Creo el producto asociado a la oportunidad.
        // Este producto debe tener todos los campos obligatorios
        // que existen en tu org.
        // -----------------------------------------------------
        Product2 producto = new Product2(
            Name = 'Tarjeta Visa Gold',
            IsActive = true
        );

        // Campos obligatorios del producto
        producto.put('Tipo_de_Tarjeta__c', 'Visa');
        producto.put('Categoria_Segmento__c', 'Oro');
        producto.put('Linea_Credito_Min__c', 1000);
        producto.put('Linea_Credito_Max__c', 5000);
        producto.put('Tasa_de_Interes__c', 24.5);
        producto.put('Canal_de_Venta__c', 'web');

        // Campo opcional
        producto.put('Membresia_Anual__c', 150);

        insert producto;

        // -----------------------------------------------------
        // GIVEN: Simulo que el ejecutivo es quien crea la
        // oportunidad ganada.
        // Se usa System.runAs porque el PDF exige probar el
        // comportamiento con el usuario final.
        // -----------------------------------------------------
        System.runAs(ejecutivo) {

            Opportunity opp = new Opportunity(
                Name = 'Oportunidad Gold',
                AccountId = cliente.Id,
                StageName = 'Cerrado Ganado',
                CloseDate = Date.today(),
                Amount = 15000
            );

            // Campos personalizados de la oportunidad
            opp.put('Linea_Credito__c', 20000);
            opp.put('Canal_Origen__c', 'Web');
            opp.put('Product__c', producto.Id);

            insert opp;
        }
    }

    // =========================================================
    // ESCENARIO 1
    // GIVEN: Existe un cliente con una oportunidad ganada.
    // WHEN: Se invoca el endpoint REST usando el DNI.
    // THEN: La API retorna correctamente toda la información.
    // =========================================================
    @IsTest
    static void givenClienteConOportunidadGanada_whenInvocarRest_thenRetornaJsonCorrecto() {

        // GIVEN: Obtengo el usuario ejecutivo creado en el setup
        User ejecutivo = [
            SELECT Id
            FROM User
            WHERE Alias = 'mlopez'
            LIMIT 1
        ];

        // GIVEN: Simulo que el ejecutivo hace la llamada REST
        System.runAs(ejecutivo) {

            // GIVEN: Construyo el request HTTP GET
            RestRequest req = new RestRequest();
            req.requestURI =
                '/services/apexrest/v1/clientes/12345678/oportunidades-ganadas';
            req.httpMethod = 'GET';

            RestContext.request = req;
            RestContext.response = new RestResponse();

            Test.startTest();

            // WHEN: Se ejecuta el método REST
            ClienteOportunidadesRestService.ResponseDTO response =
                ClienteOportunidadesRestService.getOportunidadesGanadas();

            Test.stopTest();

            // THEN: Verifico que el DNI retornado es correcto
            System.assertEquals('12345678', response.clienteId);

            // THEN: Verifico el nombre del cliente
            System.assertEquals('Juan Perez', response.nombreCliente);

            // THEN: Debe existir una sola oportunidad ganada
            System.assertEquals(1, response.totalOportunidades);

            // THEN: Verifico el producto asociado
            System.assertEquals(
                'Tarjeta Visa Gold',
                response.oportunidadesGanadas[0].producto
            );

            // THEN: Verifico el monto aprobado
            System.assertEquals(
                15000,
                response.oportunidadesGanadas[0].montoAprobado
            );

            // THEN: Verifico la línea de crédito
            System.assertEquals(
                20000,
                response.oportunidadesGanadas[0].lineaCredito
            );

            // THEN: Verifico el canal de origen
            System.assertEquals(
                'web',
                response.oportunidadesGanadas[0].canalOrigen.toLowerCase()
            );

            // THEN: Verifico el nombre del ejecutivo
            System.assertEquals(
                'Maria Lopez',
                response.oportunidadesGanadas[0].ejecutivo
            );
        }
    }

    // =========================================================
    // ESCENARIO 2
    // GIVEN: Existe un cliente, pero no tiene oportunidades
    // ganadas.
    // WHEN: Se invoca el endpoint con el DNI de ese cliente.
    // THEN: La API devuelve una lista vacía.
    // =========================================================
    @IsTest
    static void givenClienteSinOportunidades_whenInvocarRest_thenRetornaListaVacia() {

        // GIVEN: Creo un cliente nuevo sin oportunidades
        Account otroCliente = new Account(
            Name = 'Pedro Ramirez',
            DNI__c = '87654321'
        );
        insert otroCliente;

        // GIVEN: Construyo el request REST
        RestRequest req = new RestRequest();
        req.requestURI =
            '/services/apexrest/v1/clientes/87654321/oportunidades-ganadas';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();

        // WHEN: Invoco el endpoint
        ClienteOportunidadesRestService.ResponseDTO response =
            ClienteOportunidadesRestService.getOportunidadesGanadas();

        Test.stopTest();

        // THEN: Verifico el cliente retornado
        System.assertEquals('87654321', response.clienteId);
        System.assertEquals('Pedro Ramirez', response.nombreCliente);

        // THEN: Verifico que no haya oportunidades
        System.assertEquals(0, response.totalOportunidades);
        System.assertEquals(0, response.oportunidadesGanadas.size());
    }

    // =========================================================
    // ESCENARIO 3
    // GIVEN: Se consulta un DNI inexistente.
    // WHEN: El endpoint intenta buscar ese cliente.
    // THEN: Se produce una excepción.
    // =========================================================
    @IsTest
    static void givenClienteInexistente_whenInvocarRest_thenLanzaExcepcion() {

        // GIVEN: Construyo una llamada con un DNI que no existe
        RestRequest req = new RestRequest();
        req.requestURI =
            '/services/apexrest/v1/clientes/99999999/oportunidades-ganadas';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();

        try {

            // WHEN: Se ejecuta el endpoint
            ClienteOportunidadesRestService.getOportunidadesGanadas();

            // THEN: Si no lanzó excepción, la prueba falla
            System.assert(false, 'Debió lanzar excepción');

        } catch (Exception e) {

            // THEN: Verifico que la excepción sea la esperada
            System.assert(
                e.getMessage().contains('List has no rows')
            );
        }

        Test.stopTest();
    }
}