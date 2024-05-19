;;; early-init.el --- Emacs 27+ pre-initialisation config

;;; Commentary:

;;; Code:

;; turn off some items before the GUI loads to prevent flashing
(setq inhibit-startup-screen t)

;; turn on menu (for GUIs only), turn off tool-bar, scroll-bar
(if (display-graphic-p)
    (menu-bar-mode 1)
  (menu-bar-mode -1))

(tool-bar-mode -1)
(scroll-bar-mode -1)

;; So we can detect this having been loaded
(provide 'early-init)

;;; early-init.el ends here
