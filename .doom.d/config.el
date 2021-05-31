;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Sebastian Erives"
      user-mail-address "serivesmejia@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:

(setq doom-font "Fira Mono 13"
      doom-variable-pitch-font "Overpass 13")

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-flatwhite)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

(setq doom-scratch-initial-major-mode "org-mode")

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq undo-limit 60000000
      evil-want-fine-undo t
      auto-save-default t)

(use-package treemacs
  :config
  (setq treemacs-collapse-dirs 4
        treemacs-indentation 1
        treemacs-width 32))

(defun synchronize-theme ()
    (setq hour 
        (string-to-number 
            (substring (current-time-string) 11 13)))
    (if (member hour (number-sequence 8 19))
        (setq now 'doom-flatwhite)
        (setq now 'doom-vibrant)) 
    (if (equal now doom-theme)
        nil
        (setq doom-theme now)
        (eval now) ) ) ;; end of (defun ...

(run-with-timer 0 3600 'synchronize-theme)

(setq centaur-tabs-set-icons t)

(defvar fancy-splash-image-template
  (expand-file-name "misc/splash-images/emacs-e-template.svg" doom-private-dir)
  "Default template svg used for the splash image, with substitutions from ")

(defvar fancy-splash-sizes
  `((:height 300 :min-height 50 :padding (0 . 2))
    (:height 250 :min-height 42 :padding (2 . 4))
    (:height 200 :min-height 35 :padding (3 . 3))
    (:height 150 :min-height 28 :padding (3 . 3))
    (:height 100 :min-height 20 :padding (2 . 2))
    (:height 75  :min-height 15 :padding (2 . 1))
    (:height 50  :min-height 10 :padding (1 . 0))
    (:height 1   :min-height 0  :padding (0 . 0)))
  "list of plists with the following properties
  :height the height of the image
  :min-height minimum `frame-height' for image
  :padding `+doom-dashboard-banner-padding' (top . bottom) to apply
  :template non-default template file
  :file file to use instead of template")

(defvar fancy-splash-template-colours
  '(("$colour1" . keywords) ("$colour2" . type) ("$colour3" . base5) ("$colour4" . base8))
  "list of colour-replacement alists of the form (\"$placeholder\" . 'theme-colour) which applied the template")

(unless (file-exists-p (expand-file-name "theme-splashes" doom-cache-dir))
  (make-directory (expand-file-name "theme-splashes" doom-cache-dir) t))

(defun fancy-splash-filename (theme-name height)
  (expand-file-name (concat (file-name-as-directory "theme-splashes")
                            theme-name
                            "-" (number-to-string height) ".svg")
                    doom-cache-dir))

(defun fancy-splash-clear-cache ()
  "Delete all cached fancy splash images"
  (interactive)
  (delete-directory (expand-file-name "theme-splashes" doom-cache-dir) t)
  (message "Cache cleared!"))

(defun fancy-splash-generate-image (template height)
  "Read TEMPLATE and create an image if HEIGHT with colour substitutions as
   described by `fancy-splash-template-colours' for the current theme"
  (with-temp-buffer
    (insert-file-contents template)
    (re-search-forward "$height" nil t)
    (replace-match (number-to-string height) nil nil)
    (dolist (substitution fancy-splash-template-colours)
      (goto-char (point-min))
      (while (re-search-forward (car substitution) nil t)
        (replace-match (doom-color (cdr substitution)) nil nil)))
    (write-region nil nil
                  (fancy-splash-filename (symbol-name doom-theme) height) nil nil)))

(defun fancy-splash-generate-images ()
  "Perform `fancy-splash-generate-image' in bulk"
  (dolist (size fancy-splash-sizes)
    (unless (plist-get size :file)
      (fancy-splash-generate-image (or (plist-get size :template)
                                       fancy-splash-image-template)
                                   (plist-get size :height)))))

(defun ensure-theme-splash-images-exist (&optional height)
  (unless (file-exists-p (fancy-splash-filename
                          (symbol-name doom-theme)
                          (or height
                              (plist-get (car fancy-splash-sizes) :height))))
    (fancy-splash-generate-images)))

(defun get-appropriate-splash ()
  (let ((height (frame-height)))
    (cl-some (lambda (size) (when (>= height (plist-get size :min-height)) size))
             fancy-splash-sizes)))

(setq fancy-splash-last-size nil)
(setq fancy-splash-last-theme nil)
(defun set-appropriate-splash (&rest _)
  (let ((appropriate-image (get-appropriate-splash)))
    (unless (and (equal appropriate-image fancy-splash-last-size)
                 (equal doom-theme fancy-splash-last-theme)))
    (unless (plist-get appropriate-image :file)
      (ensure-theme-splash-images-exist (plist-get appropriate-image :height)))
    (setq fancy-splash-image
          (or (plist-get appropriate-image :file)
              (fancy-splash-filename (symbol-name doom-theme) (plist-get appropriate-image :height))))
    (setq +doom-dashboard-banner-padding (plist-get appropriate-image :padding))
    (setq fancy-splash-last-size appropriate-image)
    (setq fancy-splash-last-theme doom-theme)
    (+doom-dashboard-reload)))

(add-hook 'window-size-change-functions #'set-appropriate-splash)
(add-hook 'doom-load-theme-hook #'set-appropriate-splash)

(defvar phrase-api-url
  (nth (random 3)
       '(("https://corporatebs-generator.sameerkumar.website/" :phrase)
         ("https://useless-facts.sameerkumar.website/api" :data)
         ("https://dev-excuses-api.herokuapp.com/" :text))))

(defmacro phrase-generate-callback (token &optional format-fn ignore-read-only callback buffer-name)
  `(lambda (status)
     (unless (plist-get status :error)
       (goto-char url-http-end-of-headers)
       (let ((phrase (plist-get (json-parse-buffer :object-type 'plist) (cadr phrase-api-url)))
             (inhibit-read-only ,(when (eval ignore-read-only) t)))
         (setq phrase-last (cons phrase (float-time)))
         (with-current-buffer ,(or (eval buffer-name) (buffer-name (current-buffer)))
           (save-excursion
             (goto-char (point-min))
             (when (search-forward ,token nil t)
               (with-silent-modifications
                 (replace-match "")
                 (insert ,(if format-fn format-fn 'phrase)))))
           ,callback)))))

(defvar phrase-last nil)
(defvar phrase-timeout 5)

(defmacro phrase-insert-async (&optional format-fn token ignore-read-only callback buffer-name)
  `(let ((inhibit-message t))
     (if (and phrase-last
              (> phrase-timeout (- (float-time) (cdr phrase-last))))
         (let ((phrase (car phrase-last)))
           ,(if format-fn format-fn 'phrase))
       (url-retrieve (car phrase-api-url)
                     (phrase-generate-callback ,(or token "\ufeff") ,format-fn ,ignore-read-only ,callback ,buffer-name))
       ;; For reference, \ufeff = Zero-width no-break space / BOM
       ,(or token "\ufeff"))))

(defun doom-dashboard-phrase ()
  (phrase-insert-async
   (progn
     (setq-local phrase-position (point))
     (mapconcat
      (lambda (line)
        (+doom-dashboard--center
         +doom-dashboard--width
         (with-temp-buffer
           (insert-text-button
            line
            'action
            (lambda (_)
              (setq phrase-last nil)
              (+doom-dashboard-reload t))
            'face 'doom-dashboard-menu-title
            'mouse-face 'doom-dashboard-menu-title
            'help-echo "Random phrase"
            'follow-link t)
           (buffer-string))))
      (split-string
       (with-temp-buffer
         (insert phrase)
         (setq fill-column (min 70 (/ (* 2 (window-width)) 3)))
         (fill-region (point-min) (point-max))
         (buffer-string))
       "\n")
      "\n"))
   nil t
   (progn
     (goto-char phrase-position)
     (forward-whitespace 1))
   +doom-dashboard-name))

(defadvice! doom-dashboard-widget-loaded-with-phrase ()
  :override #'doom-dashboard-widget-loaded
  (setq line-spacing 0.2)
  (insert
   "\n\n"
   (propertize
    (+doom-dashboard--center
     +doom-dashboard--width
     (doom-display-benchmark-h 'return))
    'face 'doom-dashboard-loaded)
   "\n"
   (doom-dashboard-phrase)
   "\n"))

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-mode-hook (hide-mode-line-mode 1) (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))
