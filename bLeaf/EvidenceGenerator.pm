package Com::elle::bLeaf::EvidenceGenerator;

use Com::elle::bLeaf::EvidenceGenerator::Evidence;
use Com::elle::bLeaf::EvidenceGenerator::Resources;
use Com::elle::bLeaf::EvidenceGenerator::Review;
use Com::elle::bLeaf::EvidenceGenerator::SourceManager;

use BOSS::Config;
use DateTime;
use Encode::Encoder;
use KMax::Util::KeyBindings;
use KMax::Util::Minibuffer;
use Manager::Dialog qw(Approve ApproveCommands Message);
use PerlLib::SwissArmyKnife;
use Text::CSV;
use Text::LevenshteinXS qw(distance);
use XML::Simple qw(XMLin);

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf MyResources CutOff CutoffLabel SearchText
	ThresholdFrame Top1 TopFrame NewsFrame Res1 Res2 DebugData
	Statuses MyApplications MyConfHistory MyHistory MyResponses
	MyTable MyConfiguration EntryIDs LastID MySourceManager
	MyDateTime Duration2 MySource MyTitle NewsFrameText
	StandardWidth ButtonFrame CategoryFrame NewsResults Seen
	EvidenceFrame SubsetSelectFrame SubsetSelectFrame2 MyAddEntity
	SelectionFrame Counter PreviousSeenCounters Results
	MyEntityType DescriptionText CurrentNews MyCategory
	SelectionFrame2 Width Height MyEvidence Reviewer
	ReviewedCheckbutton MiscInfoText Polarities Unreviewed
	MyNormalizationResults MyXMLGenerator MyKeyBindings
	MyMinibuffer /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = q(
	-U [<sources>...]		Update sources
	-l [<sources>...]		Load sources
	-s [<sources>...]		Search sources
	-c [<sources>...]		Choose sources

	--max-causes <num>		Maximum number of causes to process

	--dbpedia			Include DBpedia analysis

	--regenerate			Regenerate from data points

	--unreviewed			Skip to next unreviewed item

	--debug				Debug

	-r <reviewer>			Name of the reviewer

	-u [<host> <port>]		Run as a UniLang agent
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf
    ($self->Config->CLIConfig);
  $conf = $self->Conf;

  die "Must specify a reviewer with the -r command line argument\n" unless exists $self->Conf->{'-r'};
  $self->Reviewer($conf->{'-r'});
  my $reviewers =
    {
     "beethoven" => 1,
     "insight" => 1,
     "sky" => 1,
    };
  if (! exists $reviewers->{$self->Reviewer}) {
    print Dumper($reviewers);
    die "Must be a specified reviewer.\n";
  }

  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::agent->Register
    (Host => defined $conf->{-u}->{'<host>'} ?
     $conf->{-u}->{'<host>'} : "localhost",
     Port => defined $conf->{-u}->{'<port>'} ?
     $conf->{-u}->{'<port>'} : "9000");

  $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer";

  $self->Unreviewed(exists $conf->{'--unreviewed'});
  $self->MySourceManager
    (Com::elle::bLeaf::EvidenceGenerator::SourceManager->new
     ());
  $self->MyResources
    (Com::elle::bLeaf::EvidenceGenerator::Resources->new
     ());

  $self->StandardWidth(100);
  $self->MyDateTime(DateTime->now());
  $self->Duration2(DateTime::Duration->new(seconds => 5));
  $self->Seen({});
  $self->Counter(0);
  $self->PreviousSeenCounters([]);
  $self->Width(1300);
  $self->Height(700);
}

