package Com::elle::bLeaf::EvidenceGenerator::Entity;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Type System Contents Normalized NormalizedURL Count Relevance /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Type($args{Type});
  if ($args{OpenCalais}) {
    $self->Count($args{OpenCalais}->{count});
    $self->Contents($args{OpenCalais}->{content});
    if (exists $args{OpenCalais}->{normalized}) {
      $self->Normalized($args{OpenCalais}->{normalized});
    }
    $self->Relevance($args{OpenCalais}->{relevance});
    $self->System("OpenCalais");
  } else {
    $self->System($args{System});
    $self->Contents($args{Contents});
    if ($args{NormalizedURL}) {
      $self->NormalizedURL($args{NormalizedURL});
    }
    if ($args{Normalized}) {
      $self->Normalized($args{Normalized});
    } else {
      if ($args{NormalizedURL}) {
	my $url = $self->NormalizedURL;
	if ($url =~ /^http:\/\/dbpedia\.org\/resource\/(.+)$/) {
	  $url =~ s/_/ /g;
	  $self->Normalized($url);
	}
      } else {
	# WE could probably add an additional layer of normalization
	# here

	# perhaps try to normalize based on a normalization service
	# which includes normalizing to manufacturer
	$self->Normalized($self->Contents);
      }
    }
  }
}

sub Print {
  my ($self,%args) = @_;
  print $self->SPrint();
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper
    (
     $self->Type,
     $self->System,
     $self->Contents,
     $self->Normalized,
     $self->NormalizedURL,
    );
}

sub ShouldSelect {
  my ($self,%args) = @_;
  if (
      ($self->Type eq "company") or
      ($self->Type eq "country")
     ) {
    return 1;
  } else {
    return 0;
  }
}

1;
