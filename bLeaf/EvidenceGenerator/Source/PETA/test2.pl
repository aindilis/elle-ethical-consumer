#!/usr/bin/perl -w

use PerlLib::Cacher;

my $cacher = PerlLib::Cacher->new
  (
   CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/peta/FileCache",
  );

$cacher->get("http://www.frdcsa.org");
print $cacher->is_cached()."\n";
$cacher->delete("http://www.frdcsa.org");
$cacher->get("http://www.frdcsa.org");
print $cacher->is_cached()."\n";
