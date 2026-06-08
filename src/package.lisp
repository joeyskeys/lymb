;;;; package.lisp — project package definition.

(defpackage :lymb
  (:use :cl)
  (:export
   ;; expression predicates
   :number-expr-p
   :symbol-expr-p
   :sum-expr-p
   :product-expr-p
   :power-expr-p
   ;; expression accessors
   :expr-op
   :expr-args
   :expr-base
   :expr-exponent
   ;; constructors
   :make-sum
   :make-product
   :make-power
   ;; printing
   :expr->string
   :print-expr
   :show
   ;; simplification
   :simplify
   ;; REPL
   :lymb))

(in-package :lymb)
