;;
;; size is not the primary concern nowadays
(prefer-coding-system 'utf-8)

;;
;; measure the loading time per file.
;;
;(defadvice load (around load-with-time-logging)
;  "display the load time for each file."
;  (let ((now (float-time)))
;    ad-do-it
;    (message "%2.2f seconds is used." (- (float-time) now))))
;(ad-activate 'load)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; it's assumed that the HOME "~" is pointing to "git/xiongyw/doc/it/emacs/"
;; now we want the "default-directory" points to "git/xiongyw/"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq default-directory "~/../../../")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set load path
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq load-path (append (list "~/.emacs.d/"
                              "~/.emacs.d/git-emacs/"
                              "~/.emacs.d/haskell-mode/"
                              "~/.emacs.d/auto-complete-1.3.1/"
                              "~/.emacs.d/yasnippet/"
                              "~/.emacs.d/w3m-lisp/"
;                              "~/.emacs.d/lintnode/"
                              nil) load-path))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-save-list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq auto-save-list-file-prefix (concat default-directory "auto-save-list/.saves-"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; book mark file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq bookmark-default-file (concat default-directory "bookmark.emacs"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; *Messsage* size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq message-log-max 10000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; git-emacs: http://www.cnblogs.com/holbrook/archive/2012/04/26/2470923.html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'git-emacs)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set frame title as the file name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq frame-title-format
      '((:eval (funcall (lambda () (if buffer-file-name
                                       buffer-file-name
                                     (buffer-name)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; customize font and color
;; http://www.telecom.otago.ac.nz/tele402/emacs.php
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (tango-dark)))
 '(send-mail-function (quote smtpmail-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "grey90" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 132 :width normal :foundry "outline" :family "Andale Mono")))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; no beep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq visible-bell t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; no splash screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq inhibit-startup-message t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; always case-sensitive, don't be too smart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default case-fold-search nil) 
(setq-default case-replace nil)

