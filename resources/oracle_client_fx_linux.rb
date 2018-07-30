#
# cookbook::oracle_client_fx
# resource::oracle_client_fx
#
# author::fxinnovation
# description::Installs oracle client on linux
#
resource_name :oracle_client_fx

provides :oracle_client_fx, os: 'linux'

property :java_version,             String, default: '8'
property :ora_user,                 String, default: 'oracle'
property :ora_group,                String, default: 'dba'
property :version,                  String, default: '11.2'
property :installer_checksum,       String, default: '6d03e05c0fa3a5f6a0fb6aa75f7b9dce9e09a31d776516694f7fa6ebce9bb775'
property :installer_url,            String
property :sqlnet_options,           Hash, default: {}
property :tnsnames_options,         String, default: ''
property :tls_certificate_url,      String, default: ''

action :build do
  base_path    = '/opt/oracle'
  var_path     = '/var/oracle'
  home_path    = "/opt/oracle/product/#{version}"
  bin_path     = "#{home_path}/bin"
  lib_path     = "#{home_path}/lib"
  wallet_path  = "#{home_path}/ssl_wallet"
  dependencies = %w(gcc-c++ gcc compat-libstdc++-33 compat-libstdc++-33.i686 glibc glibc.i686 unixODBC unixODBC.i686 elfutils-libelf-devel libstdc++ libaio-devel unixODBC-devel sysstat)

  node.default['java']['jdk_version'] = new_resource.java_version
  include_recipe 'java::default'

  user ora_user do
    comment 'Oracle user.'
    system true
    manage_home false
  end

  group ora_group do
    members ora_user
    append true
    system true
  end

  dependencies.each do |oracle_dependency|
    package oracle_dependency
  end

  template '/etc/profile.d/oracle.sh' do
    source 'etc/profile.d/oracle.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      home_path: home_path,
      bin_path: bin_path,
      lib_path: lib_path
    )
    verify 'bash -n %{path}'
  end

  template '/etc/ld.so.conf.d/oracle.conf' do
    source 'etc/ld.so.conf.d/oracle.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      lib_path: lib_path
    )
  end

  directory base_path do
    owner ora_user
    group ora_group
    mode '2755'
    action :create
  end

  directory var_path do
    owner ora_user
    group ora_group
    mode '2755'
    action :create
  end

  unzip_fx "linux-oracle_client-#{version}" do
    source installer_url
    checksum installer_checksum
    mode '0755'
    recursive true
    creates 'client'
    target_dir "/linux-oracle_client-#{version}"
    action :extract
  end

  template "linux-oracle_client-#{version}/client/install/oraparam.ini" do
    source "oracle-home/#{version}/install/oraparam.ini.erb"
    owner ora_user
    group ora_group
    mode '0644'
  end

  template "linux-oracle_client-#{version}/client/response/client_install.rsp" do
    source "oracle-home/#{version}/response/client_install.rsp.erb"
    owner ora_user
    group ora_group
    mode '0644'
    variables(
      base_path: base_path,
      group: new_resource.ora_group,
      home_path: home_path,
      bin_path: bin_path,
      lib_path: lib_path
    )
  end

  execute 'run oracle installer' do
    command "source /etc/profile && ./runInstaller -silent -responseFile /linux-oracle_client-#{version}/client/response/client_install.rsp"
    cwd "linux-oracle_client-#{version}/client/"
    user ora_user
  end

  # This is because oracle installer returns early but a subprocess continues to install.
  # Thus at this time installation might be unfinished. Install usually takes 30s.
  execute 'wait for oracle client to be installed.' do
    not_if { ::File.exist?("#{home_path}/root.sh") }
    command 'sleep 60'
  end

  execute 'run oracle client end of installation' do
    command "#{home_path}/root.sh"
  end

  file "#{home_path}/network/admin/tnsnames.ora" do
    content tnsnames_options
    mode '0640'
    owner ora_user
    group ora_group
  end

  template "#{home_path}/network/admin/sqlnet.ora" do
    source "oracle-home/#{version}/network/admin/sqlnet.ora.erb"
    owner ora_user
    group ora_group
    mode '0640'
    variables(
      sqlnet_options: new_resource.sqlnet_options
    )
  end

  directory wallet_path do
    not_if { tls_certificate_url == '' }
    owner ora_user
    group ora_group
    mode '0750'
    action :create
  end

  remote_file "#{wallet_path}/root-cert.pem" do
    not_if { tls_certificate_url == '' }
    source tls_certificate_url
    mode '0640'
    owner ora_user
    group ora_group
  end

  execute 'create wallet' do
    not_if { tls_certificate_url == '' }
    command "source /etc/profile && orapki wallet create -wallet #{wallet_path} -auto_login_only"
    user ora_user
  end

  execute 'add wallet' do
    not_if { tls_certificate_url == '' }
    command "source /etc/profile && orapki wallet add -wallet #{wallet_path} -trusted_cert -cert #{wallet_path}/root-cert.pem -auto_login_only "
    user ora_user
  end
end
