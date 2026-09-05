(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(misterioso))
 '(package-selected-packages
   '(ai-code cmake-mode company-auctex cython-mode ess lsp-pyright lsp-ui
	     magit marginalia orderless pdf-tools projectile pyvenv
	     reformatter rg vertico vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(tab-bar ((t (:inherit default :background "#1c1c1c" :foreground "#d0d0d0" :box nil))))
 '(tab-bar-tab ((t (:inherit tab-bar :background "#3a3a3a" :foreground "#ffffff" :weight bold :box nil))))
 '(tab-bar-tab-inactive ((t (:inherit tab-bar :background "#1c1c1c" :foreground "#9e9e9e" :box nil)))))

(load "~/.emacs.d/init.el")
