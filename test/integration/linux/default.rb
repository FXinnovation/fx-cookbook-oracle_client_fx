title 'Oracle client installation'

control 'oracle_client_fx_linux' do
  impact 1
  title 'Oracle client on linux.'
  desc 'Ensure oracle client is installed correctly.'

  base_path     = '/opt/oracle'
  var_path      = '/var/oracle'
  home_path     = "#{base_path}/product/11.2"
  bin_path      = "#{home_path}/bin"
  wallet_path   = "#{home_path}/ssl_wallet"
  admin_path    = "#{home_path}/network/admin"
  dependencies  = %w(gcc-c++ gcc compat-libstdc++-33 glibc unixODBC elfutils-libelf-devel libstdc++ libaio-devel unixODBC-devel sysstat)
  user          = 'oracle'
  group         = 'dba'

  describe bash('java -version') do
    its('exit_status') { should eq 0 }
    its('stderr') { should match ".*1.8.*\n" }
  end

  describe group('dba') do
    it { should exist }
  end

  describe user('oracle') do
    it { should exist }
    its('groups') { should include('dba') }
  end

  dependencies.each do |dependency|
    describe package(dependency) do
      it { should be_installed }
    end
  end

  describe directory(home_path) do
    its('mode') { should cmp '0770' }
    its('owner') { should eq user }
    its('group') { should eq group }
  end

  describe directory(var_path) do
    its('mode') { should cmp '02755' }
    its('owner') { should eq user }
    its('group') { should eq group }
  end

  describe file("#{wallet_path}/cwallet.sso") do
    its('mode') { should cmp '0600' }
    its('owner') { should eq user }
    its('group') { should eq 'root' }
  end

  describe file("#{admin_path}/tnsnames.ora") do
    its('mode') { should cmp '0640' }
    its('owner') { should eq user }
    its('group') { should eq group }
  end

  describe file("#{admin_path}/sqlnet.ora") do
    its('mode') { should cmp '0640' }
    its('owner') { should eq user }
    its('group') { should eq group }
  end

  describe os_env('ORACLE_HOME') do
    its('split') { should include(home_path) }
  end

  describe command("#{bin_path}/sqlplus") do
    it { should exist }
  end
end
