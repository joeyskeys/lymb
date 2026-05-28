# Lymb

A symbolic algebra tool in Common Lisp, built from scratch for learning. No Quicklisp, ASDF, or third-party libraries — only SBCL and plain `(load ...)` files.

## Layout

```
lymb/
  load.lisp          ← entry point (loads src/ in order)
  run.lisp           ← load + start REPL
  README.md
  src/
    package.lisp     package :lymb
    expr.lisp        expression predicates & constructors
    print.lisp       readable strings (e.g. "2·x + 3")
    simplify.lisp    basic rewrite rules
    repl.lisp        interactive loop
```

## How to run

From the project root:

```powershell
sbcl --load load.lisp
```

Or load and start the REPL:

```powershell
sbcl --script run.lisp
```

Then try:

```lisp
(simplify '(+ 0 x))           ; => x
(simplify '(* 1 x (+ 2 3)))   ; => (* x 5)
(expr->string '(+ (* 2 x) 3))  ; => "(2·x) + 3"
(lymb)                        ; REPL: (simplify '...) and (show '...)
```

## Expression format

Expressions are normal Lisp data — no custom parser yet:

| Kind    | Example        |
|---------|----------------|
| number  | `3`, `1/2`     |
| symbol  | `'x`           |
| sum     | `'(+ x 2)`     |
| product | `'(* 3 x)`     |
| power   | `'(expt x 2)`  |

Always quote compound forms (or build them with `make-sum`, `make-product`, `make-power`).

## Design choices (for learning)

1. **Manual loading** — `load.lisp` loads files in a fixed order so you see how a project is wired without ASDF.
2. **S-expressions as AST** — sums/products are lists like `'(+ x 1)`; Lisp is already a good representation.
3. **Small simplifier** — folds numeric parts, removes `+ 0`, `* 1`, `* 0`, and evaluates numeric powers.
4. **REPL** — `simplify` and `show` forms for quick experiments.
