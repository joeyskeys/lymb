;;;; simplify.lisp — rewrite rules for symbolic expressions.
;;;;
;;;; This is intentionally small. Add rules here as you learn more Lisp.

(in-package :lymb)

(defun simplify (expr)
  "Return a simplified copy of EXPR."
  (simplify-expr expr))

(defun simplify-expr (expr)
  (cond
    ((number-expr-p expr) expr)
    ((symbol-expr-p expr) expr)
    ((sum-expr-p expr) (simplify-sum (expr-args expr)))
    ((product-expr-p expr) (simplify-product (expr-args expr)))
    ((power-expr-p expr)
     (simplify-power (expr-base expr) (expr-exponent expr)))
    (t expr)))

(defun simplify-sum (terms)
  (let ((simplified (mapcar #'simplify-expr terms)))
    (simplify-sum-terms simplified)))

(defun canonical-symbolic-part (part)
  (if (product-expr-p part)
      (let ((sorted (sort (copy-seq (expr-args part)) #'expr-order<)))
        (if (= (length sorted) 1)
            (first sorted)
            (apply #'make-product sorted)))
      part))

(defun expr-order< (a b)
  (string< (write-to-string a) (write-to-string b)))

(defun split-term-coefficient (term)
  "Return (values coefficient symbolic-part) for a sum term."
  (cond
    ((symbol-expr-p term)
     (values 1 term))
    ((product-expr-p term)
     (let ((coeff 1)
           (factors nil))
       (dolist (factor (expr-args term))
         (if (number-expr-p factor)
             (setf coeff (* coeff factor))
             (push factor factors)))
       (values coeff
               (canonical-symbolic-part
                (if (= (length factors) 1)
                    (first factors)
                    (apply #'make-product (nreverse factors)))))))
    (t
     (values 1 term))))

(defun add-like-term (groups sym coeff)
  (if (zerop coeff)
      groups
      (let ((pair (assoc sym groups :test #'equal)))
        (if pair
            (progn
              (incf (cdr pair) coeff)
              (if (zerop (cdr pair))
                  (remove pair groups :test #'eq)
                  groups))
            (cons (cons sym coeff) groups)))))

(defun rebuild-sum-term (sym coeff)
  (cond
    ((eql sym 1) coeff)
    ((eql coeff 1) sym)
    (t (make-product coeff sym))))

(defun simplify-sum-terms (terms)
  (let ((constant 0)
        (groups nil))
    (dolist (term terms)
      (if (number-expr-p term)
          (incf constant term)
          (multiple-value-bind (coeff sym)
              (split-term-coefficient term)
            (setf groups (add-like-term groups sym coeff)))))
    (let ((combined (mapcar (lambda (pair)
                              (rebuild-sum-term (car pair) (cdr pair)))
                            groups)))
      (cond
        ((and (zerop constant) (null combined)) 0)
        ((zerop constant)
         (if (= (length combined) 1)
             (first combined)
             (apply #'make-sum combined)))
        ((null combined) constant)
        ((= (length combined) 1)
         (make-sum (first combined) constant))
        (t (apply #'make-sum (append combined (list constant))))))))

(defun simplify-product (factors)
  (let ((simplified (mapcar #'simplify-expr factors)))
    (simplify-product-factors simplified)))

(defun simplify-product-factors (factors)
  (let ((constant 1)
        (rest nil))
    (dolist (factor factors)
      (cond
        ((number-expr-p factor)
         (setf constant (* constant factor)))
        ((eql factor 0)
         (return-from simplify-product-factors 0))
        (t
         (push factor rest))))
    (let ((combined (nreverse rest)))
      (cond
        ((eql constant 0) 0)
        ((eql constant 1)
         (cond
           ((null combined) 1)
           ((= (length combined) 1) (first combined))
           (t (apply #'make-product combined))))
        ((null combined) constant)
        ((= (length combined) 1)
         (make-product (first combined) constant))
        (t (apply #'make-product (append combined (list constant))))))))

(defun simplify-power (base exponent)
  (let ((b (simplify-expr base))
        (e (simplify-expr exponent)))
    (cond
      ((and (number-expr-p e) (zerop e)) 1)
      ((and (number-expr-p e) (eql e 1)) b)
      ((and (number-expr-p b) (number-expr-p e))
       (expt b e))
      (t (make-power b e)))))
