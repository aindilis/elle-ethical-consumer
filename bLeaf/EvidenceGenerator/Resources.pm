package Com::elle::bLeaf::EvidenceGenerator::Resources;

use Com::elle::bLeaf::EvidenceGenerator::Markup;
use Com::elle::bLeaf::EvidenceGenerator::Normalizer;

use Capability::TextAnalysis;
use PerlLib::Cacher;
use PerlLib::HTMLConverter;
use PerlLib::MySQL;
use PerlLib::ToText;
use Sayer;
use System::WWW::DBpediaSpotlight;
use System::WWW::GEPIR;

use DateTime::Format::ICal;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMySQL MyCacher MyToText MyMainWindow MyDateManip
   DateTimeDurationFormatter MyMarkup Mech Dontskip Skip MySayer
   TextAnalysis Rows Regexes MyDBpediaSpotlight MyNormalizer
   MyHTMLConverter NumberOfTerms Frequency Manufacturers2GCP
   MyCategories MyGEPIR /

  ];

sub init {
  my ($self,%args) = @_;
  print "Started loading\n";
  $self->Regexes({});
  $self->MySayer
    (Sayer->new
     (
      DBName => "sayer_elle_bleaf",
     ));
  $self->Skip
    ({
      CoreferenceResolution => 1,
      CycLsForNP => 1,
      DateExtraction => 1,
      FactExtraction => 1,
      GetDatesTIMEX3 => 1,
      KNext => 1,
      MontyLingua => 1,
      NounPhraseExtraction => 1,
      # SemanticAnnotation => 1,
      DBpediaSpotlight => 1,
      SpeechActClassification => 1,
      TermExtraction => 1,
      Tokenization => 1,
      WSD => 1,
     });
  $self->Dontskip
    ({
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
      # DBpediaSpotlight => 1,
      # SpeechActClassification => 1,
      # TermExtraction => 1,
      # Tokenization => 1,
      # WSD => 1,
     });
  $self->MyCacher
    (PerlLib::Cacher->new);
  $self->MyToText
    (PerlLib::ToText->new);
  $self->MyDBpediaSpotlight
    (System::WWW::DBpediaSpotlight->new());
  $self->MyMarkup
    (Com::elle::bLeaf::EvidenceGenerator::Markup->new());
  $self->MyHTMLConverter
    (PerlLib::HTMLConverter->new());
  $self->LoadManufacturers();
  $self->GenerateLanguageModel();
  $self->MyMySQL
    (PerlLib::MySQL->new
     (DBName => "Com_elle_bLeaf"));
  foreach my $row (@rows) {
    my $regex = $row->[1];
    $regex =~ s/([^A-Za-z0-9])/\\$1/sg;
    push @regexes, $regex;
    $self->Regexes->{$regex} = $row->[1];
  }
  $self->MyNormalizer
    (Com::elle::bLeaf::EvidenceGenerator::Normalizer->new());


  # Source A is for Environmental Reporting,
  # Source B is against Environmental Reporting
  # Company X is for Environmental Reporting
  # polarity(A,X) = 1
  # polarity(B,X) = -1

  # Source A title is X promotes Environmental Reporting
  # Source B title is X demotes Environmental Reporting


  $self->MyCategories
    ({
      "Human Rights" => {
			 "Poverty" => -1,
			 "Health and Wellness" => 1,
			 "Discrimination" => -1,
			 "Religious Rights" => 1,
			},
      "Animal" => {
		   "Animal Testing" => -1,
		   "Factory Farming" => -1,
		   "Animal Rights" => 1,
		   "Animal Cruelty" => -1,
		  },
      "Environment" => {
			"Environmental Reporting" => 1,
			"Nuclear Power" => 1,
			"Climate Change" => 1,
			"Pollution and Toxics" => 1,
			"Habitats and Resources" => 1,
			"Carbon Footprint" => 1,
		       },
      "Business Practices" => {
			       "Worker Rights" => 1,
			       "Supply Chain Policy" => 1,
			       "Irresponsible Marketing" => 1,
			       "Arms and Military Supply" => 1,
			      },
      "Politics" => {
		     "Anti Social Finance" => 1,
		     "Boycott Calls" => 1,
		     "Genetic Engineering" => 1,
		     "Political Activity" => 1,
		     "Fairtrade" => 1,
		    },
      "Technology" => {
		       "Net Neutrality" => 1,
		       "Open/Closed Source" => 1,
		       "Big/Little Brother" => 1,
		       "Genetic Engineering" => 1,
		       "Stem Cell/Cloning Research" => 1,
		      },
     });
  print "Finished loading\n";
}

sub Execute {
  my ($self,%args) = @_;
  if (1) {			# do named entity recognition
    delete $self->Skip->{NamedEntityRecognition};
    $self->Dontskip->{NamedEntityRecognition} = 1;
  } else {			# don't do named entity recognition
    $self->Skip->{NamedEntityRecognition} = 1;
    delete $self->Dontskip->{NamedEntityRecognition};
  }
  if ($UNIVERSAL::evidencegenerator->Conf->{'--dbpedia'}) { # do dbpedia
    delete $self->Skip->{DBpediaSpotlight};
    $self->Dontskip->{DBpediaSpotlight} = 1;
  } else {			# skip dbpedia
    $self->Skip->{DBpediaSpotlight} = 1;
    delete $self->Dontskip->{DBpediaSpotlight};
  }
  $self->TextAnalysis
    (Capability::TextAnalysis->new
     (
      Sayer => $self->MySayer,
      Skip => $self->Skip,
      DontSkip => $self->Dontskip,
     ));
  $self->MyGEPIR
    (System::WWW::GEPIR->new
     (Sayer => $self->MySayer));
}


sub LoadManufacturers {
  my ($self,%args) = @_;
  my $csvfile = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/manufacturers/upcdatabase-2008.03.01/mfrs.csv";
  my $csv = Text::CSV->new ( { binary => 1 } ) # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
  open my $fh, "<:encoding(utf8)", $csvfile or die "$csvfile: $!";
  $self->Manufacturers2GCP({});
  while ( my $row = $csv->getline( $fh ) ) {
    push @rows, [$row->[0],lc($row->[1])];
    if (! exists $self->Manufacturers2GCP->{lc($row->[1])}) {
      $self->Manufacturers2GCP->{lc($row->[1])} = [$row->[0]];
    } else {
      push @{$self->Manufacturers2GCP->{lc($row->[1])}}, $row->[0];
    }
  }
  $csv->eof or $csv->error_diag();
  close $fh;
  $self->Rows(\@rows);
}

sub GenerateLanguageModel {
  my ($self,%args) = @_;
  print "Generating Language Model\n";
  my @corpus;
  foreach my $row (@{$self->Rows}) {
    push @corpus, $row->[1];
  }
  print "Generating IDF\n";
  my $num = 0;
  foreach my $word (map {lc($_)} split /\W+/, join("\n",@corpus)) {
    # print Dumper($word);
    if (defined $freq{$word}) {
      $freq{$word} += 1;
    } else {
      $freq{$word} = 1;
    }
    ++$num;
  }
  $self->NumberOfTerms($num);
  $self->Frequency(\%freq);
  print "Done Generating Language Model\n";
}

sub FormatDateTime {
  my ($self,%args) = @_;
  return DateTime::Format::ICal->format_datetime($args{DateTime});
}

1;
