package Com::elle::bLeaf::EvidenceGenerator::Evidence;

use Com::elle::bLeaf::EvidenceGenerator::Entity;

use Manager::Dialog qw(SubsetSelect);
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyNews Categories Results SelectedResults
   EvidenceGenerator NewSelf Reviews Polarities /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyNews($args{News});
  $self->EvidenceGenerator($args{EvidenceGenerator});
  # check the DB to see if there is an evidence point saved
  my $primarykey = $self->MyNews->PrimaryKey;
  my $mysql = $self->EvidenceGenerator->MyResources->MyMySQL;
  my $res = $mysql->Do
    (
     Statement => "select * from evidence where id=".$mysql->Quote($primarykey),
     KeyField => 'id',
    );
  if (scalar keys %$res) {
    eval $res->{$primarykey}->{contents};
    my $newself = $VAR1;
    if (ref $newself eq "Com::elle::bLeaf::EvidenceGenerator::Evidence") {
      $newself->EvidenceGenerator($self->EvidenceGenerator);
      if (! defined $newself->Polarities) {
	$newself->Polarities({});
      }
      $self->NewSelf($newself);
    }
  } else {
    $self->Categories($args{Categories});
    $self->LoadResults();
    $self->Reviews([]);
  }
}

sub Print {
  my ($self,%args) = @_;
  print $self->SPrint();
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper
    ([
      $self->MyNews,
      $self->Categories,
      $self->Results,
      $self->SelectedResults,
     ]);
}

sub SaveToDB {
  my ($self,%args) = @_;
  # save all the results to the DB
  # $self->Results();
  # save the list of selected results to the DB
  my $mysql = $self->EvidenceGenerator->MyResources->MyMySQL;
  my $evidencegenerator = $self->EvidenceGenerator();
  $self->EvidenceGenerator(undef);
  my $primarykey = $self->MyNews->PrimaryKey;
  my $quotedpk = $mysql->Quote($primarykey);
  my $res1 = $mysql->Do
    (
     Statement => "delete from evidence where id=$quotedpk;",
    );
  my $res2 = $mysql->Do
    (
     Statement => "insert into evidence values ($quotedpk,".$mysql->Quote(Dumper($self)).")",
    );
  $self->EvidenceGenerator($evidencegenerator);
}

sub LoadResults {
  my ($self,%args) = @_;
  my $latinified = $self->latin1ify($self->MyNews->Contents);
  my $results = $self->EvidenceGenerator->MyResources->TextAnalysis->AnalyzeText
    (
     Text => $latinified,
     OnlyRetrieve => 1,
    );
  my $res = $self->ProcessResults
    (Results => $results);
  if ($res->{Success}) {
    $self->Results($res->{Results});
  } else {
    $self->Results([]);
  }
  $self->SelectedResults(undef);
  $self->Polarities({});
}

sub latin1ify {
  my ($self,$string) = (shift,shift || "");
  Encode::encode
      (
       "iso-8859-1",
       Encode::decode_utf8($string),
      );
}

sub ProcessResults {
  my ($self,%args) = @_;
  my $res = $args{Results};
  print Dumper($res);
  my @results;
  foreach my $ref (@{$res->{SemanticAnnotation}}) {
    if (exists $ref->{CalaisSimpleOutputFormat}->{Company}) {
      my $reftype = ref $ref->{CalaisSimpleOutputFormat}->{Company};
      if ($reftype eq "ARRAY") {
	foreach my $entry (@{$ref->{CalaisSimpleOutputFormat}->{Company}}) {
	  push @results,
	    Com::elle::bLeaf::EvidenceGenerator::Entity->new
		(
		 Type => "company",
		 OpenCalais => $entry,
		);
	}
      } elsif ($reftype eq "HASH") {
	push @results,
	  Com::elle::bLeaf::EvidenceGenerator::Entity->new
	      (
	       Type => "company",
	       OpenCalais => $ref->{CalaisSimpleOutputFormat}->{Company},
	      );
      }
    }
    if (exists $ref->{CalaisSimpleOutputFormat}->{Organization}) {
      my $reftype = ref $ref->{CalaisSimpleOutputFormat}->{Organization};
      if ($reftype eq "ARRAY") {
    	foreach my $entry (@{$ref->{CalaisSimpleOutputFormat}->{Organization}}) {
    	  push @results,
	    Com::elle::bLeaf::EvidenceGenerator::Entity->new
		(
		 Type => "organization",
		 OpenCalais => $entry,
		);
    	}
      } elsif ($reftype eq "HASH") {
    	push @results,
	  Com::elle::bLeaf::EvidenceGenerator::Entity->new
	      (
	       Type => "organization",
	       OpenCalais => $ref->{CalaisSimpleOutputFormat}->{Organization},
	      );
      }
    }
    if (exists $ref->{CalaisSimpleOutputFormat}->{Country}) {
      my $reftype = ref $ref->{CalaisSimpleOutputFormat}->{Country};
      if ($reftype eq "ARRAY") {
    	foreach my $entry (@{$ref->{CalaisSimpleOutputFormat}->{Country}}) {
    	  push @results,
	    Com::elle::bLeaf::EvidenceGenerator::Entity->new
		(
		 Type => "country",
		 OpenCalais => $entry,
		);
    	}
      } elsif ($reftype eq "HASH") {
    	push @results,
	  Com::elle::bLeaf::EvidenceGenerator::Entity->new
	      (
	       Type => "country",
	       OpenCalais => $ref->{CalaisSimpleOutputFormat}->{Country},
	      );
      }
    }
  }

  # process DBpedia results
  foreach my $item (@{$res->{DBpediaSpotlight}}) {
    if ($item->{Success}) {
      my $res2 = $self->ProcessDBpediaSpotlight(Text => $item->{Result});
      if ($res2->{Success}) {
  	push @results, @{$res2->{Results}};
      }
    }
  }

  # process named entity recognition results
  foreach my $item1 (@{$res->{NamedEntityRecognition}}) {
    foreach my $item2 (@$item1) {
      my $contents = join(" ",@{$item2->[0]});
      my $type = lc($item2->[1]);
      push @results,
	Com::elle::bLeaf::EvidenceGenerator::Entity->new
	    (
	     Type => $type,
	     System => "Named Entity Recognition",
	     Contents => $contents,
	    );
    }
  }

  return {
	  Success => 1,
	  Results => \@results,
	 };
}

