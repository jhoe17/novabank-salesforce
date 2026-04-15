// La anotación @RestResource expone esta clase como un servicio REST.
// La URL disponible será:
// /services/apexrest/v1/clientes/{clienteId}/oportunidades-ganadas
@RestResource(urlMapping='/v1/clientes/*/oportunidades-ganadas')

// "with sharing" hace que la clase respete los permisos
global with sharing class ClienteOportunidadesRestService {

    // =========================================================
    // DTO DE OPORTUNIDAD
    // Esta clase representa la estructura de cada oportunidad
    // que será enviada en la respuesta JSON.
    // =========================================================
    global class OportunidadDTO {
        // Id de la oportunidad
        public String oportunidadId;
        // Nombre del producto relacionado a la oportunidad
        public String producto;
        // Monto aprobado de la oportunidad
        public Decimal montoAprobado;
        // Línea de crédito otorgada
        public Decimal lineaCredito;
        // Tasa de interés del producto asociado
        public Decimal tasaInteres;
        // Fecha de cierre de la oportunidad
        public Date fechaCierre;
        // Canal por el cual se originó la oportunidad
        public String canalOrigen;
        // Nombre del ejecutivo responsable
        public String ejecutivo;
    }

    // =========================================================
    // DTO DE RESPUESTA
    // Esta clase representa el JSON completo que retornará
    // el endpoint REST.
    // =========================================================
    global class ResponseDTO {

        // DNI o identificador del cliente recibido en la URL
        public String clienteId;
        // Nombre del cliente encontrado
        public String nombreCliente;
        // Lista de oportunidades ganadas del cliente
        public List<OportunidadDTO> oportunidadesGanadas;
        // Cantidad total de oportunidades encontradas
        public Integer totalOportunidades;
    }

    // =========================================================
    // MÉTODO GET DEL SERVICIO REST
    // Se ejecuta cuando alguien hace una petición HTTP GET
    // al endpoint configurado.
    // =========================================================
    @HttpGet
    global static ResponseDTO getOportunidadesGanadas() {

        // Obtengo el request HTTP actual
        RestRequest req = RestContext.request;
        // Obtengo la URL completa recibida
        String uri = req.requestURI;
        // Divido la URL usando "/" para extraer el clienteId
        // Ejemplo:
        // /services/apexrest/v1/clientes/12345678/oportunidades-ganadas
        List<String> parts = uri.split('/');
        // Obtengo el valor que está antes de
        // "oportunidades-ganadas", es decir el clienteId
        String clienteId = parts[parts.size() - 2];
        // =====================================================
        // BUSCO EL CLIENTE EN ACCOUNT UTILIZANDO EL DNI
        // =====================================================
        Account cliente = [
            SELECT Id, Name, DNI__c
            FROM Account
            WHERE DNI__c = :clienteId
            LIMIT 1
        ];

        // =====================================================
        // BUSCO TODAS LAS OPORTUNIDADES DEL CLIENTE
        // EN ESTADO CERRADO GANADO
        // =====================================================
        List<Opportunity> oportunidades = [
            SELECT Id,
                   Name,
                   Amount,
                   CloseDate,
                   // Nombre del dueño de la oportunidad
                   Owner.Name,
                   Linea_Credito__c,
                   Canal_Origen__c,
                   Product__r.Name,
                   // Tasa de interés del producto
                   Product__r.Tasa_de_Interes__c
            FROM Opportunity
            // Solo oportunidades del cliente encontrado
            WHERE AccountId = :cliente.Id
              AND StageName = 'Cerrado Ganado'
            ORDER BY CloseDate DESC
        ];

        // =====================================================
        // CREO EL OBJETO DE RESPUESTA
        // =====================================================
        ResponseDTO response = new ResponseDTO();
        // Completo los datos generales del cliente
        response.clienteId = cliente.DNI__c;
        response.nombreCliente = cliente.Name;
        // Inicializo la lista de oportunidades
        response.oportunidadesGanadas = new List<OportunidadDTO>();
        // RECORRO CADA OPORTUNIDAD Y LA TRANSFORMO AL DTO
        for (Opportunity opp : oportunidades) {
            // Creo un DTO por cada oportunidad
            OportunidadDTO dto = new OportunidadDTO();
            // Guardo el Id de la oportunidad
            dto.oportunidadId = opp.Id;
            // Si existe producto, guardo su nombre
            dto.producto = opp.Product__r != null
                ? opp.Product__r.Name
                : null;
            // Monto aprobado
            dto.montoAprobado = opp.Amount;
            // Línea de crédito custom
            dto.lineaCredito = opp.Linea_Credito__c;
            // Si existe producto, obtengo la tasa de interés
            dto.tasaInteres = opp.Product__r != null
                ? opp.Product__r.Tasa_de_Interes__c
                : null;
            // Fecha de cierre
            dto.fechaCierre = opp.CloseDate;
            // Canal de origen
            dto.canalOrigen = opp.Canal_Origen__c;
            // Nombre del ejecutivo dueño de la oportunidad
            dto.ejecutivo = opp.Owner != null
                ? opp.Owner.Name
                : null;
            // Agrego el DTO a la lista de la respuesta
            response.oportunidadesGanadas.add(dto);
        }
        // Calculo la cantidad total de oportunidades
        response.totalOportunidades = response.oportunidadesGanadas.size();
        // Retorno la respuesta.
        // Salesforce la convierte automáticamente a JSON.
        return response;
    }
}