#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use System::WWW::OpenCalais;
use XML::Simple qw(XMLin);

my $opencalais = System::WWW::OpenCalais->new
  (Type => "Text/RDF");
my $causexmlsdir = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/cause-processor/cause-xml";
my $files = `ls $causexmlsdir`;
foreach my $file (split /\n/, $files) {
  my $fn = "$causexmlsdir/$file";
  print "<$fn>\n";
  my $contents = read_file($fn);
  my $xml = XMLin($contents);
  # print Dumper($xml);
  # need to process the description
  my $res = $opencalais->ProcessAndParse
    (Contents => $xml->{description});
  print Dumper($res);
  GetSignalFromUserToProceed();

}
