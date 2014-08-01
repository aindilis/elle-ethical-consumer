#!/usr/bin/perl -w

use PerlLib::Cacher;
# use PerlLib::IE::AIE;
use PerlLib::SwissArmyKnife;
use PerlLib::HTMLConverter;

my $cacher = PerlLib::Cacher->new
  (
   CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/ethical-consumer/FileCache",
  );

my $htmlconverter = PerlLib::HTMLConverter->new();

$cacher->get("http://www.ethicalconsumer.org/Boycotts/currentboycottslist.aspx");
my $content = $cacher->content();
# print $content;

# my $aie = PerlLib::IE::AIE->new(Contents => $content);

if ($content =~ /<!-- Start_Module_1460 -->(.+?)<!-- End_Module_1460 -->/s) {
  my $talk = $1;
  my @items = split /&#160;/,$talk;
  # print Dumper(\@items);
  # exit(0);
  foreach my $item (@items) {
    if ($item =~ /<h3>(.+?)<\/h3>(.+)/s) {
      my $title = $1;
      my $content = $2;
      my $res = $htmlconverter->ConvertToTxt
	(
	 Contents => "<p>$title</p>",
	);
      $res =~ s/^\s*//;
      $res =~ s/\s*$//;
      $res =~ s/\s+/ /g;
      # print $res."\n";
      # print $content."\n";
      my $res2 = $htmlconverter->ConvertToTxt
	(
	 Contents => "<p>$content</p>",
	);
      $res2 =~ s/^\s*//;
      $res2 =~ s/\s*$//;
      $res2 =~ s/\s+/ /g;

      print Dumper([
		    $res,
		    $res2,
		   ]);
    }
  }
}
