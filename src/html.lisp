;;;; html.lisp — HTML DSL built with macros.
;;;;
;;;; Tags are keywords. Text and expressions become escaped output.
;;;;
;;;;   (html (:body
;;;;           (:h1 "welcome, " user-name)
;;;;           (:ul (html-loop for item in shopping-list
;;;;                 (:li item)))))
;;;;
;;;; At macro-expansion time, `html` walks the nested forms and builds
;;;; a plain `(concatenate 'string ...)` expression — no runtime parser.

(in-package :lymb)

;;; --- runtime helpers (normal functions, evaluated later) ---

(defun html-escape (string)
  "Escape &, <, >, and \" for safe HTML text nodes."
  (let ((s (etypecase string
             (string string)
             (t (princ-to-string string)))))
    (with-output-to-string (out)
      (loop for ch across s
            do (case ch
                 (#\& (write-string "&amp;" out))
                 (#\< (write-string "&lt;" out))
                 (#\> (write-string "&gt;" out))
                 (#\" (write-string "&quot;" out))
                 (otherwise (write-char ch out)))))))

(defun html-text (value)
  "Turn any Lisp value into an escaped HTML text fragment."
  (if (null value)
      ""
      (html-escape value)))

(defun html-join (strings)
  "Join a list of HTML fragments into one string."
  (if (null strings)
      ""
      (apply #'concatenate 'string strings)))

;;; --- macro-expansion helpers (run while loading/compiling) ---

(defun html-tag-p (form)
  (and (consp form) (keywordp (car form))))

(defun html-loop-p (form)
  (and (consp form) (eq (car form) 'html-loop)))

(defun html-emit-loop (form)
  (let* ((args (cdr form))
         (var (second args))
         (list-expr (fourth args))
         (body (nthcdr 4 args)))
    (unless (and (eq (first args) 'for) (eq (third args) 'in))
      (error "html-loop: expected (html-loop for VAR in LIST ...), got ~s" form))
    `(html-join
      (mapcar (lambda (,var)
                (concatenate 'string ,@(mapcar #'html-emit body)))
              ,list-expr))))

(defun html-emit (form)
  "Convert one DSL form into a Lisp expression that produces HTML."
  (cond
    ((stringp form)
     `(html-text ,form))
    ((html-tag-p form)
     (let* ((tag (string-downcase (symbol-name (car form))))
            (open (format nil "<~a>" tag))
            (close (format nil "</~a>" tag))
            (children (mapcar #'html-emit (cdr form))))
       `(concatenate 'string ,open ,@children ,close)))
    ((html-loop-p form)
     (html-emit-loop form))
    (t
     `(html-text ,form))))

;;; --- the macros you call in source code ---

(defmacro html (&rest body)
  "Expand a tree of tag forms into one HTML string."
  (if (null body)
      ""
      `(concatenate 'string ,@(mapcar #'html-emit body))))

(defmacro html-loop (&rest args)
  (html-emit-loop `(html-loop ,@args)))

;;; --- demo ---

(defun html-demo ()
  "Return a sample page built with the HTML DSL."
  (let ((user-name "Alice")
        (shopping-list '("apples" "bread" "milk")))
    (html
      (:html
       (:body
        (:h1 "welcome, " user-name)
        (:ul
         (html-loop for item in shopping-list
           (:li item))))))))
