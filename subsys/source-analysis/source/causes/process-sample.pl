#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $text = read_file("sample.html");
print $text."\n\n\n";
# my @res = $text =~ /<a href="([^"]+)" title="([^"]+)" target="([^"]+)>(.+?)<\/a>/sg;
my @res = $text =~ /<a href="([^"]+)" title="([^"]+)" target="([^"]+)">(.+?)<\/a>/sg;
print Dumper(\@res);
