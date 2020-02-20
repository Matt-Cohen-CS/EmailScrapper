# webadv_alert.pl:

sub help {
  # Using a Perl multi-line string:
  $message = "

  Using: perl -w webadv_alert.pl <arguments>

    where <arguments> are the following seprated by a space:
      -Term          : which semester the class is in, e.g. \"20/SP - 2020 Spring\"
      -Subject       : which Subject the class is in, e.g. \"ENGLISH (EN)\"
      -Course Number : course number, e.g., 202
      -Section Number: course section, e.g., 51
      -Email address : alert recipient's email address, e.g. test\@test.com

    \n";

  print $message;
}

######## End of subroutines #######

$numargs = $#ARGV + 1;

if ($numargs < 5 || $ARGV[0] =~ /--help/) {
  help();
  exit(1);
}

use WWW::Mechanize;

$url = "https://www2.monmouth.edu/muwebadv/wa3/search/SearchClassesV2.aspx";
$mech = WWW::Mechanize->new();
$mech->get($url);

# Get term options
$content = $mech->content();

# Using option tag to find terms and add them to terms array
@terms = $content =~ /<option value="[0-9]{2,}.*\/[A-Z]{2,}">(.*)<\/option>/g;


# Check if term is valid. If invalid list valid terms.
if (my ($matched) = grep $_ eq $ARGV[0], @terms) {
    $term = $ARGV[0];
}
else {
  print "Term entered is invalid. \nValid terms are: \n";

  foreach $term (sort @terms) {
    print "  $term \n";
  }
  exit(1);
}

# Select the term
$mech->field("_ctl0:MainContent:ddlTerm", $term);

# Select the subject
$subject = $ARGV[1];
$mech->field("_ctl0:MainContent:ddlSubj_1", $subject);

# Select the course number
$coursenumber = $ARGV[2];
$mech->field("_ctl0:MainContent:txtCourseNum_1", $coursenumber);

# Select the section number
$sectionnumber = $ARGV[3];
$mech->field("_ctl0:MainContent:txtSectionNum_1", $sectionnumber);

# "Click" the Submit button
$mech->click_button(name => "_ctl0:MainContent:btnSubmit");

# Get resulting html
$page = $mech->content();

print $page;
