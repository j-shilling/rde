;; (menu-bar-mode -1)

					; (setq font-use-system-font t)

(defun run-command-in-eshell (cmd)
  (eshell)
  (eshell-kill-input)
  (end-of-buffer)
  (insert cmd)
  (eshell-send-input))

(defun rde/rebuild ()
  (interactive)
  (run-command-in-eshell "nixos-rebuild build --flake /home/abcdw/work/rde"))

(defun rde/switch ()
  (interactive)
  (run-command-in-eshell "sudo nixos-rebuild switch --flake /home/abcdw/work/rde"))

(defun rde/switch-and-restart-emacs ()
  (interactive)
  (run-command-in-eshell "sudo nixos-rebuild switch --flake /home/abcdw/work/rde && restart-emacs"))



;; (call-process "sudo nixos-rebuild switch --flake /home/abcdw/work/rde" nil (get-buffer-create "test-buf"))
;; (call-process "sudo nixos-rebuild switch --flake /home/abcdw/work/rde" nil (get-buffer-create "test-buf"))
;; (if (eshell-exit-success-p)
;;     (restart-emacs))

;; (set-face-attribute 'default (selected-frame) :height 100
;; 		    :weight 'semi-light)

;;; Configs to reference
;;; https://github.com/bbatsov/emacs.d/blob/master/init.el
;;; https://github.com/balsoft/nixos-config/blob/master/modules/applications/emacs/default.nix

;; It works


(defun rde/display-load-time ()
  (interactive)
  (message "rde emacs loaded in %s, C-h C-a for welcome screen." (emacs-init-time)))
;; (add-hook 'after-init-hook 'rde/display-load-time)

(setq inhibit-splash-screen t)
;; (setq inhibit-startup-echo-area-message "abcdw")
(defun display-startup-echo-area-message ()
  (rde/display-load-time))

;; (set-face-attribute 'default (selected-frame) :family "Iosevka" :weight 'semi-light)
;;; https://www.freedesktop.org/software/fontconfig/fontconfig-user.html
(setq my-font (font-spec :family "Iosevka" :weight 'semi-light :size 28))
(set-face-attribute 'default nil :font my-font)


;; ;; It doesn't


(global-set-key (kbd "C-c r r") 'rde/switch-and-restart-emacs)
(global-set-key (kbd "C-c f e") '(lambda () (interactive) (find-file "~/work/rde/src/modules/emacs/init.el")))
(global-set-key (kbd "C-c f h") '(lambda () (interactive) (find-file "~/work/rde/src/home.nix")))
(global-set-key (kbd "C-c f i") '(lambda () (interactive) (find-file "~/work/rde/src/hosts/ixy/configuration.nix")))
(global-set-key (kbd "s-o") 'other-window)
(global-set-key (kbd "s-n") 'switch-to-next-buffer)
(global-set-key (kbd "s-p") 'switch-to-prev-buffer)


(eval-when-compile
  (require 'use-package))

(use-package nix-mode
  :defer t
  :mode "\\.nix\\'"
  :bind (:map nix-mode-map
	      (("C-c l p" . nix-format-buffer))))

(use-package magit
  :defer t
  :bind (("C-x g" . magit-status)))

(use-package modus-operandi-theme
  ;;; Read more here: https://protesilaos.com/modus-themes/
  :config
  (load-theme 'modus-operandi t))

(use-package dired
  :config
  (setq dired-listing-switches
        "-aFhl --group-directories-first --time-style=long-iso"))
  
(use-package org :defer t)

(use-package org-roam
  :hook
  (after-init . org-roam-mode)
  :config
  (org-roam-mode 1)
  :custom
  (org-roam-directory "~/work/org-files/notes")
  :bind (
	 :map org-roam-mode-map
         (("C-c n l" . org-roam)
          ("C-c n f" . org-roam-find-file)
          ("C-c n g" . org-roam-graph-show))
         :map org-mode-map
         (("C-c n i" . org-roam-insert))
         (("C-c n I" . org-roam-insert-immediate))))

(use-package company-org-roam
  :after org-roam company ; saves 0.3s startup time
  :config
  (push 'company-org-roam company-backends))

(use-package company
  :hook
  (after-init . global-company-mode))

(use-package ivy
  :config
  (ivy-mode 1)
  (global-set-key (kbd "C-c C-r") 'ivy-resume))

(use-package olivetti
  :config
  (setq olivetti-minimum-body-width 80))

(use-package restart-emacs)
;; TODO: Visualise regexp substitution
