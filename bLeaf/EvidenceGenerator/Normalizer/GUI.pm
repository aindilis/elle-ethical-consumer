package Com::elle::bLeaf::EvidenceGenerator::Normalizer::GUI;

use Manager::Dialog qw(ChooseByProcessor QueryUser ApproveCommands);

use BOSS::Config;
use PerlLib::Cacher;

use PerlLib::SwissArmyKnife;
use Text::CSV;
use Text::LevenshteinXS qw(distance);
use Tk;
use URI::Encode qw(uri_encode uri_decode);
use XML::Simple qw(XMLout);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Conf Config Content GEPIRCompanyName2GCPs TopFrame SearchText
	Top1 MyCountry CompanyAddresses OriginalName /

  ];

sub init {
  my ($self,%args) = @_;
  $self->GEPIRCompanyName2GCPs({});
  $self->CompanyAddresses({});
  $UNIVERSAL::mygui = $self;
}

sub ProcessCompanyName {
  my ($self,%args) = @_;
  my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
    (
     -title => "Normalize Entity",
    );
  $top1->geometry("800x600");
  $self->Top1($top1);
  my $searchtext;
  if ($args{Name}) {
    # check if there is already a result
    $self->OriginalName($args{Name});
    my $mysql = $UNIVERSAL::evidencegenerator->MyResources->MyMySQL;
    my $originalnamequoted = $mysql->Quote($self->OriginalName);
    my $res = $mysql->Do
      (
       Statement => "select * from company_lookup where name=$originalnamequoted",
       KeyField => "name",
      );
    if (scalar keys %$res) {
      my $resultsdumper = $res->{$self->OriginalName}->{results};
      eval $resultsdumper;
      my @results = @$VAR1;
      $self->Top1->destroy();
      Message
	(
	 Message => "Using cached results for ".$self->OriginalName,
	 GetSignalFromUserToProceed => (! exists $UNIVERSAL::evidencegenerator->Conf->{'--regenerate'}),
	);
      return
	{
	 Success => 1,
	 Results => \@results,
	};
    } else {
      if (exists $UNIVERSAL::evidencegenerator->Conf->{'--regenerate'}) {
	return {
		Success => 0,
		Error => "skipped",
	       };
      }
    }
    $searchtext = $args{Name};
    $self->SearchText(\$searchtext);
    my $searchframe = $self->Top1->Frame()->pack(-side => 'top');
    my $search = $searchframe->Entry
      (
       -relief       => 'sunken',
       -borderwidth  => 2,
       -textvariable => \$searchtext,
       -width        => 40,
      )->pack(-side => 'left');




    my $mycountry = "UNITED STATES (3.0)";
    $self->MyCountry(\$mycountry);
    my $name = $searchframe->BrowseEntry
      (
       -variable => $self->MyCountry,
       -width => 50,
      )->pack(-side => 'top');

    foreach my $key 
      (sort keys %{$UNIVERSAL::evidencegenerator->MyResources->MyGEPIR->iDdlCountryList}) {
      $name->insert('end',$key);
    }

    $searchframe->Button
      (
       -text => "Google",
       -command => sub {
	 my $search = "http://www.google.com/#hl=en&q=".uri_encode(${$self->SearchText});
	 system "firefox -remote 'openUrl($search)'"
       },
      )->pack(-side => "right");
    $searchframe->Button
      (
       -text => "GEPIR",
       -command => sub {
	 # rerun the search

	 # have to close out of the current one, launch the search
	 # with the new value
	 $self->Search
	   (
	    Name => ${$self->SearchText},
	    GEPIR => 1,
	   );
       },
      )->pack(-side => "right");
    $searchframe->Button
      (
       -text => "Search",
       -command => sub {
	 # rerun the search

	 # have to close out of the current one, launch the search
	 # with the new value
	 $self->Search
	   (
	    Name => ${$self->SearchText},
	    GEPIR => 0,
	   );
       },
      )->pack(-side => "right");
  }
  if ($args{Message}) {
    my $text = $self->Top1->Text
      (
       -width => 80,
       -height => 10,
      );
    $text->Contents($args{Message});
    $text->configure(-state => "disabled");
    $text->pack();
  }
  my $ourresults;
  my @availableargs =
    (
     "Desc",
     "MenuOffset",
     "NoAllowWrap",
     "Processor",
     "Prompt",
     "Selection",
     "Set",
     "Type",
    );

  my $res = $self->Search
    (
     Name => $args{Name},
    );

  $self->Top1->destroy();

  # choose which one to use
  # save the aligned item in the db
  print Dumper($res);
  if ($res->{Success}) {
    # we have a manufacturer id now
    # process this into the XML
    return {
	    Success => 1,
	    Results => $res->{Results},
	   };
  } else {
    # if none of the above
    # search GEPIR
  }
}

