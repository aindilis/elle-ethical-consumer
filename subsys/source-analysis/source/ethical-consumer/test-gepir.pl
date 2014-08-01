#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use Sayer;
use System::WWW::GEPIR;

my $sayer =
  Sayer->new
  (
   DBName => "sayer_test",
  );
my $gepir = System::WWW::GEPIR->new
  (Sayer => $sayer);

my $results = $gepir->CacheResults
  (
   CompanyName => "Sony",
   Country => "US",
  );

# print Dumper($results);
if ($results->{Success}) {
  print Dumper($results->{Result});
}
# print Dumper({Hey => $results});
