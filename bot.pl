#!/usr/bin/perl

#create table repeated( id integer UNIQUE NOT NULL);

use strict;
use Net::Twitter;
use Net::Twitter::Diff;
use Net::Twitter::Search;
use Data::Dumper;
use DBI;


my $dsn    = "dbi:Pg:dbname=bots";
my $dbh    = DBI->connect($dsn, 'brenda', '')
  or unlock_die ("Cannot connect to the database '$dsn': $DBI::errstr");

my $username = $ARGV[0];
my $password = $ARGV[1]; 
my $trigger =  $ARGV[2]; 

die ("Username and Password and trigger required\n") unless ($username && $password && $trigger);

my $twit = Net::Twitter::Diff->new(  username => $username, password => $password);
my $search = Net::Twitter::Search->new(  username => $username, password => $password);

my %repeated = {};

my @result = getRecordSet('SELECT * FROM repeated ORDER BY id DESC LIMIT 1000');
foreach my $t (@result) {
  $repeated{$t->{id}} = 1;
}


	my $results = $search->search($trigger);
 	foreach my $tweet (@{ $results }) {
 		my $speaker =  $tweet->{from_user};
        	my $text = $tweet->{text};
 		my $time = $tweet->{created_at};
       	 	print "$time <$speaker> $text\n";
 		if($repeated{$tweet->{id}}) {
 			print "\t Already repeated\n";
 		}
 		elsif ($speaker =~ m/$username/i) {
 			print "\tThat's me!\n";
 		}
 		else {
 			my $repeat = $text;
 			chomp($repeat);
 			$repeat = "\@$speaker says $repeat";
 			print "*** \tRepeating: $repeat\n";
 			$twit->update($repeat);
 			my $sQuery = $dbh->prepare('INSERT INTO repeated (id) VALUES (?)');
 			$sQuery->execute($tweet->{id});
 			$repeated{$tweet->{id}} = 1;
  	  	}
 	}


sub getRecordSet {
    my $query = shift;
    my $sQuery = $dbh->prepare($query);
    $sQuery->execute or die ("Error in query:\n $query\n");

    my $hRecordSet;
    my @aReturnRecordSet;
    while ( my $sRecordSet = $sQuery->fetchrow_hashref()) {
        push(@aReturnRecordSet,$sRecordSet);
    }

    return (@aReturnRecordSet);
}

