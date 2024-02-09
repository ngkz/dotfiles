;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Kazutoshi Noguchi"
      user-mail-address "@email@")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

(setq doom-font (font-spec :family "Sarasa Term J Nerd Font" :size 9.0)
      doom-unicode-font nil)
; Nerd Font symbols: 
; Emoji: 😀😻

;; make `doom doctor` happy https://github.com/doomemacs/doomemacs/issues/7431
(setq nerd-icons-font-names '("sarasa-term-j-regular-nerd-font.ttf"))

;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
(setq doom-theme 'doom-monokai-classic)
(setq doom-monokai-classic-brighter-comments t)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; default comment syntax
(setq-default comment-start "# ")

;; Highlight trailing spaces, tab, hard space, and full-width space
(require 'whitespace)
(setq whitespace-style '(
                         face
                         trailing
                         tabs
                         spaces
                         newline
                         space-mark
                         tab-mark
                         newline-mark
                         ))
(setq whitespace-display-mappings '(
                                    (space-mark   ?\u3000 [?＿])      ;full-width space
                                    (space-mark   ?\u00A0 [?␣])       ;nbsp
                                    (tab-mark     ?\t     [?» ?\t])   ;tab
                                    (newline-mark ?\n     [?↲ ?\n])   ;newline
                                    ))
(setq whitespace-space-regexp "\\([\u3000]+\\)") ; highlight only full-width space
(global-whitespace-mode t)

;; Disable auto-fill-mode when in markdown mode
; (add-hook 'markdown-mode-hook (lambda () (auto-fill-mode -1)))

;; Enable soft line wrap
(global-visual-line-mode t)

;; Resize window quickly
;; http://d.hatena.ne.jp/khiker/20100119/window_resize
(defun my-window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
        (current-width (window-width))
        (current-height (window-height))
        (dx (if (= (nth 0 (window-edges)) 0) 1
              -1))
        (dy (if (= (nth 1 (window-edges)) 0) 1
              -1))
        action c)
    (catch 'end-flag
      (while t
        (setq action
              (read-key-sequence-vector (format "size[%dx%d]"
                                                (window-width)
                                                (window-height))))
        (setq c (aref action 0))
        (cond ((= c ?l)
               (enlarge-window-horizontally (* dx 5)))
              ((= c ?L)
               (enlarge-window-horizontally dx))
              ((= c ?h)
               (shrink-window-horizontally (* dx 5)))
              ((= c ?H)
               (shrink-window-horizontally dx))
              ((= c ?j)
               (enlarge-window (* dy 2)))
              ((= c ?J)
               (enlarge-window dy))
              ((= c ?k)
               (shrink-window (* dy 2)))
              ((= c ?K)
               (shrink-window dy))
              ;; otherwise
              (t
               (let ((last-command-char (aref action 0))
                     (command (key-binding action)))
                 (when command
                   (call-interactively command)))
               (message "Quit")
               (throw 'end-flag t)))))))

(map! :map evil-window-map
      "SPC" #'my-window-resizer) ; CTRL-w SPC or SPC w SPC

;; switch between window with C-hjkl
(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right)
;; move the window with C-S-hjkl
(map! :n "C-S-h" #'+evil/window-move-left
      :n "C-S-j" #'+evil/window-move-down
      :n "C-S-k" #'+evil/window-move-up
      :n "C-S-l" #'+evil/window-move-right)

;; minimal number of screen lines to keep above and below the cursor
(setq-default scroll-margin 3)
;; minimal number of screen columns to keep to the left and to the right of the cursor
(setq-default hscroll-margin 5)

;; delete character without yanking
(map! :n "x" #'delete-char)

;; Don't do square-bracket space-expansion where it doesn't make sense to
; (after! smartparens-text
;   (sp-local-pair 'text-mode
;                  "[" nil :post-handlers '(:rem ("| " "SPC"))))

;; smartparens is more annoying than useful
; (after! smartparens (smartparens-global-mode -1))

;; Make C-d usable in insert mode
(map! :i "C-d" #'delete-char)

;; move cursor by display lines by default
;; (swap hjkl and gh gj gk gl)
(map! :nvo "j" #'evil-next-visual-line
      :nvo "k" #'evil-previous-visual-line
      :nvo "gj" #'evil-next-line
      :nvo "gk" #'evil-prev-line)

;; org-mode
;; It must be set before org loads!
(setq org-directory "~/docs/all/org/")
(defconst doom-docs-org-font-lock-keywords
'(("^\\( *\\)#\\+begin_quote\n\\1 \\([󰝗󱌣󰐃󰔓󰟶󰥔]\\) "
2 (pcase (match-string 2)
        ("󰝗" 'font-lock-comment-face)
        ("󱌣" 'font-lock-comment-face)
        ("󰐃" 'error)
        ("󰔓" 'success)
        ("󰟶" 'font-lock-keyword-face)
        ("󰥔" 'font-lock-constant-face)
        ("" 'warning))))
"Extra font-lock keywords for Doom documentation.")
(after! org
  (setq
   ;; log when a certain todo item was finished
   org-log-done t
   ;; better source block indentation
   org-src-preserve-indentation nil
   ;; hide inline style characters
   org-hide-emphasis-markers t
   ;; show special symbols as unicode characters
   org-pretty-entities t
   ;; folding symbol
   org-ellipsis "  "
   ;; log into LOGBOOK drawer
   org-log-into-drawer t
   ;; log when reschedule
   org-log-reschedule 'note
   org-log-redeadline 'note
   ;; show completed tasks and clocks by default
   org-agenda-start-with-log-mode t
   org-agenda-log-mode-items '(state clock)
   ;; customize org-capture-template
   org-capture-templates
   '(("t" "TODO" entry
      (file+headline +org-capture-todo-file "Inbox")
      "* TODO %?" :prepend t)
     ("n" "Note" entry
      (file+headline +org-capture-notes-file "Inbox")
      "* %u %?" :prepend t)
     ("j" "Journal" entry
      (file+olp+datetree +org-capture-journal-file)
      "* %T %?" :prepend t)
     ("w" "Weekly review" entry
      (file+olp+datetree +org-capture-journal-file)
      "* %U 週次レビュー\n| 日付 | 起床 | 夜更かし | 出社 | 就寝 | 生産的な時間 | やったこと | 長期TODO/PJ消化 |\n|------+------+----------+------+------+--------------+------------+-----------------|\n| %?     |      |          |      |      |              |            |                 |"
      :prepend t)))
  ;; admonition
  (font-lock-add-keywords 'org-mode doom-docs-org-font-lock-keywords)
  ;; enable habit tracking
  (add-to-list 'org-modules 'org-habit t)
  ;; reset checkboxes on repeating
  (add-to-list 'org-modules 'org-checklist t))

(after! org-download
  ;; sway screen capture
  (setq org-download-screenshot-method "grim -g \"$(slurp)\" %s"))

(custom-set-faces!
  '(org-document-title :weight bold :height 1.25)
  '(org-document-info :weight normal :height 1.1)
  '(org-level-1 :inherit outline-1 :height 1.15))

;; Make sure that the weekdays in the time stamps of your Org mode files and in the agenda appear in English.
(setq system-time-locale "C")

;; transparent background
(add-to-list 'default-frame-alist '(alpha-background . 96))

;; change todo highlight colors
(after! hl-todo
  (setq hl-todo-keyword-faces
        `(("XXX" font-lock-keyword-face bold)
          ("HACK" font-lock-keyword-face bold)
          ("DEPRECATED" warning bold))))

;; reduce terminal lag
(after! vterm
  (setq vterm-timer-delay 0.03))

;; alert 5 minutes before schedules or deadlines
(after! alert
  (setq alert-default-style 'libnotify))
(use-package! org-alert
  :init
  (setq org-alert-notify-cutoff 5
        org-alert-notify-after-event-cutoff 10
        ;; https://github.com/spegoraro/org-alert/blob/b4bfd4cead89215cc9a46162234f7a4836da4dad/README.md#custom-regexp-for-matching-times
        org-alert-time-match-string "\\(?:SCHEDULED\\|DEADLINE\\):.*?<.*?\\([0-9]\\{2\\}:[0-9]\\{2\\}\\).*>")
  :config
  (org-alert-enable))
