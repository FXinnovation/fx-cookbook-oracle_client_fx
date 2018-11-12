name             'oracle_client_fx'
maintainer       'FX Innovation'
maintainer_email 'cloudsquad@fxinnovation.com'
license          'MIT'
description      'Installs/Configures oracle client.'
long_description 'Installs/Configures oracle client.'
supports         'redhat', '>= 6.0'
supports         'centos', '>= 6.0'
version          '0.1.1'
chef_version     '>= 12.24' if respond_to?(:chef_version)
source_url       'https://bitbucket.org/fxadmin/public-common-cookbook-oracle_client_fx/'
issues_url       'https://bitbucket.org/fxadmin/public-common-cookbook-oracle_client_fx/issues/'
depends          'java', '~> 2.0.0'
depends          'unzip_fx'
