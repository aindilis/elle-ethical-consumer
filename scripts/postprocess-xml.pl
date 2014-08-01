#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::HTMLConverter;
use PerlLib::SwissArmyKnife;

use XML::Simple;

$specification = q(
	-i <file>	XML file input
	-o <file>	XML file output
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

die unless exists $conf->{'-i'} and -f $conf->{'-i'};

my $converter = PerlLib::HTMLConverter->new();

my $c = read_file($conf->{'-i'});

# my $xml = XMLin($c);
# print Dumper($xml);
# separate categories into two tags, supercategories and ?subcategories
# subject verb object adding field to the evidence generator

my @entries = $c =~ /((<evidence>.*?<description>)(.*?)(<\/description>.*?<categories>)(.*?)(<\/categories>.*?<\/evidence>))/sg;
my @newentries;
while (@entries) {
  my ($entire,$start,$description,$middle,$categories,$end) = (shift @entries,shift @entries,shift @entries,shift @entries,shift @entries,
							       shift @entries);
  # print Dumper($description);
  my $desc2 = DePrep($description);
  my $newdescription = Prep($converter->ConvertToTxt
			    (
			     Contents => $desc2,
			    ));
  $newdescription =~ s/^\s*//s;
  $newdescription =~ s/\s*$//s;
  my @cats = $categories =~ /\s*<category>\s*<category-name>\s*(.+?)\s*<\/category-name>\s*<\/category>\s*/sg;
  my @newcats;
  foreach my $cat (@cats) {
    if ($cat =~ /^(.+)\s*\|\s*(.+)$/) {
      push @newcats, "<category><category-name>$1</category-name><subcategory-name>$2</subcategory-name></category>";
    } else {
      push @newcats, "<category><category-name>$category</category-name></category>";
    }
  }
  my $newcategories = join("\n", @newcats);
  push @newentries, join("\n", ($start,$newdescription,$middle,$newcategories,$end));
}

sub DePrep {
  my ($xml) = (shift);
  return XMLin("<opt>".$xml."</opt>");
}

sub Prep {
  my ($it) = (shift);
  my $tmp = XMLout($it);
  if ($tmp =~ /^<opt>(.*)<\/opt>$/sm) {
    return $1;
  } else {
    die "ERROR <$tmp>\n";
  }
}

my $xml = "<?xml version='1.0' ?>
<!DOCTYPE announcement [
<!ELEMENT announcement (metadata,items)>
<!ELEMENT metadata (version)>
<!ELEMENT version (#PCDATA)>
<!ELEMENT items ((group|evidence)+)>
<!ELEMENT group (group-name,group-desc,add?,remove?)>
<!ELEMENT group-name (#PCDATA)>
<!ELEMENT group-desc (#PCDATA)>
<!ELEMENT add (company+)>
<!ELEMENT remove (company+)>
<!ELEMENT evidence (title,description,categories,source,links,companies,reviews)>
<!ELEMENT title (#PCDATA)>
<!ELEMENT description (#PCDATA)>
<!ELEMENT categories (category*)>
<!ELEMENT category (category-name,category-rating?,subcategory-name?,subcategory-rating?)>
<!ELEMENT category-name (#PCDATA)>
<!ELEMENT category-rating (#PCDATA)>
<!ELEMENT subcategory-name (#PCDATA)>
<!ELEMENT subcategory-rating (#PCDATA)>
<!ELEMENT source (link)>
<!ELEMENT link (link-text,url,date)>
<!ELEMENT link-text (#PCDATA)>
<!ELEMENT url (#PCDATA)>
<!ELEMENT date (#PCDATA)>
<!ELEMENT links (link*)>
<!ELEMENT companies (company+)>
<!ELEMENT company (normalized,tagged,address,GCPs,values)>
<!ELEMENT normalized (#PCDATA)>
<!ELEMENT tagged (#PCDATA)>
<!ELEMENT address (#PCDATA)>
<!ELEMENT GCPs (GCP*)>
<!ELEMENT GCP (#PCDATA)>
<!ELEMENT values (value+)>
<!ELEMENT value (value-name,score)>
<!ELEMENT value-name (#PCDATA)>
<!ELEMENT score (#PCDATA)>
<!ELEMENT reviews (review+)>
<!ELEMENT review (reviewer,date)>
<!ELEMENT reviewer (#PCDATA)>
]>
<announcement>
  <metadata>
    <version>bLeaf 0.10</version>
  </metadata>
  <items>
".join("\n", @newentries)."
  </items>
</announcement>";

my $fh = IO::File->new();
my $outfile = $conf->{'-o'};
$fh->open(">$outfile") or die "cannot open $outfile\n";
print $fh $xml;
$fh->close();
system "xmlstarlet fo ".shell_quote($outfile)." > /tmp/postprocess.xml; mv /tmp/postprocess.xml ".shell_quote($outfile);

# subcategory
# rating all the same
