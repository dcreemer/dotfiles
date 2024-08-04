;;; init.el -- dcreemer's emacs file
;;
;;; Commentary:
;; see README.md for info and credits

;;; Code:

;; -----------------------------------------------------------------------------
;; bootstrap the package system
;; -----------------------------------------------------------------------------

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Add MELPA to end of archives list
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; bootup package system
(setq package-native-compile t)
(package-initialize)

(eval-when-compile
  (require 'use-package))

;; -----------------------------------------------------------------------------
;; define the state of the system
;; -----------------------------------------------------------------------------

(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-mac-gui* (and (display-graphic-p) *is-a-mac*))

;; Mac OS X Emacs.app needs a bit of help getting shell variables
(use-package exec-path-from-shell
  :if (display-graphic-p)
  :ensure t
  :init
  (setq exec-path-from-shell-check-startup-files nil)
  :config
  (dolist (var '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO" "LANG" "LC_CTYPE"
                 "GOPATH" "OS" "DIST"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

;; in terminals, enable basic mouse support
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; keep all transient state in a custom directory
(defvar user-state-directory
  (expand-file-name "state" user-emacs-directory)
  "Default directory for transient user state.")

(defun state-file (path)
  "Calculate the PATH for a transient state file."
  (expand-file-name path user-state-directory))

;; save backup files to common location, and keep more versions
(setq backup-directory-alist `(("." . ,(state-file "backups")))
      delete-old-versions t
      kept-new-versions 3
      kept-old-versions 2
      version-control t)

;; auto-save also goes to state directory
(setq auto-save-list-file-prefix (state-file "auto-save-list/.saves-"))
(setq auto-save-file-name-transforms
      `(("\\`\\([^/]*/\\)*\\([^/]*\\)\\'" ; match /path/to/file and capture (file)
         ,(concat (state-file "auto-saves/") "\\2") t)))

;; customizations go in a separate file
(setq custom-file (locate-user-emacs-file "custom.el"))

;; -----------------------------------------------------------------------------
;; UI-based customizations
;; -----------------------------------------------------------------------------

;; we need diminish for the use-package support
(use-package diminish
  :ensure t)

;; set the color theme to something nice on startup
(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi-deuteranopia :no-confirm))

;; fill column is about 1/2 full screen w/with two side-by-side windows on my mac
(setq-default fill-column 90)

;; always show column numbers
(setq-default column-number-mode t)

;; indent is 4 charactes
(setq-default c-basic-offset 4)

;; tabs are 8
(setq-default tab-width 8)

;; never insert tabs
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

;; why isn't it always this?
(setq scroll-preserve-screen-position t)

;; remember files I have visited
(use-package recentf
  :ensure nil
  :config
  (setq recentf-max-saved-items 500)
  (setq recentf-max-menu-items 5)
  (setq recentf-save-file (state-file "recentf"))
  (setq recentf-exclude '("/tmp/" "/ssh:"))
  (recentf-mode +1))

;; preview line on goto
(use-package goto-line-preview
  :ensure t
  :bind ("M-g M-g" . #'goto-line-preview))

;; ace-jump
(use-package ace-jump-mode
  :ensure t
  :bind ("M-j" . ace-jump-mode))

;; y or n instead of yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; which-key is great
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

;; configure a nicer modeline...
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; ... with icons
(use-package nerd-icons
  :ensure t)

;; whitespace
(use-package whitespace
  :ensure t
  :diminish whitespace-mode
  :hook (prog-mode . whitespace-mode)
  :config
  (setq whitespace-line-column 99)
  (setq whitespace-style '(face empty lines-tail trailing)))

;; colorize parents
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; like join from vim.
(defun dc/join-forward ()
  "Join the next line to the current one."
  (interactive)
  (join-line 1))

(global-set-key (kbd "C-c J") #'dc/join-forward)

;; make the cursor more visible:
(global-hl-line-mode)

;; undo tree
(use-package vundo
  :ensure t
  :bind ("M-_" . vundo))

;; Revert Dired and other buffers
(customize-set-variable 'global-auto-revert-non-file-buffers t)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

(use-package ibuffer
  :bind ("C-x C-b" . #'ibuffer-list-buffers)
  :config
  ;; turn off forward and backward movement cycling
  (customize-set-variable 'ibuffer-movement-cycle nil)
  ;; the number of hours before a buffer is considered "old" by ibuffer.
  (customize-set-variable 'ibuffer-old-time 24))

;; -----------------------------------------------------------------------------
;; Basic Utilities
;; -----------------------------------------------------------------------------

(use-package ivy
  :ensure t
  :config
  (ivy-mode))

(use-package vterm
  :ensure t)

;; -----------------------------------------------------------------------------
;; Programming Mode Configuration
;; -----------------------------------------------------------------------------

(use-package projectile
  :ensure t
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (setq projectile-cache-file (state-file "projectile.cache")
        projectile-known-projects-file (state-file "projectile-bookmarks.eld"))
  (when (executable-find "rg")
    (setq-default projectile-generic-command "rg --files --hidden -0"))
  (projectile-mode +1))

;; line numbers & delimiters
(use-package prog-mode
  :ensure nil
  :hook ((prog-mode . display-line-numbers-mode)
         (prog-mode . electric-pair-mode)))

;; company for completion
(use-package company
  :ensure t
  :init
  (global-company-mode))

;; tree-sitter for all languages available
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist '(python clojure))
  (delete 'rust treesit-auto-langs) ;; missing some features
  (global-treesit-auto-mode))

(use-package gptel
  :ensure t
  :bind ("C-c RET" . gptel-send)
  :config
  (gptel-make-ollama "Ollama"
    :host "localhost:11434"
    :stream t
    :models '("codestral:latest" "llama3:latest")))

;; markdown
(use-package markdown-mode
  :ensure t
  :defer t
  :mode ("\\.md\\'" "\\.markdown\\'")
  :config
  :hook ((markdown-mode . display-fill-column-indicator-mode)
         (markdown-mode . auto-fill-mode)))

(use-package rust-mode
  :ensure t
  :defer t
  :hook ((rust-mode    . eglot-ensure)
         (rust-mode    . cargo-minor-mode))
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
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10))

(use-package clojure-mode
  :ensure t
  :defer t
  :config
  :hook ((clojure-mode    . aggressive-indent-mode)
         (clojure-ts-mode . aggressive-indent-mode)))

(use-package cider
  :ensure t
  :defer t)

(provide 'init)

;;; init.el ends here
