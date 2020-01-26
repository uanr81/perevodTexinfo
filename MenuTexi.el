(defun vstPrvAnkr ()
  "Замена переведенных ссылок на ноды"
  (interactive)
  (let ( line ткБфр
	 (spisPerev (list))
	 (spsFile (list)))
;;;Чешем в начало буфера
    (goto-char (point-min))
    (while (not (eobp))
      (setq line (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
      (cond ((string-match "##\\*\\(?1:.+\\)\\*##Првд#\\*\\*\\(?2:.+\\)\\*\\*#" line)
	     (add-to-list 'spisPerev (cons (match-string-no-properties 1 line) (match-string-no-properties 2 line))))
	    ((string-match "\\*\\{3\\}ОбрФайл\\*\\{3\\}\\(?1:.+\\)*?\\*\\{3\\}" line)
	     (add-to-list 'spsFile (match-string-no-properties 1 line))))
      (forward-line 1))
    (dolist (ткФайл spsFile)
;;;Создаем буфер и сохраняем его имя
      (setq ткБфр (find-file-noselect ткФайл))
;;;Переключаемся в созданный буфер
      (switch-to-buffer ткБфр)
;;;Чешем в начало буфера
      (goto-char (point-min))
      (dolist (ткЗамена spisPerev)
	(while (search-forward (car ткЗамена) nil t)
	  (replace-match (cdr ткЗамена)))
	(goto-char (point-min))
	)
      ;(let ((current-prefix-arg '(4)))
;	(texinfo-master-menu))
      (ignore-errors
	(texinfo-all-menus-update))
      (write-file ткФайл)
      (kill-buffer ткБфр)
      )
    (СоздатьНовоеМеню spsFile)
    ))

(defun СоздатьНовоеМеню (spsFiles)
  (let ((ткФайл (ido-completing-read "Выберите главный файл texi из списка: " spsFiles)))
;;;Создаем буфер и сохраняем его имя
					;(setq ткБфр (find-file-noselect ткФайл))
;;;Переключаемся в созданный буфер
					;(switch-to-buffer ткБфр)
    (texinfo-multiple-files-update ткФайл t nil)
    (write-file ткФайл)
    (setq ткБфр (find-file-noselect ткФайл))
    (switch-to-buffer ткБфр)
    (kill-buffer ткБфр)
    (setq spsFiles (delete ткФайл spsFiles))
    (dolist (ткПутьФайл spsFiles)
      (setq ткБфр (find-file-noselect ткПутьФайл))
      (switch-to-buffer ткБфр)
      (write-file ткФайл)
      (kill-buffer ткБфр)
      )
    )
  )


(defun crtTrnsSAnkr ()
  "Создание файла для перевода ссылок на ноды"
  (interactive)
;;;спсВклФйл список подключаемых файлов
;;;спсЯкр список якорей
;;;спсСсылок список ссылок
;;;бфрПрв имя буфера для перевода
  (let* ( nameBufPerevod BufPerevod 
;;;вводим имя файла перевода
	 (имяФайлаПеревода (read-string "имя файла перевода якорей:" nil nil (concat (file-name-directory buffer-file-name) "perevod")))
	 (спсВклФйл (ПлчПдклФйл))
	 (общСпис (ПлчСпсЯкр спсВклФйл))
	 (спсЯкр (cdr (assoc "Якоря" общСпис)))
	 (спсСодержание (cdr (assoc "Содержание" общСпис)))
	 (спсЯкр (ПлчСпсСсылок спсВклФйл спсЯкр))
	 )
;;;имя буфера перевода
    (setq nameBufPerevod " буферПеревода")
;;;создаём буфер и сохраняем в переменную 
    (setq BufPerevod (generate-new-buffer nameBufPerevod))
;;;Переключаемся в созданный буфер
    (set-buffer BufPerevod)
;;;чешем в начало
    (goto-char (point-min))
;;;Выводим все обработанные файлы
    (dolist (ткПутьФайл спсВклФйл)
      (insert (concat "***ОбрФайл***" ткПутьФайл "***"))
      (newline 1)
      )
;;;Выводим все якоря по одному в строку в созданный буфер
    (dolist (ткЯкрНд спсЯкр)
      (insert (concat "ЯкрНд**#" (car ткЯкрНд) "#**#_Фйл_#" (car (cdr (assoc "Файл" ткЯкрНд))) "#_кнФйл_#"))
      (newline 1)
      (insert (concat "ТчкНд***" "##*" (car (cdr (assoc "ТочкаНоды" ткЯкрНд))) "*##" "Првд" "#**" (car (cdr (assoc "ТочкаНоды" ткЯкрНд))) "**#"))
      (if (cdr (assoc "спсСсылок" ткЯкрНд)) 
	  (progn (newline 1)
		 (insert (concat "***СсылкиНаНоду#" (car ткЯкрНд) "#***"))
		 (dolist (ткСсылка (cdr (assoc "спсСсылок" ткЯкрНд)))
		   (newline 1)
		   (insert (concat "##*" ткСсылка "*##" "Првд" "#**" ткСсылка "**#")))
		 (newline 1)
		 (insert (concat "***КонецСсылкиНаНоду#" (car ткЯкрНд) "#***"))))
      (if (cdr (assoc "спсСдрж" ткЯкрНд)) 
	  (progn (newline 1)
		 (insert (concat "***СтруктураНоды#" (car ткЯкрНд) "#***"))
		 (dolist (ткСтрктНд (cdr (assoc "спсСдрж" ткЯкрНд)))
		   (newline 1)
		   (insert (concat "##*" ткСтрктНд "*##" "Првд" "#**" ткСтрктНд "**#")))
		 (newline 1)
		 (insert (concat "***КонецСтруктураНоды#" (car ткЯкрНд) "#***"))))
      (newline 1)
      (insert (concat "***КонецНода_#_" (car ткЯкрНд) "_#_***"))
      (newline 1)
      )
    (if (> (length спсСодержание) 0)
	(progn (insert "Описание Структур не вошедших в ноды")
	       (dolist (ткСтрктБезНоды спсСодержание)
		 (newline 1)
		   (insert (concat "##*" ткСтрктБезНоды "*##" "Првд" "#**" ткСтрктБезНоды "**#")))
	       (newline 1)
	       (insert (concat "***КонецОписанияСтруктур"))
	       ))
    (write-file имяФайлаПеревода)
    (kill-buffer BufPerevod)
    )
  )

;;; функция ПлчПдклФйл возвращает список путей всех включаемых конструкцией @include файлов
(defun ПлчПдклФйл ()
  (let* ((спсВклФйл (list buffer-file-name)) (спсДляОбхода (list buffer-file-name)) (спсОбрФайлов (list))
							   (спсВклФйл (РкрсСздСпсФйлв спсДляОбхода спсОбрФайлов спсВклФйл)))
    спсВклФйл
    )
  )
;;;ПлчСпсЯкр функция возвращает список якорей файлов  
(defun ПлчСпсЯкр (списокФайлов)
;;;спсЯкр переменная для списка якорей файлов в спФйл
  (let* (
	 спсОбщий
	 (спсЯкр (list "Якоря"))
	 (спсСдр (list "Содержание"))
	 ткБфр)
    ;;;Перебираем список с путями к файлам
    (dolist (текИмяФайла списокФайлов)
;;;Создаем буфер и сохраняем его имя
      (setq ткБфр (find-file-noselect текИмяФайла))
;;;Переключаемся в созданный буфер
      (switch-to-buffer ткБфр)
;;;Чешем в начало буфера
      (goto-char (point-min))
;;;Ищем якоря и добавляем их в список
      (while (and (< (point) (point-max))
		  (re-search-forward 
;;;Ищем ноду или якорь, добавляем в список
		   "^\\(?2:@node[[:space:]]+\\(?1:.+\\),?.*\\)\\|\\(?2:@anchor{\\(?1:[^}]+\\)}+?\\)" (point-max) t))
	(let* ((line (match-string-no-properties 2)) (soderjanie (match-string-no-properties 1)) (newSps `(,soderjanie ("Файл" ,текИмяФайла) ("ТочкаНоды" ,line) ,(cons "спсСсылок" nil) ,(cons "спсСдрж" nil))))
			 ;  (newSps (list (list soderjanie (cons "Файл" (cons текИмяФайла nil)) (cons "ТочкаНоды" (cons line nil)) (list "спсСсылок")))))
			;(add-to-list 'списокЯкорей `(,soderjanie ("Файл" ,текИмяФайла) ("ТочкаНоды" ,line) ,(seq-copy spsSsl)))
		      ;(if (not (member soderjanie списокЯкорей))
	;	  (setcdr (last списокЯкорей) newSps))
	  (setcdr (last спсЯкр) (add-to-list 'спсЯкр newSps t))
	  ;(setcdr (last спсЯкр) newSps)
	  )
	)
;;;Ищем команды структурирования
      (goto-char (point-min))
      (let (vNode imiaNodu)
	(while (and (< (point) (point-max))
		    (re-search-forward 
;;;Ищем ноду c структурированием, если находим описание структуры добавляем в список к нужной ноде
		     "^@node\\>[[:blank:]]+\\(?1:.+\\)\\|\\(?1:\\(@\\(?:appendix\\(?:s\\(?:ec\\(?:tion\\)?\\|ubs\\(?:\\(?:ubs\\)?ec\\)\\)\\)?\\|chap\\(?:heading\\|ter\\)\\|heading\\|majorheading\\|s\\(?:ection\\|ub\\(?:heading\\|s\\(?:ection\\|ub\\(?:heading\\|section\\)\\)\\)\\)\\|top\\|unnumbered\\(?:s\\(?:\\(?:ubs\\(?:ubs\\)?\\)?ec\\)\\)?\\)\\).+\\)" nil t))
	  (let ((vsiaStroka (match-string-no-properties 0)) (dn (match-string-no-properties 1)))
	    (if (numberp (string-match "@node" vsiaStroka))
		(progn (setq vNode t) (setq imiaNodu dn))
	      (if vNode
		  (let ((спсСдржн (assoc "спсСдрж" (assoc imiaNodu спсЯкр))))
		    (setcdr (last спсСдржн) (cdr (add-to-list 'спсСдржн dn t))))
		(add-to-list 'спсСдр dn t)
		))
	    )))
		    ;(if (not (member (match-string-no-properties 0) списокОглавления))
		;	  (setcdr (last списокОглавления) (cons (match-string-no-properties 0) nil)))
	;(let* ((line (match-string-no-properties 0)))
	;  (add-to-list 'спсСдр (match-string-no-properties 0) t))
	;)       
;;;Удаляем обработанный буфер
      (kill-buffer ткБфр))
    (setq спсОбщий (list спсЯкр спсСдр))
    спсОбщий)
  )



;;;ПлчСпсСсылок функция возвращает список прекрестных ссылок  
(defun ПлчСпсСсылок (списокФайлов спЯкрНд)
;;;спсЯкр переменная для списка перекрестных ссылок якорей файлов в спФйл
;;;ткБфр для имени буфера обработки
  (let (ткБфр)
;;;Перебираем список с путями к файлам
    (dolist (текИмяФайла списокФайлов спЯкрНд)
;;;Создаем буфер и сохраняем его имя
      (setq ткБфр (find-file-noselect текИмяФайла))
;;;Переключаемся в созданный буфер
      (switch-to-buffer ткБфр)
;;;Чешем в начало буфера
      (goto-char (point-min))
;;;Ищем перекрестные ссылки и добавляем их в список
      (while (and (< (point) (point-max))
		  (re-search-forward 
		   "\\(?2:@xref{\\(?1:[^,}]+\\)\\)\\|\\(?2:@ref{\\(?1:[^,}]+\\)\\)\\|\\(?2:@pxref{\\(?1:[^,}]+\\)\\)\\|\\(?2:@inforef{\\(?1:[^,}]+\\)\\)" nil t))
	(let* ((nd (match-string-no-properties 1)) (спсИзм (assoc "спсСсылок" (assoc nd спЯкрНд))) sslk)
	  (if (string= (string (following-char)) "}")
	      (progn (forward-char) (setq sslk (buffer-substring-no-properties (match-beginning 2) (point))))
	    (let* ((нчлСслк (match-beginning 2)) (пзПрвОткрСкбк (match-beginning 1))
		   (клОткр 1) (клЗкр 0))
	      (while (/= клОткр клЗкр)
		(progn (re-search-forward "[^@]\\(?3:}\\)\\|[^@]\\(?3:{\\)" nil t)
		       (cond ((string= (match-string-no-properties 3) "}") (setq клЗкр (1+ клЗкр)))
			     ((string= (match-string-no-properties 3) "{") (setq клОткр (1+ клОткр))))))
	      (setq sslk (buffer-substring-no-properties нчлСслк (match-end 0)))))
	  (if (and спсИзм (not (member sslk спсИзм)))
	      (setcdr (last спсИзм) (list sslk)))
	))

        ;;;Удаляем обработанный буфер
      (kill-buffer ткБфр)
      )
;;;Возвращаем список ссылок
    спЯкрНд
    )
 )

(defun РкрсСздСпсФйлв (спсДляОбхода спсОбойденных спсФайлов)
;;;tkBfr для хранения имени буфера, tkPth для найденного файла,tkFl текущий файл буфера
  (let* (tkBfr tkPth (tkFl (car спсДляОбхода)))
      ;;;Убираем первый элемент списка, текущий файл обработан 
    (setq спсДляОбхода (cdr спсДляОбхода))
      ;;;Создаем буфер и сохраняем его имя
    (setq tkBfr (find-file-noselect tkFl))
      ;;;Переключаемся в созданный буфер
    (switch-to-buffer tkBfr)
      ;;;Чешем в начало буфера
    (add-to-list 'спсОбойденных tkFl)
    (goto-char (point-min))
    (while (and (< (point) (point-max))
		(re-search-forward 
		 "^@include[[:space:]]+\\([A-Za-z]+.?[A-Za-z]*\\)$" (point-max) t))
      (setq tkPth (expand-file-name (match-string-no-properties 1) (file-name-directory buffer-file-name)))
      (if (not (member tkPth спсОбойденных))
	  (progn (add-to-list 'спсФайлов tkPth)
		 (add-to-list 'спсДляОбхода tkPth)))
      	)
    (kill-buffer tkBfr)
    )
  (if (not (eq спсДляОбхода nil))
      (РкрсСздСпсФйлв спсДляОбхода спсОбойденных спсФайлов))
  спсФайлов
  )
  
