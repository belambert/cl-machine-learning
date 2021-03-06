;; Copyright 2010-2018 Ben Lambert

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at

;;     http://www.apache.org/licenses/LICENSE-2.0

;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(in-package :optimization)

(defun powell (f n &key x (tolerance *default-tolerance*) (linemin-tolerance *default-linemin-tolerance*)
	       (linemin *default-linemin*) ximat (max-iterations 200) verbose)
  "Taken directly from Press.  Doesn't work yet and is really complicated!
   Powell's method.
   See: http://en.wikipedia.org/wiki/Powell's_method . "
  (with-optimization
    (ensure-origin x n)
    (setf f (wrap-function-with-counter f))
    (unless ximat  ;; a 2d matrix
      (setf ximat (get-unit-vector-matrix n)))
    (let* ((fptt 0.0d0) ;;?
	   (pt (get-zero-vector n))
	   (ptt (get-zero-vector n))
	   (p x)
	   (fret (funcall f p)) ;; the function return value
	   (fp fret)            ;; the prev function return value... 
	   (xi (make-array n :element-type 'double-float :initial-element 0.0d0))) ;; the search direction line...
      (declare (vector pt ptt))
      (setf pt (copy-seq p))
      ;; Why do the directions want to be a 2d array??
      (loop for iter from 0 below max-iterations do
	   (setf fp fret)
	   (pprint p)
	   (pprint fp)
	   (let ((ibig 0)     ;; index of the largest decrease?
		 (del 0.0d0)) ;; size of largest decrease
	     ;; Loop over all the directions in the set
	     (dotimes (i n)
	       ;; Get a row/column out of the direction set matrix...
	       (dotimes (j n)
		 (setf (aref xi j) (aref ximat j i)))	       
	       (setf fptt fret)
	       (when verbose (format t "Doing line minimization along vector:~{ ~f~}~%" (coerce xi 'list)))
	       (setf p (line-minimization f p xi :tolerance linemin-tolerance :linemin linemin :verbose verbose))
	       (when verbose (format t "Min x:~{ ~f~}~%" (coerce p 'list)))
	       (setf fret (funcall f p))
	       ;; Check if it had the largest decrease, and save it if it did
	       (when (> (- fptt fret) del)
		 (Setf del (- fptt fret))
		 (setf ibig (+ i 1))))
	     ;; Check if we've converged
	     (when (converged-p fp fret tolerance)
	       (return-from powell p))
	     ;; We can do this much easier, I think
	     ;; Extrapolated point?
	     (dotimes (j n)
	       (setf (aref ptt j) (- (* 2.0 (aref p j)) (aref pt j)))
	       (setf (aref xi j) (- (aref p j) (aref pt j)))
	       (setf (aref pt j) (aref p j)))
	     (setf fptt (funcall f ptt))
	     (when (< fptt fp)
	       ;; t-bird, since t is reserved in Lisp
	       (let ((t-bird (- (* 2.0 (+ fp (* -2.0 fret) fptt) (square (- fp fret del)))
				(* del (square (- fp fptt))))))
		 (when (< t-bird 0.0)
		   (setf fret (line-minimization f p xi :tolerance linemin-tolerance :linemin linemin))
		   (dotimes (j n)
		     (setf (aref ximat j (- ibig 1)) (aref ximat j (- n 1)))
		     (setf (aref ximat j (- n 1)) (aref xi j)))))))))))
