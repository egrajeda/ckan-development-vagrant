# ckan-development-vagrant

Vagrant setup to run a CKAN VM for development.

## Installation

  1. Clone this repository:

  ```
  git clone https://github.com/egrajeda/ckan-development-vagrant.git
  ```

  2. Clone [CKAN](https://github.com/ckan/ckan) and [CKAN DataPusher](https://github.com/ckan/datapusher):
  
  ```
  git clone https://github.com/ckan/ckan.git
  git clone https://github.com/ckan/datapusher.git ckan-datapusher
  ```
  
  3. If you haven't already, install [`ubuntu/trusty64`](https://atlas.hashicorp.com/ubuntu/boxes/trusty64) Vagrant box.
  
  ```
  vagrant box add ubuntu/trusty64
  ```
  
  4. Run the VM:
  
  ```
  cd ckan-development-vagrant 
  vagrant up
  ```
  
  The VM might take between 30 and 60 minutes to provision. If the provisioning fails, please try again with
  `vagrant provision`. If it fails again, please create an issue.
  
  5. SSH into the VM and run CKAN:
  
  ```
  vagrant ssh
  cd /ckan
  paster serve --reload development.ini
  ```
  
## TODO

1. Add a default `development.ini` and `test-core.ini` file.
2. Add the steps to configure the DataStore permissions.
