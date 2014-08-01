#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $images = `ls -1 /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/images/*.jpg`;
foreach my $image (split /\n/,$images) {
  system "xview -shrink ".shell_quote($image);
}
