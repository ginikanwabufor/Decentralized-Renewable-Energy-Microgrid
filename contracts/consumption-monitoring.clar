;; consumption-monitoring.clar
;; This contract records energy usage by consumers

(define-map energy-consumers
  { consumer-id: uint }
  {
    owner: principal,
    total-consumed: uint
  }
)

(define-data-var last-consumer-id uint u0)
(define-data-var total-energy-consumed uint u0)

(define-read-only (get-consumer (consumer-id uint))
  (map-get? energy-consumers { consumer-id: consumer-id })
)

(define-public (register-consumer)
  (let
    (
      (new-consumer-id (+ (var-get last-consumer-id) u1))
    )
    (var-set last-consumer-id new-consumer-id)
    (ok (map-set energy-consumers
      { consumer-id: new-consumer-id }
      {
        owner: tx-sender,
        total-consumed: u0
      }
    ))
  )
)

(define-public (record-energy-consumption (consumer-id uint) (amount uint))
  (let
    (
      (consumer (unwrap! (get-consumer consumer-id) (err u404)))
    )
    (asserts! (is-eq (get owner consumer) tx-sender) (err u403))
    (var-set total-energy-consumed (+ (var-get total-energy-consumed) amount))
    (ok (map-set energy-consumers
      { consumer-id: consumer-id }
      (merge consumer
        { total-consumed: (+ (get total-consumed consumer) amount) }
      )
    ))
  )
)

(define-read-only (get-total-energy-consumed)
  (var-get total-energy-consumed)
)

