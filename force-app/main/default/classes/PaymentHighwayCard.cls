public class PaymentHighwayCard {
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

    public PaymentHighwayCard(String pan, String expiryYear, String expiryMonth, String cvc) {
        this.pan = pan;
        this.expiry_year = expiryYear;
        this.expiry_month = expiryMonth;
        this.cvc = cvc;
    }

    public PaymentHighwayCard(String type, String expiryYear, String expiryMonth) {
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
