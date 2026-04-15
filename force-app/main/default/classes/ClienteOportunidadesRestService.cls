@RestResource(urlMapping='/v1/clientes/*/oportunidades-ganadas')
global with sharing class ClienteOportunidadesRestService {

    global class OportunidadDTO {
        public String oportunidadId;
        public String producto;
        public Decimal montoAprobado;
        public Decimal lineaCredito;
        public Decimal tasaInteres;
        public Date fechaCierre;
        public String canalOrigen;
        public String ejecutivo;
    }

    global class ResponseDTO {
        public String clienteId;
        public String nombreCliente;
        public List<OportunidadDTO> oportunidadesGanadas;
        public Integer totalOportunidades;
    }

    @HttpGet
    global static ResponseDTO getOportunidadesGanadas() {
        RestRequest req = RestContext.request;
        String uri = req.requestURI;

        List<String> parts = uri.split('/');
        String clienteId = parts[parts.size() - 2];

        Account cliente = [
            SELECT Id, Name, DNI__c
            FROM Account
            WHERE DNI__c = :clienteId
            LIMIT 1
        ];

        List<Opportunity> oportunidades = [
            SELECT Id,
                   Name,
                   Amount,
                   CloseDate,
                   Owner.Name,
                   Linea_Credito__c,
                   Canal_Origen__c,
                   Product__r.Name,
                   Product__r.Tasa_de_Interes__c
            FROM Opportunity
            WHERE AccountId = :cliente.Id
              AND StageName = 'Cerrado Ganado'
            ORDER BY CloseDate DESC
        ];

        ResponseDTO response = new ResponseDTO();
        response.clienteId = cliente.DNI__c;
        response.nombreCliente = cliente.Name;
        response.oportunidadesGanadas = new List<OportunidadDTO>();

        for (Opportunity opp : oportunidades) {
            OportunidadDTO dto = new OportunidadDTO();
            dto.oportunidadId = opp.Id;
            dto.producto = opp.Product__r != null ? opp.Product__r.Name : null;
            dto.montoAprobado = opp.Amount;
            dto.lineaCredito = opp.Linea_Credito__c;
            dto.tasaInteres = opp.Product__r != null ? opp.Product__r.Tasa_de_Interes__c : null;
            dto.fechaCierre = opp.CloseDate;
            dto.canalOrigen = opp.Canal_Origen__c;
            dto.ejecutivo = opp.Owner != null ? opp.Owner.Name : null;

            response.oportunidadesGanadas.add(dto);
        }

        response.totalOportunidades = response.oportunidadesGanadas.size();
        return response;
    }
}