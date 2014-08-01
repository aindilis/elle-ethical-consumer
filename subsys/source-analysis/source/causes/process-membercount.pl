#!/usr/bin/perl -w

use Capability::TextAnalysis;
use PerlLib::SwissArmyKnife;
use Sayer;
use System::WWW::DBpediaSpotlight;

use DateTime;
use Encode::Encoder;
use XML::Simple qw(XMLin);

# grep "member-count type="  cause-xml/* > membercount.txt

my $sayer =
  Sayer->new
  (
   DBName => "sayer_elle_bleaf",
  );

my $textanalysis =
  Capability::TextAnalysis->new
  (
   Sayer => $sayer,
   Skip => {
	    CoreferenceResolution => 1,
	    CycLsForNP => 1,
	    DateExtraction => 1,
	    FactExtraction => 1,
	    GetDatesTIMEX3 => 1,
	    KNext => 1,
	    MontyLingua => 1,
	    NamedEntityRecognition => 1,
	    NounPhraseExtraction => 1,
	    # SemanticAnnotation => 1,
	    # DBpediaSpotlight => 1,
	    SpeechActClassification => 1,
	    TermExtraction => 1,
	    Tokenization => 1,
	    WSD => 1,
	   },
   DontSkip => {
		# CoreferenceResolution => 1,
		# CycLsForNP => 1,
		# DateExtraction => 1,
		# FactExtraction => 1,
		# GetDatesTIMEX3 => 1,
		# KNext => 1,
		# MontyLingua => 1,
		# NamedEntityRecognition => 1,
		# NounPhraseExtraction => 1,
		SemanticAnnotation => 1,
		DBpediaSpotlight => 1,
		# SpeechActClassification => 1,
		# TermExtraction => 1,
		# Tokenization => 1,
		# WSD => 1,
	       },
  );


my $dbpediaspotlight = System::WWW::DBpediaSpotlight->new();

my $causes = {};
foreach my $line (split /\n/, `cat /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/membercount.txt`) {
  # print "<$line>\n";
  # cause-xml/1957.xml:  <member-count type="integer">16</member-count>>
  if ($line =~ /^cause-xml\/(\d+)\.xml:\s+<member-count type="integer">(\d+)<\/member-count>$/) {
    my ($cause,$count) = ($1,$2);
    $causes->{$cause} = $count;
  }
}

my $last;
my $datetime = DateTime->now();
my $duration2 = DateTime::Duration->new(seconds => 5);

foreach my $cause (sort {$causes->{$b} <=> $causes->{$a}} keys %$causes) {
  print $causes->{$cause}."\t".$cause."\n";
  # process this cause with the proper data analysis
  print $cause."\n";
  my $causesdir = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/cause-xml";
  my $c = read_file("$causesdir/$cause.xml");
  # print $c."\n";
  my $xml = XMLin($c);
  my $desc = $xml->{description};
  # process this with both OpenCalais and DBpediaSpotlight


  my $last = $datetime;
  $datetime = DateTime->now();
  if (! $textanalysis->AllResultsWereCached) {
    $duration = $datetime - $last;
    my $res = DateTime::Duration->compare($duration, $duration2, $datetime);
    print $res."\n";
    if ($res < 0) {
      # compute the delay
      my $duration3 = $duration2 - $duration;
      my $extra = $duration3->{seconds};
      print "sleeping an extra $extra\n";
      sleep $extra;
    }
  } else {
    print "All results were cached\n";
  }
  print "processing\n";
  my $results = $textanalysis->AnalyzeText
    (
     Text => latin1ify($desc),
    );
  print Dumper($results);
  # print Dumper($results);
  # GetSignalFromUserToProceed();
}

sub latin1ify {
  my $string = shift || "";
  Encode::encode
      (
       "iso-8859-1",
       Encode::decode_utf8($string),
      );
}
