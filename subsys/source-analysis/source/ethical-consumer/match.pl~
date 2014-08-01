#!/usr/bin/perl -w

# this version only looks at apt-cache, but in theory should utilize
# CSO, right?  also should be promoted into a module

# consider using Text::PhraseDistance, or similar

use PerlLib::MySQL;

use Data::Dumper;
use Manager::Dialog qw (SubsetSelect ApproveCommands);

my $method = "cso";
my $mymysql;
if ($method eq "cso") {
  $mymysql = PerlLib::MySQL->new(DBName => "cso");
}
my $contentsfile = $ARGV[0];
my %freq;
my $num = 0;
my @results;

my $freqdbfile = "/tmp/freq.db";

GenerateLanguageModel();
ChoosePackageProvidingRequirement();

print Dumper(\@results);
ApproveCommands
  (Commands => ["echo ".join(" ",@results)],
   Method => "parallel");


sub GenerateLanguageModel {
  print "Generating Language Model\n";
  if (0) {			#-e "freq.db") {
    (%freq,$num) = eval `cat $freqdbfile`;
    print "NUM:$num\n";
  } else {
    my @corpus;
    if ($method eq "apt-cache") {
      my $results = `apt-cache search -f .`;
      foreach my $entry (split /\n\n/, $results) {
	$entry =~ /Description: (.*?)\n(.*)(^\S+:)?/sm;
	push @corpus, "$1\n$2";
      }
    } elsif ($method eq "cso") {
      my $results = $mymysql->Do
	(Statement => "select * from systems");
      foreach my $key (keys %$results) {
	push @corpus, join("\n",($results->{$key}->{Name} || "",
				 $results->{$key}->{ShortDesc} || "",
				 $results->{$key}->{LongDesc} || ""));
      }
    }
    print "Generating IDF\n";
    foreach my $word (split /\W+/, join("\n",@corpus)) {
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
  }
  print "Done Generating Language Model\n";
}

sub ChoosePackageProvidingRequirement {
  foreach my $line (split /\n/,`cat $contentsfile`) {
    my %score;
    chomp $line;
    my @keywords = split /\W+/, $line;
    foreach my $keyword (@keywords) {
      if (length $keyword > 3) {
	if ($method eq "apt-cache") {
	  foreach my $result (split /\n/, `apt-cache search $keyword`) {
	    if ($result =~ / - .*/) {
	      if ($freq{$keyword}) {
		$score{$result} += ($num / $freq{$keyword});
	      }
	    }
	  }
	} elsif ($method eq "cso") {
	  # use stop words to get rid of massive searches later on
	  my $results = $mymysql->Do
	    (Statement =>
	     "select * from systems where Name like '%$keyword%' or ShortDesc like '%$keyword%' or LongDesc like '%$keyword'");
	  # get a count of how frequently the term shows up
	  # do TFIDF here
	  foreach my $key (keys %$results) {
	    if ($freq{$keyword}) {
	      $score{$results->{$key}->{ID}.": ".$results->{$key}->{Name}." - ".$results->{$key}->{ShortDesc}} +=
		($num / $freq{$keyword});
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
    foreach my $res (SubsetSelect
		     (Set => $set,
		      Selection => {})) {
      if ($method eq "apt-cache") {
	$res =~ s/ - .*//;
	push @results, $res;
      } elsif ($method eq "cso") {
	$res =~ s/:.*//;
	# now we want to save into some persistance database this
	# information
      }
    }
  }
}
