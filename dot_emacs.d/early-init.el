;;; -*- lexical-binding: t -*-
;;; early-init.el

;;; Commentary:

;;; Code:

;; work around native compilation target version issue
(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET" "27.0"))

;; turn off some items before the GUI loads to prevent flashing
(setq inhibit-startup-screen t)

;; So we can detect this having been loaded
(provide 'early-init)

;;; early-init.el ends here
