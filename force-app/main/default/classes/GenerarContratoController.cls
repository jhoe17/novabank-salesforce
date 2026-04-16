public with sharing class GenerarContratoController {

    private Id opportunityId;

    public GenerarContratoController(ApexPages.StandardController stdController) {
        this.opportunityId = stdController.getId();
    }

    public PageReference generarYRedirigir() {
        ContratoGeneratorService.generarContrato(opportunityId);

        PageReference oppPage = new ApexPages.StandardController(
            new Opportunity(Id = opportunityId)
        ).view();

        oppPage.setRedirect(true);
        return oppPage;
    }
}