# THIS FILE WILL BE OVERWRITTEN ON CONTAINER START
#
# persistent customizations should be made in the local override file:
#
#   /var/opt/opscode/etc/chef-server-local.rb
#

require 'uri'
_uri = ::URI.parse(ENV['EXTERNAL_URL'] || 'https://127.0.0.1/')

if _uri.port == _uri.default_port
  api_fqdn _uri.hostname
else
  api_fqdn "#{_uri.hostname}:#{_uri.port}"
end

bookshelf['external_url'] = _uri.to_s
bookshelf['url'] = _uri.to_s
nginx['enable_non_ssl'] = true
nginx['url'] = _uri.to_s
nginx['x_forwarded_proto'] = _uri.scheme
opscode_erchef['base_resource_url'] = _uri.to_s

_local = '/var/opt/opscode/etc/chef-server-local.rb'
if File.exists?(_local)
  instance_eval(File.read(_local), _local)
end
