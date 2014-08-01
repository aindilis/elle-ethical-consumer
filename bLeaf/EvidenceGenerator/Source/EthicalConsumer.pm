package Com::elle::bLeaf::EvidenceGenerator::Source::EthicalConsumer;

use Com::elle::bLeaf::EvidenceGenerator::News;
use Com::elle::bLeaf::EvidenceGenerator::NewsSource;

use PerlLib::Cacher;
use PerlLib::Collection;
use PerlLib::SwissArmyKnife;
use PerlLib::URIExtractor;

use XML::Simple qw(XMLin);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Loaded MyNews Verbose MyCacher SourceURL Content /
  ];

sub init {
  my ($self,%args) = @_;
  $self->Verbose(0);
  $self->Loaded(0);
  $self->MyNews
    (PerlLib::Collection->new
     (StorageFile => $args{StorageFile}
      || "$UNIVERSAL::systemdir/data/source/Causes/news",
      Type => "Com::elle::bLeaf::EvidenceGenerator::News"));
  $self->MyNews->Contents({});
  $self->MyCacher
    (PerlLib::Cacher->new
     (
      CacheRoot => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/ethical-consumer/FileCache",
     ));
  $self->SourceURL("http://www.ethicalconsumer.org/Boycotts/currentboycottslist.aspx");
}

sub UpdateSource {
  my ($self,%args) = @_;

}

sub LoadSource {
  my ($self,%args) = @_;
  Message(Message => "Loading source: Ethical Consumer");
  $self->MyCacher->get($self->SourceURL);
  $self->Content($self->MyCacher->content());
  if ($self->Content =~ /<!-- Start_Module_1460 -->(.+?)<!-- End_Module_1460 -->/s) {
    my $talk = $1;
    my @items = split /&#160;/,$talk;
    # print Dumper(\@items);
    # exit(0);
    my @evidences;
    my $i = 0;
    foreach my $item (@items) {
      if ($item =~ /<h3>(.+?)<\/h3>(.+)/s) {
	my $title = $1;
	$self->Content($2);
	my $res = $UNIVERSAL::evidencegenerator->MyResources->MyHTMLConverter->ConvertToTxt
	  (
	   Contents => "<p>$title</p>",
	  );
	$res =~ s/^\s*//;
	$res =~ s/\s*$//;
	$res =~ s/\s+/ /g;
	# print $res."\n";
	# print $content."\n";

	# extract the URI here and add to links
	my @links;
	my @potentials = $self->Content =~ /<a href="([^"]+)">\s*(.+?)\s*<\/a>/isg;
	while (@potentials) {
	  my ($url,$text) = (shift @potentials,shift @potentials);
	  push @links, Com::elle::bLeaf::EvidenceGenerator::Link->new
	    (
	     URL => $url,
	     LinkText => $text,
	    );
	}

	my $res2 = $UNIVERSAL::evidencegenerator->MyResources->MyHTMLConverter->ConvertToTxt
	  (
	   Contents => "<p>".$self->Content."</p>",
	  );
	$res2 =~ s/^\s*//;
	$res2 =~ s/\s*$//;
	$res2 =~ s/\s+/ /g;
	my $company = $res;
	my $description = $res2;
	# print Dumper({WOW => [$company,$description]});
	my $newssource = Com::elle::bLeaf::EvidenceGenerator::NewsSource->new
	  (
	   SourceText => "EthicalConsumer: $company",
	   URL => $self->SourceURL,
	  );
	my $news = Com::elle::bLeaf::EvidenceGenerator::News->new
	  (
	   Sources => [$newssource],
	   Links => \@links,
	   Title => "Boycott $company",
	   Contents => $description,
	   Score => 10000 - $i,
	   Categories => {},
	   MiscInfo => "",
	  );
	# process this with both OpenCalais and DBpediaSpotlight
	$self->MyNews->AddAutoIncrement
	  (
	   Item => $news,
	  );
      }
      ++$i;
    }
  $self->MyNews->Save;
  } else {
    die "Cannot load EthicalConsumer\n";
  }
  Message(Message => "Done loading source: Causes");
}

1;