sub Search {
  my ($self,%args) = @_;
  my @set1 = @{$self->GetTop
		 (
		  Method => 'freq',
		  Name => $args{Name},
		  Num => 25,
		 )};
  my @set2 = @{$self->GetTop
		 (
		  Method => 'distance',
		  Name => $args{Name},
		  Num => 25,
		 )};
  my @set3;
  if ($args{GEPIR}) {
    @set3 = @{$self->GetTop
		(
		 Method => 'GEPIR',
		 Name => $args{Name},
		 Num => 25,
		)};
  }
  my $res = $self->OurSubsetSelect
    (
     Set1 => \@set1,
     Set2 => \@set2,
     Set3 => \@set3,
     Selection => {},
     Name => $args{Name},
    );
  return $res;
}

sub GetTop {
  my ($self,%args) = @_;
  my $scores = {};
  my $name = $args{Name};
  my $lcname = lc($name);
  my $method = $args{Method};
  if ($method eq "distance") {
    foreach my $row (@{$UNIVERSAL::evidencegenerator->MyResources->Rows}) {
      my $score = distance($lcname,$row->[1]);
      $scores->{$row->[1]} = $score;
    }
    my @list = sort {$scores->{$a} <=> $scores->{$b}} keys %$scores;
    my @top = splice(@list,0,$args{Num});
    return \@top;
  } elsif ($method eq "freq") {
    my $line = $lcname;
    my %score;
    chomp $line;
    my @keywords = map {lc($_)} split /\W+/, $line;
    my $freq = $UNIVERSAL::evidencegenerator->MyResources->Frequency;
    my $num = $UNIVERSAL::evidencegenerator->MyResources->NumberOfTerms;
    foreach my $keyword (@keywords) {
      if (length $keyword > 3) {
	foreach my $result (map {$_->[1]} @{$UNIVERSAL::evidencegenerator->MyResources->Rows}) {
	  if ($result =~ /\b$keyword\b/i) {
	    if (! exists $freq->{$keyword}) {
	      print Dumper($keyword);
	    } else {
	      $score{$result} += ($num / $freq->{$keyword});
	    }
	  }
	}
      }
    }
    my @top = sort {$score{$a} <=> $score{$b}} keys %score;
    my $set;
    if (@top > $args{Num}) {
      $set = [reverse splice (@top,-$args{Num})]
    } else {
      $set = [reverse @top];
    }
    return $set;
  } elsif ($method eq "GEPIR") {
    # skip for now
    my $res = $UNIVERSAL::evidencegenerator->MyResources->MyGEPIR->CacheResults
      (
       CompanyName => $name,
       Country => $UNIVERSAL::evidencegenerator->MyResources->MyGEPIR->iDdlCountryList->{${$self->MyCountry}},
      );
    my $set = [];
    if ($res->{Success}) {
      foreach my $result (@{$res->{Result}}) {
	if ($result->{GCP} =~ /\S/) {
	  my @items = split /\n/, $result->{Company};
	  my $companyname = shift @items;
	  push @$set, $companyname;
	  $self->GEPIRCompanyName2GCPs->{$companyname} = $result->{GCP};
	  my $address = join("\n",@items);
	  $self->CompanyAddresses->{$companyname} = $self->CleanAddress(Address => $address);
	}
      }
    }
    return $set;
  }
  return [];
}

