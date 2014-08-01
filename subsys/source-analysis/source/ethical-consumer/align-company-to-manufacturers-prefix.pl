#!/usr/bin/perl -w

sub LoadManufacturers {
  my $csvfile = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/manufacturers/upcdatabase-2008.03.01/mfrs.csv";
  my $csv = Text::CSV->new ( { binary => 1 } ) # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
  open my $fh, "<:encoding(utf8)", $csvfile or die "$csvfile: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    push @rows, [$row->[0],lc($row->[1])];
  }
  $csv->eof or $csv->error_diag();
  close $fh;
  # print Dumper(\@rows);
}

sub ProcessCompanyName {
  my %args = @_;
  my $scores = {};
  my $lcname = lc($args{Name});
  foreach my $row (@rows) {
    my $score = distance($lcname,$row->[1]);
    $scores->{$row->[1]} = $score;
  }
  my @list = sort {$scores->{$a} <=> $scores->{$b}} keys %$scores;
  my @top = splice(@list,0,10);
  print Dumper({
		Name => $args{Name},
		Top => \@top,
	       });
}
