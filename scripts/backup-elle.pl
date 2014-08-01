#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $date = DateTimeStamp();
my $command = "tar czf /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/data/elle-ethical-consumer-$date.tgz /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/";
print $command."\n";
system $command;
