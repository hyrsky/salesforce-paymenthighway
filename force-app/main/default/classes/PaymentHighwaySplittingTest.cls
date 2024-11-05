@isTest
public class PaymentHighwaySplittingTest {
    /**
     * Tests PaymentHighwaySplitting
     */
     @isTest
     static void testSplitting() {
        PaymentHighwaySplitting splitting = new PaymentHighwaySplitting('123', 456);
 
        System.assertEquals(splitting.getMerchantId(), '123');
        System.assertEquals(splitting.getAmount(), 456);
     }
}