#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use XML::Simple;

$specification = q(
	-i <file>	XML file input
	-o <file>	XML file output
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

die unless exists $conf->{'-i'} and -f $conf->{'-i'};

my $c = read_file($conf->{'-i'});

my @entries = $c =~ /(<evidence>.*?<\/evidence>)/sg;

my $header=<<OUT;
<?xml version="1.0"?>
<!DOCTYPE evidences SYSTEM "http://elleconnect.com/bleaf/xml/dtds/bLeaf-v1.0.dtd">
<announcement>
  <metadata>
    <version>bLeaf 0.10</version>
  </metadata>
  <items>
OUT

my $footer=<<OUT;
  </items>
</announcement>
OUT

my $filenameprefix = $conf->{'-o'};
my $i = 1;
while (@entries) {
  my @next250 = splice @entries, 0, 250;
  my $fh = IO::File->new();
  my $outfile = $filenameprefix."-$i.xml";
  $fh->open(">$outfile") or die "cannot open $outfile\n";
  print $fh $header."\n".join("\n",@next250)."\n".$footer;
  $fh->close();
  system "xmlstarlet fo ".shell_quote($outfile)." > /tmp/postprocess.xml; mv /tmp/postprocess.xml ".shell_quote($outfile);
  ++$i;
}
