#base_init 'default' do
#  action :build
#end

#
# cookbook::oracle_client_fx
# recipe::default
#
# author::fxinnovation
# description::Test recipe used for kitchen tests
#

oracle_client_fx 'kitchen' do
  action :build
end
