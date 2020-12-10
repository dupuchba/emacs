;;; init.el --- Baptiste Dupuch init file            -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Baptiste Dupuch

;; Author: Baptiste Dupuch <baptiste@dupu.ch>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:


;;;;;;;;;;;;;;;;;;;
;; PACKAGE SETUP ;;
;;;;;;;;;;;;;;;;;;;

;; Comment macro always useful when trying new stuff
(defmacro comment (&rest body)
  nil)

(require 'package)

(add-to-list 'package-archives
	     '("org" . "http://orgmode.org/elpa/")
             t)

(add-to-list 'package-archives
             (cons "melpa-stable" "https://stable.melpa.org/packages/")
             t)

(add-to-list 'package-archives (cons "gnu" "https://elpa.gnu.org/packages/"))

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/")
             t)

(package-initialize)

(set-face-attribute 'default nil :height 180 :font "Fira Code")

;; keep the installed packages in elpa directory
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory))

;; update package metadata if cache is missing
(unless package-archive-contents
  (package-refresh-contents))

;; Must be loaded first as we use it then for all other external
;; packages
(unless (package-installed-p 'use-package)
  (package-install 'use-package))


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GENERAL CONFIGURATION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Usefull when working on an other computer as my main one
(setq user-full-name "Baptiste Dupuch"
      user-mail-address "baptiste@dupu.ch")


;; Change buffer name
(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (concat "File system path : " (abbreviate-file-name (buffer-file-name)))
                 "%b"))))


;; Always load newest byte code
(setq load-prefer-newer t)

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

(defconst dupuchba-savefile-dir (expand-file-name "savefile" user-emacs-directory))

;; create the savefile dir if it doesn't exist
(unless (file-exists-p dupuchba-savefile-dir)
  (make-directory dupuchba-savefile-dir))

(defconst dupuchba-backup-directory (expand-file-name "backup" dupuchba-savefile-dir))

(unless (file-exists-p dupuchba-backup-directory)
  (make-directory dupuchba-backup-directory))

;; It's annoying when backup files ares stored in the code repo. So I
;; setup a backupdir for all backup files
(setq backup-directory-alist `((".*" . ,dupuchba-backup-directory)))
;; VCs backup files should not exists
(setq vc-make-backup-files nil)
(setq auto-save-file-name-transforms
          `((".*" ,dupuchba-backup-directory t)))

