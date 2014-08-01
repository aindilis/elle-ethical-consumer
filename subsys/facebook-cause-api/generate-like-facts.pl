#!/usr/bin/perl -w

use KBS2::Client;
use PerlLib::SwissArmyKnife;

my $context = "Com::elle::BLeaf";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $causes = GetCausesURL();
foreach my $causeurl (@$causes) {
  if ($causeurl =~ /^http:\/\/api.causes.com\/causes\/(\d+).xml$/) {
    my $causeno = $1;
    print Dumper($causeurl);
    my $res = $client->Send
      (
       QueryAgent => 1,
       Assert => [["Likes", "me", ["Facebook-Cause-fn",$causeno]]],
       InputType => "Interlingua",
      );
    print Dumper($res);
  }
}

sub GetCausesURL {
  return [
	  "http://api.causes.com/causes/72910.xml",
	 ];
}