sub ProcessDBpediaSpotlight {
  my ($self,%args) = @_;
  my $text = $args{Text};
  my @res = $text =~ /<a href="([^"]+)" title="([^"]+)" target="([^"]+)">(.+?)<\/a>/sg;
  my @results;
  while (@res) {
    my ($href,$title,$target,$contents) = (shift @res, shift @res, shift @res, shift @res);
    push @results,
      Com::elle::bLeaf::EvidenceGenerator::Entity->new
	  (
	   Type => "unknown",
	   System => "DBpedia Spotlight",
	   NormalizedURL => $href,
	   Contents => $contents,
	  );
  }
  return {
	  Success => 1,
	  Results => \@results,
	 };
}

sub AddEntity {
  my ($self,%args) = @_;
  if (defined $args{Contents} and $args{Contents} =~ /\S/) {
    my $entity = Com::elle::bLeaf::EvidenceGenerator::Entity->new
      (
       Type => $args{Type},
       System => "Manually Added",
       Contents => $args{Contents},
      );
    push @{$self->Results}, $entity;
    my @selectedresults;
    foreach my $child ($self->EvidenceGenerator->SelectionFrame->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
      if (defined $child->{'Value'} and $child->{'Value'}) {
	push @selectedresults, $child->cget('-text');
      }
    }
    push @selectedresults, $entity->Contents;
    $self->SelectedResults(\@selectedresults);
    $self->EvidenceGenerator->UpdateResults();
  } else {
    Message(Message => "Nothing appears to be selected");
  }
}

sub DeleteEntity {
  my ($self,%args) = @_;
  my @res = SubsetSelect
    (
     Message => "Select which entity to remove",
     Set => [map {$_->Contents} @{$self->Results}],
     Selection => {},
    );
  print Dumper($res);
  my @new;
  foreach my $result (@{$self->Results}) {
    my $skip = 0;
    foreach my $contents (@res) {
      if ($result->Contents eq $contents) {
	$skip = 1;
      }
    }
    if (! $skip) {
      push @new, $result;
    }
  }
  $self->Results(\@new);
  $self->UpdateSelectedResults();
}

sub UpdateSelectedResults {
  my ($self,%args) = @_;
  my $all = {};
  foreach my $result (@{$self->Results}) {
    $all->{$result->Contents} = 1;
  }
  my $selected = {};
  foreach my $childa ($self->EvidenceGenerator->SelectionFrame->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
    my $child;
    foreach my $childb ($childa->children()) {
      my $ref = ref $childb;
      if ($ref eq "Tk::Checkbutton") {
	$child = $childb;
      }
    }

    my $contents = $child->cget('-text');
    if (exists $all->{$contents}) {
      if (defined $child->{'Value'} and $child->{'Value'}) {
  	$selected->{$contents} = 1;
      }
    }
  }
  my @selectedresults = sort keys %$selected;
  $self->SelectedResults(\@selectedresults);

  # now we want to synchronize items with polarities
  foreach my $key (keys %$all) {
    # change the polarity to the variable, if the variable has a value
    if (exists $self->EvidenceGenerator->Polarities->{$key} and
	${$self->EvidenceGenerator->Polarities->{$key}} =~ /^(\-1|0||\+1)$/) {
      $self->Polarities->{$key} = ${$self->EvidenceGenerator->Polarities->{$key}};
    }
  }
}

1;
