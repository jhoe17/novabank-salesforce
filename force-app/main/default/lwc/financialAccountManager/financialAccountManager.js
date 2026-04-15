import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/FinancialAccountController.getAccounts';
import deleteAccount from '@salesforce/apex/FinancialAccountController.deleteAccount';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FinancialAccountManager extends NavigationMixin(LightningElement) {

    data = [];

    columns = [
        { label: 'Número Tarjeta', fieldName: 'Numero_Tarjeta__c' },
        { label: 'Línea Crédito', fieldName: 'Linea_Credito__c', type: 'currency' },
        { label: 'Estado', fieldName: 'Estado__c' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Editar', name: 'edit' },
                    { label: 'Eliminar', name: 'delete' }
                ]
            }
        }
    ];

    // 🔹 LISTAR
    @wire(getAccounts)
    wiredData({ error, data }) {
        if (data) {
            this.data = data;
        }
    }

    // 🔹 ACCIONES
    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'edit') {
            this.editRecord(row.Id);
        } else if (action === 'delete') {
            this.deleteRecord(row.Id);
        }
    }

    // 🔹 CREAR
    handleNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'FinancialAccount__c',
                actionName: 'new'
            }
        });
    }

    // 🔹 EDITAR
    editRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'FinancialAccount__c',
                actionName: 'edit'
            }
        });
    }

    // 🔹 ELIMINAR
    deleteRecord(recordId) {
        deleteAccount({ recordId: recordId })
            .then(() => {
                this.showToast('Éxito', 'Registro eliminado', 'success');
            })
            .catch(() => {
                this.showToast('Error', 'Error al eliminar', 'error');
            });
    }

    // 🔹 TOAST
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}