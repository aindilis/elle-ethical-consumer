package RapidResponse::Application::FollowUp;

# ("created-by" "PPI-Convert-Script-To-Module")

use Manager::Dialog qw(Approve ApproveCommands Message SubsetSelect);
use PerlLib::SwissArmyKnife;

use DateTime;
use DateTime::Duration;
use DateTime::Format::Duration;
use DateTime::Format::MySQL;
use File::Temp qw(tempdir);
use FileHandle;
use Text::Levenshtein qw(distance);
use Text::Wrap;
use Tk;
use Tk::BrowseEntry;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Entry Box RSSFile Scroll ScrollFrame Top1 MyMainWindow
   InitialConditions Fields1 Fields2 Order1 Order2 TopLevel Debug
   MyConfiguration /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $self->Entry($args{Entry});
  $self->RSSFile();
  $self->InitialConditions({});
  $self->ManageEntry;
}

sub ManageEntry {
  my ($self,%args) = @_;
  $self->MyConfiguration
    ($UNIVERSAL::rapidresponse->MyConfiguration);
  $self->TopLevel
    ($UNIVERSAL::rapidresponse->MyResources->MyMainWindow->Toplevel
     (
      -title => $self->Entry->{title},
      -height => 600,
      -width => 800,
     ));

  my $defaultfollowuplettertext = $self->MyConfiguration->CurrentProfile->{templates}->{"default-followup-letter"}->{defaultfollowupletter};

  # have a set of text boxes to display the common information

  # go ahead and display everything, add buttons for submitting the
  # job

  # populate the default letter

  # have a few different templates for different types of jobs

  # rate job similarity using existing job search stuff

  # auto attach resumes

  # also record the job application to the database
  $self->Order1
    ([
      "title",
      "link",
      "description",
      "dc:date",
      "dc:language",
      "dc:rights",
      "dc:source",
      # "dc:title",
      "dc:type",
      "dcterms:issued",
     ]);
  $self->Fields1
    ({
      "title" => {
		  Type => "small",
		 },
      "link" => {
		 Type => "small",
		},
      "description" => {
			Type => "large",
		       },
      "dc:date" => {
		    Type => "small",
		   },
      "dc:language" => {
			Type => "small",
		       },
      "dc:rights" => {
		      Type => "small",
		     },
      "dc:source" => {
		      Type => "small",
		     },
      "dc:title" => {
		     Type => "small",
		    },
      "dc:type" => {
		    Type => "small",
		   },
      "dcterms:issued" => {
			   Type => "small",
			  },
     });

  my $fieldframes = $self->TopLevel->Frame()->pack(-side => "left");
  foreach my $field (@{$self->Order1}) {
    my $var;
    if ($field eq "description") {
      my $res = $UNIVERSAL::rapidresponse->MyResources->MyToText->ToText
	(
	 String => $self->Entry->{$field},
	);
      if ($res->{Success}) {
	$var = $res->{Text};
      } else {
	$var = $self->Entry->{$field};
      }
    } else {
      $var = $self->Entry->{$field};
    }
    $self->Fields1->{$field}->{EntryText} = \$var;
    my $fieldframe = $fieldframes->Frame();
    $fieldframe->Label
      (
       -text => $field,
      )->pack(-side => 'left');
    if ($self->Fields1->{$field}->{Type} eq "large") {
      my $text = $fieldframe->Text
	(
	 -width => 80,
	 -height => 30,
	);
      # render this to text
      $self->InitialConditions->{$field} = ${$self->Fields1->{$field}->{EntryText}};
      $fields->{$field}->{Text} = $text;
      $text->Contents(${$self->Fields1->{$field}->{EntryText}});
      $text->pack(-side => 'right');
      if ($field eq "description") {
	$UNIVERSAL::rapidresponse->MyResources->MyMarkup->MarkupText
	  (
	   Text => $text,
	  );
      }
    } else {
      $fieldframe->Entry
	(
	 -width => length(${$self->Fields1->{$field}->{EntryText}}),
	 -textvariable => $self->Fields1->{$field}->{EntryText},
	)->pack(-side => 'right');
    }
    $fieldframe->pack
      (-side => "top");
  }

  ########################################

  my $textframes = $self->TopLevel->Frame();

  # ahead and add a drop down selector for different configurations
  # $textframes->DropDownMenu;

#   my $dropdown_value;
#   my $dropdown = $textframes->BrowseEntry
#     (
#      -variable => \$dropdown_value,
#      -width => 80,
#     )->pack;

#   # Configure dropdown
#   $dropdown->configure
#     (
#      # What to do when an entry is selected
#      -browsecmd => sub {
#        print Dumper([$dropdown_value]);
#        $dropdown_value = "";
#      },
#     );
#   $dropdown->bind
#     (
#      '<Return>' => sub {
#        print Dumper([$dropdown_value]);
#        $dropdown_value = "";
#      },
#     );

#   my @items = ("Resume", "Resume with Cover Letter");

#   # Populate dropdown with values
#   foreach my $sampletask (@items) {
#     $dropdown->insert('end',$sampletask);
#   }

  $self->Order2
    ([
      "To:",
      "Cc:",
      "Bcc:",
      "Subject:",
      "From:",
      # "Fcc: +backup",
      "Body",
      "Cover",
     ]);
  $self->Fields2
    ({
      "To:" => {
		Type => "small",
		Default => $self->Entry->{"dc:source"},
	       },
      "Cc:" => {
		Type => "small",
		Default => "",
	       },
      "Bcc:" => {
		 Type => "small",
		 Default => "",
		},
      "Subject:" => {
		     Type => "small",
		     Default => "Following Up Re: ".$self->Entry->{title},
		    },
      "From:" => {
		  Type => "small",
		  Default => $self->MyConfiguration->ProfileEmailAddress,
		 },
      "Body" => {
		 Type => "large",
		 Default => $defaultfollowuplettertext,
		},
     });
  foreach my $field (@{$self->Order2}) {
    my $var;
    if ($field eq "Body" or $field eq "Cover") {
      my $t = $self->Fields2->{$field}->{Default};
      my $position = $self->Entry->{title};
      my $url = $self->Entry->{"dc:source"};
      $t =~ s/<POSITION>/$position/g;
      $t =~ s/<POSTSCRIPTUM>/This is in response to:\n$url/g;
      $var = $t;
    } elsif ($field eq "To:") {
      # have to retrieve the webpage and extract the email
      my $url = $self->Entry->{"dc:source"};
      $UNIVERSAL::rapidresponse->MyResources->MyCacher->get($url);
      my $content = $UNIVERSAL::rapidresponse->MyResources->MyCacher->content;
      my $email = "";
      if ($content =~ /Reply to: <[^>]+?>(.+?)<\/a>/s) {
	$email = $1;
      }
      print Dumper
	({
	  Url => $url,
	  # Content => $content,
	  Email => $email,
	 }) if 0;
      $var = $email;
    } else {
      $var = $self->Fields2->{$field}->{Default};
    }

    $self->Fields2->{$field}->{EntryText} = \$var;
    my $fieldframe = $textframes->Frame();
    $fieldframe->Label
      (
       -text => $field,
      )->pack(-side => 'left');
    if ($self->Fields2->{$field}->{Type} eq "large") {
      my $text = $fieldframe->Text
	(
	 -width => 80,
	 -height => 15,
	 -wrap => "word",
	);
      # render this to text
      $self->InitialConditions->{$field} = ${$self->Fields2->{$field}->{EntryText}};
      $self->Fields2->{$field}->{Text} = $text;
      $text->Contents(${$self->Fields2->{$field}->{EntryText}});
      $text->pack(-side => 'right');
    } else {
      $fieldframe->Entry
	(
	 -width => length(${$self->Fields2->{$field}->{EntryText}}),
	 -textvariable => $self->Fields2->{$field}->{EntryText},
	)->pack(-side => 'right');
    }
    $fieldframe->pack
      (-side => "top");
  }

  my $buttonframe2 = $textframes->Frame();
  $buttonframe2->Button
    (
     -text => "Cancel",
     -command => sub {
       # verify cancellation and then close out of top2
       # check whether the text fields have been changed from their defaults

       if (Approve("Cancel Follow-Up?")) {
	 $self->TopLevel->destroy();
       }
     },
    )->pack(-side => "right");
  $buttonframe2->Button
    (
     -text => "Ignore",
     -command => sub {
       $self->IgnoreFollowUp;
     },
    )->pack(-side => "right");
  $buttonframe2->Button
    (
     -text => "Submit Follow-Up",
     -command => sub {
       $self->SubmitFollowUp;
     },
    )->pack(-side => "right");
  $buttonframe2->pack
    (-side => "top");
  $textframes->pack(-side => "right");
}

