# To use with thin 
#  thin start -p PORT -R config.ru
#
#require 'webrick'
#require 'webrick/https'
#require 'openssl'
#
#CERT_PATH = '/opt/ca-test/server/'
#
#webrick_options = {
#        :Port               => 8443,
#        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
#        #:DocumentRoot       => "/ruby/htdocs",
#        :DocumentRoot       => "public",
#        :SSLEnable          => true,
#        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
#        :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "my-server.crt")).read),
#        :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "my-server.key")).read),
#        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
#}


require File.join(File.dirname(__FILE__),  'app.rb')

#disable :run
#set :environment, :production
run App#, webrick_options