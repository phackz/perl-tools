#!/usr/bin/perl
#
# just a wrapper for system commands to yum
# it checks if package is isntalled based on a rpm -q
# If it's installed it outputs it's installed. If not
# installed $? returns 1 and it will call yum to 
# install it. Tested on RHEL 5, and 6. Used in script
# to setup machines as ldapclients
# -phackz

use strict;
use warnings;

sub check_pre_req_package {
  my $package = shift;
  system("rpm -q $package > /dev/null 2>&1");
  if ($? != "0") {
    print "Package $package not found, Installing now \n";
    system("yum install -y $package > /dev/null 2>&1");
    print "Package $package installed successfully! \n";
  }
  elsif ($? == "0") {
    print "Package $package is already installed \n";
  }
}

#my @pre_req_packages = ('openldap', 'nss_ldap', 'openldap-clients', 'libuser');

my @pre_req_packages = qw(strace nmap gcc);

foreach(@pre_req_packages) {
  check_pre_req_package($_);
}
exit;
