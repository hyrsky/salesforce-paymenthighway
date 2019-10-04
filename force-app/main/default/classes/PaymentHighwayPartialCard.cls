public class PaymentHighwayPartialCard {
    private String partial_pan;
    private String type;
    private String expire_year;
    private String expire_month;
    private String cvc_required;
    private String bin;

    private String funding;
    private String category;

    private String country_code;

    private String card_fingerprint;
    private String pan_fingerprint;

    public String getPartialPan() {
        return partial_pan;
    }

    public String getType() {
        return type;
    }

    public String getExpiryYear() {
        return expire_year;
    }

    public String getExpiryMonth() {
        return expire_month;
    }

    public Date getExpiryDate() {
        Integer year = Integer.valueOf(getExpiryYear());
        Integer month = Integer.valueOf(getExpiryMonth());

        return Date.newInstance(year, month, Date.daysInMonth(year, month));
    }

    public String getCvcRequired() {
        return cvc_required;
    }

    public String getFunding() {
        return funding;
    }

    public String getBin() {
        return bin;
    }

    public String getCategory() {
        return category;
    }

    public String getCountryCode() {
        return country_code;
    }


    public String getCardFingerprint() {
        return card_fingerprint;
    }

    public String getPanFingerprint() {
        return pan_fingerprint;
    }
}
