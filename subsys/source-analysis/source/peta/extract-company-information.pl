#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $c = read_file("sample.html");
# print $c."\n";
my $urls = {};
if ($c =~ /<ul class="company-list">(.+?)<\/ul>/s) {
  print $1;
  my $contents = $1;
  my @items = $contents =~ /<li>(.+?)<\/li>/sg;
  foreach my $item (@items) {
    if ($item =~ /<a title="[^"]+" href="([^"]+)">(.+?)<\/a>/s) {
      my $url = "http://www.peta.org".$1;
      my $name = $2;
      $urls->{$name} = $url;
    } else {
      print "ERROR: $item\n";
    }
  }
}

print Dumper($urls);
