;;; consult-ugrep.el --- Ugrep integration using Consult -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Joachim Nielandt

;; Author: Joachim Nielandt <joachim.nielandt@gmail.com>
;; Homepage: https://github.com/joachimnielandt/consult-ugrep
;; Package-Requires: ((emacs "27.1") (consult "0.16"))
;; SPDX-License-Identifier: MIT
;; Version: 0.1.2

;; This file is not part of GNU Emacs.

;;; Commentary:
;;; This is a quick modification of the consult-ag package. All props go to yadex205.

;; consult-ugrep provides interfaces for using `ugrep`.
;; To use this, turn on `consult-ugrep` in your init-file or interactively.

(eval-when-compile ;; as mentioned in consult-ag - required for byte-compile
  (require 'cl-lib)
  (require 'subr-x))
(require 'consult)

;; define binary ugrep interaction
(setq ugrep-bin "ugrep")
(setq ugrep-args "--line-buffered --color=never --ignore-case --bool --files --exclude-dir=.git --line-number --column-number -I -r")
(setq ugrep-command (concat ugrep-bin " " ugrep-args))

(defun consult-ugrep--builder (input)
  "Build command line given INPUT."
  (pcase-let* ((cmd (split-string-and-unquote ugrep-command))
               (`(,arg . ,opts) (consult--command-split input)))
    `(,@cmd ,@opts ,arg ".")))

(defun consult-ugrep--format (line)
  "Parse LINE into candidate text."
  (when (string-match "^\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\):\\(.*\\)$" line)
    (let* ((filename (match-string 1 line))
           (row (match-string 2 line))
           (column (match-string 3 line))
           (body (match-string 4 line))
           (candidate (format "%s:%s:%s:%s"
                              (propertize filename 'face 'consult-file)
                              (propertize row 'face 'consult-line-number)
                              (propertize column 'face 'consult-line-number) body)))
      (propertize candidate 'filename filename 'row row 'column column))))

(defun consult-ugrep--grep-position (cand &optional find-file)
  "Return the candidate position marker for CAND.
FIND-FILE is the file open function, defaulting to `find-file`."
  (when cand
    (let ((file (get-text-property 0 'filename cand))
          (row (string-to-number (get-text-property 0 'row cand)))
          (column (- (string-to-number (get-text-property 0 'column cand)) 1)))
      (consult--position-marker (funcall (or find-file #'find-file) file) row column))))

(defun consult-ugrep--grep-state ()
  "Not documented."
  (let ((open (consult--temporary-files))
        (jump (consult--jump-state)))
    (lambda (action cand)
      (unless cand
        (funcall open nil))
      (funcall jump action (consult-ugrep--grep-position cand open)))))

;;;###autoload
(defun consult-ugrep (&optional target initial)
  "Consult ugrep for query in TARGET file(s) with INITIAL input."
  (interactive)
  (let* ((prompt-dir (consult--directory-prompt "Consult ugrep: " target))
         (default-directory (cdr prompt-dir)))
    (consult--read (consult--async-command #'consult-ugrep--builder
                     (consult--async-map #'consult-ugrep--format))
                   :prompt (car prompt-dir)
                   :lookup #'consult--lookup-member
                   :state (consult-ugrep--grep-state)
                   :initial (consult--async-split-initial initial)
                   :require-match t
                   :category 'file
                   :sort nil)))

(provide 'consult-ugrep)

;;; consult-ugrep.el ends here
