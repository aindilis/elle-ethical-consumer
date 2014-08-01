#!/usr/bin/perl -w

use PerlLib::Cacher;
use PerlLib::SwissArmyKnife;

use WWW::Mechanize;

my $content;
if (0) {
  my $mech = WWW::Mechanize->new();
  $mech->get("http://jobs.perl.org/rss/telecommute.rss");
  $content = $mech->content();
} else {
  $content = read_file("telecommute.rss");
}
my @urls = $content =~ /<item rdf:about="([^\"]+)">/sg;
print Dumper(\@urls);
my $cacher = PerlLib::Cacher->new
  (
   CacheRoot => "/var/lib/myfrdcsa/codebases/minor/js-rapid-response/data/source/JobsPerlOrg/FileCache",
  );
my $i = 0;
foreach my $url (@urls) {
  $cacher->get($url);
  my $pagecontent = $cacher->content();
  my @items = $pagecontent =~ /<tr>\s*<td valign=top>\s*<a name="([^\"]+)"><\/a>([^:]+):\s*<\/td>\s*<td valign=top>\s*(.+?)\s*<\/td>\s*<\/tr>/sg;
  print "$i\n";
  ++$i;
  # print Dumper(\@items);
  GetSignalFromUserToProceed();
}
