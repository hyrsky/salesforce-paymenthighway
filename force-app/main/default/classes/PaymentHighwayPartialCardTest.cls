@isTest
public class PaymentHighwayPartialCardTest {
    /**
     * Tests PaymentHighwayPartialCard
     */
    @isTest
    static void testPartialCard() {
        String json = '{ "partial_pan": "12", "type": "23", "expire_year": "2024", "expire_month": "11", "cvc_required": "56", "bin": "67", "funding": "78", "category": "89", "country_code": "90", "card_fingerprint": "01", "pan_fingerprint": "666" }';

        JSONParser parser = System.JSON.createParser(json);
        PaymentHighwayPartialCard partialCard = (PaymentHighwayPartialCard)parser.readValueAs(PaymentHighwayPartialCard.class);

        System.assertEquals(partialCard.getPartialPan(), '12');
        System.assertEquals(partialCard.getType(), '23');
        System.assertEquals(partialCard.getExpiryYear(), '34');
        System.assertEquals(partialCard.getExpiryMonth(), '45');
        System.assertEquals(partialCard.getExpiryDate(), new Date(2024, 11, 30));
        System.assertEquals(partialCard.getCvcRequired(), '56');
        System.assertEquals(partialCard.getBin(), '67');
        System.assertEquals(partialCard.getFunding(), '78');
        System.assertEquals(partialCard.getCategory(), '89');
        System.assertEquals(partialCard.getCountryCode(), '90');
        System.assertEquals(partialCard.getCardFingerprint(), '01');
        System.assertEquals(partialCard.getPanFingerprint(), '666');
    }
}