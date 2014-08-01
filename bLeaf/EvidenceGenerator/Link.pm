package Com::elle::bLeaf::EvidenceGenerator::Link;

use PerlLib::SwissArmyKnife;

use DateTime;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / LinkText URL /

  ];

sub init {
  my ($self,%args) = @_;
  $self->LinkText($args{LinkText});
  $self->URL($args{URL});
}

sub Print {
  my ($self,%args) = @_;
  print $self->SPrint;
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper
    ([
      $self->LinkText,
      $self->URL,
     ]);
}

1;
