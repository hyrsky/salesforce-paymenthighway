[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![CircleCI](https://circleci.com/gh/hyrsky/salesforce-paymenthighway.svg?style=svg)](https://circleci.com/gh/hyrsky/salesforce-paymenthighway)

# SFDX App

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
