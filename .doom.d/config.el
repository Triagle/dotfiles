;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Jake Faulkner"
      user-mail-address "jakefaulkn@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :family "RobotoMono Nerd Font" :size 14))
(setq doom-variable-pitch-font (font-spec :family "Roboto" :size 14 :weight 'semi-light))
(setq doom-unicode-font (font-spec :family "Noto Sans Math"))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'modus-operandi)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Sync/")

(after! LaTeX
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-electric-math (cons "\\(" "\\)")
        LaTeX-electric-left-right-brace t
        TeX-electric-sub-and-superscript t
        TeX-command-extra-options "-shell-escape"
        TeX-master nil
        TeX-source-correlate-start-server t
        TeX-engine 'xetex)
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (add-hook 'latex-mode-hook #'turn-on-auto-fill)
  (LaTeX-add-environments '("theorem"  LaTeX-env-label)
                          '("lemma" LaTeX-env-label)
                          '("definition" LaTeX-env-label)
                          '("corollary" LaTeX-env-label))
  (setf LaTeX-label-alist (cl-list* '("lemma" . "lem:") '("theorem" . "thm:") '("definition" . "def:") '("corollary" . "cor:") LaTeX-label-alist)))


(after! reftex
  (add-to-list 'reftex-label-alist '("theorem" ?h "thm:" "~\\ref{%s}" t ("Theorem" "theorem") nil) )
  (add-to-list 'reftex-label-alist '("definition" ?d "def:" "~\\ref{%s}" t ("Definition" "definition") nil) )
  (add-to-list 'reftex-label-alist '("corollary" ?c "cor:" "~\\ref{%s}" t ("Corollary" "corollary") nil) )
  (add-to-list 'reftex-label-alist '("lemma" ?m "lem:" "~\\ref{%s}" t ("Lemma" "lemma") nil) )
  (reftex-reset-mode))

(after! cdlatex
  (defun add-labelled-env (environment shortcut)
    (add-to-list 'cdlatex-env-alist (list environment (format "\\begin{%s}\nAUTOLABEL\n?\n\\end{%s}" environment environment) nil))
    (add-to-list 'cdlatex-command-alist (list shortcut (format "Insert %s env" environment) "" 'cdlatex-environment (list environment) t nil)))
  (defun jake/cdlatex-hook ()
    ;; Fixing #35 on github, cdlatex-takeover-parenthesis doesn't work...
    (unbind-key "(" cdlatex-mode-map)
    (unbind-key "{" cdlatex-mode-map)
    (unbind-key "[" cdlatex-mode-map))
  (add-to-list 'safe-local-variable-values
               '(TeX-command-extra-options . "-shell-escape"))
  (map! :map cdlatex-mode-map
        "TAB" #'cdlatex-tab)
  (add-hook! LaTeX-mode #'jake/cdlatex-hook #'+word-wrap-mode)

  (setq cdlatex-use-dollar-to-ensure-math nil)
  (add-to-list 'cdlatex-math-modify-alist '(115 "\\mathbb" nil t nil nil))
  (dolist (kv '(("theorem" "thm") ("definition" "def") ("corollary" "cor") ("lemma" "lem")))
    (add-labelled-env (car kv) (cadr kv))))


(add-hook! org-mode #'org-appear-mode)

(after! org
  (setq org-agenda-files '("~/Sync/todo.org")
        org-refile-targets '((nil . (:maxlevel . 2)) ("~/Sync/archive.org" . (:level . 1)))
        org-default-notes-file "~/Sync/todo.org"
        org-directory "~/Sync"
        org-pretty-entities t
        org-hide-emphasis-markers t
        org-roam-directory "~/Sync/org-roam"))


(global-set-key (kbd "M-/") 'hippie-expand)

(setq-default abbrev-mode t)
(add-hook 'prog-mode-hook (lambda () (abbrev-mode -1)))
(setq abbrev-file-name "~/.emacs.d/abbrev.el")

(after! mu4e
  (require 'smtpmail)

  (set-email-account! "uni"
                      '((mu4e-sent-folder       . "/uni/Sent Mail")
                        (mu4e-drafts-folder     . "/uni/Drafts")
                        (mu4e-trash-folder      . "/uni/Trash")
                        (message-send-mail-function . message-send-mail-with-sendmail)
                        (mail-specify-envelope-from . t)
                        (message-sendmail-envelope-from . header)
                        (sendmail-program . "/usr/bin/msmtp")
                        (mail-envelope-from . header)
                        (mu4e-refile-folder     . "/uni/All Mail")
                        (smtpmail-user-mail-address . "jaf150@uclive.ac.nz")
                        (user-mail-address      . "jake.faulkner@pg.canterbury.ac.nz"))
                      t)

  (set-email-account! "gmail"
                      '((mu4e-sent-folder       . "/gmail/sent")
                        (mu4e-drafts-folder     . "/gmail/drafts")
                        (mu4e-trash-folder      . "/gmail/trash")
                        (mu4e-refile-folder     . "/gmail/archive")
                        (send-mail-function . smtpmail-send-it)
                        (smtpmail-smtp-user     . "jakefaulkn@gmail.com")
                        (user-mail-address      . "jakefaulkn@gmail.com")
                        (smtpmail-default-smtp-server . "smtp.gmail.com")
                        (smtpmail-smtp-server . "smtp.gmail.com")
                        (smtpmail-smtp-service . 587)
                        (smtpmail-auth-credentials . (expand-file-name "~/.authinfo")))
                      nil)
  (setq +mu4e-gmail-accounts '(("jakefaulkn@gmail.com" . "/gmail"))))


(map! "s-<return>" #'embark-act)

(after! citar
  (setq! citar-bibliography '("~/Sync/bibliography/bibliography.bib")
        citar-library-paths '("~/Sync/bibliography/pdfs")))


(use-package gap
  :mode (("\\.g\\'" . gap-mode)
         ("\\.gap\\'" . gap-mode))
  :init
  (setq gap-executable "/usr/bin/gap"
        gap-start-options '("-f" "-b" "-m" "2m" "-E")
        gap-electric-semicolon nil
        gap-electric-equals nil)
  (defun +gap-open-repl ()
    (interactive)
    (unless (gap-running-p)
      (gap))
    (pop-to-buffer gap-process-buffer))
  (set-repl-handler! 'gap-mode #'+gap-open-repl)
  (set-popup-rule! "^\\*GAP Help\\*" :size 0.3))



(setq-default cursor-type 'bar)

(after! citar
  (setq citar-notes-paths '("~/Sync/org-roam")))
(use-package! org-roam-bibtex
  :when (featurep! :lang org +roam2)
  :after org-roam
  :preface
  ;; if the user has not set a template mechanism set a reasonable one of them
  ;; The package already tests for nil itself so we define a dummy tester
  (defvar orb-preformat-keywords
    '("title" "url" "file" "author-or-editor" "keywords" "citekey" "pdf"))
  ;;:hook (org-roam-mode . org-roam-bibtex-mode)
  :custom
  (orb-note-actions-interface 'default)
  :init
  (setq bibtex-completion-bibliography "~/Sync/bibliography/bibliography.bib")
  :config
  (setq orb-insert-interface 'generic)
  (setq orb-process-file-keyword t
        orb-file-field-extensions '("pdf")))

(defun jake/share-this-file ()
  (interactive)
  (let* ((fp (buffer-file-name (current-buffer)))
         (command (format "woof %s" fp))
         (proc (start-process-shell-command "woof" (get-buffer-create "*woof*") command)))
    (set-process-filter proc (lambda (proc line)
                               (when (string-match "Now serving on \\(.*\\)" line)
                                 (message line))))))
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