(setq transient-mark-mode t)
(setq column-number-mode t)
(fset 'yes-or-no-p 'y-or-n-p)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-complete: https://github.com/auto-complete/auto-complete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-complete-config)
; Make sure we can find the dictionaries
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete-1.3.1/dict/")
; Use dictionaries by default
(setq-default ac-sources (add-to-list 'ac-sources 'ac-source-dictionary))
(global-auto-complete-mode t)
; Start auto-completion after 2 characters of a word
(setq ac-auto-start 2)
; case sensitivity is important when finding matches
(setq ac-ignore-case nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Yasnippet: https://github.com/capitaomorte/yasnippet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'yasnippet)
(yas-global-mode 1)
;; Load the snippet files themselves
(yas/load-directory "~/.emacs.d/yasnippet/snippets/text-mode/")
;; Let's have snippets in the auto-complete dropdown
(add-to-list 'ac-sources 'ac-source-yasnippet)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;lintnode: https://github.com/davidmiller/lintnode.git
;git clone https://github.com/davidmiller/lintnode.git
;cd lintnode
;npm install express connect-form haml underscore
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(require 'flymake-jslint)
;; Make sure we can find the lintnode executable
;(setq lintnode-location "~/.emacs.d/lintnode")
;; JSLint can be... opinionated
;(setq lintnode-jslint-excludes (list 'nomen 'undef 'plusplus 'onevar 'white))
;; Start the server when we first open a js file and start checking
;(add-hook 'js-mode-hook
;          (lambda ()
;            (lintnode-hook)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JavaScript: setting up emacs as a javascript editing environment for fun and profit
;; http://blog.deadpansincerity.com/2011/05/setting-up-emacs-as-a-javascript-editing-environment-for-fun-and-profit/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; node.js, 2013-10-14
;; http://www.emacswiki.org/emacs/NodeJs, "M-x run-js"
(require 'js-comint)
;; Use node as our repl: first verify in emacs shell that "node --interactive" works
(setq inferior-js-program-command "node --interactive")
(add-hook 'js2-mode-hook '(lambda () 
			    (local-set-key "\C-x\C-e" 'js-send-last-sexp)
			    (local-set-key "\C-\M-x" 'js-send-last-sexp-and-go)
			    (local-set-key "\C-cb" 'js-send-buffer)
			    (local-set-key "\C-c\C-b" 'js-send-buffer-and-go)
			    (local-set-key "\C-cl" 'js-load-file-and-go)
			    ))

(setq inferior-js-mode-hook
      (lambda ()
        ;; We like nice colors
        (ansi-color-for-comint-mode-on)
        ;; Deal with some prompt nonsense
        (add-to-list 'comint-preoutput-filter-functions
                     (lambda (output)
                       (replace-regexp-in-string ".*1G\.\.\..*5G" "..."
                     (replace-regexp-in-string ".*1G.*3G" "&gt;" output))))))
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'linum)
(global-linum-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ido-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ido-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; org mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; default directory
(setq org-directory "~/journal")
;; global key
(define-key global-map "\C-cr" 'org-remember)
;; setup remember.el for use with org-mode
;(org-remember-insinuate)
;; default folder
(setq org-default-notes-file
      (concat org-directory (concat (format-time-string "%Y") ".org")))
(setq org-support-shift-select t)
(add-hook 'org-mode-hook
          (lambda ()
           ;; auto-fill mode off
            (auto-fill-mode -1)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enough: get rid of auto-fill!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(turn-off-auto-fill)
(remove-hook 'text-mode-hook 'turn-on-auto-fill)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; tabbar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'tabbar)
(tabbar-mode t)
;; just put all tabs in one group
(setq tabbar-buffer-groups-function
          (lambda ()
            (list "All")))
;; navigate among tabs
(global-set-key [C-left] 'tabbar-backward-tab)
(global-set-key [C-right] 'tabbar-forward-tab)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; w3m: http://blog.chinaunix.net/uid-20680669-id-3339757.html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'exec-path "c:/emacs/emacs-24.2/windows_emacs_w3m/w3m") 
(require 'w3m-load)
(setq w3m-use-favicon nil)
(setq w3m-command-arguments '("-cookie" "-F"))
(setq w3m-use-cookies t)
(setq w3m-home-page "http://www.googlestable.com")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; display time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(setq display-time-24hr-format t)
;;(setq display-time-day-and-date t)
(setq display-time-format "[%Y-%m-%d %H:%M:%S]")
(setq display-time-interval 1)
(display-time-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; cscope for windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1. download source tgz from "http://cscope.sf.net" and extract it. under
;;   "cscope-15.8a\contrib\xcscope" there are two files:
;;   - xcscope.el: put this under "C:\emacs\emacs-24.2\site-lisp", and add the following line
;;     in "init.el", try "c-x c-e". if success (minibuffer shows "xcscope", then the elisp
;;     package is installed correctly. otherwise, an error window will show up.
(require 'xcscope)
;(require 'ascope)
;(require 'cscope)
;;     be noted that cscope commands "C-c s *" are only activiated in source files.
;;   - xcscope_indexer

;; 2. download cscope-win32 executable "cscope.exe" from "http://code.google.com/p/cscope-win32/",
;;   and put it under "C:\emacs\emacs-24.2\bin"
;; 3. open a .c file, and press "C-c s I" and input a root diractory of your project. emacs will
;;    complain that it can not find "cscope_indexer", which is expected
;; 4. Open a source file, using  "C-c s a" to indicate the path to the file "cscope.files", which is prepared there before by "find".
;;    then "C-c s s" etc to generate the database "ncscope.out" and do the rest...
;;    in "xcscope.el", there are the following lines to define the executable name:
;; (defcustom cscope-program "cscope"
;;  "*The pathname of the cscope executable to use."
;;  :type 'string
;;  :group 'cscope)
;; if we change the executable name there, and restart emacs (eval-buffer does not work), and then emacs will
;; complain it can not find the executable when it tries to build the db. 
;;
;; 5. ways to improve the cscope performance by changing command line options for building the database



;; sr speedbar: http://www.emacswiki.org/emacs-en/SrSpeedbar
;(require 'sr-speedbar)

;; check the host: windows or linux
;(setq WINDOWS (not (null (getenv "COMSPEC"))))
;; note: there is a predefined variable "system-type"...




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; match paren: http://hi.baidu.com/skyyjl/item/64b8b8a5676b77d95bf191af
;;;; modified(bruin, 2013-01-26)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun goto-match (arg)
  (interactive "p")
  (let ((stop nil) (c 1) (p-save (point)) (forward t) (self "") (target ""))
    (cond ((looking-at "}") (setq forward nil) (setq self "}") (setq target "{"))
          ((looking-at "{") (setq forward t)   (setq self "{") (setq target "}"))
          ((looking-at ")") (setq forward nil) (setq self ")") (setq target "("))
          ((looking-at "(") (setq forward t)   (setq self "(") (setq target ")"))
          (t (setq stop t) (setq c -1)))
    (while (not stop)
      (progn
        (if forward (forward-char 1) (backward-char 1))
        (cond ((looking-at target) (setq c (1- c)))
              ((looking-at self) (setq c (1+ c))))
        (if (or (= c 0) (= (point) (point-max))) (setq stop t))))
    (if (= c -1) (self-insert-command (or arg 1)))
    (if (> c 0) (goto-char p-save))))


(global-set-key "%" 'goto-match)

(show-paren-mode t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; aspell: http://blog.sina.com.cn/s/blog_8e8bd6b90100tgtw.html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'exec-path "C:/Program Files (x86)/Aspell/bin/")
(setq ispell-program-name "aspell")
(setq-default ispell-program-name "aspell")
(setq ispell-personal-dictionary "C:/Program Files (x86)/Aspell/dict")
(require 'ispell)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(global-set-key (kbd "<f8>") 'ispell-word)
(global-set-key (kbd "C-<f8>") 'flyspell-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cursor-chg: http://www.emacswiki.org/emacs-en/ChangingCursorDynamically
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cursor-chg)  ; Load the library
(toggle-cursor-type-when-idle 1) ; Turn on cursor change when Emacs is idle
(change-cursor-mode 1) ; Turn on change for overwrite, read-only, and input mode


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://github.com/haskell/haskell-mode, manual install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load "~/.emacs.d/haskell-mode/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JSShell: http://www.emacswiki.org/emacs/jsshell-bundle.el: M-x jsshell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'jsshell-bundle)


;; ue-next-line
(require 'ue)

;; node-js-eval-region-or-buffer
(require 'node)

;; transpose-frame
(require 'transpose-frame)

;(add-to-list 'load-path "c:/emacs/emacs-24.2/site-lisp/magit-1.2.0")
;(require 'magit)


;(setq shell-file-name "C:/Program Files (x86)/Git/bin/sh.exe")
(setq explicit-shell-file-name "C:/Program Files (x86)/Git/bin/sh.exe")

(setenv "PATH" "C:/Program Files (x86)/Git/bin")





;;
;; File .emacs - These commands are executed when GNU emacs starts up.
;;
;; $Id: .emacs,v 1.8 1995/11/07 20:12:07 dewell Exp $
;; revised 8/15/2009
;;
;; Now, it resides as .emacs.d/init.el

;; Keep Emacs from executing file local variables.
;; (this is also in the site-init.el file loaded at emacs dump time.)
(setq inhibit-local-variables t  ; v18
      enable-local-variables nil ; v19
      enable-local-eval nil)     ; v19

;; Swap Backspace and Delete keys, except for v19 running under X.  This works
;; on both HPs and Suns.
(or (and (eq window-system 'x)
         (string-match "\\`19\\." emacs-version))
    (load "term/bobcat"))

;; Cause the region to be highlighted and prevent region-based commands
;; from running when the mark isn't active.
 
(pending-delete-mode t)
 (setq transient-mark-mode t)

(setq kill-emacs-query-functions
  (list (function (lambda ()
                    (ding)
                    (y-or-n-p "Really quit? ")))))

;; Fonts are automatically highlighted.  For more information
;; type M-x describe-mode font-lock-mode 

(global-font-lock-mode t)

;; "rmail" is the standard Emacs mail reading mode if you want try a
;; different one then "vm" works well
;;
;; VM mail reading mode
(autoload 'vm "vm" "Start VM on your primary inbox." t)
(autoload 'vm-visit-folder "vm" "Start VM on an arbitrary folder." t)
(autoload 'vm-visit-virtual-folder "vm" "Visit a VM virtual folder." t)
(autoload 'vm-mode "vm" "Run VM major mode on a buffer" t)
(autoload 'vm-mail "vm" "Send a mail message using VM." t)
;;
;; win-vm window+menus for VM (Use the above 5 autoloads or the following,
;;                             but not both.)
;;(let ((my-vm-pkg
;;       (if (not window-system)
;;	   "vm"
;;	 (define-key menu-bar-file-menu [rmail] '("Read Mail" . vm))
;;	 (define-key-after menu-bar-file-menu [smail]
;;	   '("Send Mail" . vm-mail) 'rmail)
;;	 "win-vm")))
;;  (autoload 'vm my-vm-pkg "Read and send mail with View Mail." t)
;;  (autoload 'vm-mode my-vm-pkg "Read and send mail with View Mail." t)
;;  (autoload 'vm-mail my-vm-pkg "Send mail with View Mail." t)
;;  (autoload 'vm-visit-folder my-vm-pkg))

;; Some color stuff if you want it.
;; (cond (window-system
;;        (setq hilit-mode-enable-list  '(not text-mode)
;;              hilit-background-mode   'light
;;              hilit-inhibit-hooks     nil
;;              hilit-inhibit-rebinding nil)
;; 
;;        (require 'hilit19)
;;        ))
;; 
;; Example of how to set the highlighting of color defaults.
;; (if (fboundp 'set-face-background)
;;     (progn
;;      (set-face-background (quote highlight) "yellow")
;;      (set-face-foreground (quote highlight) "black")))


;; Below are changes taken from the tutor .emacs file
;; Added by Craig Ruefenacht

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This provides customized support for writing programs in different kinds
;;;; of programming languages.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Load the C++ and C editing modes and specify which file extensions
;; correspond to which modes.
(autoload 'python-mode "python-mode" "Python editing mode." t)
    (setq auto-mode-alist
           (cons '("\\.py$" . python-mode) auto-mode-alist))
     (setq interpreter-mode-alist
           (cons '("python" . python-mode) interpreter-mode-alist))

(autoload 'c++-mode "cc-mode" "C++ Editing Mode" t)
(autoload 'c-mode "c-mode" "C Editing Mode"   t)
(setq auto-mode-alist
      (append '(("\\.C\\'" . c++-mode)
                ("\\.cc\\'" . c++-mode)
		("\\.c\\'" . c-mode)
                ("\\.h\\'"  . c++-mode))
	      auto-mode-alist))

;; set tab distance to something, so it doesn't change randomly and confuse people
(setq c-basic-offset 4)

;; This function is used in various programming language mode hooks below.  It
;; does indentation after every newline when writing a program.

(defun newline-indents ()
  "Bind Return to `newline-and-indent' in the local keymap."
  (local-set-key "\C-m" 'newline-and-indent))


;; Tell Emacs to use the function above in certain editing modes.

(add-hook 'lisp-mode-hook             (function newline-indents))
(add-hook 'emacs-lisp-mode-hook       (function newline-indents))
(add-hook 'lisp-interaction-mode-hook (function newline-indents))
(add-hook 'scheme-mode-hook           (function newline-indents))
(add-hook 'c-mode-hook                (function newline-indents))
(add-hook 'c++-mode-hook              (function newline-indents))
(add-hook 'java-mode-hook             (function newline-indents))


;; Fortran mode provides a special newline-and-indent function.

(add-hook 'fortran-mode-hook
	  (function (lambda ()
		      (local-set-key "\C-m" 'fortran-indent-new-line))))


;; Text-based modes (including mail, TeX, and LaTeX modes) are auto-filled.
;(add-hook 'text-mode-hook (function turn-on-auto-fill))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This makes "M-x compile" smarter by trying to guess what the compilation
;;;; command should be for the C, C++, and Fortran language modes.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; By requiring `compile' at this point, we help to ensure that the global
;; value of compile-command is set properly.  If `compile' is autoloaded when
;; the current buffer has a buffer-local copy of compile-command, then the
;; global value doesn't get set properly.

(require 'compile)


;; This gives the form of the default compilation command for C++, C, and
;; Fortran programs.  Specifying the "-lm" option for C and C++  eliminates a
;; lot of potential confusion.

(defvar compile-guess-command-table
  '((c-mode       . "gcc -Wall -g %s -o %s -lm"); Doesn't work for ".h" files.
    (c++-mode     . "g++ -g %s -o %s -lm")	; Doesn't work for ".h" files.
    (fortran-mode . "f77 -C %s -o %s")
    )
  "*Association list of major modes to compilation command descriptions, used
by the function `compile-guess-command'.  For each major mode, the compilation
command may be described by either:

  + A string, which is used as a format string.  The format string must accept
    two arguments: the simple (non-directory) name of the file to be compiled,
    and the name of the program to be produced.

  + A function.  In this case, the function is called with the two arguments
    described above and must return the compilation command.")


;; This code guesses the right compilation command when Emacs is asked
;; to compile the contents of a buffer.  It bases this guess upon the
;; filename extension of the file in the buffer.

(defun compile-guess-command ()

  (let ((command-for-mode (cdr (assq major-mode
				     compile-guess-command-table))))
    (if (and command-for-mode
	     (stringp buffer-file-name))
	(let* ((file-name (file-name-nondirectory buffer-file-name))
	       (file-name-sans-suffix (if (and (string-match "\\.[^.]*\\'"
							     file-name)
					       (> (match-beginning 0) 0))
					  (substring file-name
						     0 (match-beginning 0))
					nil)))
	  (if file-name-sans-suffix
	      (progn
		(make-local-variable 'compile-command)
		(setq compile-command
		      (if (stringp command-for-mode)
			  ;; Optimize the common case.
			  (format command-for-mode
				  file-name file-name-sans-suffix)
			(funcall command-for-mode
				 file-name file-name-sans-suffix)))
		compile-command)
	    nil))
      nil)))


;; Add the appropriate mode hooks.

(add-hook 'c-mode-hook       (function compile-guess-command))
(add-hook 'c++-mode-hook     (function compile-guess-command))
(add-hook 'fortran-mode-hook (function compile-guess-command))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; This creates and adds a "Compile" menu to the compiled language modes.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar compile-menu nil
  "The \"Compile\" menu keymap.")

(defvar check-option-modes nil
  "The list of major modes in which the \"Check\" option in the \"Compile\"
menu should be used.")

(defvar compile-menu-modes nil
  "The list of major modes in which the \"Compile\" menu has been installed.
This list used by the function `add-compile-menu-to-mode', which is called by
various major mode hooks.")


;; Create the "Compile" menu.

(if compile-menu
    nil
  (setq compile-menu (make-sparse-keymap "Compile"))
  ;; Define the menu from the bottom up.
  (define-key compile-menu [first-error] '("    First Compilation Error" .
					   first-compilation-error))
  (define-key compile-menu [prev-error]  '("    Previous Compilation Error" .
					   previous-compilation-error))
  (define-key compile-menu [next-error]  '("    Next Compilation Error" .
					   next-error))
  (define-key compile-menu [goto-line]   '("    Line Number..." .
					   goto-line))

  (define-key compile-menu [goto]        '("Goto:" . nil))
  ;;
  (define-key compile-menu [indent-region] '("Indent Selection" .
					     indent-region))

  (define-key compile-menu [make]         '("Make..." . make))

  (define-key compile-menu [check-file]   '("Check This File..." . 
					    check-file))

  (define-key compile-menu [compile]     '("Compile This File..." . compile))
  )


;;; Enable check-file only in Fortran mode buffers

(put 'check-file 'menu-enable '(eq major-mode 'fortran-mode))


;;; Here are the new commands that are invoked by the "Compile" menu.

(defun previous-compilation-error ()
  "Visit previous compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error -1))

(defun first-compilation-error ()
  "Visit the first compilation error message and corresponding source code.
See the documentation for the command `next-error' for more information."
  (interactive)
  (next-error '(4)))

(defvar check-history nil)

(defun check-file ()
  "Run ftnchek on the file contained in the current buffer"
  (interactive)
  (let* ((file-name (file-name-nondirectory buffer-file-name))
	 (check-command (read-from-minibuffer
			 "Check command: "
			 (format "ftnchek %s" file-name) nil nil
			 '(check-history . 1))))
    (save-some-buffers nil nil)
    (compile-internal check-command "Can't find next/previous error"
		      "Checking" nil nil nil)))

(defun make ()
  "Run make in the directory of the file contained in the current buffer"
  (interactive)
  (save-some-buffers nil nil)
  (compile-internal (read-from-minibuffer "Make command: " "make ")
		    "Can't find next/previous error" "Make"
		    nil nil nil))


;;; Define a function to be called by the compiled language mode hooks.

(defun add-compile-menu-to-mode ()
  "If the current major mode doesn't already have access to the \"Compile\"
menu, add it to the menu bar."
  (if (memq major-mode compile-menu-modes)
      nil
    (local-set-key [menu-bar compile] (cons "Compile" compile-menu))
    (setq compile-menu-modes (cons major-mode compile-menu-modes))
    ))


;; And finally, make sure that the "Compile" menu is available in C, C++, and
;; Fortran modes.
(add-hook 'c-mode-hook       (function add-compile-menu-to-mode))
(add-hook 'c++-c-mode-hook   (function add-compile-menu-to-mode))
(add-hook 'c++-mode-hook     (function add-compile-menu-to-mode))
(add-hook 'fortran-mode-hook (function add-compile-menu-to-mode))

;; To make emacs use spaces instead of tabs (Added by Art Lee on 2/19/2008)
(setq-default indent-tabs-mode nil)

;; This is how emacs tells the file type by the file suffix.
(setq auto-mode-alist
      (append '(("\\.mss$" . scribe-mode))
	      '(("\\.bib$" . bibtex-mode))
	      '(("\\.tex$" . latex-mode))
	      '(("\\.obj$" . lisp-mode))
	      '(("\\.st$"  . smalltalk-mode))
	      '(("\\.Z$"   . uncompress-while-visiting))
	      '(("\\.cs$"  . indented-text-mode))
	      '(("\\.C$"   . c++-mode))
	      '(("\\.cc$"  . c++-mode))
	      '(("\\.icc$" . c++-mode))
	      '(("\\.c$"   . c-mode))
	      '(("\\.y$"   . c-mode))
	      '(("\\.h$"   . c++-mode))
	      auto-mode-alist))
;;
;; Finally look for .customs.emacs file and load it if found

(if "~/.customs.emacs" 
    (load "~/.customs.emacs" t t))

;; Art: added with v. 23.1 to make spacebar complete filenames (8/17/2009)
(progn
 (define-key minibuffer-local-completion-map " " 'minibuffer-complete-word)
 (define-key minibuffer-local-filename-completion-map " " 'minibuffer-complete-word)
 (define-key minibuffer-local-must-match-filename-map " " 'minibuffer-complete-word)) 

;; Art: added with v. 23.1
;; Set env variable this way?  I used the traditional way instead
;(info "(emacs) Windows HOME")

;; End of file.


(put 'upcase-region 'disabled nil)
