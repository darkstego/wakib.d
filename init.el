;; -*- lexical-binding: t -*-

;;----------------------------------------------------------------------------
;; Adjust garbage collection
;;----------------------------------------------------------------------------
(setq gc-cons-threshold (* 20 1024 1024))


;; ---------------------
;; Setup Load Path
;; ---------------------

(nconc load-path
       (list (expand-file-name "local" user-emacs-directory)
	     (expand-file-name "wakib" user-emacs-directory)))


;; -----------------------
;; use-package
;; -----------------------
(setq load-prefer-newer t)              ; Don't load outdated byte code

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)


;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)
(use-package diminish)

;; -------------------
;; Wakib
;; -------------------
(require 'wakib-mode)
(wakib-mode 1)
(diminish 'wakib-mode)
(add-hook 'after-change-major-mode-hook 'wakib-update-major-mode-map)

;; -------------------
;; Initial Setup
;; -------------------
(tool-bar-mode -1)
(delete-selection-mode 1)
(unless (display-graphic-p)
  (menu-bar-mode -1))
;; Might cause performance issues
(advice-add 'substitute-command-keys :around #'wakib-substitute-command-keys)

;; Menu Bars
(bind-key [menu-bar file new-file]
	  `(menu-item "New File..." wakib-new-empty-buffer :enable (menu-bar-non-minibuffer-window-p)
		      :help "Create a new blank buffer"
		      :key-sequence ,(kbd "C-n")))

(bind-key [menu-bar file open-file]
	  `(menu-item "Open File..." find-file :enable (menu-bar-non-minibuffer-window-p)
		      :help "Read an existing or new file from disk"
		      :key-sequence ,(kbd "C-o")))

(bind-key [menu-bar file dired]
	  `(menu-item "Open Directory..." dired :enable (menu-bar-non-minibuffer-window-p)
		      :help "Browse a directory, to operate on its files"
		      :keys "C-e d"))

(bind-key [menu-bar file insert-file]
	  `(menu-item "Insert File..." insert-file :enable (menu-bar-non-minibuffer-window-p)
		      :help "Insert another file into current buffer"
		      :keys "C-e i"))



;; -------------------
;; Theme
;; -------------------
(use-package moe-theme
  :config
  (load-theme 'moe-dark t))

;; -------------------
;; Magit
;; -------------------
(use-package magit
  :bind
  (("C-x g" . magit-status )))



(use-package exec-path-from-shell
  :disabled
  :config
  (exec-path-from-shell-copy-env "SSH_AGENT_PID")
  (exec-path-from-shell-copy-env "SSH_AUTH_SOCK"))
    

;; -------------------
;; Ivy
;; -------------------
(use-package ivy
  :diminish ivy-mode
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-count-format "")
  (setq ivy-initial-inputs-alist nil))

(use-package counsel
  :diminish counsel-mode
  :config
  (counsel-mode 1))

(use-package smex)
  ;; :config
  ;; (global-set-key [remap execute-extended-command] 'smex))

;; -------------------
;; Projectile
;; -------------------
;; No deferred loading as bind-keymap
;; doesn't handle wakib C-d keymaps
(use-package projectile
  :diminish projectile-mode
  :config
  (setq projectile-completion-system 'ivy)
  (projectile-global-mode)
  (wakib-update-menu-map (global-key-binding [menu-bar tools Projectile]) projectile-command-map "C-d p"))
;;(projectile-project-p)


;; -------------------
;; expand-region
;; -------------------
(use-package company               
  :diminish company-mode
  :config
  (global-company-mode 1))

;; -------------------
;; expand-region
;; -------------------
(use-package expand-region
  :commands er/expand-region
  :bind ("M-A" . er/expand-region))

;; -------------------
;; avy
;; -------------------
(use-package avy
  :bind ("M-m" . avy-goto-char-2))

;; -------------------
;; which-key
;; -------------------
(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode))

;; -------------------
;; uniquify
;; -------------------

;; TODO (built into emacs, check performance hit if worth it)


(use-package quickrun
  :config
  (setq quickrun-focus-p nil)
  (defun quickrun--recenter (arg)
  (with-selected-window (get-buffer-window quickrun--buffer-name)
    (recenter arg)
    (end-of-buffer)))
  :bind
  (([f8] . quickrun )))


;; Better Parenthesis
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
(show-paren-mode 1)
(electric-pair-mode 1)
;; TODO - MOVE Electric Pair Mode to user local


;; MAJOR MODES

(use-package markdown-mode
  :mode "\\.\\(m\\(ark\\)?down\\|md\\)$")


(use-package org
  :config
  (bind-key (kbd "M-e") nil org-mode-map)
  (bind-key (kbd "C-e") nil org-mode-map))


;; Setup Splash Screen
(setq inhibit-startup-screen t)
(setq-default major-mode 'org-mode)
(setq initial-buffer-choice 'wakib-new-empty-buffer)
(setq-default initial-scratch-message ";; Emacs elisp scratch buffer. Happy hacking.\n\n")

(setq custom-file (expand-file-name "custom" user-emacs-directory))
(load custom-file t t)

