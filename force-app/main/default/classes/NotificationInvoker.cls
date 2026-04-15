public with sharing class NotificationInvoker {

    public class Request {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String recordTypeName;
    }

    @InvocableMethod(label='Enviar notificación asíncrona')
    public static void enqueueNotifications(List<Request> requests) {
        for (Request req : requests) {
            System.enqueueJob(new NotificationQueueable(req.recordId, req.recordTypeName));
        }
    }
}