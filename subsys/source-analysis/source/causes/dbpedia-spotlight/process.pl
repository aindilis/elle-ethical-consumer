#!/usr/bin/perl -w

use Data::Dumper;
use URL::Encode qw(url_encode_utf8);
use WWW::Mechanize;

sub ProcessTextWithDBPediaSpotlight {
  my %args = @_;
  my $text = $args{Text};
  my $formattedtext = url_encode_utf8($text);
  my $url = "http://spotlight.dbpedia.org/rest/annotate?text=${formattedtext}&confidence=0.4&support=20";
  # print $url."\n";
  # process this call
  if (! defined $UNIVERSAL::mech) {
    $UNIVERSAL::mech = WWW::Mechanize->new();
  }
  $mech->get( $url );
  my $result = $mech->content;
  print Dumper($result);
}
