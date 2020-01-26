;; This buffer is for notes you don't want to save, and for Lisp evaluation.
;; If you want to create a file, visit that file with C-x C-f,
;; then enter the text in that file's own buffer.
(defun НайтиНодыСодержание ()
"Находим строки с командами структурирования"
  (interactive)
(while (re-search-forward "^\\(?:@node\\>\\|\\(@\\(?:appendix\\(?:s\\(?:ec\\(?:tion\\)?\\|ubs\\(?:\\(?:ubs\\)?ec\\)\\)\\)?\\|chap\\(?:heading\\|ter\\)\\|heading\\|majorheading\\|s\\(?:ection\\|ub\\(?:heading\\|s\\(?:ection\\|ub\\(?:heading\\|section\\)\\)\\)\\)\\|top\\|unnumbered\\(?:s\\(?:\\(?:ubs\\(?:ubs\\)?\\)?ec\\)\\)?\\)\\)\\>\\)" nil t)
                             ;; Insert the replacement regexp.
			     (let ((str (match-substitute-replacement nlines)))
			       (if str
(rplacd (assoc "спсСсылок" текЯкрНд) (let ((начСписокНод (cdr (assoc "спсСсылок" текЯкрНд))))
						   (add-to-list (quote начСписокНод) (concat (match-string-no-properties 2) "##Файл#" текИмяФайла "#Файл##")) начСписокНод))
