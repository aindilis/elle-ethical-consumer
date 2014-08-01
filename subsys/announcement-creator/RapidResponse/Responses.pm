package RapidResponse::Responses;

use Manager::Dialog qw(Approve ApproveCommands Message SubsetSelect QueryUser );
use PerlLib::SwissArmyKnife;

use Net::IMAP::Client;
use Tk::TableMatrix;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMainWindow TopLevel TableFrame MyIMAP MyConfiguration /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow
    ($UNIVERSAL::rapidresponse->Top1);
  $self->MyConfiguration
    ($UNIVERSAL::rapidresponse->MyConfiguration);
  my %imapargs =
    (
     server => $self->MyConfiguration->CurrentProfile->{mail}->{hostname},
     user   => $self->MyConfiguration->CurrentProfile->{mail}->{username},
     pass   => $self->MyConfiguration->CurrentProfile->{mail}->{password},
     ssl    => 1,
    );
  $self->MyIMAP
    (Net::IMAP::Client ->new
     (
      %imapargs
     )) or die "Could not connect to IMAP server";
  $self->MyIMAP->login or
    die('Login failed: ' . $self->MyIMAP->last_error);
  $self->MyIMAP->select('INBOX');
}

sub Execute {
  my ($self,%args) = @_;
  if ($args{Check}) {
    # see if the latest INBOX ID is different
    return $self->MyIMAP->fetch('*', 'UID')->{UID};
  } else {
    $self->TopLevel
      ($self->MyMainWindow->Toplevel
       (
	-title => "Responses",
	-height => 600,
	-width => 800,
       ));
    $self->TableFrame
      ($self->TopLevel->Frame());
    $self->TableFrame->pack
      (-fill => "both", -expand => 1);
  }
}

sub RefreshDisplay {
  my ($self,%args) = @_;
  if (scalar $self->TableFrame->children) {
    $self->TableFrame->children->[0]->destroy;
  }
  my @messages = $self->MyIMAP->search('ALL');
  my $summaries = $self->MyIMAP->get_summaries($messages[0]);
  my $numberofrows = scalar @$summaries;
  my @keys = qw(uid subject date from);
  my $propername =
    {
     uid => "ID",
     subject => "Subject",
     date => "Date",
     from => "From",
    };
  my $table = $self->TableFrame->Scrolled
    (
     "TableMatrix",
     # -resizeborders => 'none',
     -titlerows => 1,
     -rows => ($numberofrows + 1),
     -colstretchmode => 'all',
     -cols => (scalar @keys),
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
  my $row = 1;
  # sort by date first of all, not by number as if we use a limited format...  ID cannot be important
  foreach my $entry (@$summaries) {
    my $col3 = 0;
    foreach my $fieldname (@keys) {
      $table->set("$row,$col3", $entry->{$fieldname});
      ++$col3;
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
       # if (Approve("Close Responses?")) {
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
  $UNIVERSAL::rapidresponse->MyResponses(undef);
}

1;
