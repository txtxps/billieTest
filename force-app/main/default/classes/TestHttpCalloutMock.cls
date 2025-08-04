public class TestHttpCalloutMock implements HttpCalloutMock {
    @TestVisible
    private final static String NOT_FOUND_ERROR_BODY = '{"code": 404, "message": "HTTP 404 Not Found"}';
    @TestVisible
    private final static String SUCCESS_RESPONSE = '[{"Publisher": "O\'Reilly Media", "Books": [{"Author": "Eric Freeman", '
        + '"Title": "Head First Design Patterns", "Edition": 1000000}, {"Author": "David Flanagan", "Title": '
        + '"JavaScript: The Definitive Guide", "Edition": 500000}, {"Author": "Mark Lutz", "Title": "Learning Python",'
        + '"Edition": 700000}]}]';

    private String body;
    private final Integer statusCode;

    public TestHttpCalloutMock() {
        this(200);
    }

    public TestHttpCalloutMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    public HttpResponse respond(HttpRequest req) {
        if (statusCode != 200) {
            body = NOT_FOUND_ERROR_BODY;
            return createResponse();
        }
        body = SUCCESS_RESPONSE;
        return createResponse();
    }

    private HttpResponse createResponse() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(body);
        return res;
    }
}