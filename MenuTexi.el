(defun vstPrvAnkr ()
  "Замена переведенных ссылок на ноды"
  (interactive)
  (let ( line
	 (spisPerev (list))
	 (spsFile (list)))
;;;Чешем в начало буфера
    (goto-char (point-min))
    (while (not (eobp))
      (setq line (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
      (cond ((string-match "##\\*\\(?1:.+\\)\\*##Перевод#\\*\\*\\(?2:.+\\)\\*\\*#" line)
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
  (let (ткБфр (ткФайл (ido-completing-read "Выберите главный файл texi из списка: " spsFiles)))
;;;Создаем буфер и сохраняем его имя
      (setq ткБфр (find-file-noselect ткФайл))
;;;Переключаемся в созданный буфер
      (switch-to-buffer ткБфр)
      (let ((current-prefix-arg '(4)))
        (texinfo-multiple-files-update))
      (write-file ткФайл)
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
  (let* (
;;;вводим имя файла перевода
	 (имяФайлаПеревода (read-string "имя файла перевода якорей:" nil nil (concat (file-name-directory buffer-file-name) "perevod")))
	 (спсВклФйл (ПлчПдклФйл))
	 (спсЯкр (ПлчСпсЯкр спсВклФйл))
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
      (insert (concat "ЯкрНд**#" (cdr (assoc "ЯкорьНода" ткЯкрНд)) "#**#_Фйл_#" (cdr (assoc "Файл" ткЯкрНд)) "#_кнФйл_#"))
      (newline 1)
      (insert (concat "ТчкНд***" "##*" (cdr (assoc "ТочкаНоды" ткЯкрНд)) "*##" "Првд" "#**" (cdr (assoc "ТочкаНоды" ткЯкрНд)) "**#"))
      (newline 1)
      (insert (concat "СдржНд***" "##*" (cdr (assoc "СдржНд" ткЯкрНд)) "*##" "Првд" "#**" (cdr (assoc "СдржНд" ткЯкрНд)) "**#"))
      (newline 1)
      (insert (concat "***СсылкиНаНоду#" (cdr (assoc "ЯкорьНода" ткЯкрНд)) "#***"))
      (dolist (ткСсылка (cdr (assoc "спсСсылок" ткЯкрНд)))
	(newline 1)
	(cond ((string-match "\\(?1:.+\\)##Файл#\\(?2:.+\\)#Файл##" ткСсылка)
	       (insert (concat "##*" (match-string-no-properties 1 ткСсылка) "*##" "Првд" "#**" (match-string-no-properties 1 ткСсылка) "**#_Фйл_#" (match-string-no-properties 2 ткСсылка) "#_кнцФйл_#")))))
      (newline 1)
      (insert (concat "***КонецСсылкиНаНоду#" (cdr (assoc "ЯкорьНода" ткЯкрНд)) "#***"))
      (newline 1)
      (insert (concat "***КонецНода_#_" (cdr (assoc "ЯкорьНода" ткЯкрНд)) "_#_***")
	      )
      (newline 1)
      )
    (write-file имяФайлаПеревода)
    (kill-buffer BufPerevod)
    )
  )

;;; функция ПлчПдклФйл возвращает список путей всех включаемых конструкцией @include файлов
(defun ПлчПдклФйл ()
  (let ((спсВклФйл (list))(спсДляОбхода (list))(спсОбрФайлов (list)))
    (add-to-list 'спсДляОбхода buffer-file-name)
    (add-to-list 'спсВклФйл buffer-file-name)
    (setq спсВклФйл (РкрсСздСпсФйлв спсДляОбхода спсОбрФайлов спсВклФйл))
    спсВклФйл
    )
  )
;;;ПлчСпсЯкр функция возвращает список якорей файлов  
(defun ПлчСпсЯкр (списокФайлов)
;;;спсЯкр переменная для списка якорей файлов в спФйл
  (let (
	(списокЯкорей (list))
	ткБфр)
;;;Перебираем список с путями к файлам
    (dolist (текИмяФайла списокФайлов списокЯкорей)
;;;Создаем буфер и сохраняем его имя
      (setq ткБфр (find-file-noselect текИмяФайла))
;;;Переключаемся в созданный буфер
      (switch-to-buffer ткБфр)
;;;Чешем в начало буфера
      (goto-char (point-min))
;;;Ищем якоря и добавляем их в список
      (while (and (< (point) (point-max))
		  (re-search-forward 
		   "\\(?1:^@node[[:space:]]+\\(?2:.+\\)\\)\n\\(?4:@[^[:punct:]]\\(?5:.+\\)\\)\\|\\(?1:@anchor{\\(?2:.+\\)}+?\\)" (point-max) t)
		  (add-to-list 'списокЯкорей (list (cons "ЯкорьНода" (match-string-no-properties 2)) (cons "Файл" текИмяФайла) (cons "ТочкаНоды" (match-string-no-properties 1)) (cons "СдржНд" (match-string-no-properties 4)) (cons "спсСсылок" '())))
		  )
	)
;;;Удаляем обработанный буфер
      (kill-buffer ткБфр)
      )
    списокЯкорей
    )
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
		   "\\(?2:@xref{\\(?1:[^,}]+\\)\\(?:,[^}]+}\\|}\\)\\)[.,]\\|\\(?2:@ref{\\(?1:[^,}]+\\)\\(?:,[^}]+}\\|}\\)\\)[.,)]\\|\\(?2:(@pxref{\\(?1:[^,}]+\\)\\(?:,[^}]+}\\|}\\))\\)\\|\\(?2:@inforef{\\(?1:[^,}]+\\)\\(?:,[^}]+}\\|}\\)\\)[.,]" (point-max) t))
					;Перебираем список ЯкорьНода чтобы найти ту на которую ссылается ссылка
	(dolist (текЯкрНд спЯкрНд)
	  (when (string= (match-string-no-properties 1) (cdr (assoc "ЯкорьНода" текЯкрНд)))
					;есть совпадение, помещаем в список найденной ноды *СсылкиНаНоду* найденную ссылку
	    (rplacd (assoc "спсСсылок" текЯкрНд) (let ((начСписокНод (cdr (assoc "спсСсылок" текЯкрНд))))
						   (add-to-list (quote начСписокНод) (concat (match-string-no-properties 2) "##Файл#" текИмяФайла "#Файл##")) начСписокНод))
	    )
	  )
	)
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
      (add-to-list 'спсФайлов tkPth)
      (if (not (seq-contains спсОбойденных tkPth))
	  (add-to-list 'спсДляОбхода tkPth)))
    (kill-buffer tkBfr)
    )
  (if (not (eq спсДляОбхода nil))
      (РкрсСздСпсФйлв спсДляОбхода спсОбойденных спсФайлов))
  спсФайлов
  )
	
