;;; -*- lexical-binding: t -*-
;;; early-init.el

;;; Commentary:

;;; Code:

;; turn off some items before the GUI loads to prevent flashing
(setq inhibit-startup-screen t)

;; So we can detect this having been loaded
(provide 'early-init)

;;; early-init.el ends here
