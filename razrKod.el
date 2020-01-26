Рег выражение для поиска команд структурирования
"^\\(?:@node\\>\\|\\(@\\(?:appendix\\(?:s\\(?:ec\\(?:tion\\)?\\|ubs\\(?:\\(?:ubs\\)?ec\\)\\)\\)?\\|chap\\(?:heading\\|ter\\)\\|heading\\|majorheading\\|s\\(?:ection\\|ub\\(?:heading\\|s\\(?:ection\\|ub\\(?:heading\\|section\\)\\)\\)\\)\\|top\\|unnumbered\\(?:s\\(?:\\(?:ubs\\(?:ubs\\)?\\)?ec\\)\\)?\\)\\)\\>\\)"

(let (спСсл (cdr (assoc "спсСсылок" текЯкрНд)))
((add-to-list спСсл (match-string-no-properties 2))
 )
(add-to-list 'текЯкрНд `(:спсСсылок ,(list (assoc :спсСсылок текЯкрНд) (match-string-no-properties 2))))
(assoc :k1 a1)


(rplacd (assoc "спсСсылок" текЯкрНд) (let ((начСписокНод (cdr (assoc "спсСсылок" текЯкрНд)))) (add-to-list (quote начСписокНод) (match-string-no-properties 2)) начСписокНод))

16.8 Disassembled Byte-Code

Люди не пишут байт-код; это задача байт компилятора. Но мы обеспечиваем дизассемблер
для удовлетворения любопытства. Ассемблер преобразует байт-код в скомпилирован
для восприятия человеком форме.

The byte-code interpreter is implemented as a simple stack machine. It pushes values onto a stack of its own, then pops them off to use them in calculations whose results are themselves pushed back on the stack. When a byte-code function returns, it pops a value off the stack and returns it as the value of the function.

In addition to the stack, byte-code functions can use, bind, and set ordinary Lisp variables, by transferring values between variables and the stack.
— Command: disassemble object &optional buffer-or-name

    This command displays the disassembled code for object. In interactive use, or if buffer-or-name is nil or omitted, the output goes in a buffer named ‘*Disassemble*’. If buffer-or-name is non-nil, it must be a buffer or the name of an existing buffer. Then the output goes there, at point, and point is left before the output.

    The argument object can be a function name, a lambda expression or a byte-code object. If it is a lambda expression, disassemble compiles it and disassembles the resulting compiled code. 

Here are two examples of using the disassemble function. We have added explanatory comments to help you relate the byte-code to the Lisp source; these do not appear in the output of disassemble.

     (defun factorial (integer)
       "Compute factorial of an integer."
       (if (= 1 integer) 1
         (* integer (factorial (1- integer)))))
          ⇒ factorial
     
     (factorial 4)
          ⇒ 24
     
     (disassemble 'factorial)
          -| byte-code for factorial:
      doc: Compute factorial of an integer.
      args: (integer)
     
     0   varref   integer        ; Get the value of integer
                                 ;   and push it onto the stack.
     1   constant 1              ; Push 1 onto stack.
     
     2   eqlsign                 ; Pop top two values off stack, compare
                                 ;   them, and push result onto stack.
     
     3   goto-if-nil 1           ; Pop and test top of stack;
                                 ;   if nil, go to 1,
                                 ;   else continue.
     6   constant 1              ; Push 1 onto top of stack.
     7   return                  ; Return the top element
                                 ;   of the stack.
     
     8:1 varref   integer        ; Push value of integer onto stack.
     9   constant factorial      ; Push factorial onto stack.
     10  varref   integer        ; Push value of integer onto stack.
     11  sub1                    ; Pop integer, decrement value,
                                 ;   push new value onto stack.
     12  call     1              ; Call function factorial using
                                 ;   the first (i.e., the top) element
                                 ;   of the stack as the argument;
                                 ;   push returned value onto stack.
     
     13 mult                     ; Pop top two values off stack, multiply
                                 ;   them, and push result onto stack.
     14 return                   ; Return the top element of stack.

The silly-loop function is somewhat more complex:

     (defun silly-loop (n)
       "Return time before and after N iterations of a loop."
       (let ((t1 (current-time-string)))
         (while (> (setq n (1- n))
                   0))
         (list t1 (current-time-string))))
          ⇒ silly-loop
     
     (disassemble 'silly-loop)
          -| byte-code for silly-loop:
      doc: Return time before and after N iterations of a loop.
      args: (n)
     
     0   constant current-time-string  ; Push
                                       ;   current-time-string
                                       ;   onto top of stack.
     
     1   call     0              ; Call current-time-string
                                 ;   with no argument,
                                 ;   pushing result onto stack.
     
     2   varbind  t1             ; Pop stack and bind t1
                                 ;   to popped value.
     
     3:1 varref   n              ; Get value of n from
                                 ;   the environment and push
                                 ;   the value onto the stack.
     4   sub1                    ; Subtract 1 from top of stack.
     
     5   dup                     ; Duplicate the top of the stack;
                                 ;   i.e., copy the top of
                                 ;   the stack and push the
                                 ;   copy onto the stack.
     6   varset   n              ; Pop the top of the stack,
                                 ;   and bind n to the value.
     
                                 ; In effect, the sequence dup varset
                                 ;   copies the top of the stack
                                 ;   into the value of n
                                 ;   without popping it.
     
     7   constant 0              ; Push 0 onto stack.
     8   gtr                     ; Pop top two values off stack,
                                 ;   test if n is greater than 0
                                 ;   and push result onto stack.
     
     9   goto-if-not-nil 1       ; Goto 1 if n > 0
                                 ;   (this continues the while loop)
                                 ;   else continue.
     
     12  varref   t1             ; Push value of t1 onto stack.
     13  constant current-time-string  ; Push current-time-string
                                       ;   onto top of stack.
     14  call     0              ; Call current-time-string again.
     
     15  unbind   1              ; Unbind t1 in local environment.
     16  list2                   ; Pop top two elements off stack,
                                 ;   create a list of them,
                                 ;   and push list onto stack.
     17  return                  ; Return value of the top of stack.
     *****************************************************************************************
flush-lines is an interactive compiled Lisp function.

(flush-lines REGEXP &optional RSTART REND INTERACTIVE)

Удаление строки, содержащей совпадение для REGEXP.
При вызове из Лиспа(и, как правило, при вызове в интерактивном режиме,
а также, смотрите ниже), относится к части буфера после точки.
Строка в точке удаляется, если и только если она содержит совпадение для
регулярного выражения, после точки.

Если REGEXP содержит символы верхнего регистра (за исключением тех,
которым предшествует '\') и ‘search-upper-case’ не-nil, совпадение
чувствительно к регистру.

Второй и третий аргумент RSTART и REND указывают регион для работы.
Строки частично содержащиеся в этой области будут удалены, только если они
содержат полное соответствие регулярному выражению.

Интерактивный, в режиме Transient Mark, когда метка активна, действует
на содержании региона. В противном случае, действуют от точки до конца
(доступной части) буфера. При вызове этой функции из Lisp, вы можете
сделать вид, что он был вызван в интерактивном режиме,
передавая не-ноль INTERACTIVE аргумент.

Если соответствие длится на несколько строк, все эти строки , подлежат удалению.
Они удаляются _перед_ ищет следующее совпадение. Таким образом, совпадение,
начиная с одной и той же строки, на которой законнчилось следующее совпадение игнорируется.
**********************************************************************
(defmacro setq-local (var val)
  "Установить переменную VAR к значению VAL в текущем буфере."
  ;; Нельзя использовать кавычку здесь, это слишком рано в загрузчике.
  (list 'set (list 'make-local-variable (list 'quote var)) val))
***********************************************************************
occur представляет собой интерактивную скомпилированую функцию Лиспа в `replace.el'.

Это связано с M-s o.

(occur REGEXP &optional NLINES)

Показать все строки в текущем буфере, содержащем соответствие с REGEXP.
Если матч спреды по нескольким линиям, все эти линии показаны.

Каждая строка отображается NLINES строк до и после, или -NLINES раньше,
если NLINES отрицательный.
NLINES по умолчанию `list-matching-lines-default-context-lines'.
При интерактивном вызове это префикс аргумент.

Строки показаны в буфере с именем `*Occur*'.
Он служит меню, чтобы найти какое-либо из вхождений в этом буфере.
h в этом буфере будет объяснить, как.

Если REGEXP содержит символы верхнего регистра (за исключением тех которым,
предшествуют `\') и `search-upper-case' это не-nil, согласование является
чувствительным к регистру.

Когда NLINES является строкой или когда функция вызывается в интерактивном
режиме с префиксом аргументом без номера (`C-u' отдельно в качестве префикса)
совпадающие строки собраны в буфер `*Occur*' с помощью NLINES в качестве
замены регулярного выражения.  NLINES может содержать \& и \N которые
конвенции следует `replace-match'.
Например, предоставление "defun\s +\(\S +\)" для REGEXP и
"\1" для NLINES собирает все имена функций в программе LISP.
Когда нет группировок подвыражений в REGEXP собирает всё совпадение.
В любом случае искомый буфер не изменяется.
**********************************************************************
(defun occur (regexp &optional nlines)
  "Show all lines in the current buffer containing a match for REGEXP.
If a match spreads across multiple lines, all those lines are shown.

Each line is displayed with NLINES lines before and after, or -NLINES
before if NLINES is negative.
NLINES defaults to `list-matching-lines-default-context-lines'.
Interactively it is the prefix arg.

The lines are shown in a buffer named `*Occur*'.
It serves as a menu to find any of the occurrences in this buffer.
\\<occur-mode-map>\\[describe-mode] in that buffer will explain how.

If REGEXP contains upper case characters (excluding those preceded by `\\')
and `search-upper-case' is non-nil, the matching is case-sensitive.

When NLINES is a string or when the function is called
interactively with prefix argument without a number (`C-u' alone
as prefix) the matching strings are collected into the `*Occur*'
buffer by using NLINES as a replacement regexp.  NLINES may
contain \\& and \\N which convention follows `replace-match'.
For example, providing \"defun\\s +\\(\\S +\\)\" for REGEXP and
\"\\1\" for NLINES collects all the function names in a lisp
program.  When there is no parenthesized subexpressions in REGEXP
the entire match is collected.  In any case the searched buffer
is not modified."
  (interactive (occur-read-primary-args))
  (occur-1 regexp nlines (list (current-buffer))))
****************************************************************
(defun occur-read-primary-args ()
  (let* ((perform-collect (consp current-prefix-arg))
         (regexp (read-regexp (if perform-collect
                                  "Collect strings matching regexp"
                                "List lines matching regexp")
                              'regexp-history-last)))
    (list regexp
	  (if perform-collect
	      ;; Perform collect operation
	      (if (zerop (regexp-opt-depth regexp))
		  ;; No subexpression so collect the entire match.
		  "\\&"
		;; Get the regexp for collection pattern.
		(let ((default (car occur-collect-regexp-history)))
		  (read-regexp
		   (format "Regexp to collect (default %s): " default)
		   default 'occur-collect-regexp-history)))
	    ;; Otherwise normal occur takes numerical prefix argument.
	    (when current-prefix-arg
	      (prefix-numeric-value current-prefix-arg))))))
**************************************************************************
(defun read-regexp (prompt &optional defaults history)
  "Read and return a regular expression as a string.
Prompt with the string PROMPT.  If PROMPT ends in \":\" (followed by
optional whitespace), use it as-is.  Otherwise, add \": \" to the end,
possibly preceded by the default result (see below).

The optional argument DEFAULTS can be either: nil, a string, a list
of strings, or a symbol.  We use DEFAULTS to construct the default
return value in case of empty input.

If DEFAULTS is a string, we use it as-is.

If DEFAULTS is a list of strings, the first element is the
default return value, but all the elements are accessible
using the history command \\<minibuffer-local-map>\\[next-history-element].

If DEFAULTS is a non-nil symbol, then if `read-regexp-defaults-function'
is non-nil, we use that in place of DEFAULTS in the following:
  If DEFAULTS is the symbol `regexp-history-last', we use the first
  element of HISTORY (if specified) or `regexp-history'.
  If DEFAULTS is a function, we call it with no arguments and use
  what it returns, which should be either nil, a string, or a list of strings.

We append the standard values from `read-regexp-suggestions' to DEFAULTS
before using it.

If the first element of DEFAULTS is non-nil (and if PROMPT does not end
in \":\", followed by optional whitespace), we add it to the prompt.

The optional argument HISTORY is a symbol to use for the history list.
If nil, uses `regexp-history'."
  (let* ((defaults
	   (if (and defaults (symbolp defaults))
	       (cond
		((eq (or read-regexp-defaults-function defaults)
		     'regexp-history-last)
		 (car (symbol-value (or history 'regexp-history))))
		((functionp (or read-regexp-defaults-function defaults))
		 (funcall (or read-regexp-defaults-function defaults))))
	     defaults))
	 (default     (if (consp defaults) (car defaults) defaults))
	 (suggestions (if (listp defaults) defaults (list defaults)))
	 (suggestions (append suggestions (read-regexp-suggestions)))
	 (suggestions (delete-dups (delq nil (delete "" suggestions))))
	 ;; Do not automatically add default to the history for empty input.
	 (history-add-new-input nil)
	 (input (read-from-minibuffer
		 (cond ((string-match-p ":[ \t]*\\'" prompt)
			prompt)
		       ((and default (> (length default) 0))
			 (format "%s (default %s): " prompt
				 (query-replace-descr default)))
		       (t
			(format "%s: " prompt)))
		 nil nil nil (or history 'regexp-history) suggestions t)))
    (if (equal input "")
	;; Return the default value when the user enters empty input.
	(prog1 (or default input)
	  (when default
	    (add-to-history (or history 'regexp-history) default)))
      ;; Otherwise, add non-empty input to the history and return input.
      (prog1 input
	(add-to-history (or history 'regexp-history) input)))))
**********************************************************************
(let ((текСсылки (assoc "спсСсылок" текЗаписьНода)))
  (if tkSpsSSl
      (add-to-list 'текСсылки allSovp)
    (setcdr 'текСсылки newSps)))
****************************************************************
Тема: Ассоциативный список
Тема: Associative list

Вопрос: Ниже приведен код, содержимое списка myList скопировал в отладчике.

("спсСсылок" "@ref{Bash Features}")

Question: The code is below, the contents of the list myList were copied in the debugger.
(let* ((myList '(("Concept Index" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Concept Index") ("спсСсылок")) ("Function Index" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Function Index") ("спсСсылок" "@ref{Bash Features}")) ("Variable Index" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Variable Index") ("спсСсылок" "@ref{Bash Features}")) ("Reserved Word Index" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Reserved Word Index") ("спсСсылок" "@ref{Bash Features}")) ("Builtin Index" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Builtin Index") ("спсСсылок" "@ref{Bash Features}")) ("Indexes" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Indexes") ("спсСсылок" "@ref{Bash Features}")) ("GNU Free Documentation License" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node GNU Free Documentation License") ("спсСсылок" "@ref{Bash Features}")) ("Major Differences From The Bourne Shell" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Major Differences From The Bourne Shell") ("спсСсылок" "@ref{Bash Features}")) ("Reporting Bugs" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Reporting Bugs") ("спсСсылок" "@ref{Bash Features}")) ("Optional Features" ("Файл" "/home/alamd/example/funEl/expirement/perevod_bash6/bash.texi") ("ТочкаНоды" "@node Optional Features") ("спсСсылок" "@ref{Bash Features}")))) (текАссоц (assoc "спсСсылок" (assoc "Optional Features" myList))) (текСписСсылок (cdr текАссоц)))
  (setcdr текАссоц (add-to-list 'текСписСсылок "hudoSsulka")) myList)


\\(?2:@xref{\\(?1:[^,}]+\\)\\(?:,[^}]+}\\|}\\)\\)

Код отрабатывает как ожидалось, в ассоциативном списке с ассоциацией "Optional Features", в ассоциативном списке с ассоциацией "спсСсылок" добавляется элемент "hudoSsulka". Однако на настоящем коде:
The code fulfills as expected, in the associative list with the association "Optional Features", in the associative list with the association "cpsLinks" the element "hudoSsulka" is added. However, on this code:

(let* ((myList спЯкрНд) (текАссоц (assoc "спсСсылок" (assoc (match-string-no-properties 1) myList))) (текСпсСсылок (cdr текАссоц)))
  (setcdr текАссоц (add-to-list (quote текСпсСсылок) (match-string-no-properties 0))) myList)

заполняются все без разбора родителя ассоциации "спсСсылок". Почему так происходит?
all indiscriminately the parent of the "cpsLinks" association is populated. Why it happens?

Спасибо, за ответ. Я воспроизвёл здесь часть реального списка, скопировав в отладчике. В коде этот список передаётся в параметре.

*************************************************************************************
Эффект, который вы описываете, возникает, когда вы используете один и тот же подсписок для построения своего списка, а не просто равные подсписки.Один и тот же список остается связанным со всеми ключами вашего списка, и вы можете адресовать этот же и единственный подсписок через все ключи. Когда вы получаете доступ к этому списку через один из ключей и изменяете его, эта модификация видна во всех записях списка.Далее следует упрощенный пример. Сначала мы определяем SUBLIST. После этого мы создаем список с ключами 1, 2, с которым связываем тот же самый SUBLIST. После этого мы изменяем список, связанный с 2, перезаписывая с помощью A.

(let* ((SUBLIST '(a b))
       (alist (mapcar (lambda (x)
               (cons x SUBLIST))
             '(1 2))))
  (setcar (cdr (assoc 2 alist)) 'A)
  alist)

Результат:

((1 A b) (2 A b))

Мы видим тот же модифицированный подсписок (A B), связанный с обоими ключами 1 и 2.

Лечение вашей проблемы просто: не ассоциирует тот же список для всех ключей, но только копий этого:

(let* ((SUBLIST '(a b))
       (alist (mapcar (lambda (x)
               (cons x (seq-copy SUBLIST)))
             '(1 2))))
  (setcar (cdr (assoc 2 alist)) 'A)
  alist)

Теперь вы получите результаты, как вы ожидаете их:

((1 a b) (2 A b))

**************************************
Another warning is in place if you have nested alists:
(setq COPY (seq-copy SUBLIST)) produces a shallow copy of your list SUBLIST. If some car of the conses of SUBLIST contains a list CARLIST then only the link to CARLIST is copied not CARLIST itself. If you actually want copies of CARLIST in COPY you should use cl-copy-tree instead of seq-copy.
Еще одно предупреждение на месте, если у вас есть вложенные alists:
(setq COPY (seq-copy SUBLIST)) производит неполную копию вашего списка SUBLIST. Если какой-то car из conses в
SUBLIST содержит список CARLIST только тогда ссылка на CARLIST копируется не CARLIST себя. Если вы
действительно хотите копии CARLIST в COPY вы должны использовать cl-copy-tree вместо seq-copy.
***************************************
Как указывалось выше, ваш вопрос не является воспроизводимым или совсем понятно, но я сильно подозреваю, что вы можете быть сталкиваясь проблемы из-за изменения котируемой списка. See emacs.stackexchange.com/q/51749/15748, emacs.stackexchange.com/q/20535/15748, and emacs.stackexchange.com/q/45814/15748. Never call setcdr directly on a quoted list, i.e. one created as '(...). Вместо этого, либо создать список со списком, или сначала сделать копию с copy-sequence or similar. –
********************************************
cl-pushnew is a Lisp macro in `cl-lib.el'.

(cl-pushnew X PLACE [KEYWORD VALUE]...)

(cl-pushnew X PLACE): вставить X во главе списка, если уже не там. Как (push X PLACE), за исключением того, что список не изменялся, если X является `eql' к элементу уже в списке.
************************************************

(defun add-to-list (list-var element &optional append compare-fn)
  "Добавить ELEMENT к значению LIST-VAR, если он еще не там. 
Тест на наличие ELEMENT делается с `equal', или с COMPARE-FN, если это non-nil.
Если ELEMENT добавляется, он добавляется в начало списка, 
если необязательный аргумент APPEND не non-nil, то ELEMENT добавляется
в конец списка.

Возвращаемое значение новое значение LIST-VAR.

Это удобно, чтобы добавить некоторые элементы переменных конфигурации, 
но, пожалуйста, не ругайте его в Elisp коде, лучше использовать 
`push' или `cl-pushnew'.

Если вы хотите использовать `add-to-list' на переменную, которая 
не определена, пока не будет загружен определенный пакет, 
вы должны поместить вызов `add-to-list' в функцию крючка, 
которая будет запущена только после загрузки пакета.  
`eval-after-load' предоставляет один из способов сделать это. 
В некоторых случаях другие крючки, такие как режим 
основных крючков, может сделать эту работу."
  (declare
   (compiler-macro
    (lambda (exp)
      ;; ИСПРАВЬ МЕНЯ: Нечто подобное можно было бы использовать для `set', а также.
      (if (or (not (eq 'quote (car-safe list-var)))
              (special-variable-p (cadr list-var))
              (not (macroexp-const-p append)))
          exp
        (let* ((sym (cadr list-var))
               (append (eval append))
               (msg (format "`add-to-list' can't use lexical var `%s'; use `push' or `cl-pushnew'"
                            sym))
               ;; Большой некрасивый хак поэтому мы только
	       ;; выведем предупреждение во время байт-компиляции, и поэтому мы можем
	       ;; использовать byte-compile-not-lexical-var-p, чтобы отключить
	       ;; предупреждение, когда DefVar был виден, но еще не выполнен.
               (warnfun (lambda ()
                          ;; FIXME: Мы должны также выдавать предупреждение на
			  ;; обязательное динамическое связывание переменных.
                          (when (assq sym byte-compile--lexical-environment)
                            (byte-compile-log-warning msg t :error))))
               (code
                (macroexp-let2 macroexp-copyable-p x element
                  `(if ,(if compare-fn
                            (progn
                              (require 'cl-lib)
                              `(cl-member ,x ,sym :test ,compare-fn))
                          ;; Для самонастройки причин, не полагаться на
			  ;; cl--compiler-macro-member для базового случая.
                          `(member ,x ,sym))
                       ,sym
                     ,(if append
                          `(setq ,sym (append ,sym (list ,x)))
                        `(push ,x ,sym))))))
          (if (not (macroexp--compiling-p))
              code
            `(progn
               (macroexp--funcall-if-compiled ',warnfun)
               ,code)))))))
  (if (cond
       ((null compare-fn)
	(member element (symbol-value list-var)))
       ((eq compare-fn 'eq)
	(memq element (symbol-value list-var)))
       ((eq compare-fn 'eql)
	(memql element (symbol-value list-var)))
       (t
	(let ((lst (symbol-value list-var)))
	  (while (and lst
		      (not (funcall compare-fn element (car lst))))
	    (setq lst (cdr lst)))
          lst)))
      (symbol-value list-var)
    (set list-var
	 (if append
	     (append (symbol-value list-var) (list element))
	   (cons element (symbol-value list-var))))))
**********************************************************
(memq ELT LIST)

Возвращение non-nil если ELT является элементом LIST. Сравнение сделано с `eq'.
Значение на самом деле хвост LIST чей автомобиль ELT.
***********************************************************
(memql ELT LIST)

Возвращение non-nil если ELT является элементом LIST. Сравнение сделано с `eql'.
Значение на самом деле хвост LIST чей автомобиль ELT.
*************************************************************
(member ELT LIST)

Возвращение non-nil если ELT является элементом LIST. Сравнение сделано с `equal'.
Значение на самом деле хвост LIST чей автомобиль ELT.
**************************************************************

(symbol-value SYMBOL)

Возвращает значение SYMBOL's значения. Ошибка, если это является недействительным.
Обратите внимание, что если `lexical-binding' задейсвована, это
возвращает глобальное значение за пределами какой-либо лексической области.
**************************************************************
lexical-binding is a variable defined in `lread.c'.
Его значение равно nil

  Автоматически становится buffer-local, когда пождключается.
  Эта переменная является безопасной, как локальная переменная файла,
  если ее значение удовлетворяет предикату `booleanp'.

Документация:
Следует ли использовать лексическое связывание при оценке кода.
Non-nil означает, что код в текущем буфере должен быть оценен с лексическим связыванием.
Эта переменная автоматически устанавливается из файла переменных интерпретируемого
файла Lisp чтения с помощью `load'. В отличие от других локальных файловых переменных,
она должна быть установлена в первой строке файла.
******************************************************************
(booleanp OBJECT)

Возвращение t если OBJECT является одним из двух канонических булевых значений: t или nil.
В противном случае возврашает nil.
******************************************************************
(let VARLIST BODY...)

Привязка переменных в соответствии с VARLIST затем Eval BODY.
Значение последней формы в BODY возвращается.
Каждый элемент VARLIST является символом (который привязан к nil) или
список (SYMBOL VALUEFORM) (который связывает SYMBOL со значением VALUEFORM).
Все VALUEFORMs вычисляются перед связыванием с символом.
*********************************************************************
(eq OBJ1 OBJ2)

Возвращение t если два аргумента один и тот же объект Лиспа.
***********************************************************************
(eql OBJ1 OBJ2)

Возвращение t если два аргумента такого же объект Лиспа.
Равноценные числа с плавающей точкой являются ‘eql’, и они не могут быть ‘eq’.
*************************************************************************
(equal O1 O2)

Возвращает t, если два объекта Лисп имеет сходную структуру и содержание.
Они должны иметь одинаковый тип данных.
Cons ячейки сравниваются путем сравнения cars и cdrs.
Векторы и строки сравниваются поэлементно.
Числа сравниваются по значению, но целые числа, не может сравниться с
числами с плавающими точками.
(Используйте ‘=’ если вы хотите сравнивать целые числа и числа с плавающей
      точкой, чтобы иметь возможность сравнить.)
Символы должны точно совпадать.
