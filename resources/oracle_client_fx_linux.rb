#
# cookbook::oracle_client_fx
# resource::oracle_client_fx
#
# author::fxinnovation
# description::Installs oracle client on linux
#
resource_name :oracle_client_fx

provides :oracle_client_fx, os: 'linux'

property :java_version,             %w(8 10 11),    default: '8'
property :user,                     String,         default: 'oracle'
property :group,                    String,         default: 'dba'
property :version,                  ['11.2'],       default: '11.2'
property :source,                   String
property :checksum,                 String
property :sqlnet_options,           Hash,           default: {}
property :tnsnames_options,         String,         default: ''
property :tls_certificate_url,      String,         default: ''

action :build do
  base_path         = '/opt/oracle'
  var_path          = '/var/oracle'
  home_path         = "#{base_path}/product/#{new_resource.version}"
  bin_path          = "#{home_path}/bin"
  lib_path          = "#{home_path}/lib"
  wallet_path       = "#{home_path}/ssl_wallet"
  dependencies      = %w(compat-libstdc++-33.i686 glibc.i686 unixODBC.i686 gcc-c++ gcc compat-libstdc++-33 glibc unixODBC elfutils-libelf-devel libstdc++ libaio-devel unixODBC-devel sysstat)

  node.default['java']['jdk_version'] = new_resource.java_version
  include_recipe 'java::default'

  declare_resource(:group, new_resource.group) do
    append true
    system true
  end

  declare_resource(:user, new_resource.user) do
    comment 'Oracle user.'
    gid new_resource.group
    system true
    manage_home false
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
      lib_path: lib_path,
      var_path: var_path
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
    owner new_resource.user
    group new_resource.group
    mode '2755'
    action :create
  end

  directory var_path do
    owner new_resource.user
    group new_resource.group
    mode '2775'
    action :create
  end

  template "#{var_path}/oraInst.loc" do
    source "oracle-inventory/#{new_resource.version}/oraInst.loc.erb"
    owner new_resource.user
    group new_resource.group
    mode '0664'
    variables(
      var_path: var_path,
      group: new_resource.group
    )
  end

  unzip_fx "linux-oracle_client-#{new_resource.version}" do
    source new_resource.source
    checksum new_resource.checksum if new_resource.property_is_set?('checksum')
    mode '0755'
    recursive true
    creates 'client'
    target_dir "/linux-oracle_client-#{new_resource.version}"
    action :extract
  end

  template "linux-oracle_client-#{new_resource.version}/client/install/oraparam.ini" do
    source "oracle-home/#{new_resource.version}/install/oraparam.ini.erb"
    owner new_resource.user
    group new_resource.group
    mode '0644'
  end

  template "linux-oracle_client-#{new_resource.version}/client/response/client_install.rsp" do
    source "oracle-home/#{new_resource.version}/response/client_install.rsp.erb"
    owner new_resource.user
    group new_resource.group
    mode '0644'
    variables(
      base_path: base_path,
      group: new_resource.group,
      home_path: home_path,
      bin_path: bin_path,
      lib_path: lib_path,
      var_path: var_path
    )
  end

  execute 'run oracle installer' do
    not_if { ::File.exist?("#{home_path}/root.sh") }
    command "source /etc/profile && ./runInstaller -noconfig -silent -waitforcompletion -ignoreprereq -ignoreSysprereqs -responseFile /linux-oracle_client-#{new_resource.version}/client/response/client_install.rsp -invPtrLoc #{var_path}/oraInst.loc"
    cwd "linux-oracle_client-#{new_resource.version}/client/"
    user new_resource.user
    group new_resource.group
    environment('USER' => new_resource.user)
    live_stream true
    returns [253]
  end

  execute 'run oracle client end of installation' do
    command "#{home_path}/root.sh"
  end

  file "#{home_path}/network/admin/tnsnames.ora" do
    content new_resource.tnsnames_options
    mode '0660'
    owner new_resource.user
    group new_resource.group
  end

  template "#{home_path}/network/admin/sqlnet.ora" do
    source "oracle-home/#{new_resource.version}/network/admin/sqlnet.ora.erb"
    owner new_resource.user
    group new_resource.group
    mode '0660'
    variables(
      sqlnet_options: new_resource.sqlnet_options
    )
  end

  directory wallet_path do
    not_if { new_resource.tls_certificate_url == '' }
    owner new_resource.user
    group new_resource.group
    mode '0750'
    action :create
  end

  remote_file "#{wallet_path}/root-cert.pem" do
    not_if { new_resource.tls_certificate_url == '' }
    source new_resource.tls_certificate_url
    mode '0640'
    owner new_resource.user
    group new_resource.group
  end

  execute 'create wallet' do
    not_if { new_resource.tls_certificate_url == '' }
    command "source /etc/profile && orapki wallet create -wallet #{wallet_path} -auto_login_only"
    user new_resource.user
  end

  execute 'add wallet' do
    not_if { new_resource.tls_certificate_url == '' }
    command "source /etc/profile && orapki wallet add -wallet #{wallet_path} -trusted_cert -cert #{wallet_path}/root-cert.pem -auto_login_only "
    user new_resource.user
  end
end
