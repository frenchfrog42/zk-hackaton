#lang racket

(define (modulus x p) `(
    (modify ,x (% ,x ,p))
    (modify ,x (+ ,x ,p))
    (modify ,x (% ,x ,p))
))

(define P "47fd7cd8168c203c8dca7168916a81975d588181b64550b829a031e1724e6430")

;; if a is a destroy x, then it copies the variable
(define (copy-if-destroy a)
    (if (and (list? a) (symbol=? (first a) 'destroy))
        (let ((s (second a)))
                `((define ,s (destroy ,a))))
            '()))
;; collect if it was a destroy above
(define (collect-if-destroy a ht)
    (if (member a ht) (list 'destroy a) a))

(provide (all-defined-out))