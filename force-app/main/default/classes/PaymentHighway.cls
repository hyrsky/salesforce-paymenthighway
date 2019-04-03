public class PaymentHighway {
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_GET = 'GET';

    /* Payment API headers */
    private static final String USER_AGENT = 'PaymentHighway Apex Lib';
    private static final String SPH_API_VERSION = '20180426';
    
    private static final String SignatureScheme = 'SPH1';
    private static final String SignatureAlgorithm = 'hmacSHA256';
    
    public class AuthenticationException extends Exception {}

    public class Card {
        String type;
        String pan;
        String partial_pan;

        // PaymentHighway has two Card types with slightly different variable names.
        String expire_year;
        String expiry_year;
        String expire_month;
        String expiry_month;
        
        String cvc;
        String cvc_required;
        String bin;
        String funding;
        String category;
        String country_code;
        
        public Card(String pan, String expiryYear, String expiryMonth, String cvc) {
            this.pan = pan;
            this.expiry_year = expiryYear;
            this.expiry_month = expiryMonth;
            this.cvc = cvc;
        }

        public Card(String type, String expiryYear, String expiryMonth) {
            this.type = type;
            this.expiry_year = expiryYear;
            this.expiry_month = expiryMonth;
        }

        public String getType() {
            return type;
        }
        
        public String getPan() {
            return pan;
        }
        
        public String getExpiryYear() {
            if (expiry_year != null) {
                return expiry_year;
            }
            return expire_year;
        }
        
        public String getExpiryMonth() {
            if (expiry_month != null) {
                return expiry_month;
            }
            return expire_month;
        }
        
        public Date getExpiryDate() {
            Integer year = Integer.valueOf(getExpiryYear());
            Integer month = Integer.valueOf(getExpiryMonth());
            
            return Date.newInstance(year, month, Date.daysInMonth(year, month));
        }
        
        public String getCvc() {
            return cvc;
        }
        
        public String getCvcRequired() {
            return cvc_required;
        }
        
        public String getBin() {
            return bin;
        }
        
        public String getFunding() {
            return funding;
        }
        
        public String getCategory() {
            return category;
        }
        
        public String getCountryCode() {
            return country_code;
        }
    }

    public class Token {
        String id;        
        String cvc;
        
        public Token(String id) {
            this.id = id;
        }
        
        public Token(String id, String cvc) {
            this.id = id;
            this.cvc = cvc;
        }

        public String getId() {
            return id;
        }
        
        public String getCvc() {
            return cvc;
        }
    }

    public class Customer {
        String network_address;
        String country_code;
        
        public Customer(String networkAddress, String countryCode) {
            this.network_address = networkAddress;
            this.country_code = countryCode;
        }
        
        public String getNetworkAddress() {
            return network_address;
        }
        
        public String getCountryCode() {
            return country_code;
        }
    }

    public class Splitting {
        String merchantId;
        Long amount;
        
        public Splitting(String merchantId, Long amount) {
            this.merchantId = merchantId;
            this.amount = amount;
        }
        
        public String getMerchantId() {
            return merchantId;
        }
        
        public Long getAmount() {
            return amount;
        }
    }
    
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
        public Card card;
        public Customer customer;
        public String cardholder_authentication;
        public Boolean recurring;
        
        public String getType() {
            return type;
        }
        
        public String getCardToken() {
            return card_token;
        }
        
        public Card getCard() {
            return card;
        }
        
        public Customer getCustomer() {
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
     * * * * * * * *
     * END RESPONSES  /\
     * * * * * * * *
     * REQUESTS       \/
     * * * * * * * *
     */

    public abstract class Request {}
    
    public class TransactionRequest extends Request {
        private String amount = null;
        // Currency is reserved word in apex.
        private String myCurrency = null;
        private Token token = null;
        private Card card = null;
        private String order = null;
        private Customer customer = null;
        // Commit is reserved word in apex
        private Boolean myCommit;
        private Splitting splitting;
        
        public TransactionRequest(Token token, String amount, String myCurrency) {
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
        
        public Token getToken() {
            return token;
        }

        public String getOrder() {
            return order;
        }
        
        public void setOrder(String order) {
            this.order = order;
        }
        
        public Customer getCustomer() {
            return customer;
        }
        
        public void setCustomer(Customer customer) {
            this.customer = customer;
        }
        
        public Boolean getCommit() {
            return myCommit;
        }
        
        public void setCommit(Boolean myCommit) {
            this.myCommit = myCommit;
        }

        public Splitting getSplitting() {
            return splitting;
        }
        
        public void setSplitting(Splitting splitting) {
            this.splitting = splitting;
        }
    }
    
    /**
     * END REQUESTS
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
    
    public class Signer {
        private String keyId = null;
        private String key = null;
        
        public Signer(String keyId, String key) {
            this.keyId = keyId;
            this.key = key;
        }
        
        /**
         * Create signature
         *
         * @param method HTTP method
         * @param uri URI
         * @param keyValues Name value pairs
         * @param body Body
         * @return String eg:
         * "SPH1 testKey 51dcbaf5a9323daed24c0cdc5bb5d344f321aa84435b64e5da3d8f6c49370532"
         */
        public String createSignature(String method, String uri, List<NameValuePair> keyValues, String body) {
            return String.format('{0} {1} {2}', new String[]{
                SignatureScheme, 
                keyId,
                sign(method, uri, keyValues, body)
            });
        }
        
        /**
         * Create signature String from the actual parameters
         *
         * @param method HTTP method
         * @param uri URI
         * @param keyValues Name value pairs
         * @param body Body
         * @return String signature
         */
        private String sign(String method, String uri, List<NameValuePair> keyValues, String body) {
            String stringToSign = String.format('{0}\n{1}\n{2}\n{3}', new String[]{
                method, uri, concatenateKeyValues(keyValues), body.trim()});

            Blob hmacData = Crypto.generateMac(
                SignatureAlgorithm,
                Blob.valueOf(stringToSign),
                Blob.valueOf(this.key));

            return EncodingUtil.convertToHex(hmacData).toLowerCase();
        }
        
        /**
         * Validates the response by checking the provided signature against the calculated one.
         *
         * @param method HTTP METHOD e.g. POST or GET
         * @param uri The request URI
         * @param keyValues The key value pairs of headers or request parameters
         * @param content The body content
         * @return True if signature is found and matches the calculated one
         */
        public boolean validateSignature(String method, String uri, List<NameValuePair> keyValues, String content) {
            String receivedSignature = findSignature(keyValues);
            
            if (String.isEmpty(receivedSignature)) {
                return false;
            } else {
                String createdSignature = this.createSignature(method, uri, keyValues, content);
                return receivedSignature.equals(createdSignature);
            }
        }
        
        /**
         * Validates the response redirection by checking the provided signature against the calculated one.
         *
           * @param keyValues The request parameters from the redirection
           * @return True if form redirect was valid
         */
        public boolean validateFormRedirect(Map<String, String> keyValues) {
            List<NameValuePair> nameValuePairs = 
                new List<NameValuePair>();
            
            for (String key : keyValues.keySet()) {   
                nameValuePairs.add(new NameValuePair(
                    key, keyValues.get(key)));
            }

            return validateSignature(
                METHOD_GET,
                '',
                nameValuePairs, 
                ''
            );
        }

        private String findSignature(List<NameValuePair> nameValuePairs) {
            String receivedSignature = '';
            
            for (NameValuePair entry : nameValuePairs) {
                if (entry.getName().equalsIgnoreCase('signature')) {
                    receivedSignature = entry.getValue();
                    break;
                }
            }
            
            return receivedSignature;
        }
        
        private String concatenateKeyValues(List<NameValuePair> sphParameters) {
            sphParameters.sort();
            String keyValuesString = '';
            for (NameValuePair entry : sphParameters) {
                // Signature is formed from parameters that start with "sph-"
                if(entry.getName().startsWithIgnoreCase('sph-')) {
                    keyValuesString += entry.getName().toLowerCase() + ':' + entry.getValue() + '\n';
                }
            }
            
            // Remove last newline
            return keyValuesString.removeEnd('\n');
        }
    }
    
    private String serviceUrl = '';
    private String account = null;
    private String merchant = null;
    private Signer signer;
    
    public PaymentHighway(String serviceUrl, String keyId, String secret,
                          String account, String merchant) {
        this.serviceUrl = serviceUrl;
        this.account = account;
        this.merchant = merchant;

        this.signer = new Signer(keyId, secret);
    }
    
    public Signer getSigner() {
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
        List<NameValuePair> nameValuePairs = createNameValuePairs();
        
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

    
    private List<NameValuePair> createNameValuePairs() {
        return new List<NameValuePair>{
            new NameValuePair('sph-api-version', SPH_API_VERSION),
            new NameValuePair('sph-account', this.account),
            new NameValuePair('sph-merchant', this.merchant),
            new NameValuePair('sph-timestamp', getUTCTime()),
            new NameValuePair('sph-request-id', generateRequestId())
        };
    }
    
    private void addHeaders(HttpRequest req, List<NameValuePair> nameValuePairs) {
        req.setHeader('User-Agent', USER_AGENT);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        for (NameValuePair nameValuePair : nameValuePairs) {
            req.setHeader(nameValuePair.getName(), nameValuePair.getValue());
        }
    } 
}