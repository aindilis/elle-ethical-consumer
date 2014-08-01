#!/usr/bin/perl -w

use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

my $mysql = PerlLib::MySQL->new
  (DBName => "Com_elle_bLeaf");

my $res = $mysql->Do
  (
   Statement => "select xml from xml",
   Array => 1,
  );

# print Dumper($res);
my @evidencexmls;
foreach my $item (@$res) {
  foreach my $item2 (@$item) {
    # print Dumper($item);
    push @evidencexmls, $item->[0];
  }
}

my $out = "<?xml version='1.0' ?>
<!DOCTYPE evidences SYSTEM \"http://elleconnect.com/andrewdo/bleaf/dtds/sample11.dtd\">
<announcement>
  <metadata>
    <version>bLeaf 0.10</version>
  </metadata>
  <items>
  ".join("\n",@evidencexmls)."
  </items>
</announcement>
";

$out =~ s/[^[:ascii:]]/ /sg;

my $fh = IO::File->new();
my $file = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/data/sample.xml";
my $file2 = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/data/sample.xml";
$fh->open(">$file") or die "cannot open $file\n";
print $fh $out;
$fh->close();

system "xmlstarlet fo ".shell_quote($file)." > /tmp/sample.xml; mv /tmp/sample.xml ".shell_quote($file);
