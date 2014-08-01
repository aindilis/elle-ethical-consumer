package Com::elle::bLeaf::EvidenceGenerator::Review;

use PerlLib::SwissArmyKnife;

use DateTime;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyDateTime Reviewer /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyDateTime($args{DateTime} || DateTime->now());
  $self->Reviewer($args{Reviewer});
}

sub PrintDate {
  my ($self,%args) = @_;
  return $UNIVERSAL::evidencegenerator->MyResources->FormatDateTime
    (DateTime => $self->MyDateTime);
}

1;
