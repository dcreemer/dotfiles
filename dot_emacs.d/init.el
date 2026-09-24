;;; -*- lexical-binding: t -*-
;;
;; init.el -- dcreemer's emacs file
;;
;;; Commentary:
;; Personal Emacs configuration.

;;; Code:

;; -----------------------------------------------------------------------------
;; Bootstrap the package system
;; -----------------------------------------------------------------------------

;; Add MELPA to end of archives list
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Compile installed packages to native code.
(setq package-native-compile t)

(eval-when-compile
  (require 'use-package))

;; -----------------------------------------------------------------------------
;; Define the state of the system
;; -----------------------------------------------------------------------------

(defconst *is-a-mac* (eq system-type 'darwin))

;; Mac OS X Emacs.app needs a bit of help getting shell variables
(use-package exec-path-from-shell
  :if *is-a-mac*
  :ensure t
  :config
  (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE"
                 "GOPATH" "OS" "DIST"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

;; Show the menu bar only in graphical frames; hide tool and scroll bars.
(if (display-graphic-p)
    (progn
      (menu-bar-mode 1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      (add-to-list 'default-frame-alist '(left . 50))
      (add-to-list 'default-frame-alist '(top . 50))
      (add-to-list 'default-frame-alist '(width . 120))  ; Columns
      (if *is-a-mac*
          ;; My macs have bigger screens
          (add-to-list 'default-frame-alist '(height . 55))
          (add-to-list 'default-frame-alist '(height . 37)))) ; Rows
  (menu-bar-mode -1))

;; Enable basic mouse support in terminals.
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; Keep transient state in a common directory.
(defvar user-state-directory
  (expand-file-name "state" user-emacs-directory)
  "Default directory for transient user state.")

(defun state-file (path)
  "Expand PATH relative to `user-state-directory'."
  (expand-file-name path user-state-directory))

;; Store backups together and keep multiple versions.
(setq backup-directory-alist `(("." . ,(state-file "backups")))
      delete-old-versions t
      kept-new-versions 3
      kept-old-versions 2
      version-control t)

;; Store auto-save files in the state directory too.
(setq auto-save-list-file-prefix (state-file "auto-save-list/.saves-")
      auto-save-file-name-transforms
      `(("\\`\\([^/]*/\\)*\\([^/]*\\)\\'" ; match /path/to/file and capture (file)
         ,(concat (state-file "auto-saves/") "\\2") t)))

;; Write customizations to a separate file.
(setq custom-file (locate-user-emacs-file "custom.el"))

;; -----------------------------------------------------------------------------
;; UI-based customizations
;; -----------------------------------------------------------------------------

;; Support use-package's :diminish keyword.
(use-package diminish
  :ensure t)

(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi-deuteranopia :no-confirm))

;; Fit text into two side-by-side windows on my Mac.
(setq-default fill-column 90)

(use-package unfill
  :ensure t
  :bind ("M-q" . unfill-toggle))

;; Always show column numbers.
(setq-default column-number-mode t)

;; Use four-space indentation for C-family modes.
(setq-default c-basic-offset 4)

;; Indent with spaces.
(setq-default indent-tabs-mode nil)

;; UTF-8 Unicode everywhere
(set-charset-priority 'unicode)
(setq locale-coding-system 'utf-8
      coding-system-for-read 'utf-8
      coding-system-for-write 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;; Preserve the cursor's screen position when scrolling.
(setq scroll-preserve-screen-position t)

;; Remember recently visited files.
(use-package recentf
  :ensure nil
  :config
  (setq recentf-max-saved-items 500
        recentf-max-menu-items 5
        recentf-save-file (state-file "recentf")
        recentf-exclude '("/tmp/" "/ssh:"))
  (recentf-mode +1))

;; Preview the destination when jumping to a line.
(use-package goto-line-preview
  :ensure t
  :bind ("M-g M-g" . goto-line-preview))

(use-package ace-jump-mode
  :ensure t
  :bind ("M-j" . ace-jump-mode))

;; Accept y or n instead of yes or no.
(defalias 'yes-or-no-p #'y-or-n-p)

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1))

(use-package nerd-icons
  :ensure t)

(use-package whitespace
  :ensure t
  :diminish whitespace-mode
  :hook (prog-mode . whitespace-mode)
  :config
  (setq whitespace-line-column 99
        whitespace-style '(face empty lines-tail trailing)))

;; Color delimiters by nesting depth.
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; Join lines as in Vim.
(defun dc/join-forward ()
  "Join the next line to the current one."
  (interactive)
  (join-line 1))

(global-set-key (kbd "C-c J") #'dc/join-forward)

;; Highlight the current line to make the cursor easier to find.
(global-hl-line-mode)

(use-package vundo
  :ensure t
  :bind ("M-_" . vundo))

;; Revert Dired and other buffers
(customize-set-variable 'global-auto-revert-non-file-buffers t)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer-list-buffers)
  :config
  ;; Stop at the ends when navigating the buffer list.
  (customize-set-variable 'ibuffer-movement-cycle nil)
  ;; Consider buffers old after 24 hours.
  (customize-set-variable 'ibuffer-old-time 24))

;; Use Ghostty for terminal buffers.
(use-package ghostel
  :ensure t
  :commands ghostel
  :init
  (setq ghostel-module-auto-install 'download
        ghostel-module-directory (state-file "ghostel/")))

(defun rlr/ghostel-buffer ()
  "Return the first buffer whose name matches Ghostel, or nil if none exists."
  (seq-find (lambda (buf)
              (string-match-p "\\*ghostel:" (buffer-name buf)))
            (buffer-list)))

(defun rlr/ghostel-toggle ()
  "Show a Ghostel buffer, create one if needed, or bury it when current."
  (interactive)
  (let ((buf (rlr/ghostel-buffer)))
    (cond
     ((not buf)
      (ghostel))
     ((eq (current-buffer) buf)
      (bury-buffer))
     (t
      (switch-to-buffer buf)))))

(bind-key* "M-$" #'rlr/ghostel-toggle)

;; -----------------------------------------------------------------------------
;; Basic utilities
;; -----------------------------------------------------------------------------

(use-package ivy
  :ensure t
  :config
  (ivy-mode))

;; -----------------------------------------------------------------------------
;; Programming mode configuration
;; -----------------------------------------------------------------------------

(use-package rg
  :ensure t
  :config
  (rg-enable-default-bindings))

(use-package projectile
  :ensure t
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (setq projectile-cache-file (state-file "projectile.cache")
        projectile-known-projects-file (state-file "projectile-bookmarks.eld"))
  (when (executable-find "rg")
    (setq-default projectile-generic-command "rg --files --hidden -0"))
  (projectile-mode +1))

;; Show line numbers and pair delimiters in programming modes.
(use-package prog-mode
  :ensure nil
  :hook ((prog-mode . display-line-numbers-mode)
         (prog-mode . electric-pair-mode)))

(use-package company
  :ensure t
  :init
  (global-company-mode))

;; Load project-specific environment settings.
(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))

;; Configure automatic tree-sitter mode selection and grammar installation.
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist '(python clojure))
  (delete 'rust treesit-auto-langs) ;; missing some features
  (global-treesit-auto-mode))

(use-package markdown-mode
  :ensure t
  :defer t
  :mode ("\\.md\\'" "\\.markdown\\'")
  :hook ((markdown-mode . display-fill-column-indicator-mode)
         (markdown-mode . auto-fill-mode)))

(use-package rust-mode
  :ensure t
  :defer t
  :hook ((rust-mode . eglot-ensure)
         (rust-mode . cargo-minor-mode))
  :config
  (setq rust-format-on-save t)
  (use-package cargo
    :ensure t))

(use-package python
  :ensure t
  :defer t
  :hook (python-base-mode . eglot-ensure))

(use-package ruff-format
  :ensure t
  :defer t
  :hook (python-base-mode . ruff-format-on-save-mode))

(use-package pet
  :ensure t
  :commands pet-mode
  :init
  (add-hook 'python-base-mode-hook #'pet-mode -10))

;; (use-package clojure-mode
;;   :ensure t
;;   :defer t
;;   :config
;;   :hook ((clojure-mode    . aggressive-indent-mode)
;;          (clojure-ts-mode . aggressive-indent-mode)))
;; 
;; (use-package cider
;;   :ensure t
;;   :defer t)

(use-package just-mode
  :ensure t
  :defer t)

(use-package janet-mode
  :ensure t
  :defer t)

;; Dove:
;; (define-derived-mode dove-mode lisp-mode "Dove"
;;   "Major mode for editing Dove files.")
;; (add-to-list 'auto-mode-alist '("\\.dove\\'" . dove-mode))

;; (let ((pm "~/personal/pona/extras/pona-mode.el"))
;;  (when (file-exists-p pm)
;;     (load-file pm)))

;; Startup dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents . 5)
                          (projects . 5))
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-center-content t))

;; Start the Emacs server.
(server-start)

(provide 'init)

;;; init.el ends here
