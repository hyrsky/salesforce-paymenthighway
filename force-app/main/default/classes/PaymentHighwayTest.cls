@isTest
public class PaymentHighwayTest {
    // No actual calls to payment highway api is made.
    public static final String TestServiceUrl = 'https://v1-hub-staging.sph-test-solinor.com';

    public static final String TestKeyId = 'testKey';
    public static final String TestSecret = 'testSecret';
    public static final String TestAccount = 'test';
    public static final String TestMerchant = 'test_merchantId';

    public class PaymentHighwayMock implements HttpCalloutMock {
        PaymentHighway.Signer signer;
        public Integer statusCode;
        public String body;
        public Boolean isCalled = false;

        public PaymentHighwayMock(PaymentHighway.Signer signer, String body, Integer statusCode) {
            this.signer = signer;
            this.body = body;
            this.statusCode = statusCode;
        }

        public PaymentHighwayMock(PaymentHighway.Signer signer, String body) {
            this.signer = signer;
            this.body = body;
            this.statusCode = 200;
        }

        public PaymentHighwayMock(PaymentHighway.Signer signer) {
            this.signer = signer;
            this.body = '';
            this.statusCode = 200;
        }

        public PaymentHighwayMock(PaymentHighway.Signer signer, Integer statusCode) {
            this.signer = signer;
            this.body = '';
            this.statusCode = statusCode;
        }

        /**
        * Generate paymenthighway response.
        *
        * This code relies on PaymentHighway.Signer validity.
        */
        public HttpResponse makeResponse(PaymentHighway.Signer signer, HttpRequest request,
                                                String body, Integer statusCode) {
            String requestId = request.getHeader('sph-request-id');
            if (requestId == null) {
                requestId = 'ca6e6695-da21-45b5-99af-c1234bcaf893';
            }

            String endpoint = request.getEndpoint().remove(TestServiceUrl);

            List<PaymentHighway.NameValuePair> keyValues = new List<PaymentHighway.NameValuePair>();
            keyValues.add(new PaymentHighway.NameValuePair('Content-Type', 'application/json'));
            keyValues.add(new PaymentHighway.NameValuePair('sph-response-id', '130d7d7b-952d-480e-87fd-97ca433191a5'));
            keyValues.add(new PaymentHighway.NameValuePair('sph-timestamp', '2018-08-16T02:08:09Z'));
            keyValues.add(new PaymentHighway.NameValuePair('sph-request-id', requestId));

            String signature = signer.createSignature(request.getMethod(), endpoint, keyValues, body);
            keyValues.add(new PaymentHighway.NameValuePair('signature', signature));

            HttpResponse response = new HttpResponse();
            for (PaymentHighway.NameValuePair pair : keyValues) {
                response.setHeader(pair.getName(), pair.getValue());
            }

            response.setBody(body);
            response.setStatusCode(statusCode);

            return response;
        }

        public HTTPResponse respond(HTTPRequest req) {
            this.isCalled = true;

            return makeResponse(this.signer, req, this.body, this.statusCode);
        }
    }


