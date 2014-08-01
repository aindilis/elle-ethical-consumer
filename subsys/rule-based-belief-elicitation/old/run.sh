#!/bin/sh

# run clips with the default file

echo '(batch "/var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/rule-based-belief-elicitation/base.clp")'
cd /var/lib/myfrdcsa/codebases/minor/elle-ethical-consumer/subsys/rule-based-belief-elicitation/clipsjni-0.3 && java -cp CLIPSJNI.jar -Djava.library.path=. CLIPSJNI.Environment