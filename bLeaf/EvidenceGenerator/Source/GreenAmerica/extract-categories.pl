#!/usr/bin/perl -w

use Com::elle::bLeaf::EvidenceGenerator::News;

use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

my $news = PerlLib::Collection->new
   (StorageFile => "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/data/source/GreenAmerica/news",
    Type => "Com::elle::bLeaf::EvidenceGenerator::News");
$news->Load();

my $categories = {};
foreach my $item ($news->Values) {
  # print Dumper($item);
  if (defined $item->Categories) {
    foreach my $category (keys %{$item->Categories}) {
      $categories->{$category}++;
    }
  } else {
    print "ERROR\n";
  }
}

print Dumper($categories);
