
(add-to-list 'load-path "~/.local/share/emacs/site-lisp/mu4e")

(setq mu4e-mu-binary "~/.local/bin/mu")
(require 'mu4e)
(require 'offlineimap)

(add-hook 'mu4e-before-startup-hook 'offlineimap)
;; default
(setq mu4e-maildir "~/Maildir")
(setq mu4e-drafts-folder "/INBOX.Drafts")
(setq mu4e-sent-folder   "/INBOX.Sent")
(setq mu4e-trash-folder  "/INBOX.Trash")
(setq mu4e-attachment-dir  "~/Maildir/Attachments")

;; Shortcuts for navigating to different folders.
(setq mu4e-maildir-shortcuts
      '( ("/INBOX"               . ?i)
         ("/INBOX.Sent"          . ?s)
         ("/INBOX.Trash"         . ?t)))

;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "~/.local/bin/offlineimap -o"
      mu4e-update-interval 120
      mu4e-headers-auto-update t)

;; something about ourselves
(setq
 user-mail-address "vengatesh.s@zilogic.com"
 user-full-name  "Vengatesh.S"
 message-signature
 (concat
  "--Regards,\n"
  "Vengatesh.S"
  "\n"))

;; sending mail -- replace USERNAME with your gmail username
;; also, make sure the gnutls command line utils are installed
;; package 'gnutls-bin' in Debian/Ubuntu

(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-starttls-credentials '(("mail.zilogic.com" 25 nil nil))
      smtpmail-auth-credentials
      '(("mail.zilogic.com" 25 "vengatesh.s@zilogic.com" nil))
      smtpmail-default-smtp-server "mail.zilogic.com"
      smtpmail-smtp-server "mail.zilogic.com"
      smtpmail-smtp-service 25)

(setq message-kill-buffer-on-exit t)

;; don't save message to Sent Messages, Gmail/IMAP takes care of this
;; (setq mu4e-sent-messages-behavior 'delete)

;; don't prompt for applying of marks, just apply
(setq mu4e-headers-leave-behavior 'apply)

;; Try to display images in mu4e
(setq
 mu4e-view-show-images t
 mu4e-view-image-max-width 800)

;; use imagemagick, if available
(when (fboundp 'imagemagick-register-types)
  (imagemagick-register-types))

(setq mu4e-confirm-quit nil
      mu4e-headers-date-format "%d/%b/%Y %H:%M" ; date format
)

;; defining the mail updating and indexing function
(defvar mu4e-update-timer nil
  "*internal* The mu4e update timer.")

(defconst mu4e-update-mail-name "*mu4e-update-mail*"
  "*internal* Name of the process to update mail")

(defun mu4e-update-mail (&optional buf)
  "Update mail (retrieve using 'mu4e-get-mail-command' and update
the database afterwards), with output going to BUF if not nil, or
discarded if nil. After retrieving mail, update the database. Note,
function is asynchronous, returns (almost) immediately, and all the
processing takes part in the background, unless buf is non-nil."
  (unless mu4e-get-mail-command
    (error "`mu4e-get-mail-command' is not defined"))
  (let* ((process-connection-type t)
         (proc (start-process-shell-command
                mu4e-update-mail-name buf mu4e-get-mail-command)))
               (mu4e-message "Retrieving mail...")))

(defconst mu4e-update-buffer-name "*mu4e-update*"
  "*internal* Name of the buffer for message retrieval / database
updating.")

(defun mu4e-update-mail-index (process event)
  (print "updating index")
  (mu4e-update-index)
  (mu4e-message "Updating index.."))

;; Function that doesn't show retrieval progress in new split window.
(defun mu4e-update-mail-show-window ()
  "Try to retrieve mail (using the user-provided shell command),
and update the database afterwards, and show the progress in a
split-window."
  (interactive)
  (unless mu4e-get-mail-command
    (error "'mu4e-get-mail-command' is not defined"))
  (let (buf (get-buffer-create mu4e-update-buffer-name))
  (mu4e-update-mail buf)
  (set-process-sentinel (get-process "*mu4e-update-mail*") 'mu4e-update-mail-index)))

;; Old function that shows the retrieve steps in a separate buffer of split window.
;; (defun mu4e-update-mail-show-window ()
;;   "Try to retrieve mail (using the user-provided shell command),
;; and update the database afterwards, and show the progress in a
;; split-window."
;;   (interactive)
;;   (unless mu4e-get-mail-command
;;     (error "'mu4e-get-mail-command' is not defined"))
;;   (let ((buf (get-buffer-create mu4e-update-buffer-name))
;;         (win
;;          (split-window (selected-window)
;;                        (- (window-height (selected-window)) 4))))
;;    (with-selected-window win
;;       (switch-to-buffer buf)
;;       (set-window-dedicated-p win t)
;;       (erase-buffer)
;;       (insert "\n") ;; FIXME -- needed so output starts
;;       (mu4e-update-mail buf)
;;       (set-process-sentinel (get-process "*mu4e-update-mail*")
;;'mu4e-update-mail-index))))

;; Start mu4e in fullscreen, immediately ping for new mail
(defun mu4e-up-to-date-status ()
  (interactive)
  (window-configuration-to-register :mu4e-fullscreen)
  (mu4e)
  (mu4e-update-mail-show-window)
  (delete-other-windows))

;; Restore previous window configuration
(defun mu4e-quit-session ()
  "Restores the previous window configuration and kills the magit buffer"
  (interactive)
  (kill-buffer)
  (jump-to-register :mu4e-fullscreen))

(run-at-time 0 (* 10 60) 'mu4e-update-mail-show-window)

(define-key mu4e-main-mode-map (kbd "q") 'mu4e-quit-session)
(define-key mu4e-headers-mode-map (kbd "M-u") 'mu4e-update-mail-show-window)

(provide 'setup-mu4e)