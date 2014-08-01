#!/usr/bin/perl -w

use Manager::Dialog qw (QueryUser SubsetSelect ApproveCommands);
use PerlLib::MySQL;

use Data::Dumper;
use Text::CSV;

my $method = "cso";
my $mymysql;
if ($method eq "cso") {
  $mymysql = PerlLib::MySQL->new(DBName => "cso");
}
my %freq;
my $num = 0;

my $freqdbfile = "/tmp/freq.db";
my @rows;
LoadManufacturers();

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

GenerateLanguageModel();
while (1) {
  $name = QueryUser("Name?");
  my $res = SearchForCompanyName(Name => $name);
}

sub GenerateLanguageModel {
  print "Generating Language Model\n";
  my @corpus;
  foreach my $row (@rows) {
    push @corpus, $row->[1];
  }
  print "Generating IDF\n";
  foreach my $word (map {lc($_)} split /\W+/, join("\n",@corpus)) {
    # print Dumper($word);
    if (defined $freq{$word}) {
      $freq{$word} += 1;
    } else {
      $freq{$word} = 1;
    }
    ++$num;
  }
  if (0) {
    print "Saving IDF\n";
    my $OUT;
    open(OUT,">$freqdbfile") or die "ouch!";
    print OUT Dumper($num,%freq);
    close(OUT);
  }
  print "Done Generating Language Model\n";
}

sub SearchForCompanyName {
  my %args = @_;
  my $line = $args{Name};
  my %score;
  chomp $line;
  my @keywords = map {lc($_)} split /\W+/, $line;
  foreach my $keyword (@keywords) {
    if (length $keyword > 3) {
      foreach my $result (map {$_->[1]} @rows) {
	if ($result =~ /$keyword/i) {
	  if (! exists $freq{$keyword}) {
	    print Dumper($keyword);
	  } else {
	    $score{$result} += ($num / $freq{$keyword});
	  }
	}
      }
    }
  }
  my @top = sort {$score{$a} <=> $score{$b}} keys %score;
  #print "\n\n$line\n".Dumper(@keywords).Dumper(reverse map {[$_,$score{$_}]} splice (@top,-10));
  print "\n\n<$line>\n";
  my $set;
  if (@top > 20) {
    $set = [reverse splice (@top,-20)]
  } else {
    $set = [reverse @top];
  }
  return $set;
  # foreach my $res (SubsetSelect
  # 		   (Set => $set,
  # 		    Selection => {})) {
  # #   push @results, $res;
  # }
}
