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
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")))
			 ;; ("marmalade" . "https://marmalade-repo.org/packages/")

;; Codes below are scraped from
;; batsov.com/articles/2012/02/19/package-management-in-emacs-the-good-the-bad-and-the-ugly/

;; List of packages to install
(defvar my-base-packages '(anaconda-mode cmake-mode
					 conda
					 company-c-headers
					 company-anaconda
					 company-auctex company-math
					 company-lua company-web
					 dumb-jump evil-tutor evil
					 evil-collection evil-escape
					 evil-multiedit
					 exec-path-from-shell
					 flycheck-pyflakes
					 helm helm-company
					 helm-projectile
					 helm-flycheck htmlize
					 lua-mode magit matlab-mode
					 markdown-mode monokai-theme
					 nlinum
					 projectile-codesearch
					 py-autopep8 py-isort
					 python-environment pyvenv
					 python-black
					 py-yapf rainbow-mode undo-tree
					 yaml-mode yasnippet xclip)
  "A list of packages to ensure are installed at launch.")

;; Set my packages as selected
(setq package-selected-packages my-base-packages)

;; Check if my base packages are installed.
(require 'cl)
(defun my-base-packages-installed-p ()
  (cl-loop for p in my-base-packages
        when (not (package-installed-p p)) do (cl-return nil)
        finally (cl-return t)))

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

;; location for my custom packages
(add-to-list 'load-path "~/.emacs.d/non-elpa/")

;; Printing for mac
(when (eq (string-match "linux" (prin1-to-string system-type)) nil)

  (load "mac-print-mode.el")

  (when (require 'mac-print-mode nil t)
    (mac-print-mode 1)
    (global-set-key (kbd "M-p") 'mac-print-buffer))
)

;; Set fond size for Mac
(when (eq (string-match "linux" (prin1-to-string system-type)) nil)
  (set-face-attribute 'default nil :height 130))

;; Tramp bug fix that started to happen for no reason
;; One guess is due to the wrong wifi configuration 
;; https://emacs.stackexchange.com/questions/18438/emacs-suspend-at-startup-ssh-connection-issue
(setq tramp-ssh-controlmaster-options
      "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=no")
(require 'tramp)


;; gnu pg fix
(setq epa-pinentry-mode 'loopback)
;; (setq epg-gpg-program "/usr/local/bin/gpg")

;; ============================================================================
;; Basic Emacs Settings
;; ============================================================================

;; Undo tree
(require 'undo-tree)
(global-undo-tree-mode)

;; Comment line
(global-set-key (kbd "C-x ;") 'comment-line)

;; Evil mode undo setting
(require 'evil)
(evil-mode 1)
(setq evil-want-fine-undo t)
;; (setq evil-undo-system "undo-tree")
(evil-set-undo-system 'undo-tree)

;; Set m as an escape key
(define-key evil-normal-state-map "m" nil)

;; Evil mode escape key
(require 'evil-escape)
(setq-default evil-escape-key-sequence "jk")
(global-set-key (kbd "C-c C-k") 'evil-escape-mode)

;; Evil multiedit
(require 'evil-multiedit)
(evil-multiedit-default-keybinds)

;; ;; -- move through softwrapped lines naturally
;; ;;    https://stackoverflow.com/a/20899418/269247
;; (define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
;; (define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
;; (define-key evil-motion-state-map (kbd "<remap> <evil-first-non-blank>") 'evil-first-non-blank-of-visual-line)
;; (define-key evil-motion-state-map (kbd "<remap> <evil-digit-argument-or-evil-beginning-of-line>") 'evil-beginning-of-visual-line)
;; (define-key evil-motion-state-map (kbd "<remap> <evil-end-of-line>") 'evil-end-of-visual-line)
;; ;; ;; make horizontal movement cross lines
;; ;; (setq-default evil-cross-lines t)
;; ;; ;; Make display suitable for visual line mode
;; ;; (setq-default global-visual-line-mode t)
;; ;; ;; Show linebreaks
;; ;; (setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))

;; ;; Hangul when toggled
(setq default-input-method "korean-hangul")
;; Set toggle key
(global-set-key (kbd "s-SPC") 'toggle-input-method)

;; Dumb jump
(dumb-jump-mode)

;; No longer needed as of emacs 25 and now I am finally on it!
(defun comment-or-uncomment-region-or-line ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)
        (next-logical-line)))

(if (< emacs-major-version 25)
    (progn
      (message "emacs version < 25, comment line behaviour is
      different, using workaround")
      (global-set-key  (kbd "C-x C-;") 'comment-or-uncomment-region-or-line))
  (progn
    (message "emacs version >= 25, comment line behaviour is fine.")))

;; Text mode and Auto Fill mode
;; The next two lines put Emacs into Text mode
;; and Auto Fill mode, and are for writers who
;; want to start writing prose rather than code.
(setq-default major-mode 'text-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(setq-default fill-column 79)

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

;; Make initial window size custom
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 90))

;; Enable desktop save on exit
(require 'desktop)
(desktop-save-mode 1)

;; Restore frames as well
(setq desktop-restore-frames nil)
(setq desktop-restore-in-current-display nil)
(setq desktop-restore-forces-onscreen nil)

;; Other desktop settings
(setq desktop-dirname             "~/.emacs.d/desktop/"
      desktop-path                (list desktop-dirname)
      desktop-files-not-to-save   "^$" ;reload tramp paths
      desktop-load-locked-desktop t)   ;load locked ones

;; Desktop file depending on HOSTNAME
(if (or (eq (string-match "iccluster" (system-name)) 0) (eq (string-match "iccvlab" (system-name)) 0))
    ;; desktop for the servers
    (setq desktop-base-file-name (concat "emacs." (system-name) ".desktop")
	  desktop-base-lock-name (concat "emacs." (system-name) ".desktop.lock"))
  ;; deskstop for my system (local)
  (setq desktop-base-file-name "emacs.local.desktop"
	desktop-base-lock-name "emacs.local.desktop.lock"))

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
  "Prevent 'yes-or-no-p' from activating a dialog."
  (let ((use-dialog-box nil))
    ad-do-it))
(defadvice y-or-n-p (around prevent-dialog-yorn activate)
  "Prevent 'y-or-n-p' from activating a dialog."
  (let ((use-dialog-box nil))
    ad-do-it))

;; do not close newly open buffers when exiting emacsclient
(setq server-kill-new-buffers nil)

;; do not ask when killing buffers: just do it
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(defun client-save-kill-emacs()
  "This function just kills everything adnd quits."
  (progn
    (tramp-cleanup-all-buffers)	; close all tramp connections
    (tramp-cleanup-all-connections)	; close all tramp connections
    (save-some-buffers 'no-confirm)	; save all open buffers
    (desktop-save-in-desktop-dir)	; save desktop
    (dolist (client server-clients)	; close all clients
      (server-delete-client client))
    (setq kill-emacs-hook 'nil) 	; remove kill hooks
    (kill-emacs)))			; kill emacs

;; ============================================================================
;; Emacs Windows Settings
;; ============================================================================

;; Disable menu bar and tool bar
(tool-bar-mode -1)
(menu-bar-mode -1)

;; Scroll bars are simply annoying... don't really help
(scroll-bar-mode -1)

;; Window resizing
(global-set-key (kbd "C-M-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-M-<down>") 'shrink-window)
(global-set-key (kbd "C-M-<up>") 'enlarge-window)

;; Enable winner mode
(winner-mode 1)

;; use Shift + arrow to move arround split pane
(windmove-default-keybindings)

;; Commenting Shortcuts
(global-set-key (kbd "\C-c;")      'comment-region)
(global-set-key (kbd "\C-c:")      'uncomment-region)
(global-set-key (kbd "C-s-<left>")      'ns-prev-frame)
(global-set-key (kbd "C-s-<right>")      'ns-next-frame)

;; ============================================================================
;; Buffer Cleanup
;; ============================================================================

;; midnight mode
(require 'midnight)

;;kill buffers if they were last disabled more than this seconds ago
(setq clean-buffer-list-delay-general 5) ; will clean after 5 days
(setq clean-buffer-list-delay-special (* 5 (* 24 3600))) ;basically5 days
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
;; Org-mode
;; ============================================================================

(require 'org)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(setq org-agenda-files '("~/Org"))
(setq org-enforce-todo-dependencies t)
(setq org-agenda-dim-blocked-tasks 'invisible)
(setq org-agenda-todo-ignore-scheduled 'future)
(setq org-agenda-tags-todo-honor-ignore-options t)

;; Priorities
(setq org-highest-priority ?A)
(setq org-lowest-priority ?E)
(setq org-default-priority ?D)

;; Logging
(setq org-log-done 'time)

;; Links
(setq org-return-follows-link t)

;; ============================================================================
;; HELM
;; ============================================================================

;; (require 'helm-config)
(require 'helm)
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-f") 'helm-find-files)

(setq helm-split-window-in-side-p t) ;; set helm to always popup below

;; support for projectile
(require 'projectile)
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

;; Show line-number in the mode line
(line-number-mode 1)
;; Show column-number in the mode line
(column-number-mode 1)

;; use nlinum instead as linum is slugish

;; Enabled only with emacs 25+
(if (< emacs-major-version 25)
    (progn
      (message "emacs version < 25, will not use nlinum globally,
      using workaround")
      ;; nlinum workaround
      (defun initialize-nlinum (&optional frame)
	(require 'nlinum)
	(add-hook 'prog-mode-hook 'nlinum-mode))
      (when (daemonp)
	(add-hook 'window-setup-hook 'initialize-nlinum)
	(defadvice make-frame (around toggle-nlinum-mode compile activate)
	  (nlinum-mode -1) ad-do-it (nlinum-mode 1))))
  (progn
    (message "emacs version >= 25, will use nlinum globally")
    (require 'nlinum)
    (global-nlinum-mode 1)
    ;; specify line number format
    (unless window-system
      (setq nlinum-format "%d "))))

;; ============================================================================
;; Auto Headers
;; ============================================================================
(require 'header2)
(autoload 'auto-update-file-header "header2")
(add-hook 'write-file-hooks 'auto-update-file-header)

;; Change copyright notice to my lab
(setq header-copyright-notice "Copyright (C), Visual Computing Group @ University of Victoria.\n")

;; Header stylings
(setq make-header-hook '(
			 ;;header-mode-line
			 header-title
			 header-blank
			 header-file-name
			 header-description
			 ;; header-status
			 header-author
			 header-maintainer
			 header-creation-date
			 ;; header-rcs-id
			 header-version
			 ;; header-pkg-requires
			 ;; header-sccs
			 ;; header-modification-date
			 ;; header-modification-author
			 ;; header-update-count
			 ;; header-url
			 ;; header-doc-url
			 ;; header-keywords
			 ;; header-compatibility
			 ;; header-blank
			 ;; header-lib-requires
			 header-end-line
			 header-commentary
			 header-blank
			 header-blank
			 header-blank
			 header-end-line
			 header-history
			 header-blank
			 header-blank
			 ;; header-rcs-log
			 header-end-line
			 header-copyright
			 ;; header-free-software
			 header-code
			 header-eof
			 ))

;; ============================================================================
;; Company
;; ============================================================================
(require 'company)
;; Basic usage
;; (add-to-list 'company-backends 'company-jedi)
;; ;; Advanced usage
;; (add-to-list 'company-backends '(company-jedi company-files))
(eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-:") 'helm-company)))

;; anaconda backendB
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-anaconda))

(add-hook 'after-init-hook 'global-company-mode)

;; AUCtex plugin for Company
(require 'company-auctex)
(company-auctex-init)

;; Make Company case sensitive
(setq company-dabbrev-downcase nil)

;; ============================================================================
;; Markdown
;; ============================================================================
(require 'markdown-mode)
;; (add-hook 'markdown-mode-hook (lambda () (setq-local default-justification (quote full))))

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
(add-hook 'LaTeX-mode-hook 'turn-off-auto-fill)
(setq reftex-plug-into-AUCTeX t)

;; ;; set default justification as full for latex mode
;; (add-hook 'LaTeX-mode-hook (lambda () (setq-local default-justification (quote full))))

(add-hook 'LaTex-mode-hook '(lambda ()
                             (auto-fill-mode 1)))
(setq TeX-PDF-mode t)

;; Use Skim as viewer, enable source <-> PDF sync
;; ;; make latexmk available via C-c C-c
;; (add-hook 'LaTeX-mode-hook (lambda ()
;;   (push
;;     '("latexmk" "latexmk -pdf %s" TeX-run-TeX nil t
;;       :help "Run latexmk on file")
;;     TeX-command-list)))
;; (add-hook 'TeX-mode-hook '(lambda () (setq TeX-command-default "latexmk")))

;; For Mac
;; use Skim as default pdf viewer
;; Skim's displayline is used for forward search (from .tex to .pdf)
;; option -b highlights the current line; option -g opens Skim in the background
(when (eq (string-match "linux" (prin1-to-string system-type)) nil)
  (setq TeX-source-correlate-method (quote synctex))
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)
  (setq TeX-view-program-list
	'(("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))
  (setq TeX-view-program-selection '((output-pdf "Skim")))
  )
;; For Linux
(unless (eq (string-match "linux" (prin1-to-string system-type)) nil)
  (setq TeX-source-correlate-method (quote synctex))
  (setq TeX-source-correlate-mode t)
  (setq TeX-source-correlate-start-server t)
  ;; (setq TeX-view-program-list '(("Evince" "evince --page-index=%(outpage) %o")))
  ;; (setq TeX-view-program-selection '((output-pdf "Zathura")))
  ;; (setq TeX-view-program-selection '((output-pdf "Evince")))
  (setq TeX-view-program-selection '((output-pdf "Okular")))
)

;; ============================================================================
;; ispell
;; ============================================================================
(require 'ispell)
(when (eq (string-match "linux" (prin1-to-string system-type)) nil)
  (setq ispell-program-name "aspell"))
;; For Linux
(unless (eq (string-match "linux" (prin1-to-string system-type)) nil)
  (setq TeX-source-correlate-method (quote synctex))
  (setq ispell-program-name "ispell"))

;; ============================================================================
;; Magit
;; ============================================================================
(require 'magit)

;; Get ssh-agent if it's there!
(require 'exec-path-from-shell)
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")

;; (setq magit-display-buffer-function (quote display-buffer)) ;buffer display settings
;; (setq magit-status-buffer-switch-function 'switch-to-buffer) ;magit settings
(setq magit-push-always-verify nil)	     ;set no prompt for push verification

;; for magit status
(global-set-key (kbd "C-x g") 'magit-status)

;; for displaying popups
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

;; kill buffer correctnessq
(add-hook 'server-done-hook 'kill-buffer)

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

;; Now checks the home environment variable instead
;; use gindent in mac
(if (eq (string-match "linux" (prin1-to-string system-type)) nil)
    (setq myindent-cmd "gindent")
  (setq myindent-cmd "indent"))


;; Auto-indent using external program
(defun c-reformat-buffer()
  (interactive)
  (save-buffer)
  (setq sh-indent-command (concat
			   myindent-cmd
			   " -nbad -bap -nbc -bbo -hnl -br -brs -c33 -cd33 -ncdb -ce -ci4 -cli0 -d0 -di1 -nfc1 -i8 -ip0 -l200 -lp -npcs -nprs -npsl -sai -saf -saw -ncs -nsc -sob -nfca -cp33 -ss -ts8 -il1"
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

;; Change interpreter depending on ipython version
(if (<= 5 (string-to-number (shell-command-to-string
			     "python -c 'import IPython; print(IPython.__version__[:1])'")))
    ;; If 5 and above
    (setq python-shell-interpreter "ipython"
	  python-shell-interpreter-args "--simple-prompt -i")
  ;; If old ipython
  (setq python-shell-interpreter "ipython"
	python-shell-interpreter-args "-i"))

;; (setq python-shell-interpreter "python")

(define-coding-system-alias 'UTF-8 'utf-8)

;; For python-environment
(require 'python-environment)
(setq python-environment-default-root-name "default")
(setq python-environment-directory "~/Envs")
;; (setq python-environment-virtualenv '("virtualenv" "--quiet"))

;; For pyvenv
(require 'pyvenv)

;; Anaconda mode
(add-hook 'python-mode-hook 'anaconda-mode)
;; (add-hook 'python-mode-hook 'anaconda-eldoc-mode)

;; (add-hook 'python-mode-hook 'jedi:setup) ; enable the jedi!
;; ;; (add-hook 'python-mode-hook
;; ;;           (lambda ()
;; ;;             (local-unset-key (kbd "<backtab>"))))
;; (add-hook 'python-mode-hook
;;           (lambda ()
;;             (local-set-key (kbd "<backtab>")
;;                            'company-jedi)))

;; Bindings for evil mode
;; The following bindings are similar to spacemacs settings
(define-key evil-normal-state-map "mhh" 'anaconda-mode-show-doc)
(define-key evil-normal-state-map "mgg" 'anaconda-mode-find-definitions)
(define-key evil-normal-state-map "mga" 'anaconda-mode-find-assignments)
(define-key evil-normal-state-map "mgr" 'anaconda-mode-find-references)
;; (define-key evil-normal-state-map "mGG" 'evil-jump-backward)
(define-key evil-normal-state-map "mGG" 'xref-pop-marker-stack)

(require 'flycheck)
(add-hook 'python-mode-hook 'flycheck-mode)
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

(require 'python-black)
;; (add-hook 'python-mode-hook 'python-black-on-save-mode) ; run yapf on save
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c b")
                           'python-black-buffer)))

(require 'py-isort)
;; (add-hook 'before-save-hook 'py-isort-before-save) 
(setq python-black-extra-args '("-l 79"))
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c i")
                           'py-isort-buffer)))

(require 'conda)
(setq conda-anaconda-home "/Users/kmyi/miniconda3")
(setq conda-env-home-directory "/Users/kmyi/miniconda3")

;; ============================================================================
;; Themes
;; ============================================================================

;; (setq frame-background-mode 'dark)
;; (load-theme 'solarized t)

(load "my-monokai-theme.el")
(load-theme 'my-monokai t)

;; (load-theme 'sanityinc-tomorrow-eighties t)

;; Cursor color
(set-cursor-color "DeepSkyBlue")

;; for the daemon?
(require 'frame)
(defun set-cursor-hook (frame)
(modify-frame-parameters
  frame (list (cons 'cursor-color "DeepSkyBlue"))))

(add-hook 'after-make-frame-functions 'set-cursor-hook)

;; Set transparancy
;;(set-frame-parameter (selected-frame) 'alpha '(<active> . <inactive>))
;;(set-frame-parameter (selected-frame) 'alpha <both>)
;; (set-frame-parameter (selected-frame) 'alpha '(85 . 50))
;; (add-to-list 'default-frame-alist '(alpha . (85 . 50)))
(set-frame-parameter (selected-frame) 'alpha '(100))
(add-to-list 'default-frame-alist '(alpha . (100)))

;; ============================================================================
;; CMAKE
;; ============================================================================
;; Add cmake listfile names to the mode list.
(setq auto-mode-alist
	  (append
	   '(("CMakeLists\\.txt\\'" . cmake-mode))
	   '(("\\.cmake\\'" . cmake-mode))
	   auto-mode-alist))

;; ;; ============================================================================
;; ;; OSX
;; ;; ============================================================================
;; ;; From http://allkindsofrandomstuff.blogspot.com/2009/09/sharing-mac-clipboard-with-emacs.html
;; (defun copy-from-osx ()
;;   (shell-command-to-string "pbpaste"))

;; (defun paste-to-osx (text &optional push)
;;   (let ((process-connection-type nil)) 
;;     (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
;;       (process-send-string proc text)
;;       (process-send-eof proc))))

;; Use X Clip to copy to system clipboard
(xclip-mode 1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(undo-tree python-black anaconda-mode cmake-mode color-theme-solarized company-c-headers company-anaconda company-auctex company-math company-lua company-web dumb-jump evil-tutor evil evil-magit evil-escape evil-multiedit exec-path-from-shell flycheck-pyflakes helm helm-company helm-projectile helm-flycheck htmlize lua-mode magit matlab-mode markdown-mode monokai-theme nlinum projectile-codesearch py-autopep8 py-isort python-environment pyvenv py-yapf rainbow-mode yaml-mode yasnippet xclip))
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
