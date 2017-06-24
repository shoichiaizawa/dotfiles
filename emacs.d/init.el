; File:   init.el
; Author: Shoichi Aizawa <shoichiaizawa@gmail.com>
; Source: https://github.com/shoichiaizawa/dotfiles/tree/master/emacs.d/init.el

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

; (global-hl-line-mode t)                        ; Highlight cursor line
; (column-number-mode t)                         ; Show column number in mode-line

; (global-linum-mode 1)                          ; Show line numbers on buffers
(show-paren-mode 1)                            ; Highlight parenthesis pairs

;; Tab Bar
; (tabbar-mode 1)
; (tabbar-mwheel-mode -1)

;; Enable mouse support
(require 'mouse)
; (mouse-wheel-mode t)                           ; Mouse-wheel enabled
(xterm-mouse-mode t)
(global-set-key   [mouse-4] '(lambda () (interactive) (scroll-down 1)))
(global-set-key   [mouse-5] '(lambda () (interactive) (scroll-up   1)))
(defun track-mouse (e))
(setq mouse-sel-mode t)

;; No backup TODO: Find how to make backup directory
(setq backup-inhibited t)

;; Hookup emacs clipboard with mac system clipboard
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))
(if (eq system-type 'darwin)
  (setq interprogram-cut-function 'paste-to-osx))
(if (eq system-type 'darwin)
  (setq interprogram-paste-function 'copy-from-osx))

;;----------------------------------------------------------------------------
;; Notes
;;----------------------------------------------------------------------------

;; See some example settings here:
;; http://www.emacswiki.org/emacs/EmacsCrashCode

;; Someone taught me how to define a function in Lisp:
; (defun my-func () (interactive) (insert (shell-command-to-string "foo")))

;; Emacs on OS X:
;; http://batsov.com/articles/2012/10/14/emacs-on-osx/
;; http://kevinallenrodriguez.com/blog/keeping-up-to-date-nano-vim-emacs-editors-on-os-x/
;; http://www.emacswiki.org/emacs/EmacsForMacOS
