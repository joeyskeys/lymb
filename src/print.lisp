;;;; print.lisp — turn expressions into readable strings.

(in-package :lymb)

(defun expr->string (expr)
  (with-output-to-string (out)
    (let ((*standard-output* out)
          (*print-case* :downcase))
      (print-expr expr))))

(defun print-expr (expr)
  (cond
    ((or (number-expr-p expr) (symbol-expr-p expr))
     (princ expr))
    ((sum-expr-p expr)
     (print-infix expr '+ " + "))
    ((product-expr-p expr)
     (print-infix expr '* "·"))
    ((power-expr-p expr)
     (print-expr (expr-base expr))
     (princ "^")
     (print-expr (expr-exponent expr)))
    (t
     (princ expr))))

(defun print-infix (expr op separator)
  (loop for term on (expr-args expr)
        for first = t then nil
        do (progn
             (unless first (princ separator))
             (let ((needs-parens
                     (and (consp (car term))
                          (not (eq (caar term) op)))))
               (when needs-parens (princ "("))
               (print-expr (car term))
               (when needs-parens (princ ")"))))))
