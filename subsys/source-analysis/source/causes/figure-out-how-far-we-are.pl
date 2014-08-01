#!/usr/bin/perl -w

my $causes = {};
foreach my $line (split /\n/, `cat /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/source-analysis/source/causes/membercount.txt`) {
  # print "<$line>\n";
  # cause-xml/1957.xml:  <member-count type="integer">16</member-count>>
  if ($line =~ /^cause-xml\/(\d+)\.xml:\s+<member-count type="integer">(\d+)<\/member-count>$/) {
    my ($cause,$count) = ($1,$2);
    $causes->{$cause} = $count;
  }
}

my $i = 1;
foreach my $cause (sort {$causes->{$b} <=> $causes->{$a}} keys %$causes) {
  print "$i\t".$causes->{$cause}."\t".$cause."\n";
  ++$i;
}
