package RapidResponse::Application::Markup;

use Capability::NER;
use PerlLib::SwissArmyKnife;

use URI::Escape;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Debug Items Counter MyNER /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $self->Items({});
  $self->MyNER
    (Capability::NER->new
     (
      Engine => "Stanford",
     ));
}

sub MarkupText {
  my ($self,%args) = @_;
  # go ahead and find all phone numbers
  $self->Items({});
  my $text = $args{Text};
  my $c = $text->Contents;
  $self->MarkupPhoneNumbers
    (
     Contents => $c,
    );
  $self->MarkupOrganizations
    (
     Contents => $c,
    );
  $self->ProcessMarkup
    (
     Contents => $c,
     Text => $text,
    );
}

sub MarkupPhoneNumbers {
  my ($self,%args) = @_;
  my $contents = $args{Contents};
  my @phonenumbers = $contents =~ /(((.(\d\d\d).|(\d\d\d)).)?(\d{3}).(\d{4}))/sg;
  print Dumper(\@phonenumbers) if $self->Debug;

  while (@phonenumbers) {
    my $number = shift @phonenumbers;
    shift @phonenumbers;
    shift @phonenumbers;
    my $areacode1 = shift @phonenumbers;
    my $areacode2 = shift @phonenumbers;
    my $localcode = shift @phonenumbers;
    my $lastcode = shift @phonenumbers;
    $self->Items->{$number} =
      {
       Type => "phone-number",
       Value => join("-",$areacode1 || $areacode2 || "630",$localcode,$lastcode),
      };
  }
}

sub MarkupOrganizations {
  my ($self,%args) = @_;
  my $res = $self->MyNER->NERExtract
    (
     Text => $args{Contents},
    );
  foreach my $entry (@$res) {
    if ($entry->[1] eq "ORGANIZATION") {
      my $org = join(" ",@{$entry->[0]});
      print "<$org>\n";
      $self->Items->{$org} =
	{
	 Type => "organization",
	 Value => $org,
	};
    }
  }
}

sub GetOrganizations {
  my ($self,%args) = @_;
  my @list;
  foreach my $key (keys %{$self->Items}) {
    if ($self->Items->{$key}->{Type} eq "organization") {
      push @list, $key;
    }
  }
  return [sort @list];
}

sub ProcessMarkup {
  my ($self,%args) = @_;
  my $c = $args{Contents};
  my $text = $args{Text};
  print Dumper($self->Items) if $self->Debug;
  $self->Counter({});
  foreach my $type (qw(phone-number organization)) {
    $self->Counter->{$type} = 0;
  }
  foreach my $string (keys %{$self->Items}) {
    # get the start and end location of this string
    my $res =
      $self->GetLocation
	(
	 String => $c,
	 Substring => $string,
	 Result => $self->Items->{$string}->{Value},
	);
    my $type = $self->Items->{$string}->{Type};
    foreach my $entry (@$res) {
      print Dumper($entry) if $self->Debug;
      my $tagname;
      my @args2;
      my $color;
      if ($type eq "phone-number") {
	$color = "yellow";
	$tagname = "phonenumber-".$self->Counter->{$type};
	@args2 =
	  (
	   $tagname,
	   '<Button-1>',
	   sub {
	     my $pn = $entry->{Object};
	     $pn =~ s/\D//g;
	     my $command = "twinkle --call 001$pn &";
	     if (Approve("Perform command: $command")) {
	       system "$command";
	     }
	   },
	  );
      } elsif ($type eq "organization") {
	$color = "orange";
	$tagname = "organization-".$self->Counter->{$type};
	@args2 =
	  (
	   $tagname,
	   '<Button-1>',
	   sub {
	     my $org = $entry->{Object};
	     # look this up on google
	     # format the query
	     my $quotedsearch = uri_escape_utf8($org);
	     my $url = "http://www.google.com/search?sourceid=chrome&ie=UTF-8&q=".$quotedsearch;
	     my $command = "google-chrome -remote '$url'";
	     if (Approve("Perform command: $command")) {
	       system "$command";
	     }
	   },
	  );
      }
      # $text->configure(-state => "disabled");
      $text->tagConfigure($tagname, -background => $color);
      # $text->configure(-state => "disabled");
      print Dumper(\@args2) if $self->Debug;
      $text->tagBind(@args2);
      $text->tagAdd($tagname, $entry->{Start}, $entry->{End});
      print "<".$self->Counter->{$type}.">\n" if $self->Debug;
      $self->Counter->{$type} = $self->Counter->{$type} + 1;
    }
  }
}

sub GetLocation {
  my ($self,%args) = @_;
  my $string = $args{String};
  my $substrlen = length($args{Substring});
  my $i = 1;
  my @res;
  foreach my $line (split /\n/, $string) {
    my $linelen = length($line);
    foreach my $j (0..($linelen - $substrlen)) {
      my $substr = substr $line, $j, $substrlen;
      print "<$substr>\n" if $self->Debug;
      if ($substr eq $args{Substring}) {
	push @res, {
		    String => $substr,
		    Object => $args{Result},
		    Start => $i.".".$j,
		    End => $i.".".($j+$substrlen),
		   };
      }
    }
    ++$i;
  }
  return \@res;
}

1;
