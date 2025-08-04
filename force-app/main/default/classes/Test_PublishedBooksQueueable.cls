@IsTest
public with sharing class Test_PublishedBooksQueueable {
    @IsTest
    static void testCommonExecute() {
        insert (new VariousSettings__c(Endpoint__c = 'test.com', MinBooks__c = 600000));
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock());
        Test.startTest();
            System.enqueueJob(new PublishedBooksQueueable());
        Test.stopTest();
        Assert.isTrue(PublishedBooksQueueable.sr.isSuccess(), 'Platform event should be published');
    }

    @IsTest
    static void testErrorResponse() {
        insert (new VariousSettings__c(Endpoint__c = 'test.com', MinBooks__c = 600000));
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(300));
        Test.startTest();
            System.enqueueJob(new PublishedBooksQueueable());
        Test.stopTest();
        Assert.isTrue(String.isNotBlank(PublishedBooksQueueable.errorMessage), 'Error message should not be empty');
        Assert.areEqual(TestHttpCalloutMock.NOT_FOUND_ERROR_BODY, PublishedBooksQueueable.errorMessage, 'Should return error message');
    }

    @IsTest
    static void testParseResponse() {
        List<PublishedBooksQueueable.BookWrapper> listBooks = PublishedBooksQueueable.parseResponse(TestHttpCalloutMock.SUCCESS_RESPONSE);
        Assert.areEqual(1, listBooks.size(), 'List should contain 1 element');
        Assert.areEqual(3, listBooks.get(0).Books.size(), 'List should contain 3 elements');
    }

    @IsTest
    static void testFilterAndSortBooks() {
        insert (new VariousSettings__c(MinBooks__c = 600000));
        List<PublishedBooksQueueable.BookWrapper> listBooks = PublishedBooksQueueable.parseResponse(TestHttpCalloutMock.SUCCESS_RESPONSE);
        List<PublishedBooksQueueable.Book> filteredBooks = PublishedBooksQueueable.filterAndSortBooks(listBooks);
        Assert.areEqual(2, filteredBooks.size(), 'List should contain 2 elements');
        Assert.isTrue(filteredBooks.get(0).Edition.equals(1000000), 'List should be sorted desc');
    }
}