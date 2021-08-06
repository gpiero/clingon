(in-package :cl-user)
(defpackage :clingon.options
  (:use :cl)
  (:export
   :option
   :option-short-name
   :option-long-name
   :option-required
   :option-parameter
   :option-help
   :option-env-vars
   :option-initial-value
   :option-reduce-fn
   :option-finalize-fn
   :option-key
   :option-category
   :option-value
   :make-option
   :initialize-option
   :finalize-option
   :end-of-options-p
   :short-option-p
   :long-option-p))
(in-package :clingon.options)

(defgeneric initialize-option (option &key)
  (:documentation "Initializes an option, e.g. sets initial option value"))

(defgeneric finalize-option (option &key)
  (:documentation "Finalizes an option"))

(defparameter *end-of-options-marker*
  "--"
  "A marker specifying the end of options")

(defun end-of-options-p (arg)
  "A predicate which returns T if the given argument specifies end of options"
  (string= arg *end-of-options-marker*))

(defun short-option-p (arg)
  "A predicate which returns T if the given argument is a short option"
  (and (> (length arg) 1)
       (char= #\- (aref arg 0))
       (char/= #\- (aref arg 1))))

(defun long-option-p (arg)
  "A predicate which returns T if the given argument is a long option"
  (and (> (length arg) 2)
       (char= #\- (aref arg 0))
       (char= #\- (aref arg 1))))

(defclass option ()
  ((parameter
    :initarg :parameter
    :initform nil
    :reader option-parameter
    :documentation "Option takes a parameter identified by the given name")
   (required
    :initarg :required
    :initform nil
    :reader option-required
    :documentation "Mark the option as required. Only valid if the option takes a parameter")
   (short-name
    :initarg :short-name
    :initform nil
    :reader option-short-name
    :documentation "Short option name")
   (long-name
    :initarg :long-name
    :initform nil
    :reader option-long-name
    :documentation "Long option name")
   (help
    :initarg :help
    :initform (error "Must specify help message")
    :reader option-help
    :documentation "Usage documentation of the option")
   (env-vars
    :initarg :env-vars
    :initform nil
    :reader option-env-vars
    :documentation "List of env vars which can set the option value")
   (initial-value
    :initarg :initial-value
    :initform nil
    :reader option-initial-value
    :documentation "Initial value for the option")
   (reduce-fn
    :initarg :reduce-fn
    :initform (error "Must specify a reduce function")
    :reader option-reduce-fn
    :documentation "A function taking two arguments of the prev and current option value")
   (finalize-fn
    :initarg :finalize-fn
    :initform #'identity
    :reader option-finalize-fn
    :documentation "A function to finalize the option value. Takes a single argument.")
   (key
    :initarg :key
    :initform (error "Must specify option key")
    :reader option-key
    :documentation "Key used to associate the option with it's value")
   (category
    :initarg :category
    :initform nil
    :reader option-category
    :documentation "Option category name")
   (value
    :initarg :value
    :initform nil
    :accessor option-value
    :documentation "Computed value after finalizing the option"))
  (:documentation "A class representing a command-line option"))

(defun make-option (&rest rest)
  "Create a new instance of OPTION"
  (apply #'make-instance 'option rest))

(defmethod initialize-instance :after ((option option) &key)
  (with-slots (short-name long-name key) option
    (unless (or short-name long-name)
      (error "Option ~A must specify a short and/or long name" key))))

(defmethod initialize-option ((option option) &key)
  "Initialize the value of the option.

  Environment variables take precedence over any
  initial-value configured for the option.

  The first environment variable that resolves to a
  non-NIL result will be used to set the option."
  (let* ((env-vars (option-env-vars option))
	 (value-from-env (some #'uiop:getenvp env-vars))
	 (value (or value-from-env (option-initial-value option))))
    (setf (option-value option) value)))

(defmethod finalize-option ((option option) &key)
  "Finalizes the option and sets it's value to the
  result of invoking of :finalize-fn function"
  (let* ((finalize-fn (option-finalize-fn option))
	 (value (option-value option))
	 (final-value (funcall finalize-fn value)))
    (setf (option-value option) final-value)))
