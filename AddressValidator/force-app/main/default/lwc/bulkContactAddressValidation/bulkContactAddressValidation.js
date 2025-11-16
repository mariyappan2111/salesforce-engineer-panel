import { LightningElement, track } from 'lwc';
import validateAddressBulk from '@salesforce/apex/AddressValidationController.validateAddress';
import getAllContacts from '@salesforce/apex/AddressValidationController.getContacts';
import getTotalContactCount from '@salesforce/apex/AddressValidationController.getTotalContactCount';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BulkContactAddressValidation extends LightningElement {
    @track contactList = [];
    @track selectedIds = [];
    @track currentPage = 1;
    @track pageSize = 6;
    @track totalRecords = 0;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getAllContacts({ pageNumber: this.currentPage, pageSize: this.pageSize })
            .then((result) => {
                if (result) {
                    this.contactList = result.map(contact => ({
                        ...contact,
                        selected: this.selectedIds.includes(contact.Id),
                        badgeClass: contact.AddressValid__c === 'true' || contact.AddressValid__c === true ? 'slds-theme_success' : 'slds-theme_error'
                    }));
                } else {
                    this.contactList = [];
                    this.showToast('Info', 'No contacts found', 'info');
                }
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'Error loading contacts', 'error');
            });
        getTotalContactCount().then((count) => {
            this.totalRecords = count;
        });
    }

    handleValidate() {
        if (this.selectedIds.length === 0) {
            this.showToast('Warning', 'Please select at least one contact', 'warning');
            return;
        }

        validateAddressBulk({ recordIds: this.selectedIds })
            .then((result) => {
                if (result) {
                    const resultMap = new Map(result.results.map(r => [r.contactId, r]));
                    this.contactList = this.contactList.map(contact => {
                        if (resultMap.has(contact.Id)) {
                            const validationResult = resultMap.get(contact.Id);
                            return {
                                ...contact,
                                AddressValid__c: validationResult.isValid,
                                selected: this.selectedIds.includes(contact.Id),
                                badgeClass: validationResult.isValid ? 'slds-theme_success' : 'slds-theme_error'
                            };
                        }
                        return contact;
                    });
                    this.dispatchEvent(new RefreshEvent());
                    this.showToast('Success', 'address(es) validated successfully', 'success');
                } else {
                    this.showToast('Info', 'No records validated', 'info');
                }
            })
            .catch((error) => {
                this.showToast('Error', error.body?.message || 'Error validating addresses', 'error');
            });
        this.dispatchEvent(new RefreshEvent());
    }

    handleSelectAll(event) {
        const checked = event.target.checked;
        const checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
        checkboxes.forEach(box => {
            box.checked = checked;
        });
        const currentPageIds = this.paginatedContacts.map(c => c.Id);

        if (checked) {
            currentPageIds.forEach(id => {
                if (!this.selectedIds.includes(id)) {
                    this.selectedIds.push(id);
                }
            });
        } else {
            this.selectedIds = this.selectedIds.filter(id => !currentPageIds.includes(id));
        }
        this.contactList = this.contactList.map(ct => ({ ...ct, selected: this.selectedIds.includes(ct.Id) }));
    }

    handleSelect(event) {
        const id = event.target.value;
        if (event.target.checked) {
            if (!this.selectedIds.includes(id)) {
                this.selectedIds = [...this.selectedIds, id];
            }
        } else {
            this.selectedIds = this.selectedIds.filter(item => item !== id);
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadData();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadData();
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get paginatedContacts() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.contactList.slice(start, end);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage >= this.totalPages;
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get isValidateDisabled() {
        return this.selectedIds.length === 0;
    }

    get showPagination() {
        return this.totalRecords > this.pageSize;
    }
}