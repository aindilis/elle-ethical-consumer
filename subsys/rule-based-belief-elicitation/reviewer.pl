#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use Manager::Dialog qw(Message);
use MyFRDCSA qw(ConcatDir);
use PerlLib::SwissArmyKnife;

use XML::Simple;
use Tk;
use Tk::TableMatrix;

# review aggregated announcements

my $context = "Com::elle::BLeaf";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $importexport = KBS2::ImportExport->new();

my $top1 =
  MainWindow->new
  (
   -title => "BLeaf",
   -height => 600,
   -width => 800,
  );
$UNIVERSAL::managerdialogtkwindow = $top1;

my $itemsdb = {};
my $entrycounter = 1;

my $announcementdir = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/rule-based-belief-elicitation/data/";
my $files = `ls "$announcementdir"`;
my $numberofrows = 0;
my @columns;
foreach my $file (split /\n/, $files) {
  if ($file =~ /\.xml$/) {
    print "<$file>\n";
    my $contents = read_file(ConcatDir($announcementdir,$file));
    my $xml = XMLin($contents);
    # verify the Crypto Signature
    VerifyCryptoSignature();
    # extract out the announcements and sources, and create an object
    print Dumper($xml);
    my @items;
    if (ref $xml->{'items'}->{'item'} eq "ARRAY") {
      @items = @{$xml->{'items'}->{'item'}};
    } else {
      @items = $xml->{'items'}->{'item'};
    }
    # foreach my $item (keys $xml->{'items'}
    print Dumper($xml);
    ++$numberofrows;
    foreach my $item (@items) {
      # create an object,
      # for now just get the title
      my $source1 = $xml->{'source'};
      chomp $source1;
      $source1 =~ s/^\s+//s;
      $source1 =~ s/\s+$//s;
      my $source2 = $item->{"reason-given"}->{source};
      chomp $source2;
      $source2 =~ s/^\s+//s;
      $source2 =~ s/\s+$//s;
      print Dumper
      	({
      	  1 => $source1,
      	  2 => $source2,
      	 });
      push @columns, [$item->{title},"Reason","$source1: $source2","Action"];
      $itemsdb->{$entrycounter++} = $item;
    }
  }
}

# now select the causes to accept

my $frame = $top1->Frame();
my @keys = ("Announcement","Reason","Source","Action");
my $table = $frame->Scrolled
  (
   "TableMatrix",
   -titlerows => 1,
   -rows => ($numberofrows + 1),
   -colstretchmode => 'all',
   -cols => (scalar @keys),
   -cache => 1,
   -scrollbars => "osoe",
  )->pack();
$table->colWidth(0, 60);
$table->colWidth(2, 30);
$frame->pack();
$frame->Button
  (
   -text => "Quit",
   -command => sub {
     exit(0);
   },
  )->pack(-side => "right");

my $col2 = 0;
foreach my $key (@keys) {
  $table->set("0,$col2", $key);
  ++$col2;
}

my $row = 1;
foreach my $column (@columns) {
  my $col = 0;
  foreach my $entry (@$column) {
    if ($entry eq "Action") {
      my $button1 = $table->Button
	(
	 -text => "Agree",
	 -background => "Grey",
	 -command => sub {
	   Accept
	     (
	      Entry => ($row - 1),
	     );
	 },
	);
      $table->windowConfigure
	(
	 "$row,$col",
	 -window => $button1,
	 -sticky => 'nsew',
	);
    } elsif ($entry eq "Reason") {
      my $button2 = $table->Button
	(
	 -text => "Reason",
	 -background => "Grey",
	 -command => sub {
	   Message
	     (
	      Message => $itemsdb->{($row - 1)}->{"reason-given"}->{reason},
	     );
	 },
	);
      $table->windowConfigure
	(
	 "$row,$col",
	 -window => $button2,
	 -sticky => 'nsew',
	);
    } else {
      print "$row,$col\n";
      my $copy = $entry;
      chomp $copy;
      print Dumper({Copy => $copy});
      $table->set("$row,$col", $copy);
    }
    ++$col;
  }
  ++$row;
}

MainLoop();

sub Accept {
  my %args = @_;
  print Dumper({Args => \%args});
  # assert into the KB the rule as given by the system
  print Dumper();
  my $logic = $itemsdb->{$args{Entry}}->{logic};
  if (exists $logic->{assert}) {
    my $assertion = $logic->{assert};
    $assertion =~ s/^\s+//s;
    $assertion =~ s/\s+$//s;
    my $res = $importexport->Convert
      (
       InputType => "KIF String",
       OutputType => "Interlingua",
       Input => $assertion,
      );
    print Dumper($res);
    # assert into the DB
    if ($res->{Success}) {
      my $res2 = $client->Send
	(
	 QueryAgent => 1,
	 Assert => $res->{Output},
	 InputType => "Interlingua",
	);
    }
  }
}

# keep a data structure of the various items they subscribe too

# assert into the DB when they agree with an item

sub VerifyCryptoSignature {
  
}
