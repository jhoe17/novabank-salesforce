public with sharing class NotificationQueueable implements Queueable {

    // Id del registro que originó la notificación
    private Id recordId;

    // Tipo de registro recibido desde Flow
    // Ejemplo: Opportunity o Case
    private String recordTypeName;

    // Constructor que recibe el Id y el tipo del registro
    public NotificationQueueable(Id recordId, String recordTypeName) {
        this.recordId = recordId;
        this.recordTypeName = recordTypeName;
    }

    // Método principal que ejecuta el Queueable
    public void execute(QueueableContext context) {

        // Si el registro es una oportunidad ganada
        if (recordTypeName == 'Opportunity') {
            sendOpportunityEmail();

        // Si el registro es un caso cerrado
        } else if (recordTypeName == 'Case') {
            sendCaseEmail();
        }
    }

    // Envía el correo para oportunidades ganadas
    private void sendOpportunityEmail() {

        Opportunity opp = [
            SELECT Id,
                   Name,
                   AccountId
            FROM Opportunity
            WHERE Id = :recordId
            LIMIT 1
        ];

        if (opp.AccountId == null) {
            return;
        }

        Contact con = getPrimaryContactByAccount(opp.AccountId);

        if (con == null || String.isBlank(con.Email)) {
            return;
        }

        // Busca la plantilla de correo
        Id templateId = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'ContratoTarjetaEmitida'
            LIMIT 1
        ].Id;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Usa la plantilla
        mail.setTemplateId(templateId);

        // Contacto que recibirá el correo
        mail.setTargetObjectId(con.Id);

        // Opportunity relacionada para usar {!relatedTo}
        mail.setWhatId(opp.Id);

        // Guarda el correo en el historial
        mail.setSaveAsActivity(true);

        // Busca el contrato guardado en Files
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :opp.Id
            ORDER BY SystemModstamp DESC
            LIMIT 1
        ];

        if (!links.isEmpty()) {

            ContentVersion cv = [
                SELECT Title,
                       VersionData,
                       FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId = :links[0].ContentDocumentId
                ORDER BY VersionNumber DESC
                LIMIT 1
            ];

            Messaging.EmailFileAttachment attachment =
                new Messaging.EmailFileAttachment();

            attachment.setFileName(
                cv.Title + '.' + cv.FileExtension
            );

            attachment.setBody(cv.VersionData);

            attachment.setContentType('application/pdf');

            mail.setFileAttachments(
                new Messaging.EmailFileAttachment[] { attachment }
            );
        }

        Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ mail }
        );
    }

    // Envía el correo para casos cerrados
    private void sendCaseEmail() {

        // Obtiene el caso
        Case cs = [
            SELECT Id,
                   CaseNumber,
                   Status,
                   AccountId
            FROM Case
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Si no tiene cuenta asociada, termina
        if (cs.AccountId == null) {
            return;
        }

        // Busca el contacto principal de la cuenta
        Contact con = getPrimaryContactByAccount(cs.AccountId);

        // Si no existe contacto o email, termina
        if (con == null || String.isBlank(con.Email)) {
            return;
        }

        // Busca la plantilla de correo
        Id templateId = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'ResolucionReclamo'
            LIMIT 1
        ].Id;

        // Construye el correo usando la plantilla
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTemplateId(templateId);
        mail.setTargetObjectId(con.Id);
        mail.setWhatId(cs.Id);
        mail.setSaveAsActivity(true);

        // Envía el correo
        Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ mail }
        );
    }

    // Obtiene el primer contacto con email de la cuenta
    private Contact getPrimaryContactByAccount(Id accountId) {

        List<Contact> contacts = [
            SELECT Id,
                   Name,
                   Email,
                   AccountId
            FROM Contact
            WHERE AccountId = :accountId
              AND Email != null
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        // Si no hay contactos, retorna null
        if (contacts.isEmpty()) {
            return null;
        }

        // Retorna el primer contacto encontrado
        return contacts[0];
    }
}