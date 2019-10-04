public class PaymentHighwaySplitting {
    String merchantId;
    Long amount;

    public PaymentHighwaySplitting(String merchantId, Long amount) {
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
