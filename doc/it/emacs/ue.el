(global-set-key [C-S-up] 'up-exchange)
(global-set-key [C-S-down] 'down-exchange)



(defun up-exchange (p)
  "Exchange the current line with its previous line,
   after exchange, the point remains at the position
   of the current line."
  (interactive "p")
  (if (< 1 (line-number-at-pos))
      (let ((c (current-column)))
        (beginning-of-line)
        (kill-line 1)
        (previous-line p)
        (beginning-of-line)
        (yank)
        (previous-line 1)
        (move-to-column c))))


(defun down-exchange (p)
  "Exchange the current line with its following line,
   after exchange, the point remains at the position
   of the current line."
  (interactive "p")
  (if (< (line-number-at-pos) (count-lines (point-min) (point-max)))
      (let ((c (current-column)))
        (next-line p)
        (beginning-of-line)
        (kill-line 1)
        (previous-line 1)
        (beginning-of-line)
        (yank)
        (move-to-column c))))


