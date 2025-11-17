public class MockResponseController implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().contains('us-street.api.smarty')) {
                return new MockSmartyAPIUsResponse().respond(req);
            } else {
                return new MockSmartyAPIINTResponse().respond(req);
            }
        }
}