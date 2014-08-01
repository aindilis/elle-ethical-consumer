#!/usr/bin/perl -w

# load upc manufacturers

use PerlLib::SwissArmyKnife;
use Text::Levenshtein qw(distance);

use Text::CSV;

my @rows;

sub LoadManufacturers {
  my $csvfile = "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/manufacturers/upcdatabase-2008.03.01/mfrs.csv";
  my $csv = Text::CSV->new ( { binary => 1 } ) # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
  open my $fh, "<:encoding(utf8)", $csvfile or die "$csvfile: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    push @rows, $row;
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  print Dumper(\@rows);
}

sub ProcessCompanyName {
  my %args = @_;
  my $scores = {};
  foreach my $row (@rows) {
    my $score = distance($args{Name},$row->[1]);
    $scores->{$row->[1]} = $score;
  }
  my @list = sort {$scores->{$b} <=> $scores->{$a}} %$scores;
  my @top20 = splice(@list,0,20);
  print Dumper(\@top20);
}
