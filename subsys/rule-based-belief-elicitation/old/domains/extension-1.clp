(deffunction approve
  (?message)
  (printout t ?message crlf)
  (bind ?value (readline))
  (if (or
       (eq ?value "Y")
       (eq ?value "y")
       (eq ?value "YES")
       (eq ?value "Yes")
       (eq ?value "yes")
       )
   then
   TRUE
   else
   (if (or
	(eq ?value "N")
	(eq ?value "n")
	(eq ?value "NO")
	(eq ?value "No")
	(eq ?value "no")
	)
    then
    FALSE)))

(defrule is-senior
 (age ?person ?age)
 (test (> ?age 65))
 =>
 (tag health)
 (assert (is-senior-citizen ?person)))

(defrule is-minor
 (age ?person ?age)
 (test (< ?age 18))
 =>
 (tag health)
 (assert (is-minor ?person)))

(defrule emergency-medical-compentency "Determine"
 (live-in-same-household ?person1 ?person2)
 (is-senior-citizen ?person2)
 =>
 (tag health)
 (assert (should-have-goal ?person1 (str-cat "(has-completed-emergency-medical-training " ?person1 ")"))))

(defrule wants-goal
 (phase question-user)
 (should-have-goal ?person ?goal)
 =>
 (if (approve (str-cat "Do you want to have goal: " ?goal))
  then (assert (has-goal ?person ?goal))))

(defrule has-completed-goal
 (phase question-user)
 (has-goal ?person ?goal)
 =>
 (if (approve (str-cat "Have you completed goal: " ?goal))
  then (assert-string ?goal)))

;; if you live with an elderly person or a child, and you are of a
;; certain age, you should be sure to have medical training for
;; certain common situations
