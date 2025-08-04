public without sharing class PublishedBooksQueueable implements Queueable, Database.AllowsCallouts {
    @TestVisible
    private static Database.SaveResult sr;
    @TestVisible
    private static String errorMessage;
    private static VariousSettings__c settings = VariousSettings__c.getInstance();
    public void execute(QueueableContext context) {
        HttpRequest request = new HttpRequest();
        // https://eop0fqfuwjjx6lx.m.pipedream.net
        request.setEndpoint(settings.Endpoint__c);
        request.setMethod('GET');
        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                List<BookWrapper> listBooks = parseResponse(response.getBody());
                List<Book> filteredBooks = filterAndSortBooks(listBooks);
                if (!filteredBooks.isEmpty()) {
                    publishEvent(JSON.serialize(filteredBooks));
                }
            } else {
                errorMessage = response.getBody();
                System.debug('Error: ' + response.getStatusCode() + ', ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Error occurred while making callout: ' + e.getMessage());
            throw e;
        }
    }

    @TestVisible
    private class BookWrapper {
        public String Publisher;
        public List<Book> Books;
    }

    @TestVisible
    private class Book implements Comparable {
        public String Author;
        public String Title;
        public Integer Edition;

        public Integer compareTo(Object compareTo) {
            Book compareToBook = (Book) compareTo;

            if (Edition > compareToBook.Edition) {
                return -1;
            } else if (Edition < compareToBook.Edition) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    @TestVisible
    private static List<BookWrapper> parseResponse(String responseBody) {
        return (List<BookWrapper>) JSON.deserialize(responseBody, List<BookWrapper>.class);
    }

    @TestVisible
    private static List<Book> filterAndSortBooks(List<BookWrapper> listBW) {
        List<Book> listBooks = new List<Book>();
        for (BookWrapper bw : listBW) {
            for (Book b : bw.Books) {
                if (b.Edition >= settings.MinBooks__c) {
                    listBooks.add(b);
                }
            }
        }
        listBooks.sort();
        return listBooks;
    }

    private static void publishEvent(String books) {
        MostPublishedBooks__e event = new MostPublishedBooks__e(Books__c = books);
        if ((Limits.getDmlRows() < Limits.getLimitDmlRows()) &&
                (Limits.getPublishImmediateDML() < Limits.getLimitPublishImmediateDML())) {
            sr = EventBus.publish(event);
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        } else {
            System.debug('The Governor Limits have already been exhausted and hence failed to publish the platform.');
        }
    }
}