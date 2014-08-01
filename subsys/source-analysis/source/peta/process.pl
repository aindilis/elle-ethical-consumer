#!/usr/bin/perl -w

use PerlLib::Cacher;

my $cacher = PerlLib::Cacher->new
  (
   CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/peta/FileCache",
  );

foreach my $i (0..67) {
  my $url = "http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=0&PageIndex=$i";
  $cacher->get($url);
  print $url."\n";
  # print $cacher->content()."\n";
  if (! $cacher->is_cached()) {
    sleep 10;
  }
}

foreach my $i (0..11) {
  my $url = "http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=$i";
  $cacher->get($url);
  print $url."\n";
  # print $cacher->content()."\n";
  if (! $cacher->is_cached()) {
    sleep 10;
  }
}


