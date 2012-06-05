#!/usr/bin/perl

# Written to provide a report of network info for Linux servers 
# primarily works with RHEL 4,5,6 servers. 
# Sloppy written perl I know this. Works to generate a HTML of 
# with the network info with Hostname, IP Address, Broadcast, Network, 
# and Getway.
#
# For free use if ever needed by anyone to take use as is and modify 
#
# Tested with perl 5.8.5 on RHEL 4.9 
#
# Written by phackz <phackz88@gmail.com> May 2012

use strict;
use warnings;

use Net::SSH::Perl;

my $interface_cmd;
my $interface;
my $net_interfaces;
my @all_net_interfaces;
my @net_interface;
my @split_ip;
my $ip_addr;
my @split_bcast;
my $broadcast;
my @split_netmask;
my $netmask;
my $temp_if_config = "temp-if-config";
my $html_file = "linux-network-info.html";
my $ip_addr_cmd = "/sbin/ifconfig";
my $route;
my $route_cmd = "/sbin/ip route";
my $temp_route = "temp-route.txt";

# can rewrite password with Term Key
print "Name: ";
my $user = <>;
chomp($user);
print "\nPassword: ";
my $passwd = <>;
chomp($passwd);
print "\n";

# html variables for heading and layout
my $html_start = <<'END';
<html>
<body>
END

my $html_heading = "<h1>Linux System Network Info</h1>\n";

my $html_table_head = <<'END';
<table border ="1">
<tr>
<th>Hostname</th>
<th>IP Address</th>
<th>Broadcast</th>
<th>Netmask</th>
<th>Gateway</th>
</tr>
END

my $html_end = <<'END';
</table>
</body>
</html>
END

open(HTML, ">$html_file") or die "Can't: $!\n";
print HTML $html_start;
print HTML $html_heading;
print HTML $html_table_head;
close(HTML);


# sloppy routine to ssh into server and grab output of /sbin/ifconfig and
# /sbin/ip route can most likely be broken into many subroutines but this 
# worked with the deadline given
sub ssh_route_line {
 
  open(HTML, ">>$html_file");
  print HTML "<tr>\n";

  my $ssh = Net::SSH::Perl->new(shift) or die "Couldn't Connect to: $_\n";
 
  $ssh->login($user, $passwd); 
    
  my ($out, $err) = $ssh->cmd("hostname");
  chomp($out);
  print HTML "<td>$out</td>\n";
 
  ($out, $err) = $ssh->cmd($ip_addr_cmd);
  open(TMP, ">$temp_if_config");
    print TMP $out;
  close(TMP);

  open(FILE, "<$temp_if_config") or die "Error: $!\n";
    while (<FILE>) {
    @all_net_interfaces = grep /addr:(\d+.?\d+.?\d+.?\d+.?)/, <FILE> ;
    }
  close(FILE);
  @net_interface = split(" ", $all_net_interfaces[0]);
  @split_ip = split(":", $net_interface[1]);
  $ip_addr = $split_ip[1];

  @split_bcast = split(":", $net_interface[2]);
  $broadcast = $split_bcast[1];

  @split_netmask = split(":", $net_interface[3]);
  $netmask = $split_netmask[1];

## Used to debug results returned
#  print "my ip is: $ip_addr\n";
#  print "my broadcast is: $broadcast\n";
#  print "my netmask is: $netmask\n";
 
  print HTML "<td>$ip_addr</td>";
  print HTML "<td>$broadcast</td>\n";
  print HTML "<td>$netmask</td>\n";

  open(FILE, ">$temp_route") or die "Error: $!\n";
    print FILE $route_cmd;
  close(FILE);
  
  ($out, $err) = $ssh->cmd($route_cmd);
  open(TMP, ">$temp_route");
    print TMP $out;
  close(TMP);  

  open(FILE, "<$temp_route");
    while (<FILE>) {
      if ($_ =~ /default/) {
        if ($_ =~ /(\d+.?\d+.?\d+.?\d+.?)/) {
          $route = $1;
        }
      }
   }
  close(FILE);
  print HTML "<td>$route</td>\n";
  print HTML "</tr>\n";
  close(HTML);

}

my @servers = qw(192.168.1.1 192.168.1.2 192.168.1.3);



for my $serv (@servers) {
  eval{&ssh_route_line($serv);};
  if ($@) {
    print "Error connecting on $serv.\nError: $@\n";
  }
}

    
open(HTML, ">>$html_file");
  print HTML "$html_end";
close(HTML);

exit 0;
