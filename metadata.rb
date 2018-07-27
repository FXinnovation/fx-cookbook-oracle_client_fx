name             'oracle_client_fx'
maintainer       'FX Innovation'
maintainer_email 'cloudsquad@fxinnovation.com'
license          'All Rights Reserved'
description      'Installs/Configures public-common-cookbook-oracle_client_fx'
long_description 'Installs/Configures public-common-cookbook-oracle_client_fx'
supports         'redhat'
version          '0.1.0'
chef_version     '>= 12.24' if respond_to?(:chef_version)
issues_url       'https://fxinnovation.jira.com/projects/FM/summary'
source_url       'https://bitbucket.org/fxadmin/public-common-cookbook-oracle_client_fx/src/master/'
depends          'java',         '~> 1.50.0'
depends          'ff_linux_base'
depends          'ff_yum'
depends          'unzip_fx'