sub CleanAddress {
  my ($self,%args) = (@_);
  my @newlines;
  foreach my $line (split /\n/, $args{Address}) {
    if ($line =~ /\S/) {
      $line =~ s/^\s*//;
      $line =~ s/\s*$//;
      $line =~ s/[^[:ascii:]]/ /g;
      $line =~ s/\s+/ /g;
      push @newlines, $line;
    }
  }
  return join("\n",@newlines);
}

sub OurSubsetSelect {
  my ($self,%args) = (@_);
  $self->DisplaySearchResults(%args);
  $self->MyMainLoop();
  DoOneEvent(0);
  return $ourresults;
}

sub MyMainLoop {
  # return if exists $UNIVERSAL::evidencegenerator->Conf->{'--generate'};
  unless ($inMainLoop)
    {
      local $inMainLoop = 1;
      $cancel = 0;
      $continueloop = 1;
      while ($continueloop) {
	DoOneEvent(0);
      }
    }
}

sub DisplaySearchResults {
  my ($self,%args) = (@_);
  if (defined $self->TopFrame) {
    $self->TopFrame->destroy();
  }
  my $topframe = $self->Top1->Frame();
  $self->TopFrame($topframe);
  my $myselectionframe = $topframe->Frame()->pack(-expand => 1, -fill => 'both');

  # SELECTION 1
  my $selectionframe1 = $myselectionframe->Scrolled
    ('Frame',
     -scrollbars => 'e',
    )->pack
      (
       -expand => 1,
       -fill => "both",
      );
  foreach my $item (@{$args{Set1}}) {
    my $button = $selectionframe1->Checkbutton
      (
       -text => $item,
      );
    $button->configure(-command => sub {
			 # if (exists $button->{Value}) {
			 #   if ($button->{Value}) {
			 #     $button->{Value} = 0;
			 #   } else {
			 #     $button->{Value} = 1;
			 #   }
			 # } else {
			 #   $button->{Value} = 1;
			 # }
		       });
    $button->pack(-expand => 1, -fill => "both");
    if (exists $args{Selection}->{$item}) {
      $button->{Value} = 1;
    }
  }
  $selectionframe1->pack(-side => "left", -expand => 1, -fill => "both");




  # SELECTION 2
  my $selectionframe2 = $myselectionframe->Scrolled
    ('Frame',
     -scrollbars => 'e',
    )->pack
      (
       -expand => 1,
       -fill => "both",
      );
  foreach my $item (@{$args{Set2}}) {
    my $button = $selectionframe2->Checkbutton
      (
       -text => $item,
      );
    $button->configure(-command => sub {
			 # if (exists $button->{Value}) {
			 #   if ($button->{Value}) {
			 #     $button->{Value} = 0;
			 #   } else {
			 #     $button->{Value} = 1;
			 #   }
			 # } else {
			 #   $button->{Value} = 1;
			 # }
		       });
    $button->pack(-expand => 1, -fill => "both");
    if (exists $args{Selection}->{$item}) {
      $button->{Value} = 1;
    }
  }
  $selectionframe2->pack(-side =>"left", -expand => 1, -fill => "both");






  # SELECTION 3
  my $selectionframe3;
  if (exists $args{Set3}) {
    $selectionframe3 = $myselectionframe->Scrolled
      ('Frame',
       -scrollbars => 'e',
      )->pack
	(
	 -expand => 1,
	 -fill => "both",
	);
    foreach my $item (@{$args{Set3}}) {
      my $frame = $selectionframe3->Frame()->pack();;
      my $button = $frame->Checkbutton
	(
	 -text => $item,
	);
      $button->configure(-command => sub {
			 });
      $button->pack(-side => 'left', -expand => 1, -fill => "both");
      if (exists $args{Selection}->{$item}) {
	$button->{Value} = 1;
      }
      my $button2 = $frame->Button
	(
	 -text => "Addr",
	 -command => sub {
	   Message(
		   Message => $self->CompanyAddresses->{$item},
		   GetSignalFromUserToProceed => 1,
		  );
	 },
	)->pack(-side => 'right');
    }
    $selectionframe3->pack(-side => "left", -expand => 1, -fill => "both");
  }





  my $buttonframe = $topframe->Frame;
  $buttonframe->Button
    (
     -text => "Match",
     -command => sub {
       my @results;
       foreach my $childa ($selectionframe1->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
	 my $child = $childa;	# a->{checkbutton};
	 if (defined $child->{'Value'} and $child->{'Value'}) {
	   my $norm = $child->cget('-text');
	   push @results, {
			   Norm => $norm,
			   Tagged => $args{Name},
			   Address => "",
			   GCP => $UNIVERSAL::evidencegenerator->MyResources->Manufacturers2GCP->{$norm},
			   Original => $self->OriginalName,
			  };
	 }
       }
       foreach my $childa ($selectionframe2->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
	 my $child = $childa;	# a->{checkbutton};
	 if (defined $child->{'Value'} and $child->{'Value'}) {
	   my $norm = $child->cget('-text');
	   push @results, {
			   Norm => $norm,
			   Tagged => $args{Name},
			   Address => "",
			   GCP => $UNIVERSAL::evidencegenerator->MyResources->Manufacturers2GCP->{$norm},
			   Original => $self->OriginalName,
			  };
	 }
       }
       if (defined $selectionframe3) {
	 foreach my $childa ($selectionframe3->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
	   my $child;
	   foreach my $childb ($childa->children()) {
	     my $ref = ref $childb;
	     if ($ref eq "Tk::Checkbutton") {
	       $child = $childb;
	     }
	   }
	   if (defined $child->{'Value'} and $child->{'Value'}) {
	     my $norm = $child->cget('-text');
	     # print Dumper({ThisIsIt => [
	     # 				$norm,
	     # 				$self->GEPIRCompanyName2GCPs,
	     # 			       ]});
	     push @results, {
			     Norm => $norm,
			     Tagged => $args{Name},
			     Address => $self->CompanyAddresses->{$norm},
			     GCP => [$self->GEPIRCompanyName2GCPs->{$norm}],
			     Original => $self->OriginalName,
			    };
	   }
	 }
       }
       # insert the results into the DB with the original name

       $self->CacheResults(Results => \@results);

       $continueloop = 0;
       $ourresults = {
		      Success => 1,
		      Results => \@results,
		     };
     },
    )->pack(-side => "right");
  $buttonframe->Button
    (
     -text => "Skip",
     -command => sub {
       $continueloop = 0;
       $ourresults = {
		      Success => 0,
		      Error => "skipped",
		     };
     },
    )->pack(-side => "right");
  $buttonframe->Button
    (
     -text => "A Company but None of the Above",
     -command => sub {
       my $self = $UNIVERSAL::mygui;
       my @results;
       push @results, {
		       Norm => "",
		       Tagged => $args{Name},
		       Address => "",
		       GCP => [],
		       Original => $self->OriginalName,
		      };
       $self->CacheResults(Results => \@results);
       $continueloop = 0;
       $ourresults = {
		      Success => 1,
		      Results => \@results,
		     };
     },
    )->pack(-side => "right");
  $buttonframe->Button
    (
     -text => "Not a company",
     -command => sub {
       $continueloop = 0;
       $ourresults = {
		      Success => 0,
		      Error => "not a company",
		     };
     },
    )->pack(-side => "right");
  $buttonframe->Button
    (
     -text => "A group of companies",
     -command => sub {
       $continueloop = 0;
       $ourresults = {
		      Success => 0,
		      Error => "a group of companies",
		     };
     },
    )->pack(-side => "right");
  $buttonframe->pack(-side => "bottom");
  $topframe->pack(-fill => "both", -expand => 1);
}

sub CacheResults {
  my ($self,%args) = @_;
  my $mysql = $UNIVERSAL::evidencegenerator->MyResources->MyMySQL;
  my $originalnamequoted = $mysql->Quote($self->OriginalName);
  my $res1 = $mysql->Do
    (
     Statement => "delete from company_lookup where name=$originalnamequoted",
    );
  my $res2 = $mysql->Do
    (
     Statement => "insert into company_lookup values ($originalnamequoted,".
     $mysql->Quote(Dumper($args{Results})).")"
    );
}

1;
