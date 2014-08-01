package Com::elle::bLeaf::EvidenceGenerator::Normalizer;

use Com::elle::bLeaf::EvidenceGenerator::Normalizer::GUI;
use Com::elle::bLeaf::EvidenceGenerator::Normalizer::XMLGenerator;

use Manager::Dialog;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
}

sub Normalize {
  my ($self,%args) = @_;
  # bring up the gui for normalize gui, get the items, then generate
  # the xml point, sign and store
  my @companies;
  foreach my $companyname (sort @{$args{CompanyNames}}) {
    # look to see if this is already normalized
    # FIXME FIXME

    my $gui = Com::elle::bLeaf::EvidenceGenerator::Normalizer::GUI->new();
    my $res = $gui->ProcessCompanyName(Name => $companyname);

    if ($res->{Success}) {
      print Dumper({TheseResult => $res->{Results}});
      push @companies, @{$res->{Results}};
    }
  }
  # generate the title and have it reviewed
  $self->GenerateTitle
    (
     Title => $args{Title},
     Polarities => $args{Polarities},
     Companies => \@companies,
     Sources => $args{Sources},
    );

  # now if we are in regenerate mode, generate the xml
  if (scalar @companies) {
    return {
	    Success => 1,
	    Result => {
		       Title => $args{Title},
		       Sources => $args{Sources},
		       Links => $args{Links},
		       Description => $args{Description},
		       Companies => \@companies,
		       Categories => $args{Categories},
		       Reviews => $args{Reviews},
		       Polarities => $args{Polarities},
		      },
	   };
  } else {
    return
      {
       Success => 0,
      };
  }
}

sub GenerateTitle {
  my ($self,%args) = @_;
  # take the polarities and the companies
  return;

  my $newtitle = "This is a temporary title";

  # $args{Title},
  #   $args{Polarities},
  #     $args{Companies},
  # 	$args{Sources},

  # Norm => "",
  #   Tagged => "",
  #     Address => "",
  # 	GCP => [],
  # 	  Original => "",

  my $subject = "";
  my $verb = "";
  my $object = "";

  if (SingleCompany(%args)) {
    my $companyhash = $args{Companies}->[0];
    # determine subject
    $subject = $companyhash->{Tagged};

    # determine verb
    $verb = "on";

    # my $tmp = exists $companyhash->{Original} ? $companyhash->{Original} : $subject;
    # my $polarity
    # if (exists $args{Polarities}->{$tmp}) {
    #   $polarity = $args{Polarities}->{$tmp};
    # }
    # if (defined $polarity) {
    #   if ($polarity eq "-1") {
    # 	$verb = "impedes";
    #   } elsif ($polarity eq "0") {
    # 	$verb = "on";
    #   } elsif ($polarity eq "+1") {
    # 	$verb = "promotes";
    #   }
    # } else {
    #   $verb = "on";
    # }
  }

  if (MultipleCompaniesAndSameRating(%args)) {
    my $polarities = {};
    foreach my $companyhash (@{$args{Companies}}) {
      my $tmp = exists $companyhash->{Original} ? $companyhash->{Original} : $subject;
      my $polarity;
      if (exists $args{Polarities}->{$tmp}) {
	$polarity = $args{Polarities}->{$tmp};
	$polarities->{$polarity} = 1;
      }
    }
    my $count = scalar keys %$polarities;
    if ($count == 0) {
      # do nothing
    } elsif ($count == 1) {
      $subject = "<GROUP-NAME>";
    } elsif ($count > 1) {
      # use the source name
      if ($args{Sources}) {
	$subject = $args{Sources}->[0]->LinkText;
      } else {
	$subject = "<SOURCE-NAME>";
      }
    }
  }

  if ($UNIVERSAL::evidencegenerator->CurrentNews->Title ne ${$UNIVERSAL::evidencegenerator->MyTitle}) {
    if (Approve("Overwrite custom title (".${$UNIVERSAL::evidencegenerator->MyTitle}.") with newly generated title ($newtitle)?")) {
      ${$UNIVERSAL::evidencegenerator->MyTitle} = $newtitle;
    }
  } else {
    ${$UNIVERSAL::evidencegenerator->MyTitle} = $newtitle;
  }
}

sub SingleCompany {

}

sub MultipleCompaniesAndSameRating {

}

1;
