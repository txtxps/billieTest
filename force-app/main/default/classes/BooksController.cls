public without sharing class BooksController {
    @AuraEnabled
    public static void getBooksCallout() {
        System.enqueueJob(new PublishedBooksQueueable());
    }
}