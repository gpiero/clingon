(in-package :cl-user)
(defpackage :clingon.generics
  (:use :cl)
  (:export
   :find-short-option
   :find-long-option
   :parse-option
   :initialize-option
   :finalize-option
   :make-option))
(in-package :clingon.generics)

(defgeneric find-short-option (object name &key)
  (:documentation "Returns the short option with the given NAME, or NIL otherwise"))

(defgeneric find-long-option (object name &key)
  (:documentation "Returns the long option with the given NAME, or NIL otherwise"))

(defgeneric parse-option (kind object &key)
  (:documentation "Parses an option of the given KIND"))

(defgeneric initialize-option (option &key)
  (:documentation "Initializes an option, e.g. sets initial option value"))

(defgeneric finalize-option (option &key)
  (:documentation "Finalizes an option"))

(defgeneric make-option (kind &rest rest)
  (:documentation "Creates a new option of the given kind"))
