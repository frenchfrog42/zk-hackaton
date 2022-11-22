#lang racket

(require "../compilation.rkt")
(require "util.rkt")


(define (mulFQ2 ax ay bx by resx resy) `(
    ;; todo add check for destroy
    (define tx (* ,ax ,by))
    (define t (* ,bx ,ay))
    (define ,resx (+ (destroy tx) (destroy t)))
    (define ty (* ,ay ,by))
    (define t2 (* ,ax ,bx))
    (define ,resy (- (destroy ty) (destroy t2)))
))

(define (mulFQ2drop ax0 ay0 bx0 by0 resx resy) `(
    (define ay_ ,ay0)
    (define by_ ,by0)
    (define bx_ ,bx0)
    (define ax_ ,ax0)
    (define tx_ (* ax_ by_))
    (define t_ (* bx_ ay_))
    (define ,resx (+ (destroy tx_) (destroy t_)))
    (define t2_ (* (destroy ax_) (destroy bx_)))
    (define ty_ (* (destroy ay_) (destroy by_)))
    (define ,resy (- (destroy ty_) (destroy t2_)))
))

(define (mulXiFQ2 ax ay resx resy) `(
    (define mulXiFQ2a ,ax)
    (define mulXiFQ2b ,ay)
    (define ,resx (+ (* mulXiFQ2a 9) mulXiFQ2b))
    (define ,resy (- (* 9 (destroy mulXiFQ2b)) (destroy mulXiFQ2a)))
))

(define (mulScalarFQ2 ax ay x resx resy) `(
    (define ,resx (* ,ax ,x))
    (define ,resy (* ,ay ,x))
))

(define (addFQ2 ax ay bx by resx resy) `(
    (define ,resx (+ ,ax ,bx))
    (define ,resy (+ ,ay ,by))
))

(define (subFQ2 ax ay bx by resx resy) `(
    (define ,resx (- ,ax ,bx))
    (define ,resy (- ,ay ,by))
))

(define (negFQ2 ax ay resx resy) `(
    (define ,resx (* -1 ,ax))
    (define ,resy (* -1 ,ay))
))

(define (conjugateFQ2 ax ay resx resy) `(
    (define ,resx (* -1 ,ax))
    (define ,resy ,ay)
))

(define (doubleFQ2 ax ay resx resy) `(
    (define ,resx (* ,ax 2))
    (define ,resy (* ,ay 2))
))

(define (squareFQ2 _ax _ay resx resy) `(
    (define squareFQ2ax ,_ax)
    (define squareFQ2ay ,_ay)
    (define squareFQ2tx (- squareFQ2ay squareFQ2ax))
    (define squareFQ2ty (+ squareFQ2ax squareFQ2ay))
    (define ,resx (* 2 (* (destroy squareFQ2ax) (destroy squareFQ2ay))))
    (define ,resy (* (destroy squareFQ2ty) (destroy squareFQ2tx)))
))

(provide (all-defined-out))