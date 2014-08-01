package Com::elle::bLeaf::EvidenceGenerator::Source::GreenAmerica;

use Com::elle::bLeaf::EvidenceGenerator::Link;
use Com::elle::bLeaf::EvidenceGenerator::News;
use Com::elle::bLeaf::EvidenceGenerator::NewsSource;

use PerlLib::Cacher;
use PerlLib::Collection;
use PerlLib::HTMLConverter;
use PerlLib::SwissArmyKnife;

use XML::Simple qw(XMLin);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Loaded MyNews Verbose SourceURL Content MyCacher Companies
   CategoryMapping /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Verbose(0);
  $self->Loaded(0);
  $self->MyNews
    (PerlLib::Collection->new
     (StorageFile => $args{StorageFile}
      || "$UNIVERSAL::systemdir/data/source/GreenAmerica/news",
      Type => "Com::elle::bLeaf::EvidenceGenerator::News"));
  $self->MyNews->Contents({});
  $self->MyCacher
    (PerlLib::Cacher->new
     (
      CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/green-america/FileCache",
     ));
  $self->SourceURL("http://www.greenamerica.org/programs/responsibleshopper/learn_hub.cfm");
  $self->Companies({});
  $self->CategoryMapping
    ({
      'Campaign Action' => 'Politics | Political Activity',
      'Human Rights' => 'Human Rights',
      'Environment' => 'Environment',
      'Health and Safety' => 'Human Rights | Health and Wellness',
      'Animal Testing' => 'Animal | Animal Testing',
      'Ethics and Governance' => 'Politics',
      'Labor' => 'Business Practices | Workers Rights',
     });
}

sub UpdateSource {
  my ($self,%args) = @_;

}

sub LoadSource {
  my ($self,%args) = @_;
  Message(Message => "Loading source: GreenAmerica");
  $self->MyCacher->get($self->SourceURL);
  $self->Content($self->MyCacher->content());
  my @results = $self->Content =~ /<a href=\"(company.cfm\?id=(\d+)(\&MajorSub=(\d+)\&CompanyName=([^"]+))?)\">(.+?)<\/a>/sg;
  # print Dumper(\@results);
  while (@results) {
    my ($url,$id,$tmp,$majorsub,$companynamehtmlentities,$companyname) = (shift @results,shift @results,shift @results,shift @results,shift @results,shift @results);
    $self->Companies->{$id} = {
			       ID => $id,
			       MajorSub => $majorsub,
			       CompanyNameHTMLEntities => $companynamehtmlentities,
			       CompanyName => $companyname,
			       URL => "http://www.greenamerica.org/programs/responsibleshopper/$url",
			      };
  }
  $self->LoadCompanies();
  $self->MyNews->Save;
  Message(Message => "Done loading source: GreenAmerica");
}

sub LoadCompanies {
  my ($self,%args) = @_;
  foreach my $key (sort {$a <=> $b} keys %{$self->Companies}) {
    print $key."\n";
    my $url = $self->Companies->{$key}->{URL};
    if (! $self->MyCacher->is_cached) {
      print "sleeping\n";
      sleep 5;
    }
    $self->MyCacher->get($url);
    my $content = $self->MyCacher->content();
    # <p class="section-heading">Contact British Airways</p><br />
    # <p>British Airways<br />

    #                 Harmondsworth<br />

    # London,   UB7 0GB
    #           United Kingdom</p>
    # <p>Phone: +44-0844-493-0787</p>
    # <p>Web: <a href="http://www.british-airways.com" target="_blank">www.british-airways.com</a></p>

    if ($content =~ /<p class="section-heading">Contact (.+?)<\/p><br \/>\s*(.+?)\s*<p class="section-heading">Alerts<\/p>(.+?)<!-- end printable body -->/s) {
      my $companynamex = $1;
      my $address = $2;
      my $items = $3;
      my $addresscleaned = $UNIVERSAL::evidencegenerator->MyResources->MyHTMLConverter->ConvertToTxt
	(
	 Contents => $address,
	);
      # print Dumper({Help => [$addresscleaned,$companynamex,$address]});
      my $links = [];
      if ($address =~ /<p>Web: <a href="([^"]+)" target="_blank">(.*?)<\/a><\/p>/s) {
	push @{$links}, Com::elle::bLeaf::EvidenceGenerator::Link->new
	  (
	   URL => $1,
	   LinkText => $2,
	  );
      }
      # print $items."\n";
      my @items = $items =~ /class="RSProfileAlertCat">(.+?)<\/strong><\/p>(.+?)(<p><strong|<!-- InstanceEndEditable -->)/sg;
      # print Dumper(\@items);
      while (@items) {
	my ($category,$text,$tmp) = (shift @items,shift @items,shift @items);
	my $categories = {$self->CategoryMapping->{$category} => 1};
	my @items2 = $text =~ /(<p><a id=(.+?)<\/p><br \/>)/sg;
	# print Dumper(\@items2);
	while (@items2) {
	  my ($item,$tmp2) = (shift @items2,shift @items2);
	  # if ($item =~ /<p><a id=\".+?\" name=\".+?\"><\/a>(.+?)<\/p>\s*<div class=\"collapsible\">\s*<h6>read more<\/h6>\s*<p>(.+?)<\/p>\s*<\/div>(.+?)\s*<\/p><br \/>/) {
	  if ($item =~ /<p><a id=\".+?\" name=\".+?\"><\/a>(.+?)&hellip;<\/p>\s*<div class=\"collapsible\">\s*<h6>read more<\/h6>\s*<p>(.+?)<\/p>\s*<\/div>(.+?)\s*<\/p><br \/>/s) {
	    my ($title,$contents,$sources) = ($1,$2,$3);
	    my @sources = $sources =~ /<p class="source">(.+?)<\/p>/sg;
	    my @mysources;
	    push @mysources, Com::elle::bLeaf::EvidenceGenerator::NewsSource->new
	      (
	       SourceText => "Green America: Company ID $key",
	       URL => $url,
	      );
	    if ($sources[0] =~ /^-- (.+?), (\d{2})\/(\d{2})\/(\d{4})$/) {
	      my $asource = $1;
	      my $amonth = $2;
	      my $aday = $3;
	      my $ayear = $4;
	      if ($sources[1] =~ /^Source URL: <a href="([^"]+)" target="_blank">(.+?)<\/a>$/) {
		my $aurl = $1;
		push @mysources, Com::elle::bLeaf::EvidenceGenerator::NewsSource->new
		  (
		   SourceText => $asource,
		   URL => $aurl,
		   Date => DateTime->new
		   (
		    month => $amonth,
		    day => $aday,
		    year => $ayear,
		   ),
		  );
	      }
	    }

	    my $news = Com::elle::bLeaf::EvidenceGenerator::News->new
	      (
	       Sources => \@mysources,
	       Links => $links,
	       Title => $title,
	       Contents => $contents,
	       Score => undef,
	       Categories => $categories,
	       MiscInfo => $addresscleaned,
	      );
	    $self->MyNews->AddAutoIncrement
	      (
	       Item => $news,
	      );
	  } else {
	    print "ERROR2 $item\n";
	  }
	}
      }
    } else {
      print "ERROR $url\n";
    }
  }
}

1;
