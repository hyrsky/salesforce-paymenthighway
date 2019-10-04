public class PaymentHighwaySigner {
    private static final String SIGNATURE_SCHEME = 'SPH1';
    private static final String SIGNATURE_ALGORITHM = 'hmacSHA256';

    private String keyId = null;
    private String key = null;

    public PaymentHighwaySigner(String keyId, String key) {
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
    public String createSignature(String method, String uri, PaymentHighway.NameValuePair[] keyValues, String body) {
        return String.format('{0} {1} {2}', new String[]{
            SIGNATURE_SCHEME,
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
    private String sign(String method, String uri, PaymentHighway.NameValuePair[] keyValues, String body) {
        String stringToSign = String.format('{0}\n{1}\n{2}\n{3}', new String[]{
            method, uri, concatenateKeyValues(keyValues), body.trim()});

        Blob hmacData = Crypto.generateMac(
            SIGNATURE_ALGORITHM,
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
    public boolean validateSignature(String method, String uri, PaymentHighway.NameValuePair[] keyValues, String content) {
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
        PaymentHighway.NameValuePair[] nameValuePairs =
            new List<PaymentHighway.NameValuePair>();

        for (String key : keyValues.keySet()) {
            nameValuePairs.add(new PaymentHighway.NameValuePair(
                key, keyValues.get(key)));
        }

        return validateSignature(
            PaymentHighway.METHOD_GET,
            '',
            nameValuePairs,
            ''
        );
    }

    private String findSignature(PaymentHighway.NameValuePair[] nameValuePairs) {
        String receivedSignature = '';

        for (PaymentHighway.NameValuePair entry : nameValuePairs) {
            if (entry.getName().equalsIgnoreCase('signature')) {
                receivedSignature = entry.getValue();
                break;
            }
        }

        return receivedSignature;
    }

    private String concatenateKeyValues(PaymentHighway.NameValuePair[] sphParameters) {
        sphParameters.sort();
        String keyValuesString = '';
        for (PaymentHighway.NameValuePair entry : sphParameters) {
            // Signature is formed from parameters that start with "sph-"
            if(entry.getName().startsWithIgnoreCase('sph-')) {
                keyValuesString += entry.getName().toLowerCase() + ':' + entry.getValue() + '\n';
            }
        }

        // Remove last newline
        return keyValuesString.removeEnd('\n');
    }
}
