package RapidResponse::Resources;

use PerlLib::Cacher;
use PerlLib::MySQL;
use PerlLib::ToText;
use RapidResponse::Application::Markup;
use Verber::Util::DateManip;

use DateTime::Format::Duration;
use WWW::Mechanize;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMySQL MyCacher MyToText MyMainWindow MyDateManip
   DateTimeDurationFormatter MyMarkup Mech /

  ];

sub init {
  my ($self,%args) = @_;
  print "Started loading\n";


  $self->MyMySQL
    (PerlLib::MySQL->new
     (

      DBName => $args{DBName}, # $dbname,
      Host => $args{Host}, # $host,
      Username => $args{Username}, # $username,
      Password => $args{Password}, # $password,
     ));
  $self->MyCacher
    (PerlLib::Cacher->new);
  $self->MyToText
    (PerlLib::ToText->new);
  $self->MyMainWindow
    ($args{MainWindow});
  $self->MyDateManip
    (Verber::Util::DateManip->new);
  $self->DateTimeDurationFormatter
    (DateTime::Format::Duration->new
     (
      pattern => '%F %T',
      normalize => 1,
     ));
  $self->MyMarkup
    (RapidResponse::Application::Markup->new);
  $self->Mech
    (WWW::Mechanize->new);


  print "Finished loading\n";
}

1;

