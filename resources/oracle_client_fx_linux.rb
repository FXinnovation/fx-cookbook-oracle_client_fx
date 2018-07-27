#
# cookbook::oracle_client_fx
# resource::oracle_client_fx
#
# author::fxinnovation
# description::Installs oracle client on linux
#
resource_name :oracle_client_fx

provides :oracle_client_fx, os: 'linux'

property :java_version,             String, default: node['java']['jdk_version']
property :depot_scheme,             String, default: 'http'
property :depot_domain,             String, default: 'depot.xcorp.fairstone.ca'
property :depot_oracle_uri,         String, default: '/repo/oracle/'
property :oracle_dependencies,      Array,  default: node['fx_oracle_client']['dependencies']
property :oracle_user,              String, default: 'oracle'
property :oracle_group,             String, default: 'dba'
property :oracle_client_version,    String, default: '11.2'
property :oracle_base_path,         String, default: '/opt/oracle'
property :oracle_var_path,          String, default: '/var/oracle'
property :oracle_home_path,         String, default: '/opt/oracle/product/11.2/orahome'
property :oracle_client_bin_path,   String, default: '/opt/oracle/product/11.2/orahome/bin'
property :oracle_client_lib_path,   String, default: '/opt/oracle/product/11.2/orahome/lib'
property :oracle_client_zip_file,   String, default: 'linux.x64_11gR2_client.zip'
property :oracle_client_checksum,   String, default: '6d03e05c0fa3a5f6a0fb6aa75f7b9dce9e09a31d776516694f7fa6ebce9bb775'
property :oracle_sqlnet_options,    HashM,  default: {}
property :oracle_tnsnames_options,  Array,  default: []

action :build do
  node.default['java']['jdk_version'] = new_resource.java_version
  include_recipe 'java::default'

  #oracle_base_path is path
  #oracle_var_path is path
  #oracle_home_path is path
  #oracle_home_path contains oracle_client_version
  #oracle_client_bin_path is path
  #oracle_client_bin_path contains oracle_client_version
  #oracle_client_lib_path is path
  #oracle_client_lib_path contains oracle_client_version
  #oracle_base_path is path

  user "#{oracle_user}" do
    comment 'Oracle user'
    system true
    manage_home false
  end

  group "#{oracle_group}" do
    members "#{oracle_user}"
    append true
    system true
  end

  new_resource.oracle_dependencies.each do |oracle_dependency|
    package oracle_dependency
  end

  template '/etc/profile.d/oracle.sh' do
    source 'etc/profile.d/oracle.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      oracle_home_path: new_resource.oracle_home_path,
      oracle_client_bin_path: new_resource.oracle_client_bin_path,
      oracle_client_lib_path: new_resource.oracle_client_lib_path
    )
    verify 'bash -n %{path}'
  end

  template '/etc/ld.so.conf.d/oracle.conf' do
    source 'etc/ld.so.conf.d/oracle.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      oracle_client_lib_path: new_resource.oracle_client_lib_path
    )
  end

  directory "#{oracle_base_path}" do
    owner "#{oracle_user}"
    group "#{oracle_group}"
    mode '2755'
    action :create
  end

  directory "#{oracle_var_path}" do
    owner "#{oracle_user}"
    group "#{oracle_group}"
    mode '2755'
    action :create
  end

  depot_oracle_url = "#{depot_scheme}://#{depot_domain}#{depot_oracle_uri}"
  unzip_fx "#{oracle_client_zip_file}" do
    source "#{depot_oracle_url}#{oracle_client_zip_file}"
    checksum "#{oracle_client_checksum}"
    mode '0755'
    recursive true
    creates 'client'
    target_dir "/linux-oracle_client-#{oracle_client_version}"
    action :extract
  end

  template "linux-oracle_client-#{oracle_client_version}/client/install/oraparam.ini" do
    source "oracle-home/#{oracle_client_version}/install/oraparam.ini.erb"
    owner "#{oracle_user}"
    group "#{oracle_group}"
    mode '0644'
  end

  template "linux-oracle_client-#{oracle_client_version}/client/response/client_install.rsp" do
    source "oracle-home/#{oracle_client_version}/response/client_install.rsp.erb"
    owner "#{oracle_user}"
    group "#{oracle_group}"
    mode '0644'
    variables(
      oracle_base_path: new_resource.oracle_base_path,
      oracle_group: new_resource.oracle_group,
      oracle_home_path: new_resource.oracle_home_path,
      oracle_client_bin_path: new_resource.oracle_client_bin_path,
      oracle_client_lib_path: new_resource.oracle_client_lib_path
    )
  end

  execute 'run oracle installer' do
    command "./runInstaller -silent -responseFile /linux-oracle_client-#{oracle_client_version}/client/response/client_install.rsp"
    cwd "linux-oracle_client-#{oracle_client_version}/client/"
    group "#{oracle_group}"
    user "#{oracle_user}"
  end

  # This is because oracle installer returns early but a subprocess continues to install.
  # Thus at this time installation might be unfinished. Install usually takes 10s.
  execute 'wait for oracle client to be installed.' do
    command 'sleep 20'
  end

  execute 'run root permission changes' do
    command "#{oracle_base_path}/orainstRoot.sh"
  end

  execute 'run oracle client end of installation' do
    command "#{oracle_home_path}/root.sh"
  end


end
