#!/usr/bin/perl

#create table repeated( id integer UNIQUE NOT NULL);

use strict;
#use Net::Twitter;
#use Net::Twitter::Diff;
use Net::Twitter::Search;
#use Data::Dumper;
#use DBI;
use Getopt::Long qw(GetOptions);
use Pod::Usage;


#my $dsn    = "dbi:Pg:dbname=bots";
#my $dbh    = DBI->connect($dsn, 'brenda', '')
#  or unlock_die ("Cannot connect to the database '$dsn': $DBI::errstr");

my ($username, $password, $trigger);
my $help = 0; 
my $max = 1;

my $result = GetOptions(
	'help' => \$help, 
	'username=s' => \$username, 
	'password=s' => \$password, 
	'trigger=s' => \$trigger, 
	'max=s' => \$max,

);

pod2usage(-exitval => 0, -verbose => 2) if($help);
pod2usage(-exitval => 1, -verbose => 1) unless ($username && $password && $trigger); 

my $search = Net::Twitter::Search->new(  username => $username, password => $password);

print "Searching for $trigger, max results $max\n";
my $results = $search->search($trigger);

my $repeats_thus_far = 0;

foreach my $tweet (@{ $results }) {
	my $speaker =  $tweet->{from_user};
	my $text = $tweet->{text};
	my $time = $tweet->{created_at};
	print "$time <$speaker> $text\n";
	if ($text =~ /^\@/) {
      print "Skipping reply\n";
    }
	elsif ($speaker =~ m/$username/i) {
		print "\tThat's me!\n";
	}
	else {
		my $repeat = $text;
		chomp($repeat);
		$repeat = "\@$speaker <3! $repeat";
		print "*** \tRepeating: $repeat\n";
		$search->update($repeat);
		$repeats_thus_far++;
	}

	if ($repeats_thus_far >= $max) {
		exit;
	}
}

__END__

=head1 NAME

bot.pl - Searches for a word/phrase on twitter, and then repeats the whole tweet to a twitter account

=head1 SYNOPSIS

  bot.pl --username=<username> --password=<password> --trigger="<phrase>"

=head1 OPTIONS

  -? --help Verbose help 

=head1 DESCRIPTION

To aggregate all posts on a subject into a single twitter account for following.

e.g. if you want to follow all tweets on "erlang", use erlang as you trigger, and create an account for this script to tweet into. By following this account you can keep up with erlang tweets

or, if you are running a conference, use the name of the conference as a trigger, and suggest conference attendees follow your official conference twitter account.

=head1 EXAMPLES

  ./bot.pl --username=DreadPirateRoberta --password=asyouwish --trigger="super happy dev house"

=head1 CREDIT

This script by Brenda Wallace
http://coffee.geek.nz

=cut


