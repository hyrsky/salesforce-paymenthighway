public class PaymentHighwayCustomer {
    String network_address;
    String country_code;

    public PaymentHighwayCustomer(String networkAddress, String countryCode) {
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
