#!/usr/bin/env sbcl --script
;;;; run.lisp — load Lymb and start the REPL.
;;;;   sbcl --script run.lisp

(load (merge-pathnames #p"load.lisp" *load-trueroot*))
(lymb)
