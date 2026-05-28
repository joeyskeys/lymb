(in-package :lymb)
(format t "simplify: ~a~%" (expr->string (simplify '(+ 0 (* 1 x (+ 2 3))))))
(format t "show:     ~a~%" (expr->string '(+ (* 2 x) 3)))
