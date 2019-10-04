public class PaymentHighway {
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';

    /* Payment API headers */
    private static final String USER_AGENT = 'PaymentHighway Apex Lib';
    private static final String SPH_API_VERSION = '20180426';

    /**
     * EXCEPTIONS
     */

    public class AuthenticationException extends Exception {}

    /**
     * RESPONSES
     */

    public class Result {
        String code;
        String message;

        public Result(String code, String message) {
            this.code = code;
            this.message = message;
        }

        public String getCode() {
            return code;
        }

        public String getMessage() {
            return message;
        }
    }

    public abstract class Response {
        public Result result;

        public Result getResult() {
            return this.result;
        }
    }

    public class InitTransactionResponse extends Response {
        String id = null;

        public String getId() {
            return id;
        }
    }

    public abstract class TransactionResponse extends Response {}

    public class DebitTransactionResponse extends TransactionResponse {
        private String filing_code;

        public String getFilingCode() {
            return filing_code;
        }
    }

    public class TokenizationResponse extends Response {
        public String type;
        public String card_token;
        public PaymentHighwayCard card;
        public PaymentHighwayCustomer customer;
        public String cardholder_authentication;
        public Boolean recurring;

        public String getType() {
            return type;
        }

        public String getCardToken() {
            return card_token;
        }

        public PaymentHighwayCard getCard() {
            return card;
        }

        public PaymentHighwayCustomer getCustomer() {
            return customer;
        }

        public String getCardholderAuthentication() {
            return cardholder_authentication;
        }

        public Boolean getRecurring() {
            return recurring;
        }
    }

    /**
     * REQUESTS
     */

    public abstract class Request {}

    public class TransactionRequest extends Request {
        private String amount = null;
        // Currency is reserved word in apex.
        private String myCurrency = null;
        private PaymentHighwayToken token = null;
        private PaymentHighwayCard card = null;
        private String order = null;
        private PaymentHighwayCustomer customer = null;
        // Commit is reserved word in apex
        private Boolean myCommit;
        private PaymentHighwaySplitting splitting;

        public TransactionRequest(PaymentHighwayToken token, String amount, String myCurrency) {
            this.token = token;
            this.amount = amount;
            this.myCurrency = myCurrency;
        }

        public String getAmount() {
            return amount;
        }

        public String getCurrency() {
            return myCurrency;
        }

        public PaymentHighwayToken getToken() {
            return token;
        }

        public String getOrder() {
            return order;
        }

        public void setOrder(String order) {
            this.order = order;
        }

        public PaymentHighwayCustomer getCustomer() {
            return customer;
        }

        public void setCustomer(PaymentHighwayCustomer customer) {
            this.customer = customer;
        }

        public Boolean getCommit() {
            return myCommit;
        }

        public void setCommit(Boolean myCommit) {
            this.myCommit = myCommit;
        }

        public PaymentHighwaySplitting getSplitting() {
            return splitting;
        }

        public void setSplitting(PaymentHighwaySplitting splitting) {
            this.splitting = splitting;
        }
    }

    /**
     * OTHER
     */

    public class NameValuePair implements Comparable {
        String name;
        String value;

        public NameValuePair(String name, String value) {
            this.name = name;
            this.value = value;
        }

        public Integer compareTo(Object compareTo) {
            return this.name.compareTo(((NameValuePair)compareTo).name);
        }

        public String getName() {
            return name;
        }

        public String getValue() {
            return value;
        }
    }

    private String serviceUrl = '';
    private String account = null;
    private String merchant = null;
    private PaymentHighwaySigner signer;

    public PaymentHighway(String serviceUrl, String keyId, String secret, String account, String merchant) {
        this.serviceUrl = serviceUrl;
        this.account = account;
        this.merchant = merchant;

        this.signer = new PaymentHighwaySigner(keyId, secret);
    }

    public PaymentHighwaySigner getSigner() {
        return signer;
    }

    /**
     * Init transaction
     *
     * In order to do safe transactions, an execution model is used where the first call
     * to /transaction acquires a financial transaction handle, later referred as "ID",
     * which ensures the transaction is executed exactly once.
     */
    public InitTransactionResponse initTransactionHandle() {
        String body = executeRequest(METHOD_POST, '/transaction');
        JSONParser parser = System.JSON.createParser(body);
        return (InitTransactionResponse)parser.readValueAs(InitTransactionResponse.class);
    }

    /**
     * Create a debit transaction to charge a card.
     */
    public DebitTransactionResponse debitTransaction(String transactionId, TransactionRequest request) {
        String requestUri = String.format('/transaction/{0}/debit', new String[]{
            transactionId
         });

        String requestBody = JSON.serialize(request, true);

        // Fix keys that were apex reserved keywords.
        requestBody = requestBody.replace('"myCurrency":', '"currency":');
        requestBody = requestBody.replace('"myCommit":', '"commit":');

        String response = executeRequest(METHOD_POST, requestUri, requestBody);
        JSONParser parser = System.JSON.createParser(response);
        return (DebitTransactionResponse)parser.readValueAs(DebitTransactionResponse.class);
    }

    /**
     * In order to be sure that a tokenized card is valid and is able to process
     * payment transactions the corresponding sph-tokenization-id must be used to
     * get the actual card token.
     *
     * The card token is fetched by calling the tokenization URI with the
     * sph-tokenization-id.
     */
    public TokenizationResponse tokenization(String tokenizationId) {
        String requestUri = String.format('/tokenization/{0}', new String[]{
            tokenizationId
         });

        String response = executeRequest(METHOD_GET, requestUri);

        JSONParser parser = System.JSON.createParser(response);
        return (TokenizationResponse)parser.readValueAs(TokenizationResponse.class);
    }

    private String getUTCTime() {
        return Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    // Should match regex: ^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}$
    private String generateRequestId() {
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        return
            h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + '4' +
            h.SubString(13,16) + '-' + 'a' + h.SubString(17,20) + '-' +
            h.substring(20);
    }

    private String executeRequest(String method, String requestUri) {
        return executeRequest(method, requestUri, '');
    }

    private String executeRequest(String method, String requestUri, String requestBody) {
        NameValuePair[] nameValuePairs = createNameValuePairs();

        String signature = this.signer.createSignature(
            method, requestUri, nameValuePairs, requestBody);
        nameValuePairs.add(new NameValuePair('signature', signature));

        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint(this.serviceUrl + requestUri);

        addHeaders(req, nameValuePairs);

        if (!String.isEmpty(requestBody)) {
            req.setBody(requestBody);
        }

        Http http = new Http();
        HttpResponse res = http.send(req);

        return handleResponse(method, requestUri, res);
    }

    private String handleResponse(String method, String uri, final HttpResponse response) {
        Integer status = response.getStatusCode();
        if (status >= 200 && status < 300) {
            String body = response.getBody();
            List<NameValuePair> headers = new List<NameValuePair>();
            for (String header : response.getHeaderKeys()) {
                headers.add(new NameValuePair(header, response.getHeader(header)));
            }

            if (!this.signer.validateSignature(method, uri, headers, body)) {
                throw new AuthenticationException(String.valueOf(status) + ': ' + response.getStatus());
            }

            return response.getBody();
        }
        else if (status == 401) {
            // Signals an authentication failure in Payment Highway.
            // Payment Highway couldn't validate signature from the given parameters.
            System.debug(LoggingLevel.ERROR, 'status: ' + status + ', ' + response.getBody());
            throw new AuthenticationException(String.valueOf(status) + ': ' + response.getStatus());
        }
        else {
            System.debug(LoggingLevel.ERROR, 'status: ' + status + ', ' + response.getBody());
            throw new CalloutException(String.valueOf(status) + ': ' + response.getStatus());
        }
    }


    private NameValuePair[] createNameValuePairs() {
        return new List<NameValuePair>{
            new NameValuePair('sph-api-version', SPH_API_VERSION),
            new NameValuePair('sph-account', this.account),
            new NameValuePair('sph-merchant', this.merchant),
            new NameValuePair('sph-timestamp', getUTCTime()),
            new NameValuePair('sph-request-id', generateRequestId())
        };
    }

    private void addHeaders(HttpRequest req, NameValuePair[] nameValuePairs) {
        req.setHeader('User-Agent', USER_AGENT);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        for (NameValuePair nameValuePair : nameValuePairs) {
            req.setHeader(nameValuePair.getName(), nameValuePair.getValue());
        }
    }
}