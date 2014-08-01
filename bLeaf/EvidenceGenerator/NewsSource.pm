package Com::elle::bLeaf::EvidenceGenerator::NewsSource;

use PerlLib::SwissArmyKnife;

use DateTime;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / SourceText URL Date /

  ];

sub init {
  my ($self,%args) = @_;
  $self->SourceText($args{SourceText});
  $self->URL($args{URL});
  $self->Date($args{Date} || DateTime->now());
}

sub Print {
  my ($self,%args) = @_;
  print $self->SPrint;
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper
    ([
      $self->SourceText,
      $self->URL,
      $self->Date,
     ]);
}

1;