sub Execute {
  my ($self,%args) = @_;
  $self->Top1
    (MainWindow->new
     (
      -title => "elle bLeaf Evidence Generator",
      -height => $self->Height,
      -width => $self->Width,
     ));
  $self->Top1->geometry($self->Width."x".$self->Height);

  $UNIVERSAL::managerdialogtkwindow = $self->Top1;

  $self->MyResources->Execute();


  # Keybindings
  $self->MyMinibuffer
    (KMax::Util::Minibuffer->new
     (Frame => $self->Top1));
  $self->MyKeyBindings
    (KMax::Util::KeyBindings->new
     (
      KeyBindingsFile => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/keybindings/keybindings-spse-official.txt",
      MyGUI => $self,
     ));
  $self->MyKeyBindings->GenerateGUI
    (
     MyMainWindow => $self->Top1,
     Minibuffer => $self->MyMinibuffer,
    );




  $frame = $self->Top1->Frame(-relief => 'flat');
  $frame->pack(-side => 'top');
  $menu = $self->Top1->Frame(-relief => 'raised', -borderwidth => '1');
  $menu->pack(-before => $frame, -side => 'top', -fill => 'x');
  $menu_file_1 = $menu->Menubutton
    (
     -text => 'File',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_file_1->command
    (
     -label => 'Exit',
     -command => sub {
       $self->Exit();
     },
     -underline => 0,
    );
  $menu_file_1->pack
    (
     -side => 'left',
    );

  $menu_file_2 = $menu->Menubutton
    (
     -text => 'View',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_file_2->pack
    (
     -side => 'left',
    );

  # $menu2 = $self->Top1->Frame(-relief => 'raised', -borderwidth => '1');
  # $menu2->pack(-side => 'top', -fill => 'x');
  my $menu2 = $self->Top1->Menu(-tearoff => 0);
  my $addmenu = $menu2->cascade
    (
     -label => 'Add',
     -tearoff => 0,
    );
  my $companymenu = $addmenu->command
    (
     -label => 'Company',
     -command => sub {
       $self->MyEvidence->AddEntity
	 (
	  Type => "company",
	  Contents => $self->NewsFrameText->getSelected( ),
	 );
     },
    );
  my $organizationmenu = $addmenu->command
    (
     -label => 'Organization',
     -command => sub {
       $self->MyEvidence->AddEntity
	 (
	  Type => "organization",
	  Contents => $self->NewsFrameText->getSelected( ),
	 );
     },
    );
  my $countrymenu = $addmenu->command
    (
     -label => 'Country',
     -command => sub {
       $self->MyEvidence->AddEntity
	 (
	  Type => "country",
	  Contents => $self->NewsFrameText->getSelected( ),
	 );
     },
    );
  my $unknownmenu = $addmenu->command
    (
     -label => 'Unknown',
     -command => sub {
       $self->MyEvidence->AddEntity
	 (
	  Type => "unknown",
	  Contents => $self->NewsFrameText->getSelected( ),
	 );
     },
    );

  $self->NewsFrame
    ($self->Top1->Frame());
  $self->CategoryFrame
    ($self->Top1->Frame());

  $self->ReviewedCheckbutton
    ($self->CategoryFrame->Checkbutton
     (
      -text => "Reviewed",
      -state => 'disabled',
     )->pack());

  my $mycategory = "";
  $self->MyCategory(\$mycategory);
  my $tmpframe = $self->CategoryFrame->Frame();
  my $name = $tmpframe->BrowseEntry
    (
     -variable => $self->MyCategory,
     -width => 50,
     -command => sub {
       $self->AddCategory(Category => ${$self->MyCategory});
     },
    )->pack(-side => 'top');

  foreach my $supercat (sort keys %{$UNIVERSAL::evidencegenerator->MyResources->MyCategories}) {
    $name->insert('end',$supercat);
    foreach my $subcat (sort keys %{$UNIVERSAL::evidencegenerator->MyResources->MyCategories->{$supercat}}) {
      $name->insert('end',$supercat." | ".$subcat);
    }
  }
  $tmpframe->Button
    (
     -text => "Remove Selected Categories",
     -command => sub {
       $self->DeleteSelectedCategories();
     },
    )->pack(-side => 'bottom');
  $tmpframe->pack(-side => 'left');
  # add the code here to redraw the categories

  $self->SubsetSelectFrame2($self->CategoryFrame->Frame());
  $self->SubsetSelectFrame2->pack(-side => 'right');
  $self->CategoryFrame->pack(-side => 'top');

  $self->ButtonFrame
    ($self->NewsFrame->Frame());
  $self->ButtonFrame->Button
    (
     -text => "<<<",
     -command => sub {
       $self->PreviousEvidencePoint();
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => "Normalize Companies",
     -command => sub {
       $self->NormalizeCompanies();
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => "Write to DB",
     -command => sub {
       $self->GUIWriteToDB();
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => "Ignore",
     -command => sub {
       $self->AddReview();
       # save to the DB?
       $self->NextEvidencePoint(Unreviewed => $self->Unreviewed);
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => ">>>",
     -command => sub {
       $self->NextEvidencePoint();
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => "Find Next Unreviewed",
     -command => sub {
       $self->FindNextUnreviewed();
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => "Find Next Cached",
     -command => sub {
       $self->NextEvidencePoint
	 (Cached => 1);
     },
    )->pack(-side => "left");
  $self->ButtonFrame->Button
    (
     -text => "Show Progress",
     -command => sub {
       $self->ShowProgress();
     },
    )->pack(-side => "left");
  $self->ButtonFrame->pack(-side => 'bottom');
  my $textframe = $self->NewsFrame->Frame->pack(-side => 'bottom');
  $self->DescriptionText
    ($textframe->Scrolled
     (
      'Text',
      # -background => 'white',
      -scrollbars => 'e',
      -width => $self->StandardWidth / 2,
      -height => 15,
      -wrap => 'word',
     )->pack
     (
      -side => "left",
     ));
  $self->MiscInfoText
    ($textframe->Scrolled
     (
      'Text',
      # -background => 'white',
      -scrollbars => 'e',
      -width => $self->StandardWidth / 2,
      -height => 15,
      -wrap => 'word',
     )->pack
     (
      -side => "right",
     ));
  $self->NewsFrameText
    ($self->NewsFrame->Scrolled
     (
      'Text',
      # -background => 'white',
      -scrollbars => 'e',
      -width => $self->StandardWidth,
      -height => 15,
      -wrap => 'word',
     )->pack
     (
      -side => "bottom",
     ));
  $self->NewsFrameText->bind
    (
     '<Button-2>',
     sub {
       $menu2->Popup
	 (
	  -popover => "cursor",
	  -popanchor => 'nw',
	 );
     },
    );
  my $mytitle = "";
  $self->MyTitle(\$mytitle);
  $self->NewsFrame->Entry
    (
     # -state => "disabled",
     -width => $self->StandardWidth,
     -textvariable => $self->MyTitle,
    )->pack(-side => "bottom");
  $self->MySource
    ($self->NewsFrame->Scrolled
     (
      'Text',
      # -background => 'white',
      -scrollbars => 'e',
      -width => $self->StandardWidth,
      -height => 8,
      -wrap => 'word',
     )->pack
     (
      -side => "bottom",
     ));
  $self->NewsFrame->pack(-side => "left");

  $self->EvidenceFrame($self->Top1->Frame());
  $self->EvidenceFrame->pack(-side => 'right',-fill => 'both', -expand => 1);
  $self->SubsetSelectFrame($self->EvidenceFrame->Frame());
  $self->SubsetSelectFrame->pack();
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-U'}) {
    $self->MySourceManager->UpdateSources
      (Sources => $conf->{'-U'});
  }
  if (exists $conf->{'-l'}) {
    $self->MySourceManager->LoadSources
      (Sources => $conf->{'-l'});
  }
  if (exists $conf->{'-s'}) {
    # $self->MySourceManager->Search
    #  (Sources => $conf->{-s});
  }
  if (exists $conf->{'-c'}) {
    $self->MySourceManager->Choose
      (Sources => $conf->{-c});
  }
  if ($conf->{'-s'}) {
    $self->GenerateEvidencePoints
      (
       Sources => $conf->{'-s'},
      );
  } else {
    $self->GenerateEvidencePoints
      (
      );
  }
  $self->MyMainLoop();
}

sub Exit {
  my ($self,%args) = @_;
  if (Approve("Exit Program?")) {
    exit(0);
  }
}

sub Checks {
  my ($self,%args) = @_;
  # CheckEmail
}

sub MyMainLoop {
  my ($self,%args) = @_;
  # return if exists $UNIVERSAL::evidencegenerator->Conf->{'--generate'};
  $self->Top1->repeat
    (
     50,
     sub {
       $self->AgentListen(),
     },
    );
  $self->Top1->repeat
    (
     60 * 60 * 1000,
     sub {
       $self->Checks(),
     },
    );
  MainLoop();
}

sub AgentListen {
  my ($self,%args) = @_;
  # UniLang::Agent::Agent
  # print ".\n";
  $UNIVERSAL::agent->Listen
    (
     TimeOut => 0.05,
    );
}

sub GenerateEvidencePoints {
  my ($self,%args) = @_;
  # with all the sources loaded, iterate over them and process with
  # this code

  # this should be the code that classifies the entry as a boycott
  # request or not
  my $res = [sort {$b->Score <=> $a->Score} @{$self->MySourceManager->SearchSources
    (
     Criteria => {Any => "."},
     Sources => $args{Sources},
    )}];
  $self->NewsResults($res);
  $self->NextEvidencePoint
    (
     Unreviewed => $self->Unreviewed,
    );
}

sub NextEvidencePoint {
  my ($self,%args) = @_;
  if (defined $self->MyEvidence) {
    $self->SaveToDB();
  }
  my $res;
  my $continue = 1;
  while ($continue) {
    print ".\n";
    $res = $self->ProcessNextNewsMeat(%args);
    if ($res->{Success}) {
      $continue = 0;
    } else {
      if ($res->{Error} eq "no more results") {
	$continue = 0;
      } elsif ($res->{Error} eq "already seen") {
	# skip
      } elsif ($res->{Error} eq "not classified as a boycott request") {
	# skip
      } elsif ($res->{Error} eq "already reviewed and in unreviewed mode") {
	# skip
      } elsif ($res->{Error} eq "no cached results") {
	# skip
      }
    }
    $self->Counter($self->Counter + 1);
  }
  if ($UNIVERSAL::evidencegenerator->Conf->{'--regenerate'}) {
    # what do we do here, we invoke the step for advancing
    $self->NormalizeCompanies();
    $self->WriteToDB();
    $self->NextEvidencePoint();
  }
}

sub PreviousEvidencePoint {
  my ($self,%args) = @_;
  $self->SaveToDB();
  my $tmp = pop @{$self->PreviousSeenCounters};
  my $lastcounter = pop @{$self->PreviousSeenCounters};
  $self->CleanCounterItem(Counter => $self->Counter);
  $self->Counter($lastcounter || 0);
  $self->CleanCounterItem(Counter => $self->Counter);
  $self->NextEvidencePoint();
}

sub CleanCounterItem {
  my ($self,%args) = @_;
  my $news = $self->NewsResults->[$args{Counter}];
  my $desc = $news->Contents;
  delete $self->Seen->{$desc};
}

sub ProcessNextNewsMeat {
  my ($self,%args) = @_;
  if (! defined $self->NewsResults) {
    $self->GenerateEvidencePoints();
  }
  if ($self->Counter >= scalar @{$self->NewsResults}) {
    return {
	    Success => 0,
	    Error => "no more results",
	   };
  } else {
    my $news = $self->NewsResults->[$self->Counter];
    $self->CurrentNews($news);
    ${$self->MyTitle} = $news->Title();
    my $newssources = "";
    foreach my $source (@{$news->Sources}) {
      $newssources .= $source->SPrint;
    }
    $self->MySource->Contents($newssources);
    my $desc = $news->Contents;
    $self->NewsFrameText->Contents($desc);
    $self->DescriptionText->Contents($desc);
    $self->MiscInfoText->Contents($self->CurrentNews->MiscInfo);
    print Dumper({Title => ${$self->MyTitle}});
    if (exists $self->Seen->{$desc}) {
      return {
	      Success => 0,
	      Error => "already seen",
	     };
    }
    $self->Seen->{$desc} = 1;

    if (0) {
      my @matches = $desc =~ /\b(boycott|objection|protest|oppose|resist|resistance|take issue|remonstrance|remonstration|ban|banish|exclude|expel|kick out|shun|shut out|complain|protestation|demonstrate|fight|fight back)\b/sgi;
      # my @matches = $desc =~ /\b(boycott|buycott)\b/sgi;
      if (! scalar @matches) {
	return {
		Success => 0,
		Error => "not classified as a boycott request",
	       };
      }
      print Dumper({Matches => \@matches});
    }
    push @{$self->PreviousSeenCounters}, $self->Counter;


    # do timing to prevent repeated hits on server
    my $last = $self->MyDateTime;
    $self->MyDateTime(DateTime->now());
    if (! $self->MyResources->TextAnalysis->AllResultsWereCached) {
      $duration = $self->MyDateTime - $last;
      my $res = DateTime::Duration->compare($duration, $self->Duration2, $self->MyDateTime);
      print $res."\n";
      if ($res < 0) {
	# compute the delay
	my $duration3 = $self->Duration2 - $duration;
	my $extra = $duration3->{seconds};
	print "sleeping an extra $extra\n";
	print "skipping sleep because we are not retrieving\n";
	# sleep $extra;
      }
    } else {
      print "All results were cached\n";
    }

    print "processing\n";
    # load the stuff

    # try to load the evidence point from the DB
    # for now, just create the evidence point

    $self->MyEvidence
      (Com::elle::bLeaf::EvidenceGenerator::Evidence->new
       (
	News => $self->CurrentNews,
	Categories => $self->CurrentNews->Categories || {},
	EvidenceGenerator => $self,
       ));
    if (defined $self->MyEvidence->NewSelf) {
      $self->MyEvidence($self->MyEvidence->NewSelf);
    } elsif (exists $self->Conf->{'--regenerate'}) {
	# this means that it was created, skip this one
	return {
		Success => 0,
		Error => "regenerating",
	       };
    }
    if (scalar @{$self->MyEvidence->Reviews}) {
      $self->ReviewedCheckbutton->{Value} = 1;
      if ($args{Unreviewed}) {
	return {
		Success => 0,
		Error => "already reviewed and in unreviewed mode",
	       };
      }
    } else {
      $self->ReviewedCheckbutton->{Value} = 0;
    }

    my $ref = ref $self->Polarities;
    if ($ref ne "HASH") {
      $self->Polarities({});
    }

    $self->UpdateResults();
    $self->DisplayCategories();

    if ($args{Cached}) {
      # check the normalization results ahead of time to see if there are any cached results
      if (! $self->ThereAreCachedResults) {
	return {
		Success => 0,
		Error => "no cached results",
	       };
      }
    }

    # now generate the selection menu

    # print Dumper($res);

    # foreach my $tmp (@results) {
    #   $self->ProcessCompanyName(Name => $tmp->{content});
    # }
    # process the next step using the manufacturers list
    # my $res123 = $self->ProcessTextWithManufacturersList
    #   (
    #    Text => $latinified,
    #   );
    # print Dumper($res123);
  }
  $self->MyNormalizationResults(undef);
  return
    {
     Success => 1,
    };
}

sub UpdateResults {
  my ($self,%args) = @_;
  $self->MyResources->MyMarkup->MarkupText
    (
     Text => $self->NewsFrameText,
     Results => $self->MyEvidence->Results,
    );
  $self->SelectEntitiesToBeBoycotted();
}

sub SelectEntitiesToBeBoycotted {
  my ($self,%args) = @_;
  my $set = {};
  my $selection = {};

  # the logic is this
  # display the correct selections
  # to do so, when loading the first time, guess the selections
  # however, if reloading a myevidence item, use the selectedresults

  foreach my $res (@{$self->MyEvidence->Results}) {
    $set->{$res->Contents} = 1;
  }

  if (defined $self->MyEvidence->SelectedResults) {
    foreach my $contents (@{$self->MyEvidence->SelectedResults}) {
      $selection->{$contents} = 1;
    }
  } else {
    foreach my $res (@{$self->MyEvidence->Results}) {
      if ($res->ShouldSelect) {
	$selection->{$res->Contents} = 1;
      }
    }
  }

  # # } elsif (defined $self->SelectionFrame) {
  # #   foreach my $child ($self->SelectionFrame->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
  # #     if (defined $child->{'Value'} and $child->{'Value'}) {
  # # 	$selection->{$child->cget('-text')} = 1;
  # #     } else {
  # # 	delete $selection->{$child->cget('-text')};
  # #     }
  # #   }

  # # $set->{$res->Contents} = 1;


  # print Dumper({Set => [$set,$selection]});
  $self->SubsetSelectFrame->destroy();
  $self->SubsetSelectFrame($self->EvidenceFrame->Frame());
  $self->SubsetSelectFrame->pack(-fill => 'both', -expand => 1);

  $self->SelectionFrame
    ($self->OurSubsetSelect
     (
      Frame => $self->SubsetSelectFrame,
      Set => [sort keys %$set],
      Selection => $selection,
      Message => "Select Entities to be Boycotted
(Mark whether the reviewer feels the source regards the
information about the company as generally reflecting
positively, neutrally or negatively on the company)",
     ));
  $self->MyEvidence->UpdateSelectedResults();
}

sub ProcessCompanyName {
  my ($self,%args) = @_;
  my $scores = {};
  my $lcname = lc($args{Name});
  foreach my $row ($self->MyResources->Rows) {
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

sub ProcessTextWithManufacturersList {
  my ($self,%args) = @_;
  my $text = $args{Text};
  # iterate over the text looking for matching

  # what are the ways we can match this text

  # 1) we can match directly using regexes
  # 2) we could use meteor sentence similarity
  # 3) we could match on number of similar tokens, or mean distance of tokens

  my @matches;
  foreach my $regex (@regexes) {
    if ($text =~ /\b$regex\b/i) {
      push @matches, $self->Regexes->{$regex};
    }
  }
  return {
	  Success => 1,
	  Result => \@matches,
	 };
}

sub OurSubsetSelect {
  my ($self,%args) = @_;
  my $title = $args{Title} || undef;
  my $topframe = $args{Frame};
  if ($args{Message}) {
    my $text = $topframe->Text
      (
       -width => 56,
       -height => 4,
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

  my $selectionframe = $topframe->Scrolled
    ('Frame',
     -scrollbars => 'e',
    )->pack
      (
       -expand => 1,
       -fill => "both",
      );
  foreach my $item (@{$args{Set}}) {
    my $tempframe = $selectionframe->Frame()->pack();
    my $button = $tempframe->Checkbutton
      (
       -text => $item,
       -command => sub {
	 $self = $UNIVERSAL::evidencegenerator;
	 $self->MyEvidence->UpdateSelectedResults();
       },
      );
    $button->pack(-side => "left", -expand => 1, -fill => "both");
    my $radiobuttonframe = $tempframe->Frame()->pack(-side => "right");

    my $polarityvalue = "";
    if (exists $self->MyEvidence->Polarities->{$item}) {
      $polarityvalue = $self->MyEvidence->Polarities->{$item};
    }
    $self->Polarities->{$item} = \$polarityvalue;

    # if (! exists $self->MyEvidence->Polarities->{$item}) {
    #   $self->MyEvidence->Polarities->{$item} = ${$self->Polarities->{$item}};
    # }

    foreach my $polarity ("-1","0","+1","") {
      my $display = $polarity;
      if ($display eq "") {
	$display = "NULL";
      }
      $radiobuttonframe->Radiobutton
	(
	 -text => $display,
	 -variable => $self->Polarities->{$item},
	 -value => $polarity,
	 -command => sub {
	   $self = $UNIVERSAL::evidencegenerator;
	   $self->MyEvidence->UpdateSelectedResults();
	 },
	)->pack(-side => 'left', -anchor => 'w');
    }
    if (exists $args{Selection}->{$item}) {
      $button->{Value} = 1;
    }
  }
  $selectionframe->pack(-side => "top", -expand => 1, -fill => "both");
  my $buttonframe = $topframe->Frame;
  my $myaddentity = "";
  $self->MyAddEntity(\$myaddentity);
  $buttonframe->Entry
    (
     -width => 30,
     -textvariable => $self->MyAddEntity,
    )->pack();
  my $myentitytype = "company";
  $self->MyEntityType(\$myentitytype);
  my $name = $buttonframe->BrowseEntry
    (
     -variable => $self->MyEntityType,
     -width => 25,
    )->pack();
  foreach my $option (qw(company organization country unknown)) {
    $name->insert('end',$option);
  }
  my $buttonsframe = $buttonframe->Frame->pack(-side => 'bottom');
  $buttonsframe->Button
    (
     -text => "Add Entity",
     -command => sub {
       $self->MyEvidence->AddEntity
	 (
	  Type => ${$self->MyEntityType},
	  Contents => ${$self->MyAddEntity},
	 );
     },
    )->pack(-side => "left");
  $buttonsframe->Button
    (
     -text => "Delete Entity",
     -command => sub {
       $self->MyEvidence->DeleteEntity();
       $self->UpdateResults();
     },
    )->pack();
  $buttonsframe->Button
    (
     -text => "Reset Entities",
     -command => sub {
       $self->MyEvidence->LoadResults();
       $self->UpdateResults();
     },
    )->pack(-side => "right");
  $buttonframe->pack(-side => "bottom");
  $topframe->pack(-fill => "both", -expand => 1);
  return $selectionframe;
}

sub OurSubsetSelect2 {
  my ($self,%args) = @_;
  my $title = $args{Title} || undef;
  my $topframe = $args{Frame};
  if ($args{Message}) {
    my $text = $topframe->Text
      (
       -width => 31,
       -height => 1,
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

  my $selectionframe = $topframe->Scrolled
    ('Frame',
     -scrollbars => 'e',
    )->pack
      (
       -expand => 1,
       -fill => "both",
      );
  foreach my $item (@{$args{Set}}) {
    my $button = $selectionframe->Checkbutton
      (
       -text => $item,
      );
    $button->pack(-side => "top", -expand => 1, -fill => "both");
    if (exists $args{Selection}->{$item}) {
      $button->{Value} = 1;
    }
  }
  $selectionframe->pack(-side => "top", -expand => 1, -fill => "both");
  $topframe->pack(-fill => "both", -expand => 1);
  return $selectionframe;
}

sub AddCategory {
  my ($self,%args) = @_;
  $self->MyEvidence->Categories->{$args{Category}} = 1;
  $self->DisplayCategories();
}

sub DisplayCategories {
  my ($self,%args) = @_;
  $self->SubsetSelectFrame2->destroy();
  $self->SubsetSelectFrame2($self->CategoryFrame->Frame());
  $self->SubsetSelectFrame2->pack(-side => 'right');
  $self->SelectionFrame2
    ($self->OurSubsetSelect2
     (
      Frame => $self->SubsetSelectFrame2,
      Set => [sort keys %{$self->MyEvidence->Categories}],
      Selection => $selection,
     ));
}

sub DeleteSelectedCategories {
  my ($self,%args) = @_;
  # preserve the selection
  if (defined $self->SelectionFrame2) {
    # FIXME
    # if (defined $self->SelectionFrame) {
    foreach my $child
      ($self->SelectionFrame2->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
      if (defined $child->{'Value'} and $child->{'Value'}) {
	delete $self->MyEvidence->Categories->{$child->cget('-text')};
      }
    }
  }
  $self->DisplayCategories();
}

sub SaveToDB {
  my ($self,%args) = @_;
  $self->MyEvidence->UpdateSelectedResults();
  $self->MyEvidence->SaveToDB();
}

sub AddReview {
  my ($self,%args) = @_;
  if (! defined $self->MyEvidence->Reviews) {
    $self->MyEvidence->Reviews([]);
  }
  push @{$self->MyEvidence->Reviews},
    Com::elle::bLeaf::EvidenceGenerator::Review->new
	(
	 Reviewer => $self->Reviewer,
	);
}

sub ShowProgress {
  my ($self,%args) = @_;
  my $mysql = $UNIVERSAL::evidencegenerator->MyResources->MyMySQL;
  my $res = $mysql->Do
    (
     Statement => "select count(id) as count from xml",
     Array => 1,
    );
  my $count = $res->[0]->[0];
  Message
    (
     Message => "You have processed $count items",
     GetSignalFromUserToProceed => 1,
    );
}

sub NormalizeCompanies {
  my ($self,%args) = @_;
  my $sources = $self->CurrentNews->Sources;
  my $links = $self->CurrentNews->Links;
  my $description = $self->DescriptionText->Contents;
  my $res = $self->MyResources->MyNormalizer->Normalize
    (
     Title => ${$self->MyTitle},
     Description => $description,
     Sources => $sources,
     Links => $links,
     CompanyNames => $self->MyEvidence->SelectedResults,
     Categories => $self->MyEvidence->Categories || {},
     Reviews => $self->MyEvidence->Reviews,
     Polarities => $self->MyEvidence->Polarities,
    );
  $self->MyNormalizationResults($res);
}

sub WriteToDB {
  my ($self,%args) = @_;
  if (! defined $self->MyNormalizationResults) {
    Message
      (
       Message => "You must first run 'Normalize Companies'",
       GetSignalFromUserToProceed => 1,
      );
    return {
	    Success => 0,
	   };
  } else {
    my $res = $self->MyNormalizationResults;
    if ($res->{Success}) {
      $self->SaveToDB();
      $self->AddReview();
      $self->MyXMLGenerator
	(Com::elle::bLeaf::EvidenceGenerator::Normalizer::XMLGenerator->new());
      my $sources = $self->CurrentNews->Sources;
      my $links = $self->CurrentNews->Links;
      my $description = $self->DescriptionText->Contents;
      my $xml = $self->MyXMLGenerator->GenerateEvidencePointXML
	(
	 Title => ${$self->MyTitle},
	 Sources => $sources,
	 Links => $links,
	 Description => $description,
	 Companies => $res->{Result}->{Companies},
	 Categories => $self->MyEvidence->Categories || {},
	 Reviews => $self->MyEvidence->Reviews,
	 Polarities => $self->MyEvidence->Polarities,
	);

      my $primarykey = $self->CurrentNews->PrimaryKey;
      my $mysql = $self->MyResources->MyMySQL;
      my $quotedpk = $mysql->Quote($primarykey);
      my $res1 = $mysql->Do
	(
	 Statement => "delete from xml where id=$quotedpk;",
	);
      my $res2 = $mysql->Do
	(
	 Statement => "insert into xml values ($quotedpk,".
	 $mysql->Quote($xml).")"
	);
      return {
	      Success => 1,
	     };
    } else {
      Message
	(
	 Message => "Normalization was unsuccessful",
	 GetSignalFromUserToProceed => 1,
	);
      return {
	      Success => 0,
	     };
    }
  }
}

sub ThereAreCachedResults {
  my ($self,%args) = @_;
  # iterate over each of the items, and check the db for cached results
  foreach my $childa ($self->SelectionFrame->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
    my $child;
    foreach my $childb ($childa->children()) {
      my $ref = ref $childb;
      if ($ref eq "Tk::Checkbutton") {
	$child = $childb;
      }
    }
    my $name = $child->cget('-text');
    if ($self->HasCachedResult(Name => $name)) {
      return 1;
    }
  }
  return 0;
}

sub HasCachedResult {
  my ($self,%args) = @_;
  my $mysql = $UNIVERSAL::evidencegenerator->MyResources->MyMySQL;
  my $originalnamequoted = $mysql->Quote($args{Name});
  my $res = $mysql->Do
    (
     Statement => "select * from company_lookup where name=$originalnamequoted",
     KeyField => "name",
    );
  if (scalar keys %$res) {
    return 1;
  }
}

sub FindNextUnreviewed {
  my ($self,%args) = @_;
  $self->NextEvidencePoint
    (Unreviewed => 1);
}

sub SpecialPETA {
  my ($self,%args) = @_;
  # first get the first line of the text
  my $companyname = $self->SpecialPETAAddEntity();
  # now select it as being positive
  my $title = ${$self->MyTitle};
  my $polarity = "0";
  if ($title =~ /doesn't do animal testing$/) {
    $polarity = "+1";
  } elsif ($title =~ /does animal testing$/) {
    $polarity = "-1";
  }
  $self->MyEvidence->Polarities->{$companyname} = $polarity;
  $self->SelectEntitiesToBeBoycotted();
  $self->NormalizeCompanies();
}

sub SpecialPETAAddEntity {
  my ($self,%args) = @_;
  # FIXME
  # ensure PETA source is loaded
  my $text = $self->DescriptionText->Contents;
  my @lines = split /\n/, $text;
  my $companyname = shift @lines;
  # then add the evidence point for it
  $self->MyEvidence->AddEntity
    (
     Type => "company",
     Contents => $companyname,
    );
  return $companyname;
}

sub GUIWriteToDB {
  my ($self,%args) = @_;
  my $res = $self->WriteToDB();
  if ($res->{Success}) {
    $self->NextEvidencePoint(Unreviewed => $self->Unreviewed);
  }
}

1;
