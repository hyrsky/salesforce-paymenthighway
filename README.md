[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![CircleCI](https://circleci.com/gh/hyrsky/salesforce-paymenthighway.svg?style=svg)](https://circleci.com/gh/hyrsky/salesforce-paymenthighway)
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

# PaymentHighway API

This is an implementation of the communication with the Payment Highway API using Apex. __The implementation is currently work in progress__.

This code is provided as-is, use it as inspiration, reference or drop it directly into your own project and use it.

For full documentation on the PaymentHighway API visit the developer website: https://paymenthighway.fi/dev/

## Overview

### PaymentApi

In order to do safe transactions, an execution model is used where the first call to /transaction acquires a financial transaction handle, later referred as “ID”, which ensures the transaction is executed exactly once. Afterwards it is possible to execute a debit transaction by using the received id handle. If the execution fails, the command can be repeated in order to confirm the transaction with the particular id has been processed.

In order to be sure that a tokenized card is valid and is able to process payment transactions the corresponding tokenization id must be used to get the actual card token.

#### Initializing the Payment API

```java
String serviceUrl = 'https://v1-hub-staging.sph-test-solinor.com';
String testKey = 'testKey';
String testSecret = 'testSecret';
String account = 'test';
String merchant = 'test_merchantId';

PaymentHighway paymentAPI = new PaymentHighway(serviceUrl, testKey, testSecret, account, merchant);
```

#### Init transaction
```java
PaymentHighway.InitTransactionResponse initResponse = paymentAPI.initTransactionHandle()
```

#### Debit with Token

```java
String token = '<token>';
Integer amount = 1990;
String currency = 'EUR';
String transactionId = initResponse.getId();

PaymentHighway.TransactionRequest transactionRequest = new PaymentHighway.TransactionRequest(token, String.valueOf(amount), currency);
PaymentHighway.TransactionResponse response = paymentAPI.debitTransaction(transactionId, transactionRequest);

if (response.getResult().getCode() == '100') {
    System.debug('Closed won');
}
```

## Dev, Build and Test

### CircleCI setup
1. Generate SSL server key and certificate. See ``.circleci/make-key.sh`` as an example.
2. Commit ``.circleci/encrypted.key`` to repository
3. Set up a Connected App in Salesforce for use with the JWT auth flow.

   * Set the OAuth callback to http://localhost:1717/OauthRedirect
   * Check Use Digital Signatures and add your certificate from step (1)
   * Select the required OAuth scopes - make sure that refresh is enabled.
   * Verify JWT works through the following command:  
   ``sfdx force:auth:jwt:grant -i <consumer-key> --jwtkeyfile path/to/server.key -u <username>``
4. Configure CircleCI variables inside of the settings for your project

   * ``HUB_CONSUMER_KEY``: Your Connected App consumer key  
   * ``HUB_SFDC_USER``: The username for your Salesforce user
   * ``HUB_SERVER_KEY_PASSWORD``: Password to encrypted key from step (1)

## Resources

## Description of Files and Directories

## Issues
