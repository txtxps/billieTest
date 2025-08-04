import { LightningElement } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import getBooksCallout from '@salesforce/apex/BooksController.getBooksCallout';

export default class PublischedBooks extends LightningElement {
    books = [];
    subscription = null;

    async connectedCallback() {
        this.subscription = await subscribe(
          '/event/MostPublishedBooks__e',
          -1,
          (event) => this.handleEvent(event)
        );
    }

    async disconnectedCallback() {
      await unsubscribe(this.subscription);
    }

    handleEvent(event) {
        try {
            this.books = JSON.parse(event.data.payload.Books__c);
        } catch (error) {
            console.error('Error parsing books data: ', error);
        }
    }

    handleGetBooks() {
        try {
            getBooksCallout();
        } catch (error) {
            console.error('Error invoking callout:', error);
        }
    }
}