;;;; load.lisp — entry point; loads all source files in order.
;;;; Run from the project root:
;;;;   sbcl --load load.lisp
;;;;   sbcl --script run.lisp

(in-package :cl-user)

(defparameter *lymb-root*
  (when *load-pathname*
    (directory-namestring *load-pathname*)))

(defun load-lymb-file (relative-path)
  (let ((full (merge-pathnames relative-path *lymb-root*)))
    (format t "~&loading ~a~%" (enough-namestring full))
    (load full)))

(dolist (file '("src/package.lisp"
                "src/expr.lisp"
                "src/print.lisp"
                "src/simplify.lisp"
                "src/repl.lisp"))
  (load-lymb-file file))

(in-package :lymb)

(format t "~&~%Lymb ready. Examples:~%")
(format t "  (simplify '(+ 0 x))~%")
(format t "  (simplify '(* 1 x (+ 2 3)))~%")
(format t "  (expr->string '(+ (* 2 x) 3))~%")
(format t "  (lymb)          ; start the interactive REPL~%~%")
