;;;; expr.lisp — represent symbolic expressions as ordinary Lisp data.
;;;;
;;;; Atoms:
;;;;   3       number
;;;;   x       symbol (use quote: 'x)
;;;;
;;;; Compound expressions use prefix lists:
;;;;   (+ a b ...)   sum
;;;;   (* a b ...)   product
;;;;   (expt b e)    power

(in-package :lymb)

(defun number-expr-p (expr)
  "True when EXPR is a numeric constant."
  (numberp expr))

(defun symbol-expr-p (expr)
  "True when EXPR is a symbolic variable."
  (symbolp expr))

(defun compound-expr-p (expr)
  (and (consp expr)
       (symbolp (car expr))
       (cdr expr)))

(defun expr-op (expr)
  (assert (compound-expr-p expr) (expr)
          "Expected a compound expression, got ~s" expr)
  (car expr))

(defun expr-args (expr)
  (assert (compound-expr-p expr) (expr)
          "Expected a compound expression, got ~s" expr)
  (cdr expr))

(defun sum-expr-p (expr)
  (and (compound-expr-p expr)
       (eq (expr-op expr) '+)))

(defun product-expr-p (expr)
  (and (compound-expr-p expr)
       (eq (expr-op expr) '*)))

(defun power-expr-p (expr)
  (and (compound-expr-p expr)
       (eq (expr-op expr) 'expt)
       (= (length (expr-args expr)) 2)))

(defun expr-base (expr)
  (assert (power-expr-p expr) (expr)
          "Expected a power expression, got ~s" expr)
  (first (expr-args expr)))

(defun expr-exponent (expr)
  (assert (power-expr-p expr) (expr)
          "Expected a power expression, got ~s" expr)
  (second (expr-args expr)))

(defun make-sum (&rest terms)
  (cons '+ (remove-if #'null terms)))

(defun make-product (&rest factors)
  (cons '* (remove-if (lambda (x) (eql x 1)) factors)))

(defun make-power (base exponent)
  (list 'expt base exponent))
