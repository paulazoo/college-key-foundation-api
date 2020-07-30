Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '322643072137-1sg9o9abpkhce3n09jik4g1lodggb53j.apps.googleusercontent.com', 'guF-q8kmdLDGFtoH2hpEWZAW'
end