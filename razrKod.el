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
  "Set variable VAR to value VAL in current buffer."
  ;; Can't use backquote here, it's too early in the bootstrap.
  (list 'set (list 'make-local-variable (list 'quote var)) val))
***********************************************************************
occur is an interactive compiled Lisp function in `replace.el'.

It is bound to M-s o.

(occur REGEXP &optional NLINES)

Show all lines in the current buffer containing a match for REGEXP.
If a match spreads across multiple lines, all those lines are shown.

Each line is displayed with NLINES lines before and after, or -NLINES
before if NLINES is negative.
NLINES defaults to `list-matching-lines-default-context-lines'.
Interactively it is the prefix arg.

The lines are shown in a buffer named `*Occur*'.
It serves as a menu to find any of the occurrences in this buffer.
h in that buffer will explain how.

If REGEXP contains upper case characters (excluding those preceded by `\')
and `search-upper-case' is non-nil, the matching is case-sensitive.

When NLINES is a string or when the function is called
interactively with prefix argument without a number (`C-u' alone
as prefix) the matching strings are collected into the `*Occur*'
buffer by using NLINES as a replacement regexp.  NLINES may
contain \& and \N which convention follows `replace-match'.
For example, providing "defun\s +\(\S +\)" for REGEXP and
"\1" for NLINES collects all the function names in a lisp
program.  When there is no parenthesized subexpressions in REGEXP
the entire match is collected.  In any case the searched buffer
is not modified.
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
