package Com::elle::BLeaf::Creator;

use BOSS::Config;
use Manager::Dialog qw(Approve ApproveCommands);
use MyFRDCSA qw(ConcatDir);
use PerlLib::SwissArmyKnife;

use Tk;
use Tk::TableMatrix;
use XML::Simple;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf Top1 TopFrame ThresholdFrame TableFrame /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = q(
	-g		Generate a new proclamation
	-a <url>	Analyze URL for Boycott calls
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf
    ($self->Config->CLIConfig);
  $conf = $self->Conf;

  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::agent->Register
    (Host => defined $conf->{-u}->{'<host>'} ?
     $conf->{-u}->{'<host>'} : "localhost",
     Port => defined $conf->{-u}->{'<port>'} ?
     $conf->{-u}->{'<port>'} : "9000");

  $self->Top1
    (MainWindow->new
     (
      -title => "BLeaf Proclamation Creator",
      -height => 600,
      -width => 800,
     ));

  $UNIVERSAL::managerdialogtkwindow = $self->Top1;
  $self->TopFrame($self->Top1->Frame());
  $self->ThresholdFrame($self->TopFrame->Frame);
}

sub Execute {
  my ($self,%args) = @_;
  $frame = $self->Top1->Frame(-relief => 'flat');
  $frame->pack(-side => 'top', -fill => 'x', -anchor => 'center');
  $menu = $self->Top1->Frame(-relief => 'raised', -borderwidth => '1');
  $menu->pack(-before => $frame, -side => 'top', -fill => 'x');
  $menu_file_1 = $menu->Menubutton
    (
     -text => 'File',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_file_1->command
    (
     -label => "Update",
     -command => sub {
       $self->UpdateDatabaseFromRSSFeed();
     },
    );
  $menu_file_1->command
    (
     -label => "Refresh",
     -command => sub {
     },
    );
  $menu_file_1->command
    (
     -label => "Truncate DB",
     -command => sub {
       $self->TruncateDB();
     },
    );
  $menu_file_1->command
    (
     -label => 'Exit',
     -command => sub {
       $self->Exit();
     },
     -underline => 0,
    );
  $menu_file_1->pack
    (
     -side => 'left',
    );

  $menu_file_2 = $menu->Menubutton
    (
     -text => 'View',
     -tearoff => 0,
     -underline => 0,
    );
  $menu_file_2->command
    (
     -label => 'Configuration',
     -command => sub {
       # load the profile of all the different
       $self->EditConfiguration();
     },
     -underline => 0,
    );
  $menu_file_2->command
    (
     -label => 'Application History',
     -command => sub {
       # load the profile of all the different
       $self->ShowHistory();
     },
     -underline => 0,
    );
  $menu_file_2->command
    (
     -label => 'Responses',
     -command => sub {
       $self->ShowResponses();
     },
     -underline => 0,
    );
  $menu_file_2->pack
    (
     -side => 'left',
    );

  $self->ThresholdFrame->pack
    (
     -side => "right",
    );
  $self->TopFrame->pack(-side => "top");
  $self->TableFrame
    ($self->Top1->Frame());
  $self->TableFrame->pack(-fill => "both", -expand => 1);
  $self->MyMainLoop;
}

sub Exit {
  my ($self,%args) = @_;
  if (Approve("Exit Program?")) {
    exit(0);
  }
}

sub Checks {
  my ($self,%args) = @_;
}


sub MyMainLoop {
  my ($self,%args) = @_;
  $self->Top1->repeat
    (
     50,
     sub {
       $self->AgentListen(),
     },
    );
  $self->Top1->repeat
    (
     60 * 60 * 1000,
     sub {
       $self->Checks(),
     },
    );
  MainLoop();
}

sub AgentListen {
  my ($self,%args) = @_;
  # UniLang::Agent::Agent
  # print ".\n";
  $UNIVERSAL::agent->Listen
    (
     TimeOut => 0.05,
    );
}

1;
