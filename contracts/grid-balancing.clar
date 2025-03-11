;; grid-balancing.clar
;; This contract manages overall stability of the local energy network

(define-data-var grid-balance int 0)

(define-read-only (get-grid-balance)
  (var-get grid-balance)
)

(define-public (update-grid-balance)
  (let
    (
      (total-produced (contract-call? .energy-production get-total-energy-produced))
      (total-consumed (contract-call? .consumption-monitoring get-total-energy-consumed))
      (new-balance (- (to-int total-produced) (to-int total-consumed)))
    )
    (var-set grid-balance new-balance)
    (ok new-balance)
  )
)

(define-public (request-energy (amount uint))
  (let
    (
      (current-balance (var-get grid-balance))
    )
    (asserts! (>= current-balance (to-int amount)) (err u400))
    (var-set grid-balance (- current-balance (to-int amount)))
    (ok true)
  )
)

(define-public (supply-energy (amount uint))
  (let
    (
      (current-balance (var-get grid-balance))
    )
    (var-set grid-balance (+ current-balance (to-int amount)))
    (ok true)
  )
)

