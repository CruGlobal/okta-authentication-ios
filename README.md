# OktaAuthentication

A swift package for authenticating with Okta (OktaOidc dependency).  This package is broken into 2 classes.  A common OktaAuthentication class for working with OktaOidc and a CruOktaAuthentication class which inherits from OktaAuthentication and includes shared functionality for Cru apps.  Most Cru apps will use the CruOktaAuthentication class.

OktaAuthentication - This class operates on the OktaOidc dependency and keeps a static reference to the OktaOidcStateManager and access token when a successful authentication is made.  

CruOktaAuthentication - This class inherits from OktaAuthentication and provides shared logic that Cru apps utilize.  Such as configuring OktaOidc, renewing a prior auth access token, sign out, and decoding a CruOktaUser.
