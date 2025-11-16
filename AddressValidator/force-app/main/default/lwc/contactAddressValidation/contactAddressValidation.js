import { LightningElement, api, track } from 'lwc';
import validateAddress_old from '@salesforce/apex/ContactAddressValidation.validateAddress';
import validateAddress_new from '@salesforce/apex/AddressValidationController.validateAddress';
import { RefreshEvent } from 'lightning/refresh';

export default class ContactAddressValidation extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track contact;
    @track error;
    @track message;

    /*handleValidate() {
        validateAddress_old({ recordId: this.recordId })
          .then((result) => {
            this.contact = result;
            this.message = 'button clicked';
            this.dispatchEvent(new RefreshEvent());
          })
          .catch((error) => {
            this.error = error;
          });
      }*/

      handleValidate() {
        validateAddress_new({ recordIds: this.recordId})
          .then((result) => {
            this.contact = result;
            this.message = 'button clicked';
            this.dispatchEvent(new RefreshEvent());
          })
          .catch((error) => {
            this.error = error;
          });
      }
}