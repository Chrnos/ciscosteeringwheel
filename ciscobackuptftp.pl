#!/usr/bin/perl
#
# Cisco Steering Wheel
# > copy system:/running-config tftp:/@TFTP/CONF
#
# Syntaxe: ./ciscobackuptftp.pl -a <Cisco IP address/name> -u <login> -p <password> -P <enablepassword> -t <TFTP server IP address> -c <configuration name>
#
# Need the Net::Telnet::Cisco library
# Installation on Ubuntu: sudo aptitude install libnet-telnet-cisco-perl
#
# Nicolargo aka Nicolas Hennion
#
#==================================================
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
#
#==================================================

my $program_name = "ciscobackuptftp.pl";
my $program_version = "0.1a";
my $program_date = "01/2011";

# Libraries
use strict;
use Getopt::Std;
use Net::Telnet::Cisco;

# Globals variables
my $address;			# IP address/hostname of the Cisco router
my $login;				# Cisco router login
my $password;			# Cisco router password
my $enablepassword;		# Cisco router enable password
my $tftp;				# TFTP Server IP address
my $confname;			# Name of the configuration file stored on the TFTP server
my @output;

# Programs argument management
my %opts = ();
getopts("hva:u:p:P:t:c:", \%opts);
if ($opts{v}) {
    # Display the version
    print "$program_name $program_version ($program_date)\n";
    exit(-1);
}
if ($opts{h} || (!$opts{a} || !$opts{u} || !$opts{p} || !$opts{P})) {
    # Help
    print "$program_name $program_version\n";
    print "usage (as super user): ", $program_name," [options]\n";
    print " -h: Print the command line help\n";
    print " -v: Print the program version\n";
    print " -a address: IP address (or host name) of the Cisco router\n";
    print " -u login: Cisco login\n";
    print " -p password: Cisco password\n";
    print " -P password: Cisco enable password\n";
    print " -t address: IP address (or host name) of the TFTP server\n";
    print " -c filename: Name of the configuration file on the TFTP server\n";
    exit (-1);
}
# Get the address or hostname
if ($opts{a}) {
    $address = $opts{a};
}
# Get the login / password
if ($opts{u}) {
    $login = $opts{u};
}
if ($opts{p}) {
    $password = $opts{p};
}
if ($opts{P}) {
    $enablepassword = $opts{P};
}

if ($opts{t}) {
    $tftp = $opts{t};
}

if ($opts{c}) {
    $confname = $opts{c};
}

# Init
my $session = Net::Telnet::Cisco->new(Host => $address);
$session->login($login, $password);

# Enable mode
if ($session->enable($enablepassword) ) {
    @output = $session->cmd("copy system:/running-config "
                        	. "tftp://$tftp/$confname\n\n\n");
    print "@output\n";
} else {
    warn "Can't enable: " . $session->errmsg;
}

# End
$session->close;