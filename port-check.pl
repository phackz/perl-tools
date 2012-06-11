#!/usr/bin/perl
#
# Simple port checker to see if port is open or not
# use in way to check without nmap, ncat, telnet, etc. 
# Also automates with no keystrokes involved just reports
# back
# 
# Will work in a environment were all ICMP requests are
# rejected for whole environment
#
# -phackz

use strict;
use warnings;

use IO::Socket::INET;

sub check_port {
  my ($server, $port) = @_;
  my $sock = IO::Socket::INET->new(PeerAddr => $server,
                                   PeerPort => $port
                                   )
             or die "Error connecting on $server:$port \n$!\n";
  print "Successful Connection on $server:$port \n";
  $sock->close();
}

#check_port("170.63.171.6", 636);
#check_port("170.63.171.7", 636);

# Could also create hash to handle many servers
# with a while or for statement

my %servers = ("170.63.171.6" => 636,
               "170.63.171.7" => 636,
               "10.0.0.1"     => 22,
              );

#while(my ($server, $port) = each(%servers)) {
#  check_port($server, $port);
#}

# errors could be handled with eval if you don't want
# the program to exit upon failure

while(my ($server, $port) = each(%servers)) {
  eval{check_port($server, $port);};
  if ($@) {
    print "$@\n";
  }
}
