;;;; repl.lisp — tiny read-eval-print loop for experimenting.

(in-package :lymb)

(defun lymb-read (stream)
  (let ((*package* (find-package :lymb)))
    (read stream nil :eof)))

(defun lymb-eval (form)
  (cond
    ((and (consp form) (eq (car form) 'simplify))
     (simplify (second form)))
    ((and (consp form) (eq (car form) 'show))
     (expr->string (second form)))
    (t
     (eval form))))

(defun lymb-print (value stream)
  (if (stringp value)
      (format stream "~a" value)
      (format stream "~s => ~a" value (expr->string value))))

(defun lymb ()
  "Start an interactive Lymb session."
  (format t "~&Lymb REPL~%")
  (format t "  (simplify '(+ x 0))~%")
  (format t "  (show '(+ (* 2 x) 3))~%")
  (format t "Type :quit to exit.~%~%")
  (loop
    (fresh-line)
    (format t "lymb> ")
    (force-output)
    (let ((form (lymb-read *standard-input*)))
      (cond
        ((eq form :eof) (return))
        ((and (consp form) (eq (car form) 'quit)) (return))
        ((eq form :quit) (return))
        (t
         (handler-case
             (lymb-print (lymb-eval form) *standard-output*)
           (error (c)
             (format t "~%Error: ~a" c))))))))
