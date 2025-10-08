[![codecov](https://codecov.io/gh/CruGlobal/okta-authentication-ios/branch/main/graph/badge.svg)](https://codecov.io/gh/CruGlobal/okta-authentication-ios)

OktaAuthentication
==================

A swift package for authenticating with Okta (OktaOidc dependency).  This package is broken into 2 classes.  A common OktaAuthentication class for working with OktaOidc and a CruOktaAuthentication class which inherits from OktaAuthentication and includes shared functionality for Cru apps.  Most Cru apps will use the CruOktaAuthentication class.

OktaAuthentication - This class operates on the OktaOidc dependency and keeps a static reference to the OktaOidcStateManager and access token when a successful authentication is made.  

CruOktaAuthentication - This class inherits from OktaAuthentication and provides shared logic that Cru apps utilize.  Such as configuring OktaOidc, renewing a prior auth access token, sign out, and decoding a CruOktaUser.

- [Publishing New Versions With GitHub Actions](#publishing-new-versions-with-github-actions)
- [Publishing New Versions Manually](#publishing-new-versions-manually)

### Publishing New Versions With GitHub Actions

Publishing new versions with GitHub Actions build workflow.

- Ensure a new version is set in the VERSION file.  This can be set manually or by manually running the Create Version workflow.

- Create a pull request on main and once merged into main GitHub actions will handle tagging the version from the VERSION file.

### Publishing New Versions Manually

Steps to publish new versions for Swift Package Manager. 

- Set the new version number in the VERSION file.

- Tag the main branch with the new version number and push the tag to origin.
