#lang racket

(require "../compilation.rkt")
(require "../util.rkt")
(require "./curve.rkt")
(require "./line.rkt")
(require "./fq12.rkt")


;; In FQ2 use this function instead of squareFQ2 to make the abstract interpretation works
;(define (squareFQ2 _ax _ay resx resy) `(
;    (define squareFQ2ax ,_ax)
;    (define squareFQ2ay ,_ay)
;    (define squareFQ2tx (- squareFQ2ay squareFQ2ax))
;    (define squareFQ2ty (+ squareFQ2ax squareFQ2ay))
;    (define ,resx (* (destroy squareFQ2ax) (destroy squareFQ2ay)))
;    (define ,resx (* 2 (destroy ,resx)))
;    (define ,resy (* (destroy squareFQ2ty) (destroy squareFQ2tx)))
;))


(define max-int 32.0) ;; 21888242871839275222246405745257275088696311157297823662689037894645226208583)

(define (get-func op)
    ;; if we have the function - we return +, otherwise we return op
    ;; return the function call from the symbol
    (cond [(eq? op '+) (lambda (x y) (if (>= (abs (- x y)) 1) (+ (/ 1 (* 256 256)) (max x y)) (+ (/ 1 256) (max x y))))]
          [(eq? op '-) (lambda (x y) (if (>= (abs (- x y)) 1) (+ (/ 1 (* 256 256)) (max x y)) (+ (/ 1 256) (max x y))))]
          [(eq? op '*) (lambda (x y) (+ x y))]))

(define (get-value-from-hashtable table key)
    (cond [(hash-has-key? table key) (hash-ref table key)]
          [else (log (+ 1 (abs key)) 256)])) ;; abs because it can be a negative number

;; write a function that takes the list of input; the code
;; and loop through each line of code to estimate the max value
;; each elements can have at maximum
(define (estimateMaxValue input liste-code)
  ;; Create a mutable hash table with input in it
  (define inputTable (make-hash))
  (for ([i (in-list input)])
      (hash-set! inputTable i max-int))
(println "Start")
(for ((code liste-code))
    ;; to debug, print the code
   ; (println code)
    ;; the 2nd element is the value to modify in the hashtable, the 3rd the value it'll have
    (let*  ((element (second code))
            ;; if element is a (destroy element), then remove the destroy
            (element (if (list? element) (second element) element))
            (value (third code))
            ;; do the same for every element of value
            ;; map over a list
            (value (if (list? value) (map (lambda (x) (if (list? x) (second x) x)) value) value))
            (value (if (and (list? value) (eq? 'destroy (first value))) (second value) value)))
       ; (println element)
       ; (println value)
       ; (println code)
        (if (list? value)
            ;; normal computation
            (hash-set! inputTable element (apply (get-func (car value)) (map (lambda (x) (get-value-from-hashtable inputTable x)) (cdr value))))
            ;; when value is a single value, just set in the hashtable
            (hash-set! inputTable element (get-value-from-hashtable inputTable value)))))
    inputTable)

(define (log256 x)
    (if (< x 256) 1 (+ 1 (log256 (/ x 256)))))


















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
(define (addCurvePointNobranch) `(
    (define z12 (* az az))
    (define z22 (* bz bz))

    (define u1 (* ax z22))
    (define u2 (* bx z12))

    (define t (* bz z22))
    (define s1 (* ay t))

    (modify t (* az z12))
    (define s2 (* by t))

    (define h (- (destroy u2) u1))

    (modify t (* 2 h))
    (define i (* t t))
    (define j (* h i))

    (modify t (- (destroy s2) s1))

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

    (define myrest 0)))

(define first-contract
(let ((res '()))
(for ((e (in-range 3)))
    (set! res
        (append
        (append
            (doubleCurvePoint)
            '((define ax resx))
            '((define ay resy))
            '((define az resz))
            '((define at rest))
            (addCurvePointNobranch)
            '((define ax myresx))
            '((define ay myresy))
            '((define az myresz))
            '((define at myrest))) res)))
    res))

(unless 1
(let ((ht (estimateMaxValue '(ax ay az at bx by bz bt) first-contract)))
    ;; print each element of the hashtable
    (for ([i (in-hash-keys ht)])
        (print i)
        (print " ")
        (println (hash-ref ht i)))))







;; 192
;; 288
;; 64
;; 64
(when 1
(let ((ht (estimateMaxValue '(rxx rxy ryx ryy rzx rzy rtx rty qx qy qz qt) (linefuncdouble))))
;;(let ((ht (estimateMaxValue '(rxx rxy ryx ryy rzx rzy rtx rty pxx pxy pyx pyy pzx pzy ptx pty qx qy qz qt r2x r2y) (linefuncadd))))
;;(let ((ht (estimateMaxValue '(retxxx retxxy retxyx retxyy retxzx retxzy retyxx retyxy retyyx retyyy retyzx retyzy input-ax input-ay input-bx input-by input-cx input-cy) (mulLine))))
;;(let ((ht (estimateMaxValue '(axxx axxy axyx axyy axzx axzy ayxx ayxy ayyx ayyy ayzx ayzy) (squareFQ12))))
    ;; print each element of the hashtable
    (let ((maxi 0))
        (for ([i (in-hash-keys ht)])
            (print i)
            (print " ")
            (set! maxi (max maxi (hash-ref ht i)))
            (println (hash-ref ht i)))
        (print "MAX VALUE:")
        (println maxi))))




;; addcurve without the branch is always above (returns a potentially larger value) than doublecurve
(unless 1
(let ((ht1 (estimateMaxValue '(ax ay az at bx by bz bt) (addCurvePoint)))
      (ht2 (estimateMaxValue '(ax ay az at bx by bz bt) (doubleCurvePoint))))
    ;; print the value of myresx
    (println (log256 (hash-ref ht1 'myresx)))
    (println (log256 (hash-ref ht2 'resx)))
    ;; print the value of myresy
    (println (log256 (hash-ref ht1 'myresy)))
    (println (log256 (hash-ref ht2 'resy)))
    ;; print the value of myresz
    (println (log256 (hash-ref ht1 'myresz)))
    (println (log256 (hash-ref ht2 'resz)))
    ;; print the value of myrest
    (println (log256 (hash-ref ht1 'myrest)))
    (println (log256 (hash-ref ht2 'rest)))))

    