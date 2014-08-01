package Com::elle::bLeaf::EvidenceGenerator;

# ("created-by" "PPI-Convert-Script-To-Module")

use BOSS::Config;
use Manager::Dialog qw(ChooseByProcessor QueryUser ApproveCommands);
use PerlLib::Cacher;
use PerlLib::HTMLConverter;
use PerlLib::SwissArmyKnife;
use Text::CSV;
use Text::LevenshteinXS qw(distance);
use Tk;
use XML::Simple qw(XMLout);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Cacher Conf Config Content HTMLConverter Num SourceUrl Rows
   Freq /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = q(
	-t		Temp
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf
    ($self->Config->CLIConfig);
  $self->Num(0);
  $self->Rows([]);
  $self->Freq({});
  $self->Cacher
    (PerlLib::Cacher->new
     (
      CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/ethical-consumer/FileCache",
     ));
  $self->HTMLConverter
    (PerlLib::HTMLConverter->new());
  $self->SourceUrl("http://www.ethicalconsumer.org/Boycotts/currentboycottslist.aspx");
}

sub Execute {
  my ($self,%args) = @_;
  $UNIVERSAL::managerdialogtkwindow = MainWindow->new();
  $UNIVERSAL::managerdialogtkwindow->withdraw();
  $self->LoadManufacturers();
  $self->GenerateLanguageModel();
  $self->Cacher->get($self->SourceUrl);
  $self->Content
    ($self->Cacher->content());
  if ($self->Content =~ /<!-- Start_Module_1460 -->(.+?)<!-- End_Module_1460 -->/s) {
  my $talk = $1;
  my @items = split /&#160;/,$talk;
  # print Dumper(\@items);
  # exit(0);
  my @evidences;
  foreach my $item (@items) {
    if ($item =~ /<h3>(.+?)<\/h3>(.+)/s) {
      my $title = $1;
      my $content = $2;
      my $res = $self->HTMLConverter->ConvertToTxt
	(
	 Contents => "<p>$title</p>",
	);
      $res =~ s/^\s*//;
      $res =~ s/\s*$//;
      $res =~ s/\s+/ /g;
      # print $res."\n";
      # print $content."\n";
      my $res2 = $self->HTMLConverter->ConvertToTxt
	(
	 Contents => "<p>$content</p>",
	);
      $res2 =~ s/^\s*//;
      $res2 =~ s/\s*$//;
      $res2 =~ s/\s+/ /g;
      my $company = $res;
      my $description = $res2;


      my $sourceprepped = $self->Prep("Ethical Consumer");
      my $linkprepped = $self->Prep($self->SourceUrl);
      my @companies = ($company);
      my @categories = ({
			 category => "Other",
			 rating => "NULL",
			});
      my $titleprepped = $self->Prep("Boycott ".join(", ",@companies));
      my $descriptionprepped = $self->Prep($description);
      my $categoriesprepped = "";
      my $companiesprepped = "";
      foreach my $category (@categories) {
	$categoriesprepped .= "<category>
      <name>".$self->Prep($category->{category})."</name>
      <rating>".$self->Prep($category->{rating})."</rating>
    </category>";
      }
      my @companies2;
      foreach my $company (@companies) {
	# process the company name
	my $res = $self->ProcessCompanyName(Name => $company);
	push @companies2, "<company>".$self->Prep($company)."</company>";
      }
      $companiesprepped = join("\n",@companies2);
      my $xmlcontents = " <evidence>
  <title>$titleprepped</title>
  <description>
    $descriptionprepped
  </description>
  <categories>
    $categoriesprepped
  </categories>
  <source>
    $sourceprepped
  </source>
  <link>
    $linkprepped
  </link>
  <companies>
    $companiesprepped
  </companies>
 </evidence>";
      push @evidences, $xmlcontents;
    }
  }
  print "<?xml version='1.0' ?>
<!DOCTYPE announcements SYSTEM \"http://elleconnect.com/andrewdo/bleaf/dtds/bLeaf.dtd\">
<evidences>
".join("\n",@evidences)."
</evidences>
";

}
}

sub Prep {
  my ($self,$it) = @_;
  my $tmp = XMLout($it);
  if ($tmp =~ /^<opt>(.*)<\/opt>$/m) {
    return $1;
  } else {
    die "ERROR <$tmp>\n";
  }
}

