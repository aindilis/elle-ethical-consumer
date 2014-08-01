#!/usr/bin/perl -w

use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

my $ie = KBS2::ImportExport->new();

permissible (permitted)       must
impermissible (forbidden, prohibited)
supererogatory (beyond the call of duty)
obligatory (duty, required)       indifferent / significant
omissible (non-obligatory)       the least one can do
  optional       better than / best / good / bad
ought


my @signs = (qw(Positive Negative));
my @deonticmodalities = (qw(Obligatory Permissible Prohibited));
my @predicates = (qw(Boycott Prefer));

foreach my $sign1 (@signs) {
  foreach my $modality (@deonticmodalities) {
    foreach my $sign2 (@signs) {
      foreach my $predicate (@predicates) {
	my $subformula1 = [$predicate,"me","Company"];
	my $subformula2;
	if ($sign2 eq "Negative") {
	  $subformula2 = [$modality, ["not",$subformula1]]
	} else {
	  $subformula2 = [$modality, $subformula1];
	}
	my $subformula3;
	if ($sign1 eq "Negative") {
	  $subformula3 = ["not",$subformula2];
	} else {
	  $subformula3 = $subformula2;
	}	  
	my $res = $ie->Convert
	  (
	   Input => [$subformula3],
	   InputType => "Interlingua",
	   OutputType => "KIF String",
	  );
	if ($res->{Success}) {
	  print $res->{Output}."\n";
	}
      }
    }
  }
}
