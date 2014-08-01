package Com::elle::bLeaf::EvidenceGenerator::Markup;

use PerlLib::SwissArmyKnife;

use URI::Escape;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Debug Items Counter /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug});
  $self->Items({});
}

sub MarkupText {
  my ($self,%args) = @_;
  # go ahead and find all phone numbers
  my $text = $args{Text};
  foreach my $tag (qw(company country organization unknown)) {
    $text->tagDelete($tag);
  }
  my $c = $text->Contents;
  $self->ProcessMarkup
    (
     Contents => $c,
     Text => $text,
     Results => $args{Results},
    );
}

sub ProcessMarkup {
  my ($self,%args) = @_;
  $self->Items({});
  foreach my $result (@{$args{Results}}) {
    if (! exists $self->Items->{$result->Contents}) {
      $self->Items->{$result->Contents} =
	{
	 Type => $result->Type,
	 Value => $result->Normalized,
	};
    }
  }
  my $c = $args{Contents};
  my $text = $args{Text};
  print Dumper($self->Items) if $self->Debug;
  $self->Counter({});
  foreach my $type (qw(unknown organization country company)) {
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
      if ($type eq "company") {
	$color = "red";
	$tagname = "company";
	# $tagname = "company-".$self->Counter->{$type};
	@args2 =
	  (
	   $tagname,
	   '<Button-1>',
	   sub {

	   },
	  );
      } elsif ($type eq "country") {
	$color = "orange";
	$tagname = "country";
	# $tagname = "country-".$self->Counter->{$type};
	@args2 =
	  (
	   $tagname,
	   '<Button-1>',
	   sub {

	   },
	  );
      } elsif ($type eq "organization") {
	$color = "yellow";
	$tagname = "organization";
	# $tagname = "organization-".$self->Counter->{$type};
	@args2 =
	  (
	   $tagname,
	   '<Button-1>',
	   sub {
	     # my $org = $entry->{Object};
	     # # look this up on google
	     # # format the query
	     # my $quotedsearch = uri_escape_utf8($org);
	     # my $url = "http://www.google.com/search?sourceid=chrome&ie=UTF-8&q=".$quotedsearch;
	     # my $command = "google-chrome -remote '$url'";
	     # if (Approve("Perform command: $command")) {
	     #   system "$command";
	     # }
	   },
	  );
      } elsif ($type eq "unknown") {
	$color = "white";
	$tagname = "unknown";
	# $tagname = "unknown-".$self->Counter->{$type};
	@args2 =
	  (
	   $tagname,
	   '<Button-1>',
	   sub {
	   },
	  );
      }
      # $text->configure(-state => "disabled");
      $text->tagConfigure($tagname, -background => $color);
      # $text->configure(-state => "disabled");
      print Dumper(\@args2) if $self->Debug;
      if (scalar @args2 == 3) {
	$text->tagBind(@args2);
      }
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
