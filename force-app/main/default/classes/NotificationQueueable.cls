// La clase se declara con "with sharing" para respetar la seguridad y visibilidad de datos del usuario actual.
public with sharing class NotificationQueueable implements Queueable {

    // Variable que almacenará el Id del registro recibido.
    // Puede ser un Id de Opportunity o de Case.
    private Id recordId;
    // Variable que almacenará el tipo de objeto recibido.
    private String recordTypeName;
    // CONSTRUCTOR
    // Recibe el Id del registro y el tipo de objeto para
    // que el Queueable sepa qué proceso ejecutar.
    public NotificationQueueable(Id recordId, String recordTypeName) {
        this.recordId = recordId;
        this.recordTypeName = recordTypeName;
    }
    // MÉTODO execute
    // Este es el método principal que se ejecuta cuando
    // el Queueable corre en segundo plano.
    public void execute(QueueableContext context) {

        // Si el tipo de registro es Opportunity,
        // se envía el correo de oportunidad ganada.
        if (recordTypeName == 'Opportunity') {
            sendOpportunityEmail();

        // Si el tipo de registro es Case,
        // se envía el correo de caso cerrado.
        } else if (recordTypeName == 'Case') {
            sendCaseEmail();
        }
    }
    // MÉTODO sendOpportunityEmail
    // Busca la oportunidad, obtiene el contacto principal
    // de la cuenta relacionada y envía el correo.
    private void sendOpportunityEmail() {
        // Consulto la oportunidad usando el Id recibido
        Opportunity opp = [
            SELECT Id, Name, StageName, AccountId
            FROM Opportunity
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Si la oportunidad no tiene cuenta relacionada,
        // no se puede identificar al cliente, por eso se detiene.
        if (opp.AccountId == null) {
            return;
        }

        // Obtengo el contacto principal de la cuenta
        Contact con = getPrimaryContactByAccount(opp.AccountId);

        // Si no existe contacto o no tiene email,
        // no se puede enviar la notificación.
        if (con == null || String.isBlank(con.Email)) {
            return;
        }

        // Creo el correo electrónico
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Defino el destinatario usando el email del contacto
        mail.setToAddresses(new List<String>{ con.Email });

        // Defino el asunto del correo
        mail.setSubject('Confirmación de oportunidad ganada');

        // Defino el cuerpo del correo
        mail.setPlainTextBody(
            'Estimado cliente, su oportunidad "' + opp.Name + '" fue cerrada como ganada.'
        );

        // Envío el correo
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
    // MÉTODO sendCaseEmail
    // Busca el caso, obtiene el contacto principal
    // de la cuenta relacionada y envía el correo.
    private void sendCaseEmail() {

        // Consulto el caso usando el Id recibido
        Case cs = [
            SELECT Id, CaseNumber, Status, AccountId
            FROM Case
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Si el caso no tiene cuenta relacionada,
        // no se puede continuar con el envío.
        if (cs.AccountId == null) {
            return;
        }

        // Obtengo el contacto principal de la cuenta
        Contact con = getPrimaryContactByAccount(cs.AccountId);

        // Si no existe contacto o no tiene email,
        // se detiene el proceso.
        if (con == null || String.isBlank(con.Email)) {
            return;
        }

        // Creo el correo electrónico
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Defino el destinatario usando el email del contacto
        mail.setToAddresses(new List<String>{ con.Email });

        // Defino el asunto del correo
        mail.setSubject('Resolución de caso');

        // Defino el cuerpo del correo
        mail.setPlainTextBody(
            'Estimado cliente, su caso #' + cs.CaseNumber + ' ha sido cerrado.'
        );

        // Envío el correo
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
    // MÉTODO getPrimaryContactByAccount
    // Busca el primer contacto asociado a una cuenta que tenga
    // email registrado.
    private Contact getPrimaryContactByAccount(Id accountId) {

        // Consulto los contactos de la cuenta con email no nulo
        List<Contact> contacts = [
            SELECT Id, Name, Email, AccountId
            FROM Contact
            WHERE AccountId = :accountId
              AND Email != null
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        // Si no existen contactos, retorno null
        if (contacts.isEmpty()) {
            return null;
        }

        // Si existe al menos uno, retorno el primero
        return contacts[0];
    }
}