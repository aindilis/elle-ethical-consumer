package RapidResponse::Application::CoverLetterGenerator;

use Manager::Dialog qw(QueryUser2);
use MyFRDCSA;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CoverLetterDir /

  ];

sub init {
  my ($self,%args) = @_;
  $self->CoverLetterDir
    ($args{CoverLetterDir} ||
     "/var/lib/myfrdcsa/codebases/minor/js-rapid-response/latex-coverletter");
}

sub GenerateCoverLetter {
  my ($self,%args) = @_;
  # my $coverlettertemplate = read_file(ConcatDir($self->CoverLetterDir,"CoverLetter.tex.template"));
  my $coverlettertemplate = $args{CoverLetterLatex};
  my $listtemplate = read_file(ConcatDir($self->CoverLetterDir,"List.tex.template"));
  my $data = {
	      FULLNAME => $args{FullName},
	      EMPLOYERNAME => $args{EmployerName},
	      PLACE => $args{Place},
	      ADDRESS => $args{Address}, # "123 Chicago Ave.\\\\Chicago, IL 60606",
	      POSITION => $args{Position},
	      ADVERTISEMENT => $args{Advertisement},
	      ENCLOSED => $args{Enclosed},
	     };
  foreach my $key (keys %$data) {
    my $sub = $data->{$key};
    $coverlettertemplate =~ s/<$key>/$sub/g;
    $listtemplate =~ s/<$key>/$sub/g;
  }

  my $fh1 = IO::File->new();
  $fh1->open(">".ConcatDir($self->CoverLetterDir,"CoverLetter.tex")) or die "cannot\n";
  print $fh1 $coverlettertemplate;
  $fh1->close();

  my $fh2 = IO::File->new();
  $fh2->open(">".ConcatDir($self->CoverLetterDir,"List.tex")) or die "cannot\n";
  print $fh2 $listtemplate;
  $fh2->close();

  system "cd ".shell_quote($self->CoverLetterDir)." && pdflatex List.tex";
  system "cp ".shell_quote(ConcatDir($self->CoverLetterDir,"List.pdf"))." ".
    shell_quote($args{CoverLetterPDFFile});
  system "xpdf ".shell_quote($args{CoverLetterPDFFile})." &";
  if (Approve("Is the coverletter correct?")) {
    return 1;
  } else {
    return 0;
  }
}

1;
