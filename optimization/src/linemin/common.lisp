;;;; Author: Benjamin Lambert (ben@benjaminlambert.com)

(declaim (optimize (debug 3)))
(in-package :optimization)
(cl-user::file-summary "1-dimensional line minimization methods for optimization")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(cl-user::section "Constants")

(defconstant +glimit+ 100.0
  "When bracketing, the maximum magnification allowed for a parabolic-fit step.")

(defconstant +r+ 0.61803399d0
  "A golden ratio.")

(defconstant +c+ (- 1.0 +r+)
  "A golden ratio.")

(defun sign (a b)
  "Return a version of a which is the same sign as b."
  (if (> b 0.0)
      (abs a)
      (- (abs a))))

