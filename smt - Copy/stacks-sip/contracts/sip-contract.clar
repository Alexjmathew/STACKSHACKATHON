;; Simple SIP Contract - LSP Error Fixed Version

;; Error constants
(define-constant ERR-INVALID-AMOUNT (err u100))
(define-constant ERR-NO-SIP-FOUND (err u101))
(define-constant ERR-SIP-ALREADY-EXISTS (err u102))

;; Data maps
(define-map users-sips principal { 
    amount: uint,
    active: bool
})

;; Create a SIP
(define-public (create-sip (amount uint))
    (begin
        ;; Check if amount is valid
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        
        ;; Check if user already has a SIP
        (asserts! (is-none (map-get? users-sips tx-sender)) ERR-SIP-ALREADY-EXISTS)
        
        ;; Create the SIP
        (map-set users-sips tx-sender {
            amount: amount,
            active: true
        })
        
        (ok true)
    )
)

;; Get user's SIP details
(define-read-only (get-my-sip)
    (map-get? users-sips tx-sender)
)

;; Get any user's SIP details
(define-read-only (get-user-sip (user principal))
    (map-get? users-sips user)
)

;; Cancel SIP
(define-public (cancel-sip)
    (begin
        (match (map-get? users-sips tx-sender)
            sip (begin
                (asserts! (get active sip) ERR-NO-SIP-FOUND)
                (map-set users-sips tx-sender (merge sip {
                    active: false
                }))
                (ok true)
            )
            ERR-NO-SIP-FOUND
        )
    )
)

;; Reactivate SIP
(define-public (reactivate-sip)
    (begin
        (match (map-get? users-sips tx-sender)
            sip (begin
                (asserts! (not (get active sip)) ERR-NO-SIP-FOUND)
                (map-set users-sips tx-sender (merge sip {
                    active: true
                }))
                (ok true)
            )
            ERR-NO-SIP-FOUND
        )
    )
)

;; Update SIP amount
(define-public (update-sip-amount (new-amount uint))
    (begin
        (asserts! (> new-amount u0) ERR-INVALID-AMOUNT)
        (match (map-get? users-sips tx-sender)
            sip (begin
                (asserts! (get active sip) ERR-NO-SIP-FOUND)
                (map-set users-sips tx-sender (merge sip {
                    amount: new-amount
                }))
                (ok true)
            )
            ERR-NO-SIP-FOUND
        )
    )
)

;; Check if user has active SIP
(define-read-only (has-active-sip (user principal))
    (match (map-get? users-sips user)
        sip (get active sip)
        false
    )
)