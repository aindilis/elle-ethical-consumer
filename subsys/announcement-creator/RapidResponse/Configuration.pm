package RapidResponse::Configuration;

use Manager::Dialog qw(Approve ApproveCommands Choose Message QueryUser SubsetSelect);
use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;

use Config::General;
use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Top1 Verbose Data MyConfig CurrentProfile MyMainWindow Fields /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMainWindow($args{MainWindow});
  $self->Verbose($args{Verbose} || 0);
  # use the data
  $self->MyConfig
    (Config::General->new
     (  $self->FindConfigFile));
  $self->Data
    ($args{Data} ||
     {
      Source => "unilang",
      Name => "new-entry",
      Description => "Sample entry",
     });
  $self->CurrentProfile($args{Profile});

  # when you do what you need to do when it needs to be done, then you
  # can do what you want to do when you want to"
}

sub FindConfigFile {
  my ($self,%args) = @_;
  my @files =
    (
     $ENV{HOME}."/.config/frdcsa/js-rapid-response.conf",
     $ENV{HOME}."/.js-rapid-response.conf",
    );
  foreach my $file (@files) {
    if (-f $file) {
      return $file;
    } else {
      print "no $file\n";
    }
  }
  die "No config file found!\n";
}

sub SelectProfile {
  my ($self,%args) = @_;
  my %profiles = $self->MyConfig->getall;
  my @profiles = keys %{$profiles{profiles}};
  my $profilename = Choose(@profiles);
  my $profile = $profiles{profiles}{$profilename};
  $self->CurrentProfile($profile);
}

