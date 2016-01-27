(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("837e53ea95a422370833d2edac16f8f9c9a36181371b8ef56a337dd3f2bc47cc" "de6ef494d359be8f8022a55e19c535d5741e6f50ac921c49a866ef03e472ae3b" default)))
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(package-archives
   (quote
    (("marmalade" . "http://marmalade-repo.org/packages/")
     ("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa-stable" . "https://stable.melpa.org/packages/"))))
 '(scroll-conservatively 10000)
 '(shell-completion-execonly t)
 '(transient-mark-mode (quote (only . t))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; start emacs single window
(setq inhibit-startup-message t)

;; hide toolbar, menu bar, scroll bar
(toggle-scroll-bar -1)
(menu-bar-mode -1)
(tool-bar-mode -1)

;;displaying current time.
(display-time-mode 1)

;; copy to clipboard
(setq x-select-enable-clipboard t)

;;delecting the selection
(delete-selection-mode 1)

;;line number mode
;;(global-linum-mode 1)
(column-number-mode 1)

;; c indentation
(setq-default c-basic-offset 4)

;; spell-check in text file
(defun fly-spell-check ()
  (when (and (stringp buffer-file-name)
	     (string-match "\\.txt\\'" buffer-file-name))
    (flyspell-mode)))

(add-hook 'find-file-hook 'fly-spell-check)

;; eshell clear buffer
(defun eshell-clear-buffer ()
  "Clear terminal"
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))
(add-hook 'eshell-mode-hook
      '(lambda()
	  (local-set-key (kbd "C-l") 'eshell-clear-buffer)))

(setq case-fold-search nil)
(show-paren-mode 1)

;; mu4e
(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'setup-mu4e)

;; window switching
(require 'window-number)
(window-number-mode 1)

;; java-mode annotation
(add-hook 'java-mode-hook
	  (lambda ()
	    "Treat Java 1.5 @-style annotations as comments."
	    (setq c-comment-start-regexp "(@|/(/|[*][*]?))")
	    (modify-syntax-entry ?@ "< b" java-mode-syntax-table)))

;; column marker
(require 'fill-column-indicator)
(setq fci-rule-color "brown")
(setq-default fci-rule-column 80)
;;(define-globalized-minor-mode global-fci-mode fci-mode (lambda () (fci-mode 1)))
;;(global-fci-mode 1)

;; ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer) 

;; full-screen-mode
(defun toggle-fullscreen (&optional f)
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
    (set-frame-parameter nil 'fullscreen
      (if (equal 'fullboth current-value)
        (if (boundp 'old-fullscreen) old-fullscreen nil)
        (progn (setq old-fullscreen current-value)
          'fullboth)))))
(global-set-key [f11] 'toggle-fullscreen)

;; multi-eshell
(require 'multi-eshell)

;; multi-eshell clear buffer
(defun my-shell-hook ()
  (local-set-key (kbd "C-l") 'erase-buffer))

(add-hook 'shell-mode-hook 'my-shell-hook)
(put 'erase-buffer 'disabled nil)

;; eshell complition
(add-hook
 'eshell-mode-hook
 (lambda ()
   (setq pcomplete-cycle-completions nil)))

;; open pop-up buffer in horizontal
(setq split-width-threshold nil)

;; ace-jump-mode
(add-to-list 'load-path "~/.emacs.d/lisp/ace-jump-mode.el")
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)
;; you can select the key you prefer to
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

;; enable a more powerful jump back function from ace jump mode
(autoload
  'ace-jump-mode-pop-mark
  "ace-jump-mode"
  "Ace jump back:-)"
  t)
(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)

;; Emacs24 theme
;;(add-to-list 'load-path "~/.emacs.d/themes/dracula-theme.el")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'dracula t)

;; load eww-lnum
(load "~/.emacs.d/lisp/eww-lnum")
(eval-after-load "eww"
  '(progn (define-key eww-mode-map "f" 'eww-lnum-follow)
          (define-key eww-mode-map "F" 'eww-lnum-universal)))

;; ace-window-jump
(global-set-key (kbd "M-q") 'ace-window)

;; switch to mini-buffer
(defun switch-to-minibuffer ()
  (interactive)
  (if (active-minibuffer-window)
      (select-window (active-minibuffer-window))
    (error "Minibuffer is not active")))

(global-set-key "\C-co" 'switch-to-minibuffer)
