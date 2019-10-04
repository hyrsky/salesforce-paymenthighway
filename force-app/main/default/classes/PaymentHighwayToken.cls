public class PaymentHighwayToken {
    String id;
    String cvc;

    public PaymentHighwayToken(String id) {
        this.id = id;
    }

    public PaymentHighwayToken(String id, String cvc) {
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