sub EditProfile {
  my ($self,%args) = @_;
  my $profile = $self->CurrentProfile();
  $self->Top1
    ($self->MyMainWindow->Toplevel
     (
      -title => "Edit Profile",
      -height => 600,
      -width => 800,
     ));
  my @order = ("URL", "Name","Response Directory","IMAP Hostname","IMAP Username",
	       "IMAP Password","DB Hostname","DB Name", "DB Username",
	       "DB Password","Resumes","Default Letter",
	       "Default Cover Letter");
  my $fields =
    {
     "URL" => {
		Description => "The URL to update",
		Args => ["mediumtext"],
		TextVar => $profile->{url},
	       },
     "Name" => {
		Description => "The applicant's name",
		Args => ["tinytext"],
		TextVar => $profile->{name},
	       },
     "Response Directory" => {
			      Description => "The directory where new responses are to be generated",
			      Args => ["mediumtext"],
			      TextVar => $profile->{responsedir},
			     },
     "IMAP Hostname" => {
		    Description => "Hostname of the IMAP mail server",
		    Args => ["tinytext"],
		    TextVar => $profile->{mail}->{hostname},
		   },
     "IMAP Username" => {
		    Description => "Username for the IMAP account",
		    Args => ["tinytext"],
		    TextVar => $profile->{mail}->{username},
		   },
     "IMAP Password" => {
		    Description => "Password for the IMAP account",
		    Args => ["tinytext"],
		    TextVar => $profile->{mail}->{password},
		   },
     "DB Hostname" => {
		    Description => "Hostname of the database server",
		    Args => ["tinytext"],
		    TextVar => $profile->{database}->{hostname},
		   },
     "DB Name" => {
		    Description => "Name of the database",
		    Args => ["tinytext"],
		    TextVar => $profile->{database}->{dbname},
		   },
     "DB Username" => {
		    Description => "Username for the database account",
		    Args => ["tinytext"],
		    TextVar => $profile->{database}->{username},
		   },
     "DB Password" => {
		    Description => "Password for the database account",
		    Args => ["tinytext"],
		    TextVar => $profile->{database}->{password},
		   },
     "Resumes" => {
		   Description => "The resume files",
		   Args => ["text"],
		   TextVar => $profile->{resumes}->{files},
		  },
     "Default Letter" => {
			  Description => "The template of the text of the email to be sent",
			  Args => ["text"],
			  TextVar => $profile->{templates}->{"default-letter"}->{defaultletter},
			 },
     "Default Cover Letter" => {
				Description => "The template of the cover letter to be sent",
				Args => ["text"],
				TextVar => $profile->{templates}->{"default-cover-letter"}->{defaultcoverletter},
			       },
    };
  $self->Fields($fields);

  $options = $self->Top1->Frame();
  foreach my $field (@order) {
    if (! exists $fields->{$field}->{Args}) {
      $options->Checkbutton
	(
	 -text => $field,
	 -command => sub { },
	)->pack(-fill => "x");	# , -anchor => 'left');
    } else {
      my $frame = $options->Frame(-relief => 'raised', -borderwidth => 2);
      my @items;
      foreach my $arg2 (@{$fields->{$field}->{Args}}) {
	my $ref = ref $arg2;
	if ($ref eq "ARRAY") {
	  # skip for now
	  $options->Checkbutton
	    (
	     -text => $field,
	     -command => sub { },
	    )->pack(-fill => "x");
	} elsif ($ref eq "") {
	  my $state;
	  if ($fields->{$field}->{Normal}) {
	    $state = "normal";
	  } else {
	    $state = "disabled";
	  }
	  if ($arg2 eq "tinytext") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->Entry
	      (
	       -state => 'disabled',
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -textvariable => \$fields->{$field}->{TextVar},
	       -width        => 25,
	      );
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } elsif ($arg2 eq "text") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => $state,
	      );
	    my $width = 80;
	    my $height = 5;
	    if (exists $fields->{$field}->{Size}) {
	      $width = $fields->{$field}->{Size}->[0];
	      $height = $fields->{$field}->{Size}->[1];
	    }
	    my $name = $frame2->Text
	      (
	       -relief       => 'sunken',
	       -borderwidth  => 2,
	       -width        =>  $width,
	       -height        => $height,
	      );
	    $name->Contents($fields->{$field}->{TextVar});
	    $name->configure(-state => $state);
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } elsif ($arg2 eq "function") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );
	    my $name = $frame2->Button
	      (
	       -text => $field,
	       -command => sub {$self->Fields->{$field}->{Function}->()},
	      );
	    $name->configure(-state => $state);
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } elsif ($arg2 eq "dropdown") {
	    my $frame2 = $frame->Frame();
	    my $nameLabel = $frame2->Label
	      (
	       -text => $field,
	       -state => 'disabled',
	      );

	    my $name = $frame2->BrowseEntry
	      (
	       -variable => \$fields->{$field}->{TextVar},
	       -width => $fields->{$field}->{Width} || 25,
	      )->pack;
	    $name->configure(-state => $state);
	    # Configure dropdown
	    $name->configure
	      (
	       # What to do when an entry is selected
	       -browsecmd => $self->Fields->{$field}->{Function},
	      );
	    $name->bind
	      (
	       '<Return>' => $self->Fields->{$field}->{Function},
	      );
	    foreach my $option (@{$self->Fields->{$field}->{Options}}) {
	      $name->insert('end',$option);
	    }
	    push @items, {
			  frame => $frame2,
			  nameLabel => $nameLabel,
			  name => $name,
			 };
	    $nameLabel->pack(-side => 'left');
	    $name->pack(-side => 'right');
	    # $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
	    $self->Fields->{$field}->{Widget} = $name;
	    if ($self->Fields->{$field}->{TakeFocus}) {
	      $name->focus;
	    }
	  } else {
	    # print Dumper({Huh => $arg2});
	  }
	}
      }
      my $checkbutton = $frame->Checkbutton
	(
	 -text => $field,
	 -command => sub {
	   foreach my $item (@items) {
	     if ($item->{name}->cget('-state') eq 'disabled') {
	       $item->{name}->configure(-state => "normal");
	       $item->{nameLabel}->configure(-state => "normal");
	     } else {
	       $item->{name}->configure(-state => "disabled");
	       $item->{nameLabel}->configure(-state => "disabled");
	     }
	   }
	 },
	);
      if ($fields->{$field}->{Normal}) {
	$checkbutton->{'Value'} = 1;
      } else {
	$checkbutton->{'Value'} = 0;
      }

      $checkbutton->pack(-fill => "x");
      foreach my $item (@items) {
	$item->{frame}->pack;
      }
      $frame->pack();
    }
  }
  $options->pack;