sub GetTop {
  my ($self,%args) = @_;
  my $name = $args{Name};
  my $lcname = lc($name);
  my $method = "freq";
  if ($method eq "distance") {
    foreach my $row (@{$self->Rows}) {
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
    foreach my $keyword (@keywords) {
      if (length $keyword > 3) {
	foreach my $result (map {$_->[1]} @{$self->Rows}) {
	  if ($result =~ /\b$keyword\b/i) {
	    if (! exists $self->Freq->{$keyword}) {
	      print Dumper($keyword);
	    } else {
	      $score{$result} += ($self->Num / $self->Freq->{$keyword});
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
  }
}

sub ProcessCompanyName {
  my ($self,%args) = @_;
  my $scores = {};
  my @top = @{$self->GetTop
		(
		 Name => $args{Name},
		 Num => 25,
		)};
  print Dumper({
		Name => $args{Name},
		Top => \@top,
	       });
  # Manager::Dialog
  my $res = $self->OurSubsetSelect
    (
     SearchText => $args{Name},
     Set => \@top,
     Selection => {},
    );
  # choose which one to use
  # save the aligned item in the db
  print Dumper($res);
}

sub LoadManufacturers {
  my ($self,%args) = @_;  
  my $csvfile = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/manufacturers/upcdatabase-2008.03.01/mfrs.csv";
  my $csv = Text::CSV->new ( { binary => 1 } ) # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
  open my $fh, "<:encoding(utf8)", $csvfile or die "$csvfile: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    push @{$self->Rows}, [$row->[0],lc($row->[1])];
  }
  $csv->eof or $csv->error_diag();
  close $fh;
  # print Dumper($self->Rows);
}

sub MyMainLoop {
  my ($self,%args) = @_;
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

sub GenerateLanguageModel {
  my ($self,%args) = @_;
  print "Generating Language Model\n";
  my @corpus;
  foreach my $row (@{$self->Rows}) {
    push @corpus, $row->[1];
  }
  print "Generating IDF\n";
  foreach my $word (map {lc($_)} split /\W+/, join("\n",@corpus)) {
    # print Dumper($word);
    if (defined $self->Freq->{$word}) {
      $self->Freq->{$word} += 1;
    } else {
      $self->Freq->{$word} = 1;
    }
    $self->Num($self->Num + 1);
  }
  print "Done Generating Language Model\n";
}

sub OurSubsetSelect {
  my ($self,%args) = (@_);
  my $title = $args{Title} || undef;
  my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
    (
     -title => $title,
    );
  my $topframe = $top1->Frame();
  $top1->geometry("800x600");
  my $searchtext;
  if ($args{SearchText}) {
    $searchtext = $args{SearchText};
    my $searchframe = $topframe->Frame()->pack(-side => 'top');
    my $search = $searchframe->Entry
      (
       -relief       => 'sunken',
       -borderwidth  => 2,
       -textvariable => \$searchtext,
       -width        => 40,
      )->pack(-side => 'left');
    $searchframe->Button
      (
       -text => "Search GEPIR",
       -command => sub {
	 # have to run the search and get values from GEPIR

       },
      )->pack(-side => "right");
    $searchframe->Button
      (
       -text => "Search",
       -command => sub {
	 # rerun the search

	 # have to close out of the current one, launch the search
	 # with the new value

       },
      )->pack(-side => "right");
  }
  if ($args{Message}) {
    my $text = $topframe->Text
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

  my $selectionframe = $topframe->Scrolled
    ('Frame',
     -scrollbars => 'e',
    )->pack
      (
       -expand => 1,
       -fill => "both",
      );
  foreach my $item (@{$args{Set}}) {
    my $itemframe = $selectionframe->Frame();
    my $button = $itemframe->Checkbutton
      (
       -text => $item,
      );
    $button->pack(-side => "left", -expand => 1, -fill => "both");
    if (exists $args{Selection}->{$item}) {
      $button->{Value} = 1;
    }
    $itemframe->Button
    (
     -text => "Google",
     -command => sub {
     },
    )->pack(-side => "right");
    $itemframe->pack();
  }
  $selectionframe->pack(-side => "top", -expand => 1, -fill => "both");

  my $buttonframe = $topframe->Frame;
  $buttonframe->Button
    (
     -text => "Match",
     -command => sub {
       my @results;
       foreach my $child ($selectionframe->{SubWidget}->{scrolled}->{SubWidget}->{frame}->children) {
	 if (defined $child->{'Value'} and $child->{'Value'}) {
	   push @results, $child->cget('-text');
	 }
       }
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
     -text => "None of the Above",
     -command => sub {  
       $continueloop = 0;
       $ourresults = {
		      Success => 0,
		      Error => "none of the above",
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
  $buttonframe->pack(-side => "bottom");
  $topframe->pack(-fill => "both", -expand => 1);

  $self->MyMainLoop();
  $top1->destroy();
  DoOneEvent(0);
  return $ourresults;
}

1;
