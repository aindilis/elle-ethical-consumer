#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use HTML::Entities;

my $contents = read_file("496.aspx");
my ($contact,$products,$availability) = ("","","");
my @contactinfo;
my $companyheader = "";
if ($contents =~ /<dl class="company-header"><dt>Company: <\/dt><dd>(.+?)<\/dd><\/dl>/) {
  $companyheader = decode_entities($1);
}
if ($contents =~ /<dl class="company-item company-contact">(.+?)<\/dl>/s) {
  $contact = $1;
  if ($contact =~ /<dd>(.+?)<\/dd>/s) {
    my $contracted = $1;
    foreach my $entry (split /<br \/>/, $contracted) {
      if ($entry =~ /<a title="([^"]+?)" href="([^"]+?)" target="_blank">(.+?)<\/a>/) {
	my $title = $1;
	my $href = $2;
	my $name = $3;
	push @contactinfo,
	  {
	   Title => decode_entities(decode_entities($title)),
	   Href => $href,
	   Name => decode_entities($name),
	  };
      } else {
	$entry = decode_entities($entry);
	$entry =~ s/^\s*//;
	$entry =~ s/\s*$//;
	$entry =~ s/\s+/ /g;
	push @contactinfo, $entry;
      }
    }
  }
}
my @productsinfo;
if ($contents =~ /<dl class="company-item company-products">(.+?)<\/dl>/s) {
  $products = $1;
  if ($products =~ /<ul class="content-list">(.+?)<\/ul>/s) {
    my $contracted = $1;
    @productsinfo = $contracted =~ /<li class="content-item">(.+?)<\/li>/sg;
  }
}
if ($contents =~ /<dl class="company-item company-availability">(.+?)<\/dl>/s) {
  $availability = $1;
  if ($availability =~ /<ul class="content-list">(.+?)<\/ul>/s) {
    my $contracted = $1;
    @availabilityinfo = $contracted =~ /<li class="content-item">(.+?)<\/li>/sg;
  }

}
print Dumper([$companyheader,\@contactinfo,\@productsinfo,\@availabilityinfo]);
