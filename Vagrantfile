# Required plugins:
#    vagrant-aws
#    vagrant-serverspec

Vagrant.configure("2") do |config|
  access_key_id = ENV['AWS_ACCESS_KEY_ID'] || File.read('.vagrant_key_id').chomp
  secret_access_key = ENV['AWS_SECRET_ACCESS_KEY'] || File.read('.vagrant_secret_access_key').chomp
  keypair = ENV['AWS_KEYPAIR_NAME'] || File.read('.vagrant_keypair_name').chomp

  # prefer aws provider over virtualbox to make it the default
  config.vm.provider 'aws'
  config.vm.provider 'virtualbox'

  config.vm.box = 'dummy'
  config.vm.box_url = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'

  # modules/account/.travis.yml has incorrect link target, and this blows up
  # when vagrant tries to rsync files as it tries to resolves symlinks.
  # see http://www.trilithium.com/johan/2011/09/delete-broken-symlinks/
  `find -L . -type l -delete`

  config.vm.provider(:aws) do |aws, override|
    aws.access_key_id = access_key_id
    aws.secret_access_key = secret_access_key
    aws.keypair_name = keypair

    # Ubuntu LTS 14.04 in us-west-2 stock
    aws.ami = 'ami-9abea4fb'
    aws.region = 'us-west-2'
    aws.instance_type = 'm3.medium'

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = File.expand_path('~/.ssh/id_rsa')
  end

  Dir['./dist/role/manifests/*.pp'].each do |role|
    # Turn `dist/role/manifests/spinach.pp` into `spinach`
    veggie = File.basename(role).gsub('.pp', '')

    config.vm.define(veggie) do |node|
      node.vm.provider(:aws) do |aws, override|
        aws.tags = {
          :Name => veggie
        }
      end

      # This is a Vagrant-local hack to make sure we have properly udpated apt
      # caches since AWS machines are definitely going to have stale ones
      node.vm.provision 'shell',
        :inline => 'if [ ! -f "/apt-cached" ]; then apt-get update && apt-get install -yq puppet && touch /apt-cached; fi'

      node.vm.provision 'puppet' do |puppet|
        puppet.manifest_file = File.basename(role)
        puppet.manifests_path = File.dirname(role)
        puppet.module_path = ['modules', 'dist']
        # Setting the work to /vagrant so our hiera configuration will resolve
        # properly to our relative hieradata/
        puppet.working_directory = '/vagrant'
        puppet.facter = {
          :vagrant => '1',
        }
        puppet.hiera_config_path = 'spec/fixtures/hiera.yaml'
        puppet.options = "--verbose --execute 'include role::#{veggie}\n include profile::vagrant'"
      end

      node.vm.provision :serverspec do |spec|
        spec.pattern = "spec/server/#{veggie}/*.rb"
      end
    end
  end
end

# vim: ft=ruby
