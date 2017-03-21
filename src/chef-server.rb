# THIS FILE WILL BE OVERWRITTEN ON CONTAINER START
#
# persistent customizations should be made in the volume mounted dir
# /var/opt/opscode/chef-server-local.rb
#

require 'uri'

if ! ENV.has_key?('PUBLIC_URL')
    ENV['PUBLIC_URL'] = 'https://127.0.0.1/'
elsif ! ENV.has_key?('OC_ID_ADMINISTRATORS')
    ENV['OC_ID_ADMINISTRATORS'] = ''
end

_uri = ::URI.parse(ENV['PUBLIC_URL'])

if _uri.port == _uri.default_port
  api_fqdn _uri.hostname
else
  api_fqdn "#{_uri.hostname}:#{_uri.port}"
end

bookshelf['external_url'] = ENV['PUBLIC_URL']
bookshelf['url'] = _uri.to_s
nginx['enable'] = true
nginx['enable_non_ssl'] = true
nginx['url'] = _uri.to_s
nginx['ssl_certificate'] = "/var/opt/opscode/nginx/ca/#{ENV['PUBLIC_URL']}.crt"
nginx['ssl_certificate_key'] = "/var/opt/opscode/nginx/ca/#{ENV['PUBLIC_URL']}.key"
nginx['x_forwarded_proto'] = _uri.scheme
oc_id['administrators'] = ENV['OC_ID_ADMINISTRATORS'].to_s.split(',')
opscode_erchef['base_resource_url'] = _uri.to_s

_local = '/var/opt/opscode/etc/chef-server-local.rb'
if File.exists?(_local)
  instance_eval(File.read(_local), _local)
end
