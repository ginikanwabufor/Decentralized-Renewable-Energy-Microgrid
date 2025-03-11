;; peer-to-peer-trading.clar
;; This contract facilitates energy exchange within the community

(define-map energy-offers
  { offer-id: uint }
  {
    seller: principal,
    amount: uint,
    price: uint
  }
)

(define-data-var last-offer-id uint u0)

(define-read-only (get-offer (offer-id uint))
  (map-get? energy-offers { offer-id: offer-id })
)

(define-public (create-offer (amount uint) (price uint))
  (let
    (
      (new-offer-id (+ (var-get last-offer-id) u1))
    )
    (var-set last-offer-id new-offer-id)
    (ok (map-set energy-offers
      { offer-id: new-offer-id }
      {
        seller: tx-sender,
        amount: amount,
        price: price
      }
    ))
  )
)

(define-public (accept-offer (offer-id uint))
  (let
    (
      (offer (unwrap! (get-offer offer-id) (err u404)))
    )
    (try! (stx-transfer? (get price offer) tx-sender (get seller offer)))
    (ok (map-delete energy-offers { offer-id: offer-id }))
  )
)

(define-public (cancel-offer (offer-id uint))
  (let
    (
      (offer (unwrap! (get-offer offer-id) (err u404)))
    )
    (asserts! (is-eq tx-sender (get seller offer)) (err u403))
    (ok (map-delete energy-offers { offer-id: offer-id }))
  )
)