#   $options = $self->Top1->Frame();
#   foreach my $field (@order) {
#     if (! exists $fields->{$field}->{Args}) {
#       $options->Checkbutton
# 	(
# 	 -text => $field,
# 	 -command => sub { },
# 	)->pack(-fill => "x");
#     } else {
#       my $frame = $options->Frame(-relief => 'raised', -borderwidth => 2);
#       my @items;
#       foreach my $arg2 (@{$fields->{$field}->{Args}}) {
# 	my $ref = ref $arg2;
# 	if ($ref eq "ARRAY") {
# 	  $options->Checkbutton
# 	    (
# 	     -text => $field,
# 	     -command => sub { },
# 	    )->pack(-fill => "x");
# 	} elsif ($ref eq "") {
# 	  if ($arg2 eq "tinytext") {
# 	    my $frame2 = $frame->Frame();
# 	    my $nameLabel = $frame2->Label
# 	      (
# 	       -text => $field,
# 	      );
# 	    my $name = $frame2->Entry
# 	      (
# 	       -relief       => 'sunken',
# 	       -borderwidth  => 2,
# 	       -textvariable => \$fields->{$field}->{TextVar},
# 	       -width        => 25,
# 	      );
# 	    push @items, {
# 			  frame => $frame2,
# 			  nameLabel => $nameLabel,
# 			  name => $name,
# 			 };
# 	    $nameLabel->pack(-side => 'left');
# 	    $name->pack(-side => 'right');
# 	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
# 	  } elsif ($arg2 eq "mediumtext") {
# 	    my $frame2 = $frame->Frame();
# 	    my $nameLabel = $frame2->Label
# 	      (
# 	       -text => $field,
# 	      );
# 	    my $name = $frame2->Entry
# 	      (
# 	       -relief       => 'sunken',
# 	       -borderwidth  => 2,
# 	       -textvariable => \$fields->{$field}->{TextVar},
# 	       -width        => 80,
# 	      );
# 	    push @items, {
# 			  frame => $frame2,
# 			  nameLabel => $nameLabel,
# 			  name => $name,
# 			 };
# 	    $nameLabel->pack(-side => 'left');
# 	    $name->pack(-side => 'right');
# 	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
# 	  } elsif ($arg2 eq "text") {
# 	    my $frame2 = $frame->Frame();
# 	    my $nameLabel = $frame2->Label
# 	      (
# 	       -text => $field,
# 	      );
# 	    my $name = $frame2->Text
# 	      (
# 	       -relief       => 'sunken',
# 	       -borderwidth  => 2,
# 	       -width        => 80,
# 	       -height        => 5,
# 	      );
# 	    $name->Contents($fields->{$field}->{TextVar});
# 	    push @items, {
# 			  frame => $frame2,
# 			  nameLabel => $nameLabel,
# 			  name => $name,
# 			 };
# 	    $nameLabel->pack(-side => 'left');
# 	    $name->pack(-side => 'right');
# 	    $name->bind('<Return>' => [ $middle, 'color', Ev(['get'])]);
# 	  } else {
# 	    # print Dumper({Huh => $arg2});
# 	  }
# 	}
#       }
#       foreach my $item (@items) {
# 	$item->{frame}->pack;
#       }
#       $frame->pack();
#     }
#   }
#   $options->pack;

  $buttons = $self->Top1->Frame();
  #   $buttons->Button
  #     (
  #      -text => "Defaults",
  #      -command => sub { },
  #     )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Save Configuration",
     -command => sub {  },
    )->pack(-side => "left");
  $buttons->Button
    (
     -text => "Cancel",
     -command => sub { $self->Top1->destroy; },
    )->pack(-side => "right");
  $buttons->pack;
}

sub ExecuteCommand {
  my ($self,%args) = @_;
  # get all the options, and run them
  # print join(" ",@args)."\n";
  # iterate over all the frames contained here
  foreach my $child ($self->Top1->children) {
    print Dumper($child);
  }
}

sub ProfileEmailAddress {
  my ($self,%args) = @_;
  return $self->CurrentProfile->{name}." <".
    $self->CurrentProfile->{mail}->{username}."@".
      $self->CurrentProfile->{mail}->{hostname}.">";
}

sub GetValueForField {
  my ($self,%args) = @_;
  my $field = $args{Field};
  # we have to carefully figure out now which one it is, I guess we
  # can no longer use the heuristic that if it has a widget, then it
  # has a Contents.  how do you check for whether a given item has a
  # contents, let's just check the widget's class and if it is in a
  # class that uses it, like Tk::Entry, then just use that

  if (exists $self->Fields->{$field}->{Widget}) {
    my $class = ref $self->Fields->{$field}->{Widget};
    if ($class =~ /^Tk::(Text)$/) {
      return $self->Fields->{$field}->{Widget}->Contents;
    }
  }
  if (exists $self->Fields->{$field}->{TextVar}) {
    return $self->Fields->{$field}->{TextVar};
  }
}
1;
