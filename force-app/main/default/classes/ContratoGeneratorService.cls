public with sharing class ContratoGeneratorService {

    @AuraEnabled
    public static Id generarContrato(Id opportunityId) {
        PageReference pdfPage = Page.ContratoOpportunity;
        pdfPage.getParameters().put('id', opportunityId);

        Blob pdfBlob;

        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('PDF de prueba');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Contrato_' + String.valueOf(opportunityId);
        cv.PathOnClient = 'Contrato_' + String.valueOf(opportunityId) + '.pdf';
        cv.VersionData = pdfBlob;
        insert cv;

        cv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = opportunityId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        return cv.ContentDocumentId;
    }
}