(defrule advanced-1
 "if a person is a citizen, they need to know their social security number"
 (is-citizen-of ?person USA)
 =>
 (assert (a root e1-1))
 (assert (a needs e1-1 x1-1 e2-1))
 (assert (a person x1-1))
 (assert (a know e2-1 x1-1 e3-1))
 (assert (a has-social-security-number e3-1 x1-1 x2-1))
 (assert (a number x2-1))
 )

(defrule advanced-2
 "if a person needs to know something, say so"
 (a root ?e1)
 (a needs ?e1 ?x1 ?e2)
 (a know ?e2 ?x1 ?e3)
 (a ?predicate ?e3 ? ?)
 =>
 (printout t ?predicate)
 )

(defrule advanced-3
 ""
 (is-citizen-of ?person USA)
 (not (has-foodstamps ?person))
 =>
 ;; person should have a goal of get food stamps person
 ;; (ought (has-goal person (get-food-stamps person)))
 (assert (a root e1-2))
 (assert (a ought e1-2 e2-2))
 (assert (b e1-2 "(ought (has-goal ?person (get-foodstamps ?person)))"))
 (assert (a has-goal e2-2 x1-2 e3-2))
 (assert (b e2-2 "(has-goal ?person (get-foodstamps ?person))"))
 (assert (a ?person x1-2))
 (assert (a get-food-stamps e3-2 x1-2))
 (assert (b e3-2 "(get-foodstamps ?person)"))
 )

(defrule advanced-4
 "if a person ought to do something, suggest they do it"
 (a root ?e1)
 (a ought ?e1 ?e2)
 (b ?e2 ?string)
 =>
 (printout t (str-cat "Perhaps you should consider doing " ?string))
 ;; read in whether he wants to do it, then assert that he do it

 )

