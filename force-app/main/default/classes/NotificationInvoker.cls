// La clase se declara con "with sharing" para respetar los permisos y visibilidad del usuario que ejecuta el Flow.
public with sharing class NotificationInvoker {

    // =========================================================
    // CLASE Request
    // Esta clase representa los datos que el Flow enviará
    // al método invocable.
    // =========================================================
    public class Request {

        // Id del registro que disparó el Flow.
        // Puede ser el Id de una Opportunity o un Case.
        @InvocableVariable(required=true)
        public Id recordId;

        // Nombre del tipo de registro recibido.
        // Ejemplo:
        // 'Opportunity'
        // 'Case'
        @InvocableVariable(required=true)
        public String recordTypeName;
    }

    // =========================================================
    // MÉTODO INVOCABLE
    // Este método puede ser llamado desde un Flow.
    // Su función es recorrer la lista de solicitudes
    // y crear un Queueable por cada una.
    // =========================================================
    @InvocableMethod(label='Enviar notificación asíncrona')
    public static void enqueueNotifications(List<Request> requests) {

        // Recorro todas las solicitudes enviadas por el Flow
        for (Request req : requests) {

            // Creo un proceso asíncrono Queueable usando
            // el Id del registro y el tipo de objeto.
            // Esto permite que el envío del correo ocurra
            // en segundo plano sin afectar el Flow.
            System.enqueueJob(
                new NotificationQueueable(
                    req.recordId,
                    req.recordTypeName
                )
            );
        }
    }
}