sub SubmitFollowUp {
  my ($self,%args) = @_;

  # stuff that we need even if we are just pretending to send
  my $from = $self->MyConfiguration->ProfileEmailAddress;
  my $to = ${$self->Fields2->{'To:'}->{EntryText}};
  my $subject = ${$self->Fields2->{'Subject:'}->{EntryText}};

  # get the text of the followup letter
  my $emailtext = $self->Fields2->{'Body'}->{Text}->Contents;

  my $res = $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Do
    (
     Statement => "select ID,Directory from metadata where Entry_ID=".$self->Entry->{ID}.";",
    );
  my $key = [keys %$res]->[0];
  my $dir = $res->{$key}->{Directory};

  if (! -d $dir) {
    die "Error no such dir: <$dir>\n";
  }

  if ($UNIVERSAL::rapidresponse->Conf->{'-a'}) {
    foreach my $field (qw(Body)) {
      my $a = $self->InitialConditions->{$field};
      my $b = $self->Fields2->{$field}->{Text}->Contents;
      my $distance = distance($a, $b);
      if ($distance < 10) {
	Message(Message => "Field $field has not been sufficiently modified, refusing to send\n");
	return;
      }
    }

    # generate the email text
    my $emailfile = "$dir/followup.txt";
    my $fh2 = IO::File->new;
    $fh2->open(">$emailfile");
    print $fh2 wrap("", "", $emailtext);
    $fh2->close();

    # finally send the email
    my $command = "mutt -s ".shell_quote($subject)." -- ".shell_quote($to)." < $emailfile";
    if (ApproveCommands
	(
	 Commands => [$command],
	 Method => "parallel",
	)) {
      # print "<$command>\n";
      my $data = $self->SetIRT;
      $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Do
	(
	 Statement => "update metadata set Status=\"followed-up\" where Entry_ID=".$self->Entry->{ID}.";",
	);
      $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Insert
	(
	 Table => "history",
	 Values => [
		    undef,
		    $self->Entry->{ID},
		    "followed-up",
		    $data->{ResponseTime},
		   ],
	);
    }
  }

  # need to refresh the main display
  $UNIVERSAL::rapidresponse->RefreshDisplay();
  $self->TopLevel->destroy();
}

