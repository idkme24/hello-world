#!/usr/bin/perl


#########################
#	Setup Script	#
#	Peyton Rathbun	#
#	11/27/15	#
#########################

## Variables
$op0=$ARGV[0];
$op1=$ARGV[1];

sub setup
{
	## Set HOSTNAME
	print "Setting HOSTNAME: $op1\n";
	$shn = system("hostnamectl set-hostname $op1");
	if ($shn == 0) {
		print "HOSTNAME has been set\n";
	} else {
		print "HOSTNAME was NOT set\n";
		exit(1);
	}

	## Set IP
	print "Setting IP ADDRESS: $op0\n";
	`rm /etc/sysconfig/network-scripts/ifcfg-eth0`;
	($oct1,$oct2,$oct3)=split(/\./, $op0);
	$GW = join ".", $oct1, $oct2, $oct3, "1";
	$DNS_STRING='ipv4.dns "22.5.20.10 22.5.20.1"';
	$sip = system("nmcli con add type ethernet con-name eth0 ifname eth0 ip4 $op0 gw4 $GW");
	`nmcli con mod eth0 $DNS_STRING`;
	if ($sip == 0) {
                print "IP ADDRESS has been set\n";
        } else {
                print "IP ADDRESS was NOT set\n";
                exit(1);
        }

	## Connect to Satelite
	print "Connecting to Satelite Server\n";
	`cd /etc/yum.repos.d/ rm -rf *`;
	`rpm -Uvh http://homcsatp401.tynra.lan/pub/katello-ca-consumer-latest.noarch.rpm`;
	$jss='subscription-manager register --org="HomeDataCenter" --activationkey="Centos-7-Base-Key-DEV"';
	$scs = system("$jss");
	if ($scs == 0) {
                print "$op1 has been joined to Satelite\nFinish configureation in Satelite UI!!\n";
		`yum -y install katello-agent`;
        } else {
                print "$op1 has NOT been joined to Satelite\n";
                exit(1);
        }

	## Connect to IPA
	print "Connecting to IPA Server\n";
	`ipa-client-install --domain=tynra.lan --server=homcipap401.tynra.lan`;
}

sub help
{
	print "help\n";
}

sub main
{
	if ($op0 eq "-h" || $op0 eq "--help") {
		&help;
	} elsif ($op0 eq "") {
		print "Bad Option\nUSAGE: setup.pl IP_ADDRESS HOSTNAME\n";
	} elsif ($op0 ne "") {
		if ($op1 eq "") {
			print "Bad Option\nUSAGE: setup.pl IP_ADDRESS HOSTNAME\n";
		} else {
			&setup;
		}
	}
}

## Call Main
&main
