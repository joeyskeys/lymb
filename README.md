# Lymb

A symbolic algebra tool in Common Lisp, built from scratch for learning.

No Quicklisp, no third-party libraries — only the Common Lisp you load with SBCL.

## Prerequisites

Install [SBCL](https://www.sbcl.org/) (Steel Bank Common Lisp). This project was tested with SBCL 2.5+.

## Project layout

```
lymb/
  load.lisp          entry point — loads all source files
  run.lisp           load + start the REPL
  src/
    package.lisp     package and exports
    expr.lisp        expression types and constructors
    print.lisp       readable output
    simplify.lisp    rewrite rules
    repl.lisp        interactive loop
```

## Run

From the project root:

```bash
# load once, stay in SBCL
sbcl --load load.lisp

# load and start the REPL
sbcl --script run.lisp
```

Inside SBCL after loading:

```lisp
(simplify '(+ 0 x))           ; => x
(simplify '(* 1 x (+ 2 3)))   ; => (* x 5)
(expr->string '(+ (* 2 x) 3))  ; => "2·x + 3"
(lymb)                        ; interactive REPL
```

## Expression format

Expressions are ordinary Lisp data:

| Meaning   | Example        |
|-----------|----------------|
| number    | `3`, `1/2`     |
| variable  | `'x`, `'y`     |
| sum       | `'(+ x 2)`     |
| product   | `'(* 3 x)`     |
| power     | `'(expt x 2)`  |

Always quote compound forms (or build them with `make-sum`, `make-product`, `make-power`).

## Where to go next

Good first exercises:

1. Add `(+ x (- x)) => 0` in `simplify.lisp`
2. Collect like terms in sums: `(+ x (* 2 x)) => (* 3 x)`
3. Implement symbolic differentiation
4. Add parsing from infix strings (without libraries — read char by char)
