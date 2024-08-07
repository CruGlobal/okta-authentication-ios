
Pod::Spec.new do |s|
    s.name = 'OktaAuthentication'
    s.version = '1.4.3'
    s.summary = 'Operates on OktaOidc and contains shared logic for Cru apps to authenticate with Okta.'
    s.description = 'A swift package that operates on top of OktaOidc.  This package contains logic for managing Okta authentication as well as shared logic specific to Cru applications authenticating with Okta. '
    s.homepage = 'https://github.com/CruGlobal/okta-authentication-ios'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'Levi Eggert' => 'levi.eggert@cru.org' }
    s.source = { :git => 'https://github.com/CruGlobal/okta-authentication-ios.git', :tag => s.version.to_s }
  
    s.swift_version = '5.7'
    s.platforms = {
        "ios": "13.0"
    }
  
    s.source_files = 'Sources/**/*.{swift}'

    s.dependency 'OktaOidc', '~> 3.11.5'    
  end
  