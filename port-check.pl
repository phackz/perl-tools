#!/usr/bin/perl
#
# Simple port checker to see if port is open or not
# as written can check ip port and you can specify the
# protocal if wanted.

use strict;
use warnings;

use IO::Socket::INET;

sub check_port {
  my ($server, $port, $proto) = @_;
  my $sock = IO::Socket::INET->new(PeerAddr => $server,
                                   PeerPort => $port,
                                   Proto    => $proto,
                                   )
             or die "Error with $server:$port: \n$!\n";
  print "Successful Connection on $server:$port \n";
  $sock->close();
}

check_port("170.63.171.6", 636);
check_port("170.63.171.7", 636);
