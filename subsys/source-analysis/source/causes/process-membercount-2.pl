#!/usr/bin/perl -w

use Capability::TextAnalysis;
use PerlLib::SwissArmyKnife;
use Sayer;
use System::WWW::DBpediaSpotlight;

use DateTime;
use Encode::Encoder;
use Text::CSV;
use Text::LevenshteinXS qw(distance);
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

my @rows;
LoadManufacturers();

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
  die "reached last item\n" if $cause == 813;
  print $causes->{$cause}."\t".$cause."\n";
  # process this cause with the proper data analysis
  print $cause."\n";
  my $causesdir = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/cause-xml";
  my $c = read_file("$causesdir/$cause.xml");
  # print $c."\n";
  my $xml = XMLin($c);
  my $desc = $xml->{description};
  # process this with both OpenCalais and DBpediaSpotlight

  my @matches = $desc =~ /\b(boycott|objection|protest|oppose|resist|resistance|take issue|remonstrance|remonstration|ban|banish|exclude|expel|kick out|shun|shut out|complain|protestation|demonstrate|fight|fight back)\b/sgi;
  if (! scalar @matches) {
    next;
  }
  print Dumper({Matches => \@matches});
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
      print "skipping sleep because we are not retrieving\n";
      # sleep $extra;
    }
  } else {
    print "All results were cached\n";
  }
  print "processing\n";
  my $results = $textanalysis->AnalyzeText
    (
     Text => latin1ify($desc),
     OnlyRetrieve => 1,
    );
  ProcessResults(Results => $results);
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

sub ProcessResults {
  my %args = @_;
  my $res = $args{Results};
  my @results;
  foreach my $ref (@{$res->{SemanticAnnotation}}) {
    if (exists $ref->{CalaisSimpleOutputFormat}->{Company}) {
      my $reftype = ref $ref->{CalaisSimpleOutputFormat}->{Company};
      if ($reftype eq "ARRAY") {
	foreach my $entry (@{$ref->{CalaisSimpleOutputFormat}->{Company}}) {
	  push @results, $entry;
	}
      } elsif ($reftype eq "HASH") {
	push @results, $ref->{CalaisSimpleOutputFormat}->{Company};
      }
    }
    # if (exists $ref->{CalaisSimpleOutputFormat}->{Organization}) {
    #   my $reftype = ref $ref->{CalaisSimpleOutputFormat}->{Organization};
    #   if ($reftype eq "ARRAY") {
    # 	foreach my $entry (@{$ref->{CalaisSimpleOutputFormat}->{Organization}}) {
    # 	  push @results, $entry;
    # 	}
    #   } elsif ($reftype eq "HASH") {
    # 	push @results, $ref->{CalaisSimpleOutputFormat}->{Organization};
    #   }
    # }
  }
  # foreach my $item (@{$res->{DBpediaSpotlight}}) {
  #   if ($item->{Success}) {
  #     my $res2 = ProcessDBpediaSpotlight(Text => $item->{Result});
  #     if ($res2->{Success}) {
  # 	push @results, @{$res2->{Results}};
  #     }
  #   }
  # }
  print Dumper({CompaniesAndOrganizations => \@results});
  foreach my $tmp (@results) {
    # /s2/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/manufacturers/upcdatabase-2008.03.01/mfrs.csv
    # print Dumper($tmp);
    ProcessCompanyName(Name => $tmp->{content});
  }
}

sub ProcessDBpediaSpotlight {
  my %args = @_;
  my $text = $args{Text};
  # print $text."\n\n\n";
  my @res = $text =~ /<a href="([^"]+)" title="([^"]+)" target="([^"]+)">(.+?)<\/a>/sg;
  print Dumper({DBpediaSpotlight => \@res});
  return {
	  Success => 0,
	 };
}

sub LoadManufacturers {
  my $csvfile = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/manufacturers/upcdatabase-2008.03.01/mfrs.csv";
  my $csv = Text::CSV->new ( { binary => 1 } ) # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
  open my $fh, "<:encoding(utf8)", $csvfile or die "$csvfile: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    push @rows, [$row->[0],lc($row->[1])];
  }
  $csv->eof or $csv->error_diag();
  close $fh;
  # print Dumper(\@rows);
}

sub ProcessCompanyName {
  my %args = @_;
  my $scores = {};
  my $lcname = lc($args{Name});
  foreach my $row (@rows) {
    my $score = distance($lcname,$row->[1]);
    $scores->{$row->[1]} = $score;
  }
  my @list = sort {$scores->{$a} <=> $scores->{$b}} keys %$scores;
  my @top = splice(@list,0,10);
  print Dumper({
		Name => $args{Name},
		Top => \@top,
	       });
}
