package Com::elle::bLeaf::EvidenceGenerator::News;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Sources Links Additional Title Contents Categories Score
   MiscInfo /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Sources($args{Sources});
  $self->Links($args{Links});
  $self->Title($args{Title});
  $self->Contents($args{Contents});
  $self->Score($args{Score});
  $self->Categories($args{Categories} || {});
  $self->MiscInfo($args{MiscInfo});
}

sub PrimaryKey {
  my ($self,%args) = @_;
  return Dumper([$self->Sources->[0],$self->Title]);
}

sub Print {
  my ($self,%args) = @_;
  print $self->SPrint;
}

sub SPrint {
  my ($self,%args) = @_;
  return Dumper
    ([
      $self->Sources,
      $self->Links,
      $self->Title,
      $self->Contents,
      $self->Score,
      $self->Categories,
      $self->MiscInfo,
     ]);
}

sub Matches {
  my ($self,%args) = (shift,@_);
  if ($args{Criteria}) {
    if ($args{Criteria}->{Any}) {
      foreach my $key (qw(Title Contents MiscInfo)) {
        if ($self->$key) {
          if ($self->$key =~ /$args{Criteria}->{Any}/) {
            return 1;
          }
        }
      }
    } else {
      foreach my $key (keys %{$args{Criteria}}) {
        if ($self->$key) {
          if ($self->$key =~ /$args{Criteria}->{$key}/i) {
            return 1;
          }
        }
      }
    }
  }
}

1;
