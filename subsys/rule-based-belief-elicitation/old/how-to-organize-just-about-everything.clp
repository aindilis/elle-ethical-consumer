(has-skill ?person set-priorities)
(has-skill ?person write-effective-to-do-list)
(has-skill ?person run-errands-efficiently)
(has-skill ?person meet-deadlines)

(has-reminder-system ?person ?system)

(contacts-are-organized ?person)

(has-skill ?person say-no)

(has-skill ?person set-goal)

(home-and-work-are-balanced ?person)

(has-weight-loss-plan ?person)

(defrule is-overweight
 ""
 (is-overweight ?person)
 =>
 (should-have-goal ?person )
 )