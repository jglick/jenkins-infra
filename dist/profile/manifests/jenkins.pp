#
# Profile for managing a Jenkins master installation
class profile::jenkins {
  include firewall

  # This is a legacy role imported from infra-puppet, thus the goofy numbering
  firewall { '108 Jenkins CLI port' :
    proto  => 'tcp',
    port   => 47278,
    action => 'accept',
  }

  firewall { '801 Allow Jenkins web access only on localhost':
    proto   => 'tcp',
    port    => 8080,
    action  => 'accept',
    iniface => 'lo',
  }

  firewall { '802 Block external Jenkins web access':
    proto  => 'tcp',
    port   => 8080,
    action => 'drop',
  }

  firewall { '810 Jenkins CLI SSH':
    proto  => 'tcp',
    port   => 22222,
    action => 'accept',
  }
}
