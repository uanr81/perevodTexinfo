(defun VudSsulky ()
  "Выделить ссылку целиком и разобрать её на параметры"
  (interactive)
  (goto-char (point-min))
  (while (and (< (point) (point-max))
		(re-search-forward 
		 "^@node\>\(?1:.+\)\|\(?2:\(@\(?:appendix\(?:s\(?:ec\(?:tion\)?\|ubs\(?:\(?:ubs\)?ec\)\)\)?\|chap\(?:heading\|ter\)\|heading\|majorheading\|s\(?:ection\|ub\(?:heading\|s\(?:ection\|ub\(?:heading\|section\)\)\)\)\|top\|unnumbered\(?:s\(?:\(?:ubs\(?:ubs\)?\)?ec\)\)?\)\).+\)" nil t))) 
      )


;  (defun count-occurences (regex string)
;  (recursive-count regex string 0))

 (defun количествоВложенныхСкобок (regex string start)
  (if (string-match regex string start)
      (+ 1 (количествоВложенныхСкобок regex string (match-end 0)))
    0))
