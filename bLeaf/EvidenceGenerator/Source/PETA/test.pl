#!/usr/bin/perl -w

use PerlLib::Cacher;
use PerlLib::SwissArmyKnife;

my $cacher = PerlLib::Cacher->new
  (
   CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/peta/FileCache",
  );

my $files =<<OUT;
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=1
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=2
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=3
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=4
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=5
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=6
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=7
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=8
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=9
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=10
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=11
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=12
http://www.peta.org/living/beauty-and-personal-care/companies/search.aspx?Testing=1&PageIndex=13
OUT

foreach my $url (reverse split /\n/, $files) {
  $cacher->get($url);
  # print $cacher->content();
  GetSignalFromUserToProceed();
}
