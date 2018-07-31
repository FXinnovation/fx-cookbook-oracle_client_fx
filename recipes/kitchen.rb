#
# cookbook::oracle_client_fx
# recipe::default
#
# author::fxinnovation
# description::Test recipe used for kitchen tests
#

oracle_client_fx 'kitchen' do
  java_version          node['oracle_client_fx']['kitchen']['jdk_version']
  version               node['oracle_client_fx']['kitchen']['version']
  source                node['oracle_client_fx']['kitchen']['source']
  checksum              node['oracle_client_fx']['kitchen']['checksum']
  sqlnet_options        node['oracle_client_fx']['kitchen']['sqlnet_options']
  tnsnames_options      node['oracle_client_fx']['kitchen']['tnsnames_options']
  tls_certificate_url   node['oracle_client_fx']['kitchen']['tls_certificate_url']
  action :build
end
