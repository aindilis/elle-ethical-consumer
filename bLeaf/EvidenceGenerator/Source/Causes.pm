package Com::elle::bLeaf::EvidenceGenerator::Source::Causes;

use Com::elle::bLeaf::EvidenceGenerator::Link;
use Com::elle::bLeaf::EvidenceGenerator::News;
use Com::elle::bLeaf::EvidenceGenerator::NewsSource;

use PerlLib::Cacher;
use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

use XML::Simple qw(XMLin);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Loaded MyNews Verbose Causes Count /
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
  $self->Causes({});
  $self->Count(0);
}

sub UpdateSource {
  my ($self,%args) = @_;
  system "cd /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/ && grep \"member-count type=\" cause-xml/* > membercount.txt";
}

sub LoadSource {
  my ($self,%args) = @_;
  Message(Message => "Loading source: Causes");
  foreach my $line (split /\n/, `cat /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/membercount.txt`) {
    # print "<$line>\n";
    # cause-xml/1957.xml:  <member-count type="integer">16</member-count>>
    if ($line =~ /^cause-xml\/(\d+)\.xml:\s+<member-count type="integer">(\d+)<\/member-count>$/) {
      my ($cause,$count) = ($1,$2);
      $self->Causes->{$cause} = $count;
    }
  }
  my $maxcauses = $UNIVERSAL::evidencegenerator->Conf->{'--max-causes'} || 10000;
  foreach my $cause (sort {$self->Causes->{$b} <=> $self->Causes->{$a}} keys %{$self->Causes}) {
    if ($self->Count > $maxcauses) {
      print "reached last item\n";
      last;
    } else {
      $self->Count($self->Count + 1);
    }
    print $self->Count."\t".$self->Causes->{$cause}."\t".$cause."\n";
    # process this cause with the proper data analysis
    print $cause."\n";
    my $causesdir = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/cause-xml";
    my $c = read_file("$causesdir/$cause.xml");
    # print $c."\n";
    my $xml = XMLin($c);
    my $desc = $xml->{description};

    my @links;
    my @potentials = $desc =~ /<a href="([^"]+)">\s*(.+?)\s*<\/a>/isg;
    while (@potentials) {
      my ($url,$text) = (shift @potentials,shift @potentials);
      push @links, Com::elle::bLeaf::EvidenceGenerator::Link->new
	(
	 URL => $url,
	 LinkText => $text,
	);
    }

    my $newssource = Com::elle::bLeaf::EvidenceGenerator::NewsSource->new
      (
       SourceText => "Causes.com: Cause $cause",
       URL => "http://api.causes.com/causes/$cause.xml",
      );

    my $news = Com::elle::bLeaf::EvidenceGenerator::News->new
      (
       Sources => [$newssource],
       Links => \@links,
       Title => $xml->{name},
       Contents => $desc,
       Score => $self->Causes->{$cause},
       Categories => {},
       MiscInfo => $c,
      );

    # process this with both OpenCalais and DBpediaSpotlight
    $self->MyNews->AddAutoIncrement
      (
       Item => $news,
      );
  }
  $self->MyNews->Save;
  Message(Message => "Done loading source: Causes");
}

1;