sub IgnoreFollowUp {
  my ($self,%args) = @_;
  # my $data = $self->SetIRT();
  $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Do
    (
     Statement => "update metadata set Status=\"ignored\" where Entry_ID=".$self->Entry->{ID}.";",
    );
  # need to refresh the main display
  $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Insert
    (
     Table => "history",
     Values => [
		undef,
		$self->Entry->{ID},
		"ignored",
		$data->{ResponseTime},
	       ],
    );

  $UNIVERSAL::rapidresponse->RefreshDisplay();
  $self->TopLevel->destroy();
}

sub SetIRT {
  my ($self,%args) = @_;
  my $postedtime = ${$self->Fields1->{'dc:date'}->{EntryText}};
  my $postedtimedt;
  if ($postedtime =~ /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/) {
    my $year = $1;
    my $month = $2;
    my $day = $3;
    my $hour = $4;
    my $minute = $5;
    my $second = $6;
    $postedtimedt = DateTime->new
      (
       year => $year,
       month => $month,
       day => $day,
       hour => $hour,
       minute => $minute,
       second => $second,
       time_zone => "America/Chicago",
      );
  }
  my $responsetimedt = DateTime->from_epoch
    (
     epoch => time,
    );
  my $responsetime = DateTime::Format::MySQL->format_datetime($responsetimedt);
  my $irtduration = $responsetimedt - $postedtimedt;
  my $irt = $UNIVERSAL::rapidresponse->MyResources->DateTimeDurationFormatter->format_duration($irtduration);
  $UNIVERSAL::rapidresponse->MyResources->MyMySQL->Do
    (
     Statement => "update metadata set IRT=\"$irt\" where Entry_ID=".$self->Entry->{ID}.";",
    );
  return {
	  ResponseTime => $responsetime,
	 };
}

1;

