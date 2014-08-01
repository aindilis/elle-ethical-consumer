#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

use Getopt::Declare;

my $spec = "
	-b <barcode>	Barcode
";

my $conf = Getopt::Declare->new($spec);
if (exists $conf->{'-b'}) {
  
}

my $id2name =
  {
   "51492" => "XYZ",
   "12345" => "Company-2",
  };
my $context = "Com::elle::BLeaf";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $barcode = GetBarcode();
my $res = GetManufacturerID(Barcode => $barcode);

if ($res->{Success}) {
  my $res2 = GetManufacturerName(ID => $res->{Result});
  if ($res2->{Success}) {
    CheckBLeaf(ManufacturerName => $res2->{Result});
    # proceed on with
  }
}

sub GetBarcode {
  if (exists $conf->{'-b'}) {
    return $conf->{'-b'};
  } else {    
    my $res = "751492506630";
    return $res;
  }
}

sub GetManufacturerID {
  my %args = @_;
  if (length($barcode) == 12) {
    if ($barcode =~ /^(\d)(\d{5})(\d{5})(\d)/) {
      return {
	      Success => 1,
	      Result => $2,
	     };
    } else {
      die "Not a valid barcode\n";
    }
  }
}

sub GetManufacturerName {
  my %args = @_; 

  # replace with a call to upcdatabase.com or upcdatabase.org, or
  # similar

  if (exists $id2name->{$args{ID}}) {
    my $name = $id2name->{$args{ID}};
    return {
	    Success => 1,
	    Result => $name,
	   };
  } else {
    return {
	    Success => 0,
	   };
  }
}

sub CheckBLeaf {
  my %args = @_;
  my $name = $args{ManufacturerName};
  # do a query to see if we are boycotting this person
  my $message = $client->Send
    (
     QueryAgent => 1,
     Query => [["Obligatory", ["Boycott", \*{'::?X'}, ["Company-fn", $name]]]],
     InputType => "Interlingua",
     Flags => {
	       Debug => 0,
	      },
    );
  my $bindings = $message->{Data}->{Result}->{Bindings}->[0];
  # print Dumper($message);
  if (scalar @$bindings) {
    print "Boycott this company\n";
  } else {
    print "This company does not need to be boycotted\n";
  }
}

