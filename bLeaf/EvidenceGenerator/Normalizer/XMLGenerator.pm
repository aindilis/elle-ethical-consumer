package Com::elle::bLeaf::EvidenceGenerator::Normalizer::XMLGenerator;

# ("created-by" "PPI-Convert-Script-To-Module")
# use Com::elle::bLeaf::RuleGenerator::Annotator;

use Manager::Dialog qw(ChooseByProcessor QueryUser ApproveCommands);

use BOSS::Config;
use PerlLib::Cacher;

use PerlLib::SwissArmyKnife;
use Text::CSV;
use Text::LevenshteinXS qw(distance);
use Tk;
use XML::Simple qw(XMLout);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Num /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Num(0);
}

sub GenerateEvidencePointXML {
  my ($self,%args) = @_;
  print Dumper(\%args);
  my @tmp = @{$args{Sources}};
  my $source = shift @tmp;
  my @links = @{$args{Links}};
  unshift @links, @tmp;
  my $sourceprepped = "";
  $sourceprepped .= "<link>".
    "<link-text>".$self->Prep($source->SourceText)."</link-text>".
      "<url>".$self->Prep($source->URL)."</url>".
	"<date>".$self->Prep($source->Date)."</date>".
	  "</link>";
  my $linksprepped = "";
  foreach my $link (@links) {
    my $linktext = "";
    if (exists $link->{SourceText}) {
      $linktext = $self->Prep($link->{SourceText});
    } else {
      $linktext = $self->Prep($link->{LinkText});
    }

    my $date = "";
    if (exists $link->{Date}) {
      $date = $self->Prep($link->{Date});
    }
    $linksprepped .= "<link>".
      "<link-text>$linktext</link-text>".
	"<url>".$self->Prep($link->URL)."</url>".
	  "<date>$date</date>".
	    "</link>";
  }

  my @companies = @{$args{Companies}};
  my @categories = sort keys %{$args{Categories}};
  my $titleprepped;
  if ($args{Title}) {
    $titleprepped = $self->Prep($args{Title});
  } else {
    $titleprepped = $self->Prep(join(", ",map {$_->{Norm}} @companies));
  }

  # description fixed
  my $description = $UNIVERSAL::evidencegenerator->MyResources->MyHTMLConverter->ConvertToTxt
    (
     Contents => $args{Description},
    );
  $description =~ s/^\s*//s;
  $description =~ s/\s*$//s;
  my $descriptionprepped = $self->Prep($description);

  # categories fixed
  my $categoriesprepped = "";
  foreach my $category (@categories) {
    if ($category =~ /^(.+)\s*\|\s*(.+)$/) {
      $categoriesprepped .= "<category><category-name>$1</category-name><subcategory-name>$2</subcategory-name></category>";
    } else {
      $categoriesprepped .= "<category><category-name>$category</category-name></category>";
    }
  }

  my $companiesprepped = "";
  my @companies2;
  my $seen = {};
  foreach my $companyhash (@companies) {
    # process the company name
    my @gcps;
    foreach my $gcp (@{$companyhash->{GCP}}) {
      push @gcps, "<GCP>".$self->Prep($gcp)."</GCP>";
    }
    my $gcps = join("\n",@gcps);
    print Dumper({WTHHELP => {
			      Polarities => $args{Polarities},
			      Original => $companyhash,
			     }});
    my $key;
    if (exists $companyhash->{Original}) {
      $key = $companyhash->{Original};
    } else {
      $key = $companyhash->{Tagged};
    }
    my $polarity = "";
    if (exists $args{Polarities}->{$key}) {
      $polarity = $args{Polarities}->{$key};
    }
    my $valuesprepped = "<value><value-name>polarity</value-name><score>".$self->Prep($polarity)."</score></value>";
    my $companyxmlstring = "   <company>
      <normalized>".$self->Prep($companyhash->{Norm})."</normalized>
      <tagged>".$self->Prep($companyhash->{Tagged})."</tagged>
      <address>".$self->Prep($companyhash->{Address})."</address>
      <GCPs>".$gcps."</GCPs>
      <values>".$valuesprepped."</values>
    </company>";
    if (! exists $seen->{$companyxmlstring}) {
      push @companies2, $companyxmlstring;
      $seen->{$companyxmlstring} = 1;
    }
  }
  $companiesprepped = join("\n",@companies2);
  my $reviewsprepped = "";
  foreach my $review (@{$args{Reviews}}) {
    $reviewsprepped .= "    <review><reviewer>".$self->Prep($review->Reviewer).
      "</reviewer><date>".$self->Prep($review->PrintDate)."</date></review>\n";
  }

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
  <links>
    $linksprepped
  </links>
  <companies>
$companiesprepped
  </companies>
  <reviews>
    $reviewsprepped
  </reviews>
 </evidence>";
  return $xmlcontents;
}

sub Prep {
  my ($self,$it) = (shift,shift);
  my $tmp = XMLout($it);
  if ($tmp =~ /^<opt>(.*)<\/opt>$/sm) {
    return $1;
  } else {
    die "ERROR <$tmp>\n";
  }
}

sub DePrep {
  my ($self,$xml) = (shift,shift);
  return XMLin("<opt>".$xml."</opt>");
}


1;
