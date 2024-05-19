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
(use-package vscode-dark-plus-theme
  :ensure t
  :config
  (load-theme 'vscode-dark-plus t))

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
  (which-key-mode)
  ; (which-key-setup-side-window-right)
  )

;; configure a nicer modeline...
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; ... with icons
(use-package nerd-icons
  :ensure t)

;; whitespace
(use-package whitespace
  :hook (prog-mode . whitespace-mode)
  :diminish whitespace-mode
  :config
  (setq whitespace-line-column 99)
  (setq whitespace-style '(face empty lines-tail trailing)))

;; like join from vim.
(defun dc/join-forward ()
  "Join the next line to the current one."
  (interactive)
  (join-line 1))

(global-set-key (kbd "C-c J") #'dc/join-forward)

;; make the cursor more visible:
(global-hl-line-mode)

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

;; line numbers
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'electric-pair-mode)

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
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; markdown
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" "\\.markdown\\'")
  :config
  :hook ((markdown-mode . display-fill-column-indicator-mode)
         (markdown-mode . auto-fill-mode)))

(use-package rust-mode
  :ensure t
  :hook (rust-mode . eglot-ensure)
  :hook (rust-ts-mode . eglot-ensure)
  :hook (rust-mode . cargo-minor-mode)
  :hook (rust-ts-mode . cargo-minor-mode)
  :config
  (use-package cargo
    :ensure t))

(use-package python
  :ensure t
  :hook (python-mode . eglot-ensure)
  :hook (python-ts-mode . eglot-ensure))

(provide 'init)

;;; init.el ends here
