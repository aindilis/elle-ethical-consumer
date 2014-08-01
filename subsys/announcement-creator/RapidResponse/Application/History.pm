package RapidResponse::Application::History;

use Manager::Dialog qw(Approve ApproveCommands Message SubsetSelect);
use PerlLib::SwissArmyKnife;

use DateTime;
use DateTime::Duration;
use DateTime::Format::MySQL;
use Tk::TableMatrix;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / TopLevel TableFrame /

  ];

sub init {
  my ($self,%args) = @_;
}

sub Execute {
  my ($self,%args) = @_;
  $self->TopLevel
    ($UNIVERSAL::rapidresponse->MyResources->MyMainWindow->Toplevel
     (
      -title => "Application History",
      -height => 600,
      -width => 800,
     ));
  $self->TableFrame
    ($self->TopLevel->Frame());
  $self->TableFrame->pack
    (-fill => "both", -expand => 1);
}

sub RefreshDisplay {
  my ($self,%args) = @_;
  if (scalar $self->TableFrame->children) {
    $self->TableFrame->children->[0]->destroy;
  }
  my @keys = qw(Entry_ID title);
  my @additional = qw(Status);
  my $propername = {
		    Entry_ID => "ID",
		    title => "Title",
		    Status => "Status",
		   };
  my $statement = "select m.Entry_ID, e.title from metadata m, entries e where Status=\"their turn\" and e.ID = m.Entry_ID";
  my $res1 = $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Do
    (
     Statement => $statement,
     KeyField => "Entry_ID",
    );
  my $numberofrows = scalar keys %$res1;
  my $table = $self->TableFrame->Scrolled
    (
     "TableMatrix",
     # -resizeborders => 'none',
     -titlerows => 1,
     -rows => ($numberofrows + 1),
     -colstretchmode => 'all',
     -cols => ((scalar @keys) + (scalar @additional)),
     -cache => 1,
     -scrollbars => "osoe",
    );
  # add some other stuff for other fields as needed
  my $col2 = 0;
  foreach my $fieldname (@keys) {
    # $table->insertCols("$col2.0", 1);
    $table->set("0,$col2", $propername->{$fieldname});
    ++$col2;
  }
  $table->colWidth(1, 20);
  $table->colWidth(2, 60);
  $table->colWidth(3, 20);
  my $row = 1;
  # sort by date first of all, not by number as if we use a limited format...  ID cannot be important
  foreach my $key (sort {$res1->{$b}->{Entry_ID} <=> $res1->{$a}->{Entry_ID}} keys %$res1) {
    my $col3 = 0;
    foreach my $fieldname (@keys) {
      $table->set("$row,$col3", $res1->{$key}->{$fieldname});
      ++$col3;
    }
    foreach my $fieldname (@additional) {
      my $id = $UNIVERSAL::rapidresponse->EntryIDs->{$key};
      if ($fieldname eq "Status") {
	# set the color based on the status
	my $status = $UNIVERSAL::rapidresponse->Res2->{$id}->{$fieldname};
	my $color = $UNIVERSAL::rapidresponse->Statuses->{$status}->{Color};
	# set the color based on the status
	my $button = $table->Button
	  (
	   -text => $status,
	   -background => $color,
	   -command => sub {
	     $UNIVERSAL::rapidresponse->PerformStateTransition
	       (
		Key => $key,
		Status => $status,
	       );
	   },
	  );
	$table->windowConfigure
	  (
	   "$row,$col3",
	   -window => $button,
	   -sticky => 'nsew',
	  );
      }
    }
    ++$row;
  }
  $table->pack
    (
     -expand => 1,
     -fill => 'both',
    );
  my $buttonframe = $self->TopLevel->Frame();
  $buttonframe->Button
    (
     -text => "Close",
     -command => sub {
       # if (Approve("Close Application History?")) {
       $self->TopLevel->destroy;
       $self->DESTROY;
       # }
     },
    )->pack(-side => "left");
  $buttonframe->pack
    (-side => "bottom");
}

sub DESTROY {
  my ($self,%args) = @_;
  $UNIVERSAL::rapidresponse->MyHistory(undef);
}

1;



