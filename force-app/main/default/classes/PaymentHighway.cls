public class PaymentHighway {
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';

    /* Payment API headers */
    private static final String USER_AGENT = 'PaymentHighway Apex Lib';
    private static final String SPH_API_VERSION = '20190430';

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

    public virtual class TransactionResponse extends Response {
        private String filing_code;

        public String getFilingCode() {
            return filing_code;
        }
    }

    public class DebitTransactionResponse extends TransactionResponse {
    }

    public class ChargeMitResponse extends TransactionResponse {
    }

    public class TokenizationResponse extends Response {
        public String type;
        public String card_token;
        public PaymentHighwayPartialCard card;
        public PaymentHighwayCustomer customer;
        public String cardholder_authentication;
        public Boolean recurring;

        public String getType() {
            return type;
        }

        public String getCardToken() {
            return card_token;
        }

        public PaymentHighwayPartialCard getPartialCard() {
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

    public abstract class Request {
        public abstract String getRequestBody();
    }

    public class TransactionRequest extends Request {
        /** Payment amount */
        private String amount = null;
        /** Payment currency (NOTE: Currency is reserved word in apex!) */
        private String myCurrency = null;
        /** Card token to charge */
        private PaymentHighwayToken token = null;
        /** Card to charge (Only for PCI DSS certified parties!) */
        //private PaymentHighwayCard card = null;
        /** Merchant-provided order ID for the purchase. Alphanumeric with dashes and underscores. Max length 254. */
        private String order = null;
        private PaymentHighwayCustomer customer = null;
        private Boolean myCommit; // Commit is reserved word in apex
        private PaymentHighwaySplitting splitting;


        /**
         * Payment using a card token when the customer is not participating in the payment flow.
         * A contract and understanding between the merchant and the customer must be established, allowing this kind of payments.

         * @param token Card token to charge
         * @param amount Payment amount
         * @param currency Payment currency
         * @param order Merchant-provided order ID for the purchase. Alphanumeric with dashes and underscores. Max length 254.
         * @return Builder
         */
        public TransactionRequest(PaymentHighwayToken token, String amount, String myCurrency, String order) {
            this.token = token;
            this.amount = amount;
            this.myCurrency = myCurrency;
            this.order = order;
        }

        /**
        * Payment with card details when the customer is participating in the payment flow. Only for PCI DSS certified parties!
        * A contract and understanding between the merchant and the customer must be established, allowing this kind of payments.
        * The usage of card must be specifically agreed upon. Normally use the token instead.
        *
        * @param card Card to charge (Only for PCI DSS certified parties!)
        * @param amount Payment amount
        * @param currency Payment currency
        * @param order Merchant-provided order ID for the purchase. Alphanumeric with dashes and underscores. Max length 254.
        */
        // public TransactionRequest(PaymentHighwayCard card, String amount, String myCurrency, String order)

        public TransactionRequest setCustomer(PaymentHighwayCustomer customer) {
            this.customer = customer;
            return this;
        }

        public TransactionRequest  setCommit(Boolean myCommit) {
            this.myCommit = myCommit;
            return this;
        }

        public TransactionRequest setSplitting(PaymentHighwaySplitting splitting) {
            this.splitting = splitting;
            return this;
        }

        public override String getRequestBody() {
            String requestBody = JSON.serialize(this, true);

            // Fix json keys that are apex reserved keywords.
            requestBody = requestBody.replace('"myCurrency":', '"currency":');
            requestBody = requestBody.replace('"myCommit":', '"commit":');

            return requestBody;
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

        public PaymentHighwayCustomer getCustomer() {
            return customer;
        }

        public Boolean getCommit() {
            return myCommit;
        }

        public PaymentHighwaySplitting getSplitting() {
            return splitting;
        }
    }

    /**
     * Revert Transaction request
     */
    public class RevertTransactionRequest extends Request {
        private String amount = null;
        private boolean blocking = true;

        /**
        * Reverts the full amount
        */
        public RevertTransactionRequest() {
        }

        public override String getRequestBody() {
            return JSON.serialize(this, true);
        }

        /**
        * reverts specified amount
        *
        * @param amount Amount to revert
        */
        public RevertTransactionRequest(String amount) {
            this.amount = amount;
        }

        public String getAmount() {
            return amount;
        }

        public boolean isBlocking() {
            return blocking;
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
     * When charging the customer's card in a context, where the customer is not actively
     * participating in the transaction, you should use the chargeMerchantInitiatedTransaction
     * method. The MIT transactions are exempt from the strong customer authentication requirements
     * of PSD2, thus the payment cannot receive the "soft-decline" response (code 400), unlike in
     * the case of customer initiated transactions.
     */
    public ChargeMitResponse chargeMerchantInitiatedTransaction(String transactionId, TransactionRequest request) {
        String requestUri = String.format('/transaction/{0}/card/charge/merchant_initiated', new String[]{
            transactionId
         });

        String response = executeRequest(METHOD_POST, requestUri, request.getRequestBody());

        JSONParser parser = System.JSON.createParser(response);
        return (ChargeMitResponse)parser.readValueAs(ChargeMitResponse.class);
    }

    /**
     * Create a debit transaction to charge a card.
     *
     * NOTE: The debitTransaction method is deprecated since Sep 14th 2019 in favor of the new
     * chargeCustomerInitiatedTransaction and chargeMerchantInitiatedTransaction in order to comply
     * with the EU's PSD2 directive.
     */
    public DebitTransactionResponse debitTransaction(String transactionId, TransactionRequest request) {
        String requestUri = String.format('/transaction/{0}/debit', new String[]{
            transactionId
        });

        String response = executeRequest(METHOD_POST, requestUri, request.getRequestBody());
        JSONParser parser = System.JSON.createParser(response);
        return (DebitTransactionResponse)parser.readValueAs(DebitTransactionResponse.class);
    }

    /**
     * Payment Highway Revert Full Transaction
     *
     * @param transactionId Transaction id
     * @return Transaction response
     */
    public TransactionResponse revertTransaction(String transactionId) {
        return this.revertTransaction(transactionId, null);
    }

    /**
     * Payment Highway Revert Partial Transaction
     *
     * @param transactionId Transaction id
     * @param amount Amount to revert
     * @return Transaction response
     */
    public TransactionResponse revertTransaction(String transactionId, String amount) {
        RevertTransactionRequest request = new RevertTransactionRequest(amount);
        String requestUri = String.format('"/transaction/{0}/revert', new String[]{
            transactionId
        });

        String response = executeRequest(METHOD_POST, requestUri, request.getRequestBody());
        JSONParser parser = System.JSON.createParser(response);
        return (TransactionResponse)parser.readValueAs(TransactionResponse.class);
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