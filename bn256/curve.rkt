#lang racket

(require "../compilation.rkt")
(require "../util.rkt")

;; 92
(define (doubleCurvePoint) `(
    (define A (* ax ax))
    (define B (* ay ay))
    (define C (* B B))
    
    (define t (+ ax (destroy B)))
    (define t2 (* t t))
    (modify t (- t2 A))
    (modify t2 (- t C))

    (define d (* 2 t2))
    (modify t (* 2 A))
    (define e (+ t (destroy A)))
    (define f (* e e))

    (modify t (* 2 d))
    (define resx (- (destroy f) t))

    (modify t (* 2 (destroy C)))
    (modify t2 (* 2 t))
    (modify t (* 2 t2))
    (define resy (- (destroy d) resx))
    (modify t2 (* (destroy e) resy))
    (modify resy (- (destroy t2) (destroy t)))

    (define prod (* ay az))
    (define resz (* 2 (destroy prod)))

    (define rest 0)
))
(define contract-doubleCurvePoint (append
    '(public)
    '((ax ay az at))
    (doubleCurvePoint)
))

;; 340
(define (addCurvePoint) `(
    (define az (% (destroy az) P))
    (define bz (% (destroy bz) P))
    (define z12 (* az az))
    (define z22 (* bz bz))

    (define u1 (* ax z22))
    (define u2 (* bx z12))

    (define t (* bz z22))
    (define s1 (* ay t))

    (modify t (* az z12))
    (define s2 (* by t))

    (define h (- (destroy u2) u1))
    (define xEqual (= 0 (% h P)))

    (modify t (* 2 h))
    (define i (* t t))
    (define j (* h i))

    (modify t (- (destroy s2) s1))
    (define yEqual (= 0 (% t P)))
    (define bothEqual (and (destroy xEqual) (destroy yEqual)))

    (define r (+ t t))
    (define v (* (destroy u1) (destroy i)))
    (define t4 (* r r))
    (define t6 (- t4 j))
    (modify t (* 2 v))  

    (define myresx (- t6 t))

    (modify t (- (destroy v) myresx))
    (modify t4 (* (destroy s1) (destroy j)))
    (modify t6 (* 2 t4))
    (modify t4 (* (destroy r) t))
    (define myresy (- t4 (destroy t6)))

    (modify t (+ az bz))
    (modify t4 (* t t))
    (modify t (- t4 (destroy z12)))
    (modify t4 (- (destroy t) (destroy z22)))
    (define myresz (* (destroy t4) (destroy h)))

    (define myrest 0)

    debug
    ;; Top stack is now myresx, myresy, myresz, myrest, bothequal

    (if (= az 0)
        ,(cons* `(
            (drop myresz)
            (drop myrest)
            (drop myresy)
            (drop myresx)
            (define myresx bx)
            (define myresy by)
            (define myresz bz)
            (define myrest bt)
            debug
            )))
    (if (and (call not ((= az 0))) (= bz 0))
        ,(cons* `(
            (drop myresz)
            (drop myrest)
            (drop myresy)
            (drop myresx)
            (define myresx ax)
            (define myresy ay)
            (define myresz az)
            (define myrest at)
            debug)))
    (if (and (and (call not ((= az 0))) (call not ((= bz 0)))) bothEqual)
        ,(cons* (append
            '((drop myresz))
            '((drop myrest))
            '((drop myresy))
            '((drop myresx))
            '(debug)
            `((ignore-execute ,(lambda () (set-stack '(bothEqual bt _az bz by bx _at _ay _ax P)))))
            '(debug)
            '((define ax _ax))
            '((define ay _ay))
            '((define az _az))
            '((define at _at))
            (doubleCurvePoint)
            '((drop ax))
            '((drop ay))
            '((drop az))
            '((drop at))
            '(debug)
            )))
    (drop bothEqual)
    debug))

(define contract-addCurvePoint (append
    '(public)
    '((P ax ay az at bx by bz bt))
    (addCurvePoint)
))

; (contract->opcodes contract-doubleCurvePoint)
(contract->opcodes contract-addCurvePoint)

(provide (all-defined-out))















;; ajouter OP_0 OP_IF OP_ENDIF (dans un if ?) casse le simulateur
(define (todo-check) `(
    (define z12 (* az az))
    (define z22 (* bz bz))

    (define u1 (* ax z22))
    (define u2 (* bx z12))

    (define t (* bz z22))
    (define s1 (* ay t))

    (modify t (* az z12))
    (define s2 (* by t))

    (define h (- (destroy u2) u1))
    (define xEqual (= 0 h))

    (modify t (* 2 h))
    (define i (* t t))
    (define j (* h i))

    (modify t (- (destroy s2) s1))
    (define yEqual (= 0 t))
    (define bothEqual (and (destroy xEqual) (destroy yEqual)))

    (define r (+ t t))
    (define v (* (destroy u1) (destroy i)))
    (define t4 (* t t))
    (define t6 (- t4 j))
    (modify t (* 2 v))  

    (define myresx (- t6 t))

    (modify t (- (destroy v) myresx))
    (modify t4 (* (destroy s1) (destroy j)))
    (modify t6 (* 2 t4))
    (modify t4 (* (destroy r) t))
    (define myresy (- t4 (destroy t6)))

    (modify t (+ az bz))
    (modify t4 (* t t))
    (modify t (- t4 (destroy z12)))
    (modify t4 (- (destroy t) (destroy z22)))
    (define myresz (* (destroy t4) (destroy h)))

    (define myrest 0)

    debug
    
    ;; Top stack is now myresx, myresy, myresz, myrest, bothequal
    
    ;; Let's check if we need to do smth else
    (define bool1 (or (= az 0) (or (= bz 0) bothEqual)))
    (if bool1
        ,(cons* `(
            (drop myrest) ;; todo opt
            (drop myresz)
            (drop myresy)
            (drop myresx)
            ;; Top stack now is bothequal, b, a
            (if (= az 0)
                ;; Copy b to the top of the stack. bothequal is top element, and b is just behind
                ,(cons* `(
               ;     "OP_DROP"
               ;     (unsafe-drop bothEqual)
               ;     "OP_2OVER"
               ;     (unsafe-define myresx)
               ;    (unsafe-define myresy)
               ;    "OP_2OVER"
               ;    (unsafe-define myresz)
               ;    (unsafe-define myrest)))
                    (drop bothEqual)
                    (define myresx bx)
                    (define myresy by)
                    (define myresz bz)
                    (define myrest bt)))
                ;; Else, copy a to the top, and maybe call doubleCurvePoint
                ,(cons* `(
                    (define myresx ax)
                    (define myresy ay)
                    (define myresz az)
                    (define myrest at)
                    ;; Top stack now is a, bothequal, b, a
                    (if (destroy bothEqual)
                        ,(cons*
                            (append
                                '(debug)
                                ;; """rename""" myres to a for doublecurvepoint
                                '((unsafe-drop ax))
                                '((unsafe-define ax))
                                '((unsafe-drop ay))
                                '((unsafe-define ay))
                                '((unsafe-drop az))
                                '((unsafe-define az))
                                '((unsafe-drop at))
                                '((unsafe-define at))
                                '(debug)
                                (doubleCurvePoint)
                                '(debug)
                                `((drop ax)
                                  (drop ay)
                                  (drop az)
                                  (drop at)
                                  )))
                    ))))))
            (drop bothEqual))
    debug))
