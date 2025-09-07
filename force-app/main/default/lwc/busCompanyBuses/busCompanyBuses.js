import { LightningElement, api, track, wire } from 'lwc';
import getBusesWithPassengers from '@salesforce/apex/BusCompanyActions.getBusesWithPassengers';

export default class BusCompanyBuses extends LightningElement {
    @api recordId; 

    @track loading = true;
    @track busesData;
    @track busesError;

    @wire(getBusesWithPassengers, { busCompanyId: '$recordId' })
    wiredBuses({ error, data }) {
        if (data) {
            this.busesData = data;
            this.busesError = null;
            this.loading = false;
        } else if (error) {
            this.busesError = error;
            this.busesData = null;
            this.loading = false;
        }
    }

    get showNoBuses() {
        return !this.busesData && !this.loading && !this.busesError;
    }
}
