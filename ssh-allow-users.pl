#!/usr/bin/perl
#
# Script to parse the /etc/ssh/sshd_config file and get the line for AllowUsers
# Then add those users to the file /etc/sshd_users
# 
# Written by phackz

use strict;
use warnings;

my $ssh_users;
my @ssh_users;

my $sshd_conf_file = "/etc/ssh/sshd_config";
my $sshd_conf_temp = "$sshd_conf_file.temp";
my $sshd_users_file = "/etc/sshd_users";

my $pamd_file = "/etc/pam.d/sshd";
my $pamd_temp = "$pamd_file.temp";

sub make_backup_file {
  my $conf_file = shift;
  my $back_file = "$conf_file.backup";
  open(FILE1, "<$conf_file")
      or die "Couldn't open file $conf_file: \n$!";
  open(FILE2, ">$back_file")
      or die "Couldn't write file $back_file: \n$!";
  while (<FILE1>) {
    print FILE2 $_;
  }
  print "Made backup file: $back_file\n";
  close(FILE1);
  close(FILE2);
}

make_backup_file($sshd_conf_file);
make_backup_file($pamd_file);

sub get_users {
  open(FILE, $sshd_conf_file)
       or die "can't open $sshd_conf_file: $!\n";
  while(<FILE>) {
    if ($_ =~ /^AllowUsers/) {
      $ssh_users = $_;
    }
  }
  close(FILE);
}

get_users();

sub array_users {
  @ssh_users = split(" ", $ssh_users);
  shift(@ssh_users);
}

array_users();

sub write_sshd_users {
  open(FILE, ">>$sshd_users_file");
  for my $user (@ssh_users) {
    print "Adding user $user to $sshd_users_file\n";
    print FILE "$user\n";
  }
  close(FILE);
}

write_sshd_users();

sub write_file_temp {
  open(FILE, "<$pamd_file") or die "Coudln't open\n";
  open(TEMP, ">$pamd_temp") or die "Couldn't open \n";
    while(<FILE>) {
      if ($. == 1) {
        print TEMP "$_\n";
      }
      else {
        print TEMP "$_";
      }
    }
  close(FILE);
  close(TEMP);
}

write_file_temp();

sub write_sshd_rule {
  my $pam_sshd = "auth       required      pam_listfile.so onerr=fail item=user sense=allow file=/etc/sshd_users";
  open(TEMP, "<$pamd_temp") or die "Couldn't open \n";
  open(FILE, ">$pamd_file") or die "Couldn't open \n";
  while(<TEMP>) {
    if ($. == 2) {
      print FILE "$pam_sshd\n";
    }
    else {
      print FILE "$_";
    }
  }
  close(TEMP);
  close(FILE);
  unlink($pamd_temp);
}

write_sshd_rule();

sub insert_comment {
  open(FILE, "<$sshd_conf_file")
       or die "Couldn't open $sshd_conf_file: $!\n";
  open(TEMP, ">$sshd_conf_temp")
       or die "Couldn't open $sshd_conf_temp: $!\n";
  while(<FILE>) {
    s/AllowUsers/#AllowUsers/g;
    print TEMP $_;
  }
  close(FILE);
  close(TEMP);
}

insert_comment();

sub write_comment_sshd {
  open(TEMP, "<$sshd_conf_temp")
       or die "Couldn't open $sshd_conf_temp: $!\n";
  open(FILE, ">$sshd_conf_file")
       or die "Couldn't open $sshd_conf_file: $!\n";
  while(<TEMP>) {
    print FILE $_;
  }
  close(FILE);
  close(TEMP);
  unlink($sshd_conf_temp);
}

write_comment_sshd();

system("/sbin/service sshd restart");

exit 0;
