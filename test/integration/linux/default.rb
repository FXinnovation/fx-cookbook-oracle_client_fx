title 'Oracle client installation'

control 'oracle_client_fx_linux' do
  impact 1
  title 'Oracle client on linux'
  desc 'Ensure oracle client is installed correctly.'

  describe bash('java -version') do
    its('exit_status') { should eq 0 }
    its('stderr') { should match ".*1.8.*\n" }
  end

  describe group('dba') do
    it { should exist }
  end

  describe user('oracle') do
    it { should exist }
    its('group') { should eq 'dba' }
  end

  packages = %w(
  )

  packages.each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  // Env variable should be present
  // sqlplus is reachable & executable
end
