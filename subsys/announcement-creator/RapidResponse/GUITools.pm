package RapidResponse::GUITools;

use Time::HiRes qw(usleep);
use Tk qw(DoOneEvent DONT_WAIT);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw /  /

  ];

sub init {
  my ($self,%args) = @_;
}

sub MyMainLoop {
  my ($self,%args) = @_;
  $self->MyMainWindow->repeat
    (
     50,
     sub {
       $self->AgentListen(),
     },
    );
  MainLoop();
}

sub AgentListen {
  my ($self,%args) = @_;
  # UniLang::Agent::Agent
  # print ".\n";
  $self->MyTempAgent->MyAgent->Listen
    (
     TimeOut => 0.05,
    );
}

1;


sub MyMainLoop {
  my ($self,%args) = @_;
  print "Hi\n";
  $self->MyMainWindow->repeat
    (
     $args{TimeOut},
     sub {
       $continueloop = 0;
     },
    );
  unless ($inMainLoop) {
    local $inMainLoop = 1;
    $continueloop = 1;
    while ($continueloop) {
      # for my $i (1..30) {
      DoOneEvent();
      # }
      if (0) {
	$self->AgentListen
	  (
	   Timeout => int($args{TimeOut} / 10),
	  );
      }
    }
  }
}

sub AgentListen {
  my ($self,%args) = @_;
  if ($UNIVERSAL::agent->RegisteredP) {
    $UNIVERSAL::agent->Listen
      (
       TimeOut => $args{TimeOut} || 0.05,
      );
  }
}


sub Listen {
  my ($self,%args) = @_;
  # print "Hi\n";
  my $count = 0;
  unless ($inMainLoop) {
    local $inMainLoop = 1;
    $continueloop = 1;
    while ($continueloop) {
      DoOneEvent(DONT_WAIT);
      usleep 1000;
      if (0) {
	$self->AgentListen
	  (
	   Timeout => int($args{TimeOut} / 10),
	  );
      }
      ++$count;
      if ($count > 10) {
	$continueloop = 0;
      }
    }
  }
}
