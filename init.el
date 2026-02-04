;;; --- Package setup (do this once, near the top) ---
(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

;; Always refresh if we have no archive contents yet (or if downloads 404 due to stale indices).
(unless package-archive-contents
  (package-refresh-contents))

;; Ensure use-package exists before any (use-package ...) forms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; --- Line numbers ---
;; linum is old/slow; display-line-numbers is built-in and faster (Emacs 26+)
;; If you prefer linum, you can keep it, but I'd strongly recommend this:
(global-display-line-numbers-mode 1)
(setq line-number-mode t)

;;; --- UI ---
(setq make-backup-files nil)

;;; --- C++ style ---
(add-hook 'c++-mode-hook
          (lambda ()
            (setq c-basic-offset 4
                  tab-width 4
                  indent-tabs-mode nil)))

;;; --- Clipboard helper (your function unchanged) ---
(defun my/pbcopy-region-via-tempfile (beg end)
  "Write active region (BEG..END) to a temp file, pbcopy it, then delete the file."
  (interactive "r")
  (unless (use-region-p)
    (user-error "No active region"))
  (let ((tmp (make-temp-file "emacs-pbcopy-" nil ".txt")))
    (unwind-protect
        (progn
          (write-region beg end tmp nil 'silent)
          (call-process "sh" nil nil nil "-c"
                        (format "cat %s | pbcopy"
                                (shell-quote-argument tmp)))
          (message "Region copied to clipboard"))
      (ignore-errors (delete-file tmp)))))

(global-set-key (kbd "C-c y") #'my/pbcopy-region-via-tempfile)

;;; --- Company + LSP (clangd) ---
(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 1))

(use-package lsp-mode
  :commands lsp
  :hook ((c-mode c++-mode python-mode) . lsp)
  :custom
  (lsp-keymap-prefix "C-c l"))

(use-package lsp-ui
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-sideline-enable t))

;;; Use for ripgrep
(use-package rg
  :commands rg
  :config (rg-enable-default-bindings))

;;; Which key for keybinds
(use-package which-key
  :init (which-key-mode))

;;; Better mini-buffer
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom (completion-styles '(orderless basic))
          (completion-category-defaults nil)
          (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

;;; For use of imenu
(global-set-key (kbd "C-c i") #'imenu)


;;; For git integration
(use-package magit
  :commands (magit-status magit-blame)
  :bind (("C-c g" . magit-status)))

;;; Vterm
(use-package vterm
  :commands vterm)

;;; See tabs at the bottom
(tab-bar-mode 1)
(setq tab-bar-position 'bottom)
(setq tab-bar-show 1)
(setq tab-bar-close-button-show nil)
(setq tab-bar-new-button-show nil)

(when (display-graphic-p)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (set-face-attribute 'default nil :family "Menlo" :height 140)
  (load-theme 'wombat t))

;; prevent server errors
(require 'server)
(unless (server-running-p)
  (server-start))

;;; Easy moving between tabs
(global-set-key (kbd "C-c [") #'tab-previous)
(global-set-key (kbd "C-c ]") #'tab-next)
;;; Easy shortcuts
(global-set-key (kbd "C-c s") #'rg)
(global-set-key (kbd "C-c t") #'vterm)


;; ---- Clean up tab-bar appearance ----
(setq tab-bar-separator "  ")   ;; space between tabs
(setq tab-bar-border 0)

(custom-set-faces
 ;; overall bar
 '(tab-bar
   ((t (:inherit default
        :background "#1c1c1c"
        :foreground "#d0d0d0"
        :box nil))))

 ;; active tab
 '(tab-bar-tab
   ((t (:inherit tab-bar
        :background "#3a3a3a"
        :foreground "#ffffff"
        :weight bold
        :box nil))))

 ;; inactive tabs
 '(tab-bar-tab-inactive
   ((t (:inherit tab-bar
        :background "#1c1c1c"
        :foreground "#9e9e9e"
        :box nil)))))

;; Better tex editing
(use-package company-auctex
  :after (company tex)
  :config
  (company-auctex-init))

;;; ---------- LaTeX + PDF workflow (zero prompts) ----------

;; AUCTeX: parse document for labels/commands, etc.
(setq TeX-auto-save t
      TeX-parse-self t)

;; AUCTeX: stop asking questions every compile
(setq TeX-save-query nil)          ;; don't ask to save before compiling
(setq TeX-command-default "LatexMk")
(setq TeX-show-compilation nil)    ;; don't steal focus with compilation window
(setq TeX-master nil)              ;; or set to "main.tex" if you want a fixed master

;; PDF Tools (view PDFs inside Emacs)
(use-package pdf-tools
  :config
  (pdf-tools-install))

(setq TeX-view-program-selection
      '((output-pdf "PDF Tools")))

;; Auto-refresh PDFs when they change + disable line numbers in PDFs
(use-package autorevert
  :ensure nil
  :init
  (global-auto-revert-mode 1)
  :custom
  (auto-revert-verbose nil))

(add-hook 'pdf-view-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)
            (auto-revert-mode 1)))

(defun my/latexmk ()
  "Save and run latexmk -pdf on the current TeX master (no prompts)."
  (interactive)
  (save-buffer)
  ;; If using AUCTeX, this respects %!TEX root and TeX-master.
  ;; If not, it still works for single-file docs.
  (let* ((tex (if (fboundp 'TeX-master-file) (TeX-master-file) buffer-file-name))
         (cmd (format "latexmk -pdf -interaction=nonstopmode -synctex=1 %s"
                      (shell-quote-argument tex))))
    (compile cmd)))


(global-set-key (kbd "C-c C-b") #'my/latexmk)

;; LaTeX indentation
(setq LaTeX-indent-level 2)
(setq LaTeX-item-indent 0)
;; latex {} pairs
(add-hook 'LaTeX-mode-hook #'electric-pair-local-mode)

;;; ---------- Python IDE ----------

;; Built-in python mode
(use-package python
  :ensure nil
  :hook (python-mode . (lambda ()
                        (setq python-indent-offset 4))))

(setq lsp-pylsp-plugins-flake8-enabled nil) ;; (only relevant if using pylsp)

;; Tell lsp-mode to use pyright
(use-package lsp-pyright
  :after lsp-mode
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))

;; Makes emacs use the same python interpreter
(use-package pyvenv
  :config
  (pyvenv-mode 1))

;; auto formats python
(use-package reformatter)

(reformatter-define black-format
  :program "black"
  :args '("-q" "-"))

(add-hook 'python-mode-hook #'black-format-on-save-mode)

