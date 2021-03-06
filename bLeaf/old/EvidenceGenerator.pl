#!/usr/bin/perl -w

use BOSS::Config;
use Manager::Dialog qw(ChooseByProcessor QueryUser ApproveCommands);
use PerlLib::Cacher;
# use PerlLib::IE::AIE;
use PerlLib::SwissArmyKnife;
use PerlLib::HTMLConverter;

use Text::CSV;
use Text::LevenshteinXS qw(distance);
use Tk;
use XML::Simple qw(XMLout);

$UNIVERSAL::managerdialogtkwindow = MainWindow->new();
$UNIVERSAL::managerdialogtkwindow->withdraw();

$specification = q(
	-t		Temp
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

my @rows;
my %freq;
my $num = 0;
my $cacher = PerlLib::Cacher->new
  (
   CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/ethical-consumer/FileCache",
  );

LoadManufacturers();
GenerateLanguageModel();

my $htmlconverter = PerlLib::HTMLConverter->new();

my $sourceurl = "http://www.ethicalconsumer.org/Boycotts/currentboycottslist.aspx";
$cacher->get($sourceurl);
my $content = $cacher->content();

# my $aie = PerlLib::IE::AIE->new(Contents => $content);

if ($content =~ /<!-- Start_Module_1460 -->(.+?)<!-- End_Module_1460 -->/s) {
  my $talk = $1;
  my @items = split /&#160;/,$talk;
  # print Dumper(\@items);
  # exit(0);
  my @evidences;
  foreach my $item (@items) {
    if ($item =~ /<h3>(.+?)<\/h3>(.+)/s) {
      my $title = $1;
      my $content = $2;
      my $res = $htmlconverter->ConvertToTxt
	(
	 Contents => "<p>$title</p>",
	);
      $res =~ s/^\s*//;
      $res =~ s/\s*$//;
      $res =~ s/\s+/ /g;
      # print $res."\n";
      # print $content."\n";
      my $res2 = $htmlconverter->ConvertToTxt
	(
	 Contents => "<p>$content</p>",
	);
      $res2 =~ s/^\s*//;
      $res2 =~ s/\s*$//;
      $res2 =~ s/\s+/ /g;
      my $company = $res;
      my $description = $res2;


      my $sourceprepped = Prep("Ethical Consumer");
      my $linkprepped = Prep($sourceurl);
      my @companies = ($company);
      my @categories = ({
			 category => "Other",
			 rating => "NULL",
			});
      my $titleprepped = Prep("Boycott ".join(", ",@companies));
      my $descriptionprepped = Prep($description);
      my $categoriesprepped = "";
      my $companiesprepped = "";
      foreach my $category (@categories) {
	$categoriesprepped .= "<category>
      <name>".Prep($category->{category})."</name>
      <rating>".Prep($category->{rating})."</rating>
    </category>";
      }
      my @companies2;
      foreach my $company (@companies) {
	# process the company name
	my $res = ProcessCompanyName(Name => $company);
	push @companies2, "<company>".Prep($company)."</company>";
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

sub Prep {
  my $it = shift;
  my $tmp = XMLout($it);
  if ($tmp =~ /^<opt>(.*)<\/opt>$/m) {
    return $1;
  } else {
    die "ERROR <$tmp>\n";
  }
}

sub GetTop {
  my %args = @_;
  my $name = $args{Name};
  my $lcname = lc($name);
  my $method = "freq";
  if ($method eq "distance") {
    foreach my $row (@rows) {
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
	foreach my $result (map {$_->[1]} @rows) {
	  if ($result =~ /\b$keyword\b/i) {
	    if (! exists $freq{$keyword}) {
	      print Dumper($keyword);
	    } else {
	      $score{$result} += ($num / $freq{$keyword});
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
  my %args = @_;
  my $scores = {};
  my @top = @{GetTop
		(
		 Name => $args{Name},
		 Num => 25,
		)};
  print Dumper({
		Name => $args{Name},
		Top => \@top,
	       });
  # Manager::Dialog
  my $res = OurSubsetSelect
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

sub MyMainLoop
{
 unless ($inMainLoop)
  {
   local $inMainLoop = 1;
   $cancel = 0;
   $continueloop = 1;
   while ($continueloop)
    {
     DoOneEvent(0);
    }
  }
}

sub GenerateLanguageModel {
  print "Generating Language Model\n";
  my @corpus;
  foreach my $row (@rows) {
    push @corpus, $row->[1];
  }
  print "Generating IDF\n";
  foreach my $word (map {lc($_)} split /\W+/, join("\n",@corpus)) {
    # print Dumper($word);
    if (defined $freq{$word}) {
      $freq{$word} += 1;
    } else {
      $freq{$word} = 1;
    }
    ++$num;
  }
  print "Done Generating Language Model\n";
}

sub OurSubsetSelect {
  my (%args) = (@_);
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

  MyMainLoop();
  $top1->destroy();
  DoOneEvent(0);
  return $ourresults;
}
