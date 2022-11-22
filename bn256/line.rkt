#lang racket

(require "fq2.rkt")
(require "../compilation.rkt")

;; https://gist.github.com/frenchfrog42/3cc0f669d5bb9e02fcb6ef9d075709c0

;; 548
(define (linefuncadd)
    (append
        (mulFQ2 'pxx 'pxy 'rtx 'rty 'Bx 'By)
        (addFQ2 'pyx 'pyy 'rzx 'rzy 'Dx 'Dy)
        (squareFQ2 '(destroy Dx) '(destroy Dy) 'Dx 'Dy)
        (subFQ2 '(destroy Dx) '(destroy Dy) 'r2x 'r2y 'Dx 'Dy)
        (subFQ2 '(destroy Dx) '(destroy Dy) 'rtx 'rty 'Dx 'Dy)
        (mulFQ2drop '(destroy Dx) '(destroy Dy) 'rtx 'rty 'Dx 'Dy)

        (subFQ2 '(destroy Bx) '(destroy By) 'rxx 'rxy 'Hx 'Hy)
        (squareFQ2 'Hx 'Hy 'Ix 'Iy)

        (addFQ2 'Ix 'Iy 'Ix 'Iy 'Ex 'Ey)
        (addFQ2 'Ex 'Ey '(destroy Ex) '(destroy Ey) 'Ex 'Ey)

        (mulFQ2drop 'Hx 'Hy 'Ex 'Ey 'Jx 'Jy)

        (subFQ2 '(destroy Dx) '(destroy Dy) 'ryx 'ryy 'L1x 'L1y)
        (subFQ2 '(destroy L1x) '(destroy L1y) 'ryx 'ryy 'L1x 'L1y)

        (mulFQ2drop 'rxx 'rxy '(destroy Ex) '(destroy Ey) 'Vx 'Vy)

        (squareFQ2 'L1x 'L1y 'rOutXx 'rOutXy)
        (subFQ2 '(destroy rOutXx) '(destroy rOutXy) 'Jx 'Jy 'rOutXx 'rOutXy)
        (subFQ2 '(destroy rOutXx) '(destroy rOutXy) 'Vx 'Vy 'rOutXx 'rOutXy)
        (subFQ2 '(destroy rOutXx) '(destroy rOutXy) 'Vx 'Vy 'rOutXx 'rOutXy)

        (addFQ2 'rzx 'rzy '(destroy Hx) '(destroy Hy) 'rOutZx 'rOutZy)
        (squareFQ2 '(destroy rOutZx) '(destroy rOutZy) 'rOutZx 'rOutZy)
        (subFQ2 '(destroy rOutZx) '(destroy rOutZy) 'rtx 'rty 'rOutZx 'rOutZy)
        (subFQ2 '(destroy rOutZx) '(destroy rOutZy) '(destroy Ix) '(destroy Iy) 'rOutZx 'rOutZy)

        (subFQ2 '(destroy Vx) '(destroy Vy) 'rOutXx 'rOutXy 'mytx 'myty)
        (mulFQ2drop '(destroy mytx) '(destroy myty) 'L1x 'L1y 'mytx 'myty)
        (mulFQ2drop 'ryx 'ryy '(destroy Jx) '(destroy Jy) 't2x 't2y)
        (addFQ2 't2x 't2y '(destroy t2x) '(destroy t2y) 't2x 't2y)
        (subFQ2 '(destroy mytx) '(destroy myty) '(destroy t2x) '(destroy t2y) 'rOutYx 'rOutYy)

        (squareFQ2 'rOutZx 'rOutZy 'rOutTx 'rOutTy)

        (addFQ2 'pyx 'pyy 'rOutZx 'rOutZy 'mytx 'myty)
        (squareFQ2 '(destroy mytx) '(destroy myty) 'mytx 'myty)
        (subFQ2 '(destroy mytx) '(destroy myty) 'r2x 'r2y 'mytx 'myty)
        (subFQ2 '(destroy mytx) '(destroy myty) 'rOutTx 'rOutTy 'mytx 'myty)

        (mulFQ2 'L1x 'L1y 'pxx 'pxy 't2x 't2y)
        (addFQ2 't2x 't2y '(destroy t2x) '(destroy t2y) 't2x 't2y)
        (subFQ2 '(destroy t2x) '(destroy t2y) '(destroy mytx) '(destroy myty) 'ax 'ay)

        (mulScalarFQ2 'rOutZx 'rOutZy 'qy 'cx 'cy)
        (addFQ2 'cx 'cy '(destroy cx) '(destroy cy) 'cx 'cy)

        (subFQ2 0 0 '(destroy L1x) '(destroy L1y) 'bx 'by)
        (mulScalarFQ2 '(destroy bx) '(destroy by) 'qx 'bx 'by)
        (addFQ2 'bx 'by '(destroy bx) '(destroy by) 'bx 'by)

        ;; cost = 30
        '((define resax (destroy ax)))
        '((define resay (destroy ay)))
        '((define resbx (destroy bx)))
        '((define resby (destroy by)))
        '((define rescx (destroy cx)))
        '((define rescy (destroy cy)))
        '((define resOutxx (destroy rOutXx)))
        '((define resOutxy (destroy rOutXy)))
        '((define resOutyx (destroy rOutYx)))
        '((define resOutyy (destroy rOutYy)))
        '((define resOutzx (destroy rOutZx)))
        '((define resOutzy (destroy rOutZy)))
        '((define resOuttx (destroy rOutTx)))
        '((define resOutty (destroy rOutTy)))))
(define contract-linefuncadd (append
    '(public)
    '((rxx rxy ryx ryy rzx rzy rtx rty pxx pxy pyx pyy pzx pzy ptx pty qx qy qz qt r2x r2y))
    (linefuncadd)
))

;; 484
(define (linefuncdouble)
    (append
        (squareFQ2 'rxx 'rxy 'Axx 'Axy)
        (squareFQ2 'ryx 'ryy 'Bxx 'Bxy)
        (squareFQ2 'Bxx 'Bxy 'Cxx 'Cxy)

        (addFQ2 'rxx 'rxy 'Bxx 'Bxy 'Dxx 'Dxy)
        (squareFQ2 '(destroy Dxx) '(destroy Dxy) 'Dxx 'Dxy)
        (subFQ2 '(destroy Dxx) '(destroy Dxy) 'Axx 'Axy 'Dxx 'Dxy)
        (subFQ2 '(destroy Dxx) '(destroy Dxy) 'Cxx 'Cxy 'Dxx 'Dxy)
        (addFQ2 'Dxx 'Dxy '(destroy Dxx) '(destroy Dxy) 'Dxx 'Dxy)

        (addFQ2 'Axx 'Axy 'Axx 'Axy 'Exx 'Exy)
        (addFQ2 '(destroy Exx) '(destroy Exy) 'Axx 'Axy 'Exx 'Exy)

        (squareFQ2 'Exx 'Exy 'Gxx 'Gxy)

        (subFQ2 'Gxx 'Gxy 'Dxx 'Dxy 'rOutXx 'rOutXy)
        (subFQ2 '(destroy rOutXx) '(destroy rOutXy) 'Dxx 'Dxy 'rOutXx 'rOutXy)

        (addFQ2 'ryx 'ryy 'rzx 'rzy 'rOutZx 'rOutZy)
        (squareFQ2 '(destroy rOutZx) '(destroy rOutZy) 'rOutZx 'rOutZy)
        (subFQ2 '(destroy rOutZx) '(destroy rOutZy) 'Bxx 'Bxy 'rOutZx 'rOutZy)
        (subFQ2 '(destroy rOutZx) '(destroy rOutZy) 'rtx 'rty 'rOutZx 'rOutZy)

        (subFQ2 '(destroy Dxx) '(destroy Dxy) 'rOutXx 'rOutXy 'rOutYx 'rOutYy)
        (mulFQ2drop '(destroy rOutYx) '(destroy rOutYy) 'Exx 'Exy 'rOutYx 'rOutYy)
        (addFQ2 'Cxx 'Cxy '(destroy Cxx) '(destroy Cxy) 'mytx 'myty)
        (addFQ2 'mytx 'myty '(destroy mytx) '(destroy myty) 'mytx 'myty)
        (addFQ2 'mytx 'myty '(destroy mytx) '(destroy myty) 'mytx 'myty)
        (subFQ2 '(destroy rOutYx) '(destroy rOutYy) '(destroy mytx) '(destroy myty) 'rOutYx 'rOutYy)

        (squareFQ2 'rOutZx 'rOutZy 'rOutTx 'rOutTy)

        (mulFQ2drop 'Exx 'Exy 'rtx 'rty 'mytx 'myty)
        (addFQ2 'mytx 'myty '(destroy mytx) '(destroy myty) 'mytx 'myty)
        (subFQ2 0 0 '(destroy mytx) '(destroy myty) 'bx 'by)
        (mulScalarFQ2 '(destroy bx) '(destroy by) 'qx 'bx 'by)

        (addFQ2 'rxx 'rxy '(destroy Exx) '(destroy Exy) 'ax 'ay)
        (squareFQ2 '(destroy ax) '(destroy ay) 'ax 'ay)
        (subFQ2 '(destroy ax) '(destroy ay) '(destroy Axx) '(destroy Axy) 'ax 'ay)
        (subFQ2 '(destroy ax) '(destroy ay) '(destroy Gxx) '(destroy Gxy) 'ax 'ay)
        (addFQ2 'Bxx 'Bxy '(destroy Bxx) '(destroy Bxy) 'mytx 'myty)
        (addFQ2 'mytx 'myty '(destroy mytx) '(destroy myty) 'mytx 'myty)
        (subFQ2 '(destroy ax) '(destroy ay) '(destroy mytx) '(destroy myty) 'ax 'ay)

        (mulFQ2 'rOutZx 'rOutZy 'rtx 'rty 'cx 'cy)
        (addFQ2 'cx 'cy '(destroy cx) '(destroy cy) 'cx 'cy)
        (mulScalarFQ2 '(destroy cx) '(destroy cy) 'qy 'cx 'cy)

        '(debug)

        '((define resax (destroy ax)))
        '((define resay (destroy ay)))
        '((define resbx (destroy bx)))
        '((define resby (destroy by)))
        '((define rescx (destroy cx)))
        '((define rescy (destroy cy)))
        '((define resOutxx (destroy rOutXx)))
        '((define resOutxy (destroy rOutXy)))
        '((define resOutyx (destroy rOutYx)))
        '((define resOutyy (destroy rOutYy)))
        '((define resOutzx (destroy rOutZx)))
        '((define resOutzy (destroy rOutZy)))
        '((define resOuttx (destroy rOutTx)))
        '((define resOutty (destroy rOutTy)))))
(define contract-linefuncdouble (append
    '(public)
    '((rxx rxy ryx ryy rzx rzy rtx rty qx qy qz qt))
    (linefuncdouble)
))

; (contract->opcodes contract-linefuncadd)
(contract->opcodes contract-linefuncdouble)