    public class ServerBadSignatureHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('signature', 'SPH1 testKey bad1dea');
            res.setHeader('sph-request-id', '61e49e82-8bc0-4509-880a-2c90a206fe84');
            res.setHeader('sph-response-id', '55a1ab50-c39d-46a9-9be5-d9cfc364bc7e');
            res.setHeader('sph-timestamp', '2018-06-22T00:53:43Z');                          
            res.setBody('{"id":"id","result":{"code":100,"message":"OK"}}');
            res.setStatusCode(200);
			return res;
        }
    }
    
    public static PaymentHighway createPaymentAPI() {
       	return new PaymentHighway(TestServiceUrl, TestKeyId, TestSecret, TestAccount, TestMerchant);
    }
    
    /**
     * Test PaymentHighway.Signer
     */

    @isTest
    static void testCreateSignature() {
        PaymentHighway.Signer signer = new PaymentHighway.Signer(TestKeyId, TestSecret);

        List<PaymentHighway.NameValuePair> keyValues = new List<PaymentHighway.NameValuePair>{
            new PaymentHighway.NameValuePair('Content-Type', 'application/json; charset=utf-8'),
            new PaymentHighway.NameValuePair('User-Agent', 'PaymentHighway Javascript Library'),
            new PaymentHighway.NameValuePair('sph-api-version', '20171127'),
            new PaymentHighway.NameValuePair('sph-account', 'test'),
            new PaymentHighway.NameValuePair('sph-merchant', 'test_merchantId'),
            new PaymentHighway.NameValuePair('sph-timestamp', '2018-06-22T01:16:42Z'),
            new PaymentHighway.NameValuePair('sph-request-id', '77dfe33c-db99-4679-b0b0-98429d6cf56e')
        };

        String signature = signer.createSignature('POST', '/transaction', keyValues, '');

        // Compare to magic value generated with official paymenthighway library.
        System.assertEquals(
            signature, 'SPH1 testKey e2d6bc32a084e2199d7bec7ae78633b8d15cfce55cddc0c8973429f4961e157a');
    }

    @isTest
    static void testValidateFormRedirect() {
        PaymentHighway.Signer signer = new PaymentHighway.Signer(TestKeyId, TestSecret);

        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('signature', 'SPH1 testKey 6137b1e32131ecf5b5ec6700a046957faf23ab534553884cd501346da8a68217');
        queryParams.put('sph-account', 'test');
        queryParams.put('sph-merchant', 'test_merchantId');
        queryParams.put('sph-tokenization-id', '667cab0b-6069-4f6b-8325-eb4734639e55');
        queryParams.put('sph-timestamp', '2018-08-16T02:05:17Z');
        queryParams.put('sph-request-id', 'f7682a58-75d3-4067-a19a-a80112a17642');
        queryParams.put('sph-success', 'OK');
        queryParams.put('unrelated', 'value');

        Boolean valid = signer.validateFormRedirect(queryParams);

        // Compare to magic value generated with official paymenthighway library.
        System.assertEquals(valid, true);
    }


    /**
     * Test PaymentAPI
     */

	@isTest
    static void testTokenize() {
        PaymentHighway paymentHighway = createPaymentAPI();
        String body = '{"card_token":"7cfb9e94-9753-44a2-9081-4d07c5a9fa36","recurring":false,"customer":{"network_address":"84.253.210.248","country_code":"FI"},"cardholder_authentication":"attempted","card":{"type":"Visa","partial_pan":"0024","expire_year":"2023","expire_month":"11","cvc_required":"no","bin":"415301","funding":"debit","country_code":"FI","category":"unknown"},"result":{"code":100,"message":"OK"}}';
        PaymentHighwayMock mock = new PaymentHighwayMock(paymentHighway.getSigner(), body);

        Test.setMock(HttpCalloutMock.class, mock);

        PaymentHighway.TokenizationResponse response = paymentHighway.tokenization('16f9d5e4-696b-47f0-a4f6-c78cb4bd10f0');

        System.assert(mock.isCalled, 'Mock should have received connection');
        System.assertNotEquals(null, response);
        System.assertEquals(response.getResult().getCode(), '100');
        System.assertEquals(response.getResult().getMessage(), 'OK');
        System.assertNotEquals(response.getCardToken(), null);
    }

	@isTest
    static void testInitTransaction() {
        PaymentHighway paymentHighway = createPaymentAPI();
        String body = '{"id":"a6b2755d-22eb-4a0c-92b1-69e3db388183","result":{"code":100,"message":"OK"}}';
        PaymentHighwayMock mock = new PaymentHighwayMock(paymentHighway.getSigner(), body);

        Test.setMock(HttpCalloutMock.class, mock);

        PaymentHighway.InitTransactionResponse response = paymentHighway.initTransactionHandle();

        System.assert(mock.isCalled, 'Mock should have received connection');
        System.assertNotEquals(null, response);
        System.assertEquals(response.getResult().getCode(), '100');
        System.assertEquals(response.getResult().getMessage(), 'OK');
        System.assertEquals(response.getId(), 'a6b2755d-22eb-4a0c-92b1-69e3db388183');
    }
    
    @isTest
    static void testDebitWithToken() {
        PaymentHighway paymentHighway = createPaymentAPI();
        String body = '{"filing_code":"180622548594","result":{"code":100,"message":"OK"}}';
        PaymentHighwayMock mock = new PaymentHighwayMock(paymentHighway.getSigner(), body);

        Test.setMock(HttpCalloutMock.class, mock);

        PaymentHighway.Token token = 
            new PaymentHighway.Token('7cfb9e94-9753-44a2-9081-4d07c5a9fa36');
        PaymentHighway.TransactionRequest request = 
            new PaymentHighway.TransactionRequest(token, '1990', 'EUR');
        
        request.setOrder('Test');
        request.setCommit(true);
        request.setCustomer(new PaymentHighway.Customer('customer', 'GB'));

        /*
        // Check that hacks for apex reserved keywords are not present.
        System.assert(!requestBody.contains('myCurrency'));
        System.assert(!requestBody.contains('myCommit'));
        */

        System.assertEquals(request.getCurrency(), 'EUR');

        PaymentHighway.DebitTransactionResponse response = 
            paymentHighway.debitTransaction('b988b77e-ca47-46c7-a4ae-27f6b8190b6b', request);

        System.assert(mock.isCalled, 'Mock should have received connection');
        System.assertNotEquals(response, null);
        System.assertEquals(response.getResult().getCode(), '100');
        System.assertEquals(response.getResult().getMessage(), 'OK');
        System.assertEquals(response.getFilingCode(), '180622548594');
    }
    
    @isTest
    static void testServerErrors() {
        PaymentHighway paymentHighway = createPaymentAPI();
        PaymentHighwayMock mock = new PaymentHighwayMock(paymentHighway.getSigner(), 'Authentication HMAC mismatch', 401);
        Test.setMock(HttpCalloutMock.class, mock);

        // Test server unauthorized
      	PaymentHighway.AuthenticationException authException;

        try {
            PaymentHighway.InitTransactionResponse response = paymentHighway.initTransactionHandle();
        }
        catch (PaymentHighway.AuthenticationException e) {
            authException = e;
        }

        System.assertNotEquals(authException, null);

        // Test server bad signature
        Test.setMock(HttpCalloutMock.class, new ServerBadSignatureHttpCalloutMock());
      	authException = null;

        try {
            PaymentHighway.InitTransactionResponse response = paymentHighway.initTransactionHandle();
        }
        catch (PaymentHighway.AuthenticationException e) {
            authException = e;
        }

        System.assertNotEquals(authException, null);

        // Test server error
        mock = new PaymentHighwayMock(paymentHighway.getSigner(), 'The server refuses to brew coffee because it is a teapot.', 418);
        Test.setMock(HttpCalloutMock.class, mock);
        CalloutException calloutException;

        try {
            PaymentHighway.InitTransactionResponse response = paymentHighway.initTransactionHandle();
        }
        catch (CalloutException e) {
            calloutException = e;
        }

        System.assertNotEquals(authException, null);
    }
}