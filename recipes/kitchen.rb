#
# cookbook::oracle_client_fx
# recipe::default
#
# author::fxinnovation
# description::Test recipe used for kitchen tests
#

oracle_client_fx 'kitchen' do
  java_version          node['java']['jdk_version']
  version               node['oracle_client_fx']['version']
  source                node['oracle_client_fx']['source']
  checksum              node['oracle_client_fx']['checksum']
  sqlnet_options        node['oracle_client_fx']['sqlnet_options']
  tnsnames_options      node['oracle_client_fx']['tnsnames_options']
  tls_certificate_url   node['oracle_client_fx']['tls_certificate_url']
  action :build
end
