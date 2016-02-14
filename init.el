;;; init.el --- Init file for my Emacs
;;
;; 
;; 
;;; Commentary:
;; Personal Emacs setup, Did not clean up anything.....
;;
;;
;;; Code:

;; ============================================================================
;; PACKAGES
;; ============================================================================
(require 'package)
(package-initialize)

;; list of repositories
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			 ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")))

;; Codes below are scraped from
;; batsov.com/articles/2012/02/19/package-management-in-emacs-the-good-the-bad-and-the-ugly/

;; List of packages to install
(defvar my-base-packages '(cmake-mode company-c-headers
				      company-jedi company-auctex
				      company-math company-web
				      flycheck-clangcheck
				      flycheck-pyflakes header2
				      helm helm-company
				      helm-projectile
				      helm-flycheck magit
				      matlab-mode markdown-mode
				      monokai-theme nlinum
				      projectile-codesearch
				      py-autopep8 py-isort
				      py-yapf rainbow-mode sphinx-doc
				      yaml-mode yasnippet xclip)
  "A list of packages to ensure are installed at launch.")

;; Set my packages as selected
(setq package-selected-packages my-base-packages)

;; Check if my base packages are installed.
(require 'cl)
(defun my-base-packages-installed-p ()
  (cl-loop for p in my-base-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

(unless (my-base-packages-installed-p)
  ;; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ;; install the missing packages
  (dolist (p my-base-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(provide 'my-base-packages)

;; ============================================================================
;; Basic Emacs Settings
;; ============================================================================

;; Text mode and Auto Fill mode
;; The next two lines put Emacs into Text mode
;; and Auto Fill mode, and are for writers who
;; want to start writing prose rather than code.
(setq-default major-mode 'text-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Enable mouse support
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] '(lambda ()
                              (interactive)
                              (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda ()
                              (interactive)
                              (scroll-up 1)))
  (defun track-mouse (e))
  (setq mouse-sel-mode t)
)

;; Enable desktop save on exit
(desktop-save-mode 1)

;; To fix dektop prob
(setq desktop-restore-frames t)
(setq desktop-restore-in-current-display t)
(setq desktop-restore-forces-onscreen nil)

;; Custom function setup to load desktop
;; (setq desktop-restore-frames nil)
;; (setq desktop-dirname             "~/.emacs.d/desktop/"
;;       desktop-base-file-name      "emacs.desktop"
;;       desktop-base-lock-name      "lock"
;;       desktop-path                (list desktop-dirname)
;;       desktop-save                t
;;       desktop-files-not-to-save   "^$" ;reload tramp paths
;;       desktop-load-locked-desktop nil)

;; (defun my-desktop ()
;;   "Load the desktop and enable autosaving"
;;   (interactive)
;;   (let ((desktop-load-locked-desktop "ask"))
;;     (desktop-read)
;;     (desktop-save-mode 1)))


;; Reverting all buffersUnprintable entity
(defun revert-all-buffers ()
    "Refreshes all open buffers from their respective files."
    (interactive)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (and (buffer-file-name)
		   (file-exists-p (buffer-file-name)) (not (buffer-modified-p)))
          (revert-buffer t t t) )))
    (message "Refreshed open files.") )


;; This script should get rid of annoying backup files by emacs
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.saves"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)       ; use versioned backups


;; Disable popup that keeps emacs from strating
(defadvice yes-or-no-p (around prevent-dialog activate)
  "Prevent yes-or-no-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))
(defadvice y-or-n-p (around prevent-dialog-yorn activate)
  "Prevent y-or-n-p from activating a dialog"
  (let ((use-dialog-box nil))
    ad-do-it))

;; ============================================================================
;; Emacs Windows Settings
;; ============================================================================

;; Disable menu bar and tool bar
(tool-bar-mode -1)
(unless window-system
  (menu-bar-mode -1))

;; Window resizing
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;; Enable winner mode
(winner-mode 1)

;; use shift+arrow to move arround split pane
(windmove-default-keybindings)

;; Commenting Shortcuts
(global-set-key (kbd "\C-c;")      'comment-region)
(global-set-key (kbd "\C-c:")      'uncomment-region)
(global-set-key (kbd "C-s-<left>")      'ns-prev-frame)
(global-set-key (kbd "C-s-<right>")      'ns-next-frame)

;; ============================================================================
;; Themes
;; ============================================================================

;; (load-theme 'solarized-dark t)

(load-theme 'monokai t)
;; (setq monokai-high-contrast-mode-line t)
(unless window-system
  (setq monokai-distinct-fringe-background t))
;; (load-theme 'sanityinc-tomorrow-eighties t)


;; ============================================================================
;; Buffer Cleanup
;; ============================================================================

;; midnight mode
(require 'midnight)

;;kill buffers if they were last disabled more than this seconds ago
(setq clean-buffer-list-delay-general 7) ; will clean after 7 days
(setq clean-buffer-list-delay-special (* 7 (* 24 3600))) ;basically 7 days
;; (setq clean-buffer-list-delay-special 2) ;basically 3 days

(defvar clean-buffer-list-timer nil
  "Stores 'clean-buffer-list timer' if there is one.
You can disable 'clean-buffer-list' by (cancel-timer
  clean-buffer-list-timer).")

;; run clean-buffer-list every 2 hours
(setq clean-buffer-list-timer (run-at-time t 7200 'clean-buffer-list))

;; kill everything, clean-buffer-list is very intelligent at not killing
;; unsaved buffer.
(setq clean-buffer-list-kill-regexps '("^.*$"))

;; keep these buffer untouched
;; prevent append multiple times
(defvar clean-buffer-list-kill-never-buffer-names-init
  clean-buffer-list-kill-never-buffer-names
  "Init value for clean-buffer-list-kill-never-buffer-names.")
(setq clean-buffer-list-kill-never-buffer-names
      (append
       '("*Messages*" "*scratch*")
       clean-buffer-list-kill-never-buffer-names-init))

;; prevent append multiple times
(defvar clean-buffer-list-kill-never-regexps-init
  clean-buffer-list-kill-never-regexps
  "Init value for clean-buffer-list-kill-never-regexps.")
;; append to *-init instead of itself
(setq clean-buffer-list-kill-never-regexps
      (append '(".*\.init.el.*" ".*helm.*")
	      clean-buffer-list-kill-never-regexps-init))


;; ============================================================================
;; HELM
;; ============================================================================

(require 'helm-config)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

(setq helm-split-window-in-side-p t) ;; set helm to always popup below

;; support for projectile
(projectile-global-mode)
;; (setq projectile-enable-caching nil)
(setq projectile-completion-system 'helm)
;; (helm-projectile-on)
(setq projectile-switch-project-action 'helm-projectile)
(global-set-key (kbd "C-c h") 'helm-projectile)

;; Gtags is not installed
;; ;; Enable helm-gtags-mode
;; (add-hook 'matlab-mode-hook 'helm-gtags-mode)
;; (add-hook 'c-mode-hook 'helm-gtags-mode)
;; (add-hook 'c++-mode-hook 'helm-gtags-mode)
;; (add-hook 'asm-mode-hook 'helm-gtags-mode)

;; ;; Set key bindings
;; (eval-after-load "helm-gtags"
;;   '(progn
;;      (define-key helm-gtags-mode-map (kbd "M-t") 'helm-gtags-find-tag)
;;      (define-key helm-gtags-mode-map (kbd "M-r") 'helm-gtags-find-rtag)
;;      (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-find-symbol)
;;      (define-key helm-gtags-mode-map (kbd "M-g M-p") 'helm-gtags-parse-file)
;;      (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
;;      (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
;;      (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)))

;; ============================================================================
;; Enable Line and Column Numbering
;; ============================================================================

;; use nlinum instead as linum is slugish
(require 'nlinum)
(global-nlinum-mode t)
;; Show line-number in the mode line
(line-number-mode 1)
;; Show column-number in the mode line
(column-number-mode 1)
;; specify line number format
(unless window-system
  (setq nlinum-format "%d "))

;; ============================================================================
;; Auto Headers
;; ============================================================================
(require 'header2)
(autoload 'auto-update-file-header "header2")
(add-hook 'write-file-hooks 'auto-update-file-header)

;; ============================================================================
;; Company
;; ============================================================================
(require 'company)
;; Basic usage
(add-to-list 'company-backends 'company-jedi)
;; ;; Advanced usage
;; (add-to-list 'company-backends '(company-jedi company-files))
(eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-:") 'helm-company)))

(add-hook 'after-init-hook 'global-company-mode)

;; AUCtex plugin for Company
(require 'company-auctex)
(company-auctex-init)

;; ============================================================================
;; Markdown
;; ============================================================================
(require 'markdown-mode)
(add-hook 'markdown-mode-hook (lambda () (setq-local default-justification (quote full))))

;; ============================================================================
;; AUC Tex Related
;; ============================================================================
(require 'tex-site)
(require 'tex)

(add-to-list
 'auto-mode-alist
 '("\\.tex$" . latex-mode))

;; Use double commenting for neatness
;; (add-hook 'LaTeX-mode-hook (lambda () (make-local-variable 'comment-add)))
(add-hook 'LaTeX-mode-hook (lambda () (setq-local comment-add 1)))

(TeX-global-PDF-mode t)
(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

;; set default justification as full for latex mode
(add-hook 'LaTeX-mode-hook (lambda () (setq-local default-justification (quote full))))

(add-hook 'LaTex-mode-hook '(lambda ()
                             (auto-fill-mode 1)))
(setq TeX-PDF-mode t)

;; Use Skim as viewer, enable source <-> PDF sync
;; make latexmk available via C-c C-c
;; Note: SyncTeX is setup via ~/.latexmkrc (see below)
(add-hook 'LaTeX-mode-hook (lambda ()
  (push
    '("latexmk" "latexmk -pdf %s" TeX-run-TeX nil t
      :help "Run latexmk on file")
    TeX-command-list)))
(add-hook 'TeX-mode-hook '(lambda () (setq TeX-command-default "latexmk")))
 
;; use Skim as default pdf viewer
;; Skim's displayline is used for forward search (from .tex to .pdf)
;; option -b highlights the current line; option -g opens Skim in the background  
(setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
(setq TeX-view-program-list
     '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))

;; ============================================================================
;; ispell
;; ============================================================================
(setq ispell-program-name "/usr/local/bin/ispell")

;; ============================================================================
;; Magit
;; ============================================================================

;; (setq magit-display-buffer-function (quote display-buffer)) ;buffer display settings
;; (setq magit-status-buffer-switch-function 'switch-to-buffer) ;magit settings
(setq magit-push-always-verify nil)	     ;set no prompt for push verification

;; for magit status
(global-set-key (kbd "C-x g") 'magit-status)

;; for displaying popups
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

;; ============================================================================
;; Fly check
;; ============================================================================
(require 'flycheck)
(add-hook 'after-init-hook 'global-flycheck-mode) 
(eval-after-load 'flycheck
  '(define-key flycheck-mode-map (kbd "C-x /") 'helm-flycheck))


;; ============================================================================
;; CPP and C
;; ============================================================================
(defun my-c-mode-common-hook ()
  (setq c-default-style "linux"
	c-basic-offset 4)
 ;; my customizations for all of c-mode, c++-mode, objc-mode, java-mode
 (c-set-offset 'substatement-open 0)
 ;; other customizations can go here

 (setq c++-tab-always-indent t)
 (setq c-basic-offset 4)                  ;; Default is 2
 (setq c-indent-level 4)                  ;; Default is 2

 (setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60))
 (setq tab-width 4)
 (setq indent-tabs-mode t)  ; use spaces only if nil
 (c-toggle-auto-newline nil)
 )

;; Hooks for C
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-common-hook 'auto-make-header)  ; Autoinsert header for C
(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-state 1)))

;; for long funciton names
(defconst my-c-lineup-maximum-indent 30)
(defun my-c-lineup-arglist (langelem)
  (let ((ret (c-lineup-arglist langelem)))
    (if (< (elt ret 0) my-c-lineup-maximum-indent)
	ret
      (save-excursion
	(goto-char (cdr langelem))
	(vector (+ (current-column) 8))))))
(defun my-indent-setup ()
    (setcdr (assoc 'arglist-cont-nonempty c-offsets-alist)
     '(c-lineup-gcc-asm-reg my-c-lineup-arglist)))

;; (defun my-indent-setup ()
;;       (c-set-offset 'arglist-intro '+))
(add-hook 'c-mode-common-hook 'my-indent-setup)

(add-hook 'c-mode-common-hook 'turn-on-auto-fill) ; Autofill for C


;; Auto-indent using external program
(defun c-reformat-buffer()
  (interactive)
  (save-buffer)
  (setq sh-indent-command (concat
			   "gindent -nbad -bap -nbc -bbo -hnl -br -brs -c33 -cd33 -ncdb -ce -ci4 -cli0 -d0 -di1 -nfc1 -i8 -ip0 -l200 -lp -npcs -nprs -npsl -sai -saf -saw -ncs -nsc -sob -nfca -cp33 -ss -ts8 -il1"
			   buffer-file-name
			   )
	)
  (mark-whole-buffer)
  (universal-argument)
  (shell-command-on-region
   (point-min)
   (point-max)
   sh-indent-command
   (buffer-name)
   )
  (save-buffer)
  )

;; Map autoindent using gnu indent to a hotkey
(add-hook 'c-mode-common-hook
	  (lambda ()
	    (define-key c-mode-base-map [f7] 'c-reformat-buffer)))

;; ============================================================================
;; MATLAB
;; ============================================================================

(add-hook 'matlab-mode-hook 'auto-make-header)	 ; Enable auto-make-header for matlab
;; (add-hook 'matlab-mode-hook 'auto-complete-mode) ; Enable auto-complete for matlab

;; (add-hook 'matlab-mode-hook (lambda ()
;; 			      (define-key matlab-mode-map "\C-c;" 'comment-region)
;; 			      (define-key matlab-mode-map "\C-c:" 'uncomment-region)
;; 			      (define-key matlab-mode-map "M-;" 'comment-dwim)))

;; ============================================================================
;; PYTHON
;; ============================================================================
(require 'python)
(add-hook 'python-mode-hook 'auto-make-header)	 ; Enable auto-make-header for python

(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i")

(add-hook 'python-mode-hook 'jedi:setup) ; enable the jedi!
;; (add-hook 'python-mode-hook
;;           (lambda ()
;;             (local-unset-key (kbd "<backtab>"))))
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "<backtab>")
                           'company-jedi)))

;; Sphinx documentation helper
(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

(require 'flycheck)
(add-hook 'python-mode-hook 'flycheck-mode) ; enable the jedi!
(setq flycheck-checker-error-threshold 2000) ; set flycheck limit to large value

(require 'py-autopep8)
;; (add-hook 'python-mode-hook 'py-autopep8-enable-on-save) ; run autopep8 on save
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c u")
                           'py-autopep8-buffer)))

(require 'py-yapf)
;; (add-hook 'python-mode-hook 'py-yapf-enable-on-save) ; run yapf on save
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c y")
                           'py-yapf-buffer)))

(require 'py-isort)
;; (add-hook 'before-save-hook 'py-isort-before-save) 
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c i")
                           'py-isort-buffer)))

;; ============================================================================
;; CMAKE
;; ============================================================================
;; Add cmake listfile names to the mode list.
(setq auto-mode-alist
	  (append
	   '(("CMakeLists\\.txt\\'" . cmake-mode))
	   '(("\\.cmake\\'" . cmake-mode))
	   auto-mode-alist))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mlint-programs (quote ("mlint")))
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
