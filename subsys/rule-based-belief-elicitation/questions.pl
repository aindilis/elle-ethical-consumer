#!/usr/bin/perl -w

# convert this to a CLIPS or Jena/SWRL system sooner or later

# actually, for simplicity, should probably just use if cases for now

# use the KB, or similar, to store preferences

use PerlLib::SwissArmyKnife;

if (Choose2
    (
     Title => "Can we ask you a few configuration questions",
     List => ["Yes","Do later","Never"],
    )) {
  if (Approve("Do you use Facebook frequently?")) {
    if (Approve("Do you use the Facebook Causes application?")) {
      if (Approve("Should we use Facebook Causes API to access your causes information?")) {
	
      }
    }
  } else {
    
  }
}
