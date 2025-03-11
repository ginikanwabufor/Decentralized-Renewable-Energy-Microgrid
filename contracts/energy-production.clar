;; energy-production.clar
;; This contract tracks energy generation from various sources

(define-map energy-producers
  { producer-id: uint }
  {
    owner: principal,
    energy-type: (string-ascii 20),
    total-generated: uint
  }
)

(define-data-var last-producer-id uint u0)
(define-data-var total-energy-produced uint u0)

(define-read-only (get-producer (producer-id uint))
  (map-get? energy-producers { producer-id: producer-id })
)

(define-public (register-producer (energy-type (string-ascii 20)))
  (let
    (
      (new-producer-id (+ (var-get last-producer-id) u1))
    )
    (var-set last-producer-id new-producer-id)
    (ok (map-set energy-producers
      { producer-id: new-producer-id }
      {
        owner: tx-sender,
        energy-type: energy-type,
        total-generated: u0
      }
    ))
  )
)

(define-public (record-energy-production (producer-id uint) (amount uint))
  (let
    (
      (producer (unwrap! (get-producer producer-id) (err u404)))
    )
    (asserts! (is-eq (get owner producer) tx-sender) (err u403))
    (var-set total-energy-produced (+ (var-get total-energy-produced) amount))
    (ok (map-set energy-producers
      { producer-id: producer-id }
      (merge producer
        { total-generated: (+ (get total-generated producer) amount) }
      )
    ))
  )
)

(define-read-only (get-total-energy-produced)
  (var-get total-energy-produced)
)

