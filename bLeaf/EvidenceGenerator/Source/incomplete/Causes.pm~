package NewsMonitor::Source::RSS;

use NewsMonitor::News;
use PerlLib::Cacher;
use PerlLib::Collection;
use PerlLib::HTMLConverter;
use PerlLib::SwissArmyKnife;

use XML::RSS::Parser;
use XML::Simple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Loaded OPMLFile MyCacher MyHTMLConverter MyNews Verbose /
  ];

sub init {
  my ($self,%args) = @_;
  $self->Verbose(0);
  $self->Loaded(0);
  $self->OPMLFile("/var/lib/myfrdcsa/codebases/minor-data/news-monitor/gnus-rss-feeds.opml");
  $self->MyCacher
    (PerlLib::Cacher->new
     (
      Expires => "1 day",
      CacheRoot => "/var/lib/myfrdcsa/codebases/minor/news-monitor/data/FileCache",
     ));
  $self->MyHTMLConverter
    (PerlLib::HTMLConverter->new());
  $self->MyNews
    (PerlLib::Collection->new
     (StorageFile => $args{StorageFile}
      || "$UNIVERSAL::systemdir/data/source/RSS/news",
      Type => "NewsMonitor::News"));
  $self->MyNews->Contents({});
}

sub UpdateSource {
  my ($self,%args) = @_;
  Message(Message => "Updating source: RSS feeds");
  $self->UpdateRSSFeeds;
}

sub LoadSource {
  my ($self,%args) = @_;
}

sub UpdateRSSFeeds {
  my ($self,%args) = @_;
  # iterate over the OPML entries
  my $contents = read_file($self->OPMLFile);
  my $xml = XMLin($contents);
  print Dumper($xmlsimple);
  foreach my $item (@{$xml->{body}->{outline}}) {
    my $url = $item->{xmlUrl};
    print $url."\n";
    my $rssoratom = $self->MyCacher->get($url);
    $self->ProcessRSSOrAtom
      (
       URL => $url,
       RSSOrAtom => $rssoratom->content,
      );
  }
}

sub ProcessRSSOrAtom {
  my ($self,%args) = @_;
  my $rssoratom = $args{RSSOrAtom};
  # print Dumper($rssoratom);
  my $rss;
  if ($rssoratom =~ /http:\/\/www.w3.org\/2005\/Atom/) {
    # convert it first from atom to rss
    my ($fh,$filename) = tempfile();
    print $fh $rssoratom;
    $rss = `cat $filename | xsltproc /home/andrewdo/.myconfig/.emacs.d/atom2rss.xsl -`;
    $fh->close();
  } else {
    $rss = $rssoratom;
  }
  my $p = XML::RSS::Parser->new;
  my $feed = $p->parse_string($rss);

  # output some values
  if (defined $feed) {
    my $feed_title = $feed->query('/channel/title');
    print $feed_title->text_content;
    my $count = $feed->item_count;
    print " ($count)\n";
    my ($title,$description,$text,$link);
    foreach my $i ( $feed->query('//item') ) {
      my $node = $i->query('title');
      $title = $node->text_content;
      if ($self->Verbose) {
	print '  Title: '.$title;
	print "\n";
      }

      my $description = $i->query('description');
      if (defined $description) {
	$description = $description->text_content;
	# print '  Desc: '.$description;
	# print "\n";
	# convert to text, along with title
	$text = $self->MyHTMLConverter->ConvertToTxt(Contents => $description);
	if ($self->Verbose) {
	  print '  Text: '.$text;
	  print "\n";
	}
	# now package this as an entry object and return
      }

      my $link = $i->query('link');
      if (defined $link) {
	$link = $link->text_content;
	if ($self->Verbose) {
	  print '  Link: '.$link;
	  print "\n";
	}
	# in the future, retrieve this link
      }
      my $news = NewsMonitor::News->new
	(
	 Source => $args{URL},
	 Title => $title,
	 Contents => $text,
	);
      $self->MyNews->AddAutoIncrement(Item => $news);
    }
  } else {
    print "ERROR with feed $args{URL}\n";
  }
}

1;
