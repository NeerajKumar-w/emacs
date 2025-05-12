;; -*- lexical-binding: t; -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values '((git-commit-major-mode . git-commit-elisp-text-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Remove UI elements

(menu-bar-mode -1)
(tool-bar-mode -1)             ; Hide the outdated icons
(scroll-bar-mode -1)           ; Hide the always-visible scrollbar
(setq inhibit-splash-screen t) ; Remove the "Welcome to GNU Emacs" splash screen
(setq use-file-dialog nil)      ; Ask for textual confirmation instead of GUI

;; Electric-Pair-Mode

(electric-pair-mode 1)

;; Package Manager

(defvar bootstrap-version)
(let ((bootstrap-file
    (expand-file-name
      "straight/repos/straight.el/bootstrap.el"
      (or (bound-and-true-p straight-base-dir)
        user-emacs-directory)))
    (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
       'silent 'inhibit-cookies)
    (goto-char (point-max))
    (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

;; Defaults

(use-package emacs
  :init
  (setq initial-scratch-message nil)
  (defun display-startup-echo-area-message ()
    (message "")))

(use-package emacs
  :init
  (defalias 'yes-or-no-p 'y-or-n-p))

(use-package emacs
  :init
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix)))

(use-package emacs
  :init
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2))

;; Font and Theme
(set-frame-font "SpaceMonoNerdFont 14" nil t)
(load-theme 'whiteboard :no-confirm)

(use-package emacs
  :init
  (defun ab/enable-line-numbers ()
    "Enable relative line numbers"
    (interactive)
    (display-line-numbers-mode)
    (setq display-line-numbers 'relative))
  (add-hook 'prog-mode-hook #'ab/enable-line-numbers))

;; Modeline

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; Eglot-LSP

(use-package eglot
  :hook ((js-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (tsx-mode . eglot-ensure)) ;; Attach Eglot to JavaScript-related modes
  :config
  (add-to-list 'eglot-server-programs
               '((js-mode js-ts-mode typescript-mode tsx-mode)
                 . ("typescript-language-server" "--stdio")))

  ;; Optional: Configure formatting on save
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'eglot-format-buffer nil t))))

;; Corfu for auto completion

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode) ;; Enable Corfu globally
  :config
  (setq corfu-auto t                     ;; Enable auto-completion
        corfu-auto-prefix 1              ;; Start after 1 character
        corfu-auto-delay 0.2))           ;; Delay before suggestions

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file) ;; File completion
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)) ;; Word expansion

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        (list (cape-super-capf #'eglot-completion-at-point #'cape-file)))))

;; Better Minibuffer  UI

(fido-vertical-mode t)

;; Projectile

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

;; Org Mode

;; Basic Org mode setup with default Emacs installation
(setq org-directory "~/org")  ;; Set your Org directory
(setq org-agenda-files (list "~/org/agenda.org"))  ;; Set agenda files
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/agenda.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("n" "Note" entry (file "~/org/notes.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

;; Optional: Visual enhancements
(setq org-startup-indented t
      org-hide-leading-stars t)

;; Formatter

(use-package format-all
  :hook (prog-mode . format-all-mode)
  :config
  (setq-default format-all-formatters
                '(("JavaScript" (prettier "--jsx-single-quote" "--tab-width 4")))))

;; Tree sitter

(use-package tree-sitter
  :ensure t)

(use-package tree-sitter-langs
  :ensure t
  :hook
  (tree-sitter-after-on . tree-sitter-hl-mode))
