(defmodule FINANCES)

;; (is-bankrupted ?person)

;; (has-fixed-wages ?person)


;; ;; capitalist definitions, probably should be avoided

;; (is-earning-rent ?person ?rent)
;; (is-earning-interest ?person ?interest)
;; (is-earning-profits ?person ?profits)
;; (owns-land ?person ?land)

;; ;; normal

;; (has-old-age-pension ?person ?pension)
;; (is-unemployed ?person)

;; (has-mortgage ?person ?shelter)
;; (is-poorly-paid ?person)

(defrule if-you-want-to-save-money-dont-eat-out
 "If you want to save money, don't eat out"
 (has-goal ?person (str-cat "(minimize-expenditure " ?person ")"))
 =>
 (tag finances)
 (has-goal ?person (str-cat "(not (is-eating-out-regularly " ?person "))")))

;; (is-frugal ?person)
