#lang racket

(require "../compilation.rkt")
(require "util.rkt")
(require "fq6.rkt")
(require "fq2.rkt")

; utils

;; create list args
;; from s create sxx sxy syx syy szx szy
(define (args s)
    (let ((f (lambda (s1 s2)
        (let ((n (string-length "destroy ")))
            (if (and (> (string-length s1) n) (string=? (substring s1 0 n) "destroy "))
                (list 'destroy (string->symbol (~a (substring s1 n) s2)))
                (string->symbol (~a s1 s2)))))))
            (list (f s "xx") (f s "xy") (f s "yx") (f s "yy") (f s "zx") (f s "zy"))))
;; calls an fq6 with list defined above
(define (fq6 name s1 s2 s3)
    (apply name (append (args s1) (args s2) (args s3))))
;; same but unary fq6 function
(define (fq6-unary name s1 s3)
    (apply name (append (args s1) (args s3))))
;; useless now but may be useful later
(define (two-args-12 list-args1 list-args2 list-res)
    (let* ((a1 (lambda (x) (list-ref list-args1 x)))
            (a2 (lambda (x) (list-ref list-args2 x)))
            (tmp-app (lambda (name a b c d e f)
                (apply name (a1 a) (a1 b) (a1 c) (a2 d) (a2 e) (a2 f) '()))) 
            (ap (lambda (name x) (match x
                ("xx" (tmp-app name 0 1 2 0 1 2))
                ("xy" (tmp-app name 0 1 2 3 4 5))
                ("xz" (tmp-app name 0 1 2 6 7 8))
                ("yx" (tmp-app name 3 4 5 0 1 2))
                ("yy" (tmp-app name 3 4 5 3 4 5))
                ("yz" (tmp-app name 3 4 5 6 7 8))
                ("zx" (tmp-app name 6 7 8 0 1 2))
                ("zy" (tmp-app name 6 7 8 3 4 5))
                ("zz" (tmp-app name 6 7 8 6 7 8))))))
                1))

;; MULFQ12

;; 1038
(define (mulFQ12)
    (append
        (fq6 mulFQ6 "ay" "by" "ac")
        (fq6 mulFQ6 "ax" "bx" "bd")
        (fq6-unary mulTauFQ6 "bd" "bd2")

        (fq6 addFQ6 "ax" "ay" "aplusb")
        (fq6 addFQ6 "bx" "by" "cplusd")
        (fq6 mulFQ6 "destroy aplusb" "destroy cplusd" "resx")
        (fq6 subFQ6 "destroy resx" "ac" "resx")
        (fq6 subFQ6 "destroy resx" "destroy bd" "resx")

        (fq6 addFQ6 "destroy ac" "destroy bd2" "resy")
    ))
(define contract-mulFQ12 (append
    '(public)
    '((axxx axxy axyx axyy axzx axzy ayxx ayxy ayyx ayyy ayzx ayzy
       bxxx bxxy bxyx bxyy bxzx bxzy byxx byxy byyx byyy byzx byzy))
    (mulFQ12)
))

;; SQUAREFQ12

;; 763
(define (squareFQ12)
    (append
        (fq6 mulFQ6 "ax" "ay" "v0")
        (fq6-unary mulTauFQ6 "ax" "t")
        (fq6 addFQ6 "ay" "destroy t" "t2")
        (fq6 addFQ6 "ax" "ay" "ty")
        (fq6 mulFQ6 "destroy ty" "destroy t2" "ty2")
        (fq6 subFQ6 "destroy ty2" "v0" "ty3")
        (fq6-unary mulTauFQ6 "v0" "t3")
        (fq6-unary doubleFQ6 "destroy v0" "resx")
        (fq6 subFQ6 "destroy ty3" "destroy t3" "resy")
    ))
(define contract-squareFQ12 (append
    '(public)
    '((axxx axxy axyx axyy axzx axzy ayxx ayxy ayyx ayyy ayzx ayzy))
    (squareFQ12)
))

;; EXP12 - turns out to be useless
(define (custom-mulFQ12)
    (append
        (fq6 mulFQ6 "ay" "by" "ac")
        (fq6 mulFQ6 "ax" "bx" "bd")
        (fq6-unary mulTauFQ6 "bd" "bd2")

        (fq6 addFQ6 "destroy ax" "destroy ay" "aplusb")
        (fq6 addFQ6 "bx" "by" "cplusd")
        (fq6 mulFQ6 "destroy aplusb" "destroy cplusd" "resx")
        (fq6 subFQ6 "destroy resx" "ac" "resx")
        (fq6 subFQ6 "destroy resx" "destroy bd" "ax")

        (fq6 addFQ6 "destroy ac" "destroy bd2" "ay")
    ))
(define (custom-squareFQ12)
    (append
        (fq6 mulFQ6 "ax" "ay" "v0")
        (fq6-unary mulTauFQ6 "ax" "t")
        (fq6 addFQ6 "ay" "destroy t" "t2")
        (fq6 addFQ6 "destroy ax" "destroy ay" "ty")
        (fq6 mulFQ6 "destroy ty" "destroy t2" "ty2")
        (fq6 subFQ6 "destroy ty2" "v0" "ty3")
        (fq6-unary mulTauFQ6 "v0" "t3")
        (fq6-unary doubleFQ6 "destroy v0" "ax")
        (fq6 subFQ6 "destroy ty3" "destroy t3" "ay")
    ))
(define (expFQ12_u u)
    (let ((res '()))
        (for/list ((e (in-range 62 -1 -1)))
            (set! res (append res (custom-squareFQ12)))
            (set! res (append res
                (if (= 0 (modulo (quotient u (for/product ((i e)) 2)) 2))
                    '()
                    (custom-mulFQ12)))))
    res))
(define contract-expFQ12_u (append
    '(public)
    '((bxxx bxxy bxyx bxyy bxzx bxzy byxx byxy byyx byyy byzx byzy))
    '((define axxx 0))
    '((define axxy 0))
    '((define axyx 0))
    '((define axyy 0))
    '((define axzx 0))
    '((define axzy 0))
    '((define ayxx 0))
    '((define ayxy 0))
    '((define ayyx 0))
    '((define ayyy 0))
    '((define ayzx 0))
    '((define ayzy 1))
    (expFQ12_u 4965661367192848881)
))


;; MULLINE

(define (create-fq6 l-input l-output)
    (for/list ((i (in-range 6)))
        `(define ,(list-ref l-output i) ,(list-ref l-input i))))
;; 580
(define (mulLine)
    (append
        ;(create-fq6 '(0 0 input-ax input-ay input-bx input-by) (args "a2"))
        ;(fq6 mulFQ6 "destroy a2" "retx" "a3")
        (apply mulFQ6-opt-zero (append '(input-ax input-ay input-bx input-by) (args "retx") (args "a3")))
        (apply mulScalarFQ6 (append (args "rety") '(input-cx input-cy) (args "resy")))

        (addFQ2 'input-bx 'input-by 'input-cx 'input-cy 'ttx 'tty)
       
        (fq6 addFQ6 "retx" "rety" "resxtmp")

        ;(create-fq6 '(0 0 input-ax input-ay (destroy ttx) (destroy tty)) (args "t2"))
        ;(fq6 mulFQ6 "destroy resxtmp" "destroy t2" "resx")
        (apply mulFQ6-opt-zero (append '(input-ax input-ay (destroy ttx) (destroy tty)) (args "destroy resxtmp") (args "resx")))

        (fq6 subFQ6 "destroy resx" "a3" "resx")
        (fq6 subFQ6 "destroy resx" "resy" "resx")
        (fq6-unary mulTauFQ6 "destroy a3" "a4")
        (fq6 addFQ6 "destroy resy" "destroy a4" "resy")
    ))
(define contract-mulLine (append
    '(public)
      '((retxxx retxxy retxyx retxyy retxzx retxzy retyxx retyxy retyyx retyyy retyzx retyzy
        input-ax input-ay input-bx input-by input-cx input-cy))
    (mulLine)
))



; (contract->opcodes contract-mulFQ12)
; (contract->opcodes contract-squareFQ12)
; (contract->opcodes contract-mulLine)