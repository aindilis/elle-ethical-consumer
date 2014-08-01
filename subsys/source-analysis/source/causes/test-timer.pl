#!/usr/bin/perl -w

use Data::Dumper;
use DateTime;
use DateTime::Duration;

my $duration2 = DateTime::Duration->new(seconds => 4);
my $datetime = DateTime->now();
for (my $i = 1; $i < 10; ++$i) {
  my $last = $datetime;
  $datetime = DateTime->now();
  $duration = $datetime - $last;
  my $res = DateTime::Duration->compare($duration, $duration2, $datetime);
  print $res."\n";
  if ($res < 0) {
    # compute the delay
    my $duration3 = $duration2 - $duration;
    my $extra = $duration3->{seconds};
    print "sleeping an extra $extra\n";
    sleep $extra;
  }
  print "sleeping $i\n";
  sleep $i;
}
