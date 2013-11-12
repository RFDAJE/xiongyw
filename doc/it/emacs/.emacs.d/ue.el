(defun up-exchange ()
  "Exchange the current line with its previous line.
After exchange, the point remains at the position of the current line."
  (interactive)
  (if (< 1 (line-number-at-pos))
      (let ((c (current-column)))
        (beginning-of-line)
        (kill-line 1)
        (previous-line 1)
        (beginning-of-line)
        (yank)
        (previous-line 1)
        (move-to-column c))))


(defun down-exchange ()
  "Exchange the current line with its following line.
After exchange, the point remains at the position of the current line."
  (interactive)
  (if (< (line-number-at-pos) (count-lines (point-min) (point-max)))
      (let ((c (current-column)))
        (next-line 1)
        (beginning-of-line)
        (kill-line 1)
        (previous-line 1)
        (beginning-of-line)
        (yank)
        (move-to-column c))))

(define-key global-map [C-S-down] 'down-exchange)
(define-key global-map [C-S-up] 'up-exchange)



;; remember the point before the application of next-line command
(setq ue-next-line-oldpoint nil)
;; was the last next-line command shifted?
(setq ue-next-line-last-shifted nil)
;; number of lines copied
(setq ue-next-line-lines-copied 0)

;; before-advice for the next-line command
(defadvice next-line (before lambda ())
  "Remember the old point value before application of the next-line command."
  (if this-command-keys-shift-translated
      (setq ue-next-line-oldpoint (point))))

;; after-advice for the next-line command
(defadvice next-line (after lambda ())
  "Kill-new or kill-append the previous line and set the shifted state."
  (if this-command-keys-shift-translated
      (progn
        (if (and (eq last-command 'next-line) ue-next-line-last-shifted)
            (kill-append (buffer-substring ue-next-line-oldpoint (point)) nil)
          (kill-new (buffer-substring ue-next-line-oldpoint (point)) nil)
          (setq ue-next-line-lines-copied 0))
        (setq ue-next-line-last-shifted t)
        (setq ue-next-line-lines-copied (1+ ue-next-line-lines-copied))
        (message "%s lines copied" ue-next-line-lines-copied))
    (setq ue-next-line-last-shifted nil)
    (setq ue-next-line-lines-copied 0)))

;; activate the advices for the next-line command  
(ad-activate 'next-line)

(provide 'ue)