;; Set meta option and alt on darwin a.k.a Macos X
(when (eq system-type 'darwin)
  (setq ns-alternate-modifier 'meta)
  (setq ns-right-alternate-modifier 'none)
  (setq ns-command-modifier 'super)
  (setq ns-right-command-modifier 'left)
  (setq ns-control-modifier 'control)
  (setq ns-right-control-modifier 'left)
  (setq ns-function-modifier 'none))

;; the toolbar is just a waste of valuable screen estate
;; in a tty tool-bar-mode does not properly auto-load, and is
;; already disabled anyway
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

;; the blinking cursor is nothing, but an annoyance
(blink-cursor-mode -1)

;; disable the annoying bell ring
(setq ring-bell-function 'ignore)

;; disable startup screen
(setq inhibit-startup-screen t)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; mode line settings
(comment  (line-number-mode nil)
          (global-linum-mode nil)
          (column-number-mode nil)
          (size-indication-mode t))
(global-set-key (kbd "M-n") #'scroll-up-line)
(global-set-key (kbd "M-p") #'scroll-down-line)

;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

;; Emacs modes typically provide a standard means to change the
;; indentation width -- eg. c-basic-offset: use that to adjust your
;; personal indentation width, while maintaining the style (and
;; meaning) of any files you load.
(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 8)            ;; but maintain correct appearance

;; Newline at end of file
(setq require-final-newline t)

;; delete the selection with a keypress
(delete-selection-mode t)

(global-auto-revert-mode t)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; hippie expand is dabbrev expand on steroids
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                         try-expand-dabbrev-all-buffers
                                         try-expand-dabbrev-from-kill
                                         try-complete-file-name-partially
                                         try-complete-file-name
                                         try-expand-all-abbrevs
                                         try-expand-list
                                         try-expand-line
                                         try-complete-lisp-symbol-partially
                                         try-complete-lisp-symbol))

;; use hippie-expand instead of dabbrev
(global-set-key (kbd "M-/") #'hippie-expand)
(global-set-key (kbd "s-/") #'hippie-expand)

;; replace buffer-menu with ibuffer
(global-set-key (kbd "C-x C-b") #'ibuffer)

;; align code in a pretty way
(global-set-key (kbd "C-x \\") #'align-regexp)

(define-key 'help-command (kbd "C-i") #'info-display-manual)

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PACKAGE CONFIGURATION & INSTALLATION ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'use-package)
(setq use-package-verbose t)

;; Hide minor modes from modeline
(use-package rich-minority
  :ensure t
  :config
  (rich-minority-mode 1)
  (setf rm-blacklist ""))

;; Set colors to distinguish between active and inactive windows
(set-face-attribute 'mode-line nil :background "azure1")
(set-face-attribute 'mode-line-inactive nil :background nil)

;;; built-in packages
(use-package paren
  :config
  (show-paren-mode +1))

;; highlight the current line
(use-package hl-line
  :config
  (global-hl-line-mode +1)
  (set-face-background hl-line-face "#808080"))

(use-package abbrev
  :config
  (setq save-abbrevs 'silently)
  (setq-default abbrev-mode t))

;; same file different buffer name
(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-separator "/")
  ;; rename after killing uniquified
  (setq uniquify-after-kill-buffer-p t)
  ;; don't muck with special buffers
  (setq uniquify-ignore-buffers-re "^\\*"))

;; saveplace remembers your location in a file when saving files
(use-package saveplace
  :config
  (setq save-place-file (expand-file-name "saveplace" dupuchba-savefile-dir))
  ;; activate it for all buffers
  (save-place-mode 1))

(use-package savehist
  :config
  (setq savehist-additional-variables
        ;; search entries
        '(search-ring regexp-search-ring)
        ;; save every minute
        savehist-autosave-interval 60
        ;; keep the home clean
        savehist-file (expand-file-name "savehist" dupuchba-savefile-dir))
  (savehist-mode +1))

;; simpler window move behavior with arraow keys
(use-package windmove
  :config
  ;; use shift + arrow keys to switch between visible buffers
  (windmove-default-keybindings))

(use-package dired
  :config
  ;; dired - reuse current buffer by pressing 'a'
  (put 'dired-find-alternate-file 'disabled nil)

  ;; always delete and copy recursively
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)

  ;; if there is a dired buffer displayed in the next window, use its
  ;; current subdir, instead of the current subdir of this dired buffer
  (setq dired-dwim-target t)

  ;; enable some really cool extensions like C-x C-j(dired-jump)
  (require 'dired-x))

(use-package crux
  :ensure t
  :bind (("C-c o" . crux-open-with)
         ("M-o" . crux-smart-open-line)
         ("C-c n" . crux-cleanup-buffer-or-region)
         ("C-c f" . crux-recentf-find-file)
         ("C-M-z" . crux-indent-defun)
         ("C-c u" . crux-view-url)
         ("C-c e" . crux-eval-and-replace)
         ("C-c w" . crux-swap-windows)
         ("C-c D" . crux-delete-file-and-buffer)
         ("C-c r" . crux-rename-buffer-and-file)
         ("C-c t" . crux-visit-term-buffer)
         ("C-c k" . crux-kill-other-buffers)
         ("C-c TAB" . crux-indent-rigidly-and-copy-to-clipboard)
         ("C-c I" . crux-find-user-init-file)
         ("C-c S" . crux-find-shell-init-file)
         ("s-r" . crux-recentf-find-file)
         ("C-^" . crux-top-join-line)
         ("s-k" . crux-kill-whole-line)
         ("C-<backspace>" . crux-kill-line-backwards)
         ("s-o" . crux-smart-open-line-above)
         ([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ([(shift return)] . crux-smart-open-line)
         ([(control shift return)] . crux-smart-open-line-above)
         ([remap kill-whole-line] . crux-kill-whole-line)
         ("C-c s" . crux-ispell-word-then-abbrev)))

(use-package lisp-mode
  :config
  (defun bozhidar-visit-ielm ()
    "Switch to default `ielm' buffer.
Start `ielm' if it's not already running."
    (interactive)
    (crux-start-or-switch-to 'ielm "*ielm*"))

  (add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)
  (define-key emacs-lisp-mode-map (kbd "C-c C-z") #'bozhidar-visit-ielm)
  (define-key emacs-lisp-mode-map (kbd "C-c C-c") #'eval-defun)
  (define-key emacs-lisp-mode-map (kbd "C-c C-b") #'eval-buffer)
  (add-hook 'lisp-interaction-mode-hook #'eldoc-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'eldoc-mode))


(use-package ielm
  :config
  (add-hook 'ielm-mode-hook #'eldoc-mode)
  (add-hook 'ielm-mode-hook #'rainbow-delimiters-mode))

;;; third-party packages
(comment (use-package zenburn-theme
           :ensure t
           :config
           (load-theme 'zenburn t))

         (use-package zerodark-theme
           :ensure t
           :config
           (load-theme 'zerodark t)
           (zerodark-setup-modeline-format))
         (use-package plan9-theme
           :ensure t
           :config
           (load-theme 'plan9 t)))

(use-package twilight-bright-theme
  :ensure t
  :config
  (load-theme 'twilight-bright t))



(use-package avy
  :ensure t
  :bind (("C-M-S-s-g" . avy-goto-word-or-subword-1)
         ("C-M-g" . avy-goto-char))
  :config
  (setq avy-background t))

(use-package git-timemachine
  :ensure t
  :bind (("s-g" . git-timemachine)))

(use-package ag
  :ensure t)

(use-package projectile
  :ensure t
  :init
  (setq projectile-completion-system 'default)
  (setq projectile-project-search-path '("~/Projects/" "~/.emacs.d"))
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (setq projectile-indexing-method 'alien)
  (projectile-mode +1))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package elisp-slime-nav
  :ensure t
  :config
  (dolist (hook '(emacs-lisp-mode-hook ielm-mode-hook))
    (add-hook hook #'elisp-slime-nav-mode)))

(use-package paredit
  :ensure t
  :bind (("C-M-/" . paredit-forward-slurp-sexp)
         ("C-M-]" . paredit-backward-slurp-sexp))
  :config
  (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
  ;; enable in the *scratch* buffer
  (add-hook 'lisp-interaction-mode-hook #'paredit-mode)
  (add-hook 'ielm-mode-hook #'paredit-mode)
  (add-hook 'lisp-mode-hook #'paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'paredit-mode))

(use-package anzu
  :ensure t
  :bind (("M-%" . anzu-query-replace)
         ("C-M-%" . anzu-query-replace-regexp))
  :config
  (global-anzu-mode))

;; used to have all cmd from shell set correctly
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

(use-package move-text
  :ensure t
  :bind
  (([(meta shift up)] . move-text-up)
   ([(meta shift down)] . move-text-down)))

(use-package rainbow-delimiters
  :ensure t)

(use-package rainbow-mode
  :ensure t
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode))

(use-package whitespace
  :init
  (dolist (hook '(prog-mode-hook text-mode-hook))
    (add-hook hook #'whitespace-mode))
  (add-hook 'before-save-hook #'whitespace-cleanup)
  :config
  (setq whitespace-line-column 180) ;; limit line length
  (setq whitespace-style '(face tabs empty trailing lines-tail)))

(use-package clojure-mode
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'paredit-mode)
  (add-hook 'clojure-mode-hook #'subword-mode)
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
  (setq whitespace-line-column 180))

(use-package inf-clojure
  :ensure t
  :config
  (setq whitespace-line-column 180))

(defun cljs-webpack-repl ()
  (interactive)
  (inf-clojure "clj -m cljs.main -co dev.cljs.edn -v -c -r"))

(use-package cider
  :ensure t
  :config
  (setq nrepl-log-messages t)
  (add-hook 'cider-mode-hook #'eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'eldoc-mode)
  (add-hook 'cider-repl-mode-hook #'paredit-mode)
  (add-hook 'cider-repl-mode-hook #'rainbow-delimiters-mode))

(comment (use-package fennel-mode
           :ensure t))

(use-package flycheck-joker
  :ensure t)

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :config
  (setq markdown-fontify-code-blocks-natively t))

(use-package adoc-mode
  :ensure t
  :mode "\\.adoc\\'")

(use-package yaml-mode
  :ensure t)

(use-package php-mode
  :ensure t
  :mode "\\.php\\'")

(use-package dockerfile-mode
  :ensure t
  :mode ("Dockerfile\\'" . dockerfile-mode))

(use-package emmet-mode
  :ensure t
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode))

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

(use-package terraform-mode
  :ensure t)

(use-package company-terraform
  :ensure t
  :config (company-terraform-init))

(use-package js2-refactor
  :ensure t)

(use-package xref-js2
  :ensure t)

(use-package company-tern
  :ensure t
  :config
  (add-to-list 'company-backends 'company-tern)
  (add-hook 'js2-mode-hook (lambda ()
                             (tern-mode)
                             (company-mode)))
  (define-key tern-mode-keymap (kbd "M-.") nil)
  (define-key tern-mode-keymap (kbd "M-,") nil))

(use-package indium
  :ensure t
  :config
  (add-hook 'js-mode-hook #'indium-interaction-mode))

(use-package js2-mode
  :ensure t
  :mode ("\\.js\\'" . js2-mode)
  :config
  (add-hook 'js2-mode-hook #'js2-refactor-mode)
  (js2r-add-keybindings-with-prefix "C-c C-r")
  (add-hook 'js2-mode-hook #'js2-imenu-extras-mode)
  (define-key js2-mode-map (kbd "C-k") #'js2r-kill)
  (define-key js-mode-map (kbd "M-.") nil)
  (add-hook 'js2-mode-hook (lambda ()
                             (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t))))

(use-package dart-mode
  :ensure t)

(use-package cask-mode
  :ensure t)

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0.5)
  (setq company-show-numbers t)
  (setq company-tooltip-limit 10)
  (setq company-minimum-prefix-length 2)
  (setq company-tooltip-align-annotations t)
  ;; invert the navigation direction if the the completion popup-isearch-match
  ;; is displayed on top (happens near the bottom of windows)
  (setq company-tooltip-flip-when-above t)
  (global-company-mode))

(use-package hl-todo
  :ensure t
  :config
  (setq hl-todo-highlight-punctuation ":")
  (global-hl-todo-mode))

(use-package zop-to-char
  :ensure t
  :bind (("M-z" . zop-up-to-char)
         ("M-Z" . zop-to-char)))

(use-package flyspell
  :config
  (when (eq system-type 'windows-nt)
    (add-to-list 'exec-path "C:/Program Files (x86)/Aspell/bin/"))
  (setq ispell-program-name "aspell" ; use aspell instead of ispell
        ispell-extra-args '("--sug-mode=ultra"))
  (add-hook 'text-mode-hook #'flyspell-mode)
  (add-hook 'prog-mode-hook #'flyspell-prog-mode))

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(use-package super-save
  :ensure t
  :config
  ;; add integration with ace-window
  (add-to-list 'super-save-triggers 'ace-window)
  (super-save-mode +1))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode +1)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode))

(use-package which-key
  :ensure t
  :config
  (which-key-mode +1))

;; needed to tweak the matching algorithm used by ivy
(use-package flx
  :ensure t)

(use-package ace-window
  :ensure t
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-ignore-current t)
  (global-set-key (kbd "s-w") 'ace-window)
  (global-set-key [remap other-window] 'ace-window))

(use-package selectrum
  :ensure t
  :config
  (selectrum-mode +1)
  (setq selectrum-num-candidates-displayed 20)
  (let ((class '((class color) (min-colors 89))))
    (custom-theme-set-faces
     'zerodark
     `(selectrum-current-candidate
       ((,class (:background "azure1"
                             :weight bold
                             ))))
     `(selectrum-primary-highlight ((,class (:foreground "#da8548"))))
     `(selectrum-secondary-highlight ((,class (:foreground "#98be65")))))))

(use-package selectrum-prescient
  :ensure t
  :config
  ;; to make sorting and filtering more intelligent
  (selectrum-prescient-mode +1)
  ;; to save your command history on disk, so the sorting gets more
  ;; intelligent over time
  (prescient-persist-mode +1))

(use-package ctrlf
  :ensure t
  :config
  (ctrlf-mode +1))

;; Example configuration for Consult
(use-package consult
  :ensure t
  ;; Replace bindings. Lazily loaded due to use-package.
  :bind (("C-c o" . consult-outline)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x r x" . consult-register)
         ("C-x r b" . consult-bookmark)
         ("M-g o" . consult-outline) ;; "M-s o" is a good alternative
         ("M-g m" . consult-mark)    ;; "M-s m" is a good alternative
         ("M-g l" . consult-line)    ;; "M-s l" is a good alternative
         ("M-s m" . consult-multi-occur)
         ("M-y" . consult-yank-pop)
         ("<help> a" . consult-apropos))

  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Replace functions (consult-multi-occur is a drop-in replacement)
  (fset 'multi-occur #'consult-multi-occur)

  ;; Configure other variables and modes in the :config section, after lazily loading the package
  :config

  ;; Optionally enable previews. Note that individual previews can be disabled
  ;; via customization variables.
  (consult-preview-mode))

;; Optionally' enable richer annotations using the Marginalia package
(use-package marginalia
  :ensure t
  ;; The :init configuration is always executed (Not lazy!)
  :init

  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

;; temporarily highlight changes from yanking, etc
(use-package volatile-highlights
  :ensure t
  :config
  (volatile-highlights-mode +1))

;; org-mode
(use-package org
  :mode (("\\.org$" . org-mode))
  :ensure org-plus-contrib
  :bind-keymap ("C-M-S-s-o" . org-mode-map)
  :bind (:map org-mode-map
              ("C-c a" . org-agenda)
              ("C-c l" . org-link)
              ("C-c c" . org-capture))

  :config
  (progn (comment (ispell-change-dictionary "francais"))
         ;;@TODO: gerer les hook sur les input-method
         (comment (set-input-method 'french-postfix))
         (setq org-log-done t)
         (setq org-catch-invisible-edits nil)
         (setq whitespace-line-column 80)
         (setq org-agenda-files `(,(expand-file-name "~/Google Drive File Stream/My Drive/Org/inbox.org")
                                  ,(expand-file-name "~/Google Drive File Stream/My Drive/Org/gtd.org")
                                  ,(expand-file-name "~/Google Drive File Stream/My Drive/Org/tickler.org")))
         (setq org-capture-templates `(("t" "Todo [inbox]" entry
                                        (file+headline ,(expand-file-name "~/Google Drive File Stream/My Drive/Org/inbox.org") "Tasks")
                                        "* TODO %i%?")
                                       ("T" "Tickler" entry
                                        (file+headline ,(expand-file-name "~/Google Drive File Stream/My Drive/Org/tickler.org") "Tickler")
                                        "* %i%? \n %U")))
         (setq org-todo-keywords '((sequence "TODO(t)" "MUST DO TODAY(m)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
         (setq org-refile-targets '(("~/Google Drive File Stream/My Drive/Org/gtd.org" :maxlevel . 4)
                                    ("~/Google Drive File Stream/My Drive/Org/someday.org" :level . 1)
                                    ("~/Google Drive File Stream/My Drive/Org/tickler.org" :maxlevel . 2)))
         (setq org-agenda-custom-commands
               '(("o" "At the office" tags-todo "@office"
                  ((org-agenda-overriding-header "Office")
                   (org-agenda-skip-function #'my-org-agenda-skill-all-siblings-but-first)))
                 ("v" "Holidays" tags-todo "vacances"
                  ((org-agenda-overriding-header "Vacances")))
                 ("t" "This Week" tags-todo "thisweek"
                  ((org-agenda-overriding-header "Todo This Week")))))

         (defun org-current-is-todo ()
           (string= "TODO" (org-get-todo-state)))

         (defun my-org-agenda-skill-all-siblings-but-first ()
           "Skip all but the first non-done entry."
           (let (should-skip-entry)
             (unless (org-current-is-todo)
               (setq should-skip-entry t))
             (save-excursion
               (while (and (not should-skip-entry)
                           (org-goto-sibling t))
                 (when (org-current-is-todo)
                   (setq should-skip-entry t))))
             (when should-skip-entry
               (or (outline-next-heading)
                   (goto-char (point-max))))))

         (defun org/get-headline-string-element  (headline backend info)
           (let ((prop-point (next-property-change 0 headline)))
             (if prop-point (plist-get (text-properties-at prop-point headline) :parent))))

         (defun org/ensure-latex-clearpage (headline backend info)
           (when (org-export-derived-backend-p backend 'latex)
             (let ((elmnt (org/get-headline-string-element headline backend info)))
               (when (member "newpage" (org-element-property :tags elmnt))
                 (concat "\\clearpage\n" headline)))))

         (add-to-list 'org-export-filter-headline-functions
                      'org/ensure-latex-clearpage)))

(use-package magit
  :ensure t)

(use-package forge
  :ensure t
  :after magit)

(use-package ox-pandoc
  :ensure t)

(use-package tex
  :defer t
  :ensure auctex
  :config
  (setq TeX-auto-save t))

(use-package org-mime
  :ensure t)

(use-package command-log-mode
  :ensure t)

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-c C->") 'mc/mark-next-like-this-word)
  (global-set-key (kbd "C-c C-/") 'mc/mark-all-words-like-this))

(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (let ((current-buffer (current-buffer)))
    (mapc (lambda (buff)
            (when (not (or (minibufferp buff) (eq current-buffer buff)))
              (kill-buffer buff)))
          (buffer-list))))

(defun copy-region-to-new-buffer ()
  "Copy the selected region to a new editable buffer."
  (interactive)
  (let* ((c-buffer (current-buffer))
         (start (if (<= (mark) (point)) (mark) (point)))
         (end (if (<= (mark) (point)) (point) (mark)))
         (n-buffer (generate-new-buffer "ohh"))
         (c-mode major-mode))
    (save-excursion
      (with-current-buffer n-buffer
        (insert-buffer-substring c-buffer start end)
        (display-buffer n-buffer)
        (funcall c-mode)))))

(defun describe-last-function()
  (interactive)
  (describe-function last-command))

(defun resize-window ()
  "Awesome function that creates temp keymaps for resizing windows."
  (interactive)
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "<right>") 'shrink-window-horizontally)
     (define-key map (kbd "<left>") 'enlarge-window-horizontally)
     (define-key map (kbd "<up>") 'shrink-window)
     (define-key map (kbd "<down>") 'enlarge-window)
     (define-key map (kbd "S-<right>") (lambda () (interactive) (shrink-window-horizontally 10)))
     (define-key map (kbd "S-<left>") (lambda () (interactive) (enlarge-window-horizontally 10)))
     (define-key map (kbd "S-<up>") (lambda () (interactive) (shrink-window 10)))
     (define-key map (kbd "S-<down>") (lambda () (interactive) (enlarge-window 10)))
     map)
   t))

(global-set-key (kbd "C-x C-<up> C-<up>") 'resize-window)

;; config changes made through the customize UI will be stored here
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(when (file-exists-p custom-file)
  (load custom-file))


;;; init.el ends here
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
