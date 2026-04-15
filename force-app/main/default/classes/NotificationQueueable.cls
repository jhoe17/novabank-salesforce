public with sharing class NotificationQueueable implements Queueable {

    private Id recordId;
    private String recordTypeName;

    public NotificationQueueable(Id recordId, String recordTypeName) {
        this.recordId = recordId;
        this.recordTypeName = recordTypeName;
    }

    public void execute(QueueableContext context) {
        if (recordTypeName == 'Opportunity') {
            sendOpportunityEmail();
        } else if (recordTypeName == 'Case') {
            sendCaseEmail();
        }
    }

    private void sendOpportunityEmail() {
        Opportunity opp = [
            SELECT Id, Name, StageName, AccountId
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

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ con.Email });
        mail.setSubject('Confirmación de oportunidad ganada');
        mail.setPlainTextBody(
            'Estimado cliente, su oportunidad "' + opp.Name + '" fue cerrada como ganada.'
        );

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    private void sendCaseEmail() {
        Case cs = [
            SELECT Id, CaseNumber, Status, AccountId
            FROM Case
            WHERE Id = :recordId
            LIMIT 1
        ];

        if (cs.AccountId == null) {
            return;
        }

        Contact con = getPrimaryContactByAccount(cs.AccountId);
        if (con == null || String.isBlank(con.Email)) {
            return;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ con.Email });
        mail.setSubject('Resolución de caso');
        mail.setPlainTextBody(
            'Estimado cliente, su caso #' + cs.CaseNumber + ' ha sido cerrado.'
        );

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    private Contact getPrimaryContactByAccount(Id accountId) {
        List<Contact> contacts = [
            SELECT Id, Name, Email, AccountId
            FROM Contact
            WHERE AccountId = :accountId
              AND Email != null
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        if (contacts.isEmpty()) {
            return null;
        }

        return contacts[0];
    }
}