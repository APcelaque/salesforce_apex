import { LightningElement, api, wire } from "lwc";
import getMoraStatus from '@salesforce/apex/MoraController.getMoraStatus';

export default class MoraAlert extends LightningElement {
    @api recordId;
    showAlert = false;

    @wire(tieneMora, { opportunityId: '$recordId' })
    wiredMora({ error, data }) {
        if (data) {
            this.showAlert = data;
        } else if (error) {
            console.error('Error al verificar mora:', error);
        }
    }
}

// Create an alert modal within your component that communicates a state that affects the entire system, not just a feature or page. (Lightning Web Components)

// async handleAlertClick() {
//   await LightningAlert.open({
//     message: "this is the alert message",
//     variant: "header", // if headerless, theme not applicable
//     theme: "default", 
//     label: "Error", // this is the header text
//   });
//   //Alert has been closed
  
// }