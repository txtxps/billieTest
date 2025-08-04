@IsTest
public with sharing class Test_BooksController {
    @IsTest
    static void testGetBooksCallout() {
        insert (new VariousSettings__c(Endpoint__c = 'test.com', MinBooks__c = 600000));
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
        Test.startTest();
            BooksController.getBooksCallout();
        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClass.Name
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'PublishedBooksQueueable'
            AND JobType = 'Queueable'
        ];
        Assert.areEqual(1, jobs.size(), 'Expected one queueable job to be enqueued');
    }
}