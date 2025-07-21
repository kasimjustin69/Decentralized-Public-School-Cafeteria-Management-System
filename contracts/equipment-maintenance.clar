;; Kitchen Equipment Maintenance Contract
;; Manages appliance repairs, maintenance scheduling, and safety inspections

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-EQUIPMENT-NOT-FOUND (err u401))
(define-constant ERR-INVALID-INPUT (err u402))
(define-constant ERR-MAINTENANCE-NOT-FOUND (err u403))
(define-constant ERR-EQUIPMENT-OUT-OF-SERVICE (err u404))

;; Data Variables
(define-data-var next-equipment-id uint u1)
(define-data-var next-maintenance-id uint u1)
(define-data-var next-inspection-id uint u1)

;; Data Maps
(define-map kitchen-equipment
  { equipment-id: uint }
  {
    name: (string-ascii 100),
    equipment-type: (string-ascii 50),
    manufacturer: (string-ascii 100),
    model-number: (string-ascii 50),
    serial-number: (string-ascii 50),
    purchase-date: uint,
    warranty-expiration: uint,
    location: (string-ascii 100),
    status: (string-ascii 20),
    last-maintenance: uint,
    next-maintenance-due: uint,
    maintenance-interval-days: uint,
    purchase-cost: uint,
    energy-rating: (string-ascii 10),
    capacity: (string-ascii 50),
    created-by: principal,
    created-at: uint
  }
)

(define-map maintenance-records
  { maintenance-id: uint }
  {
    equipment-id: uint,
    maintenance-type: (string-ascii 50),
    description: (string-ascii 500),
    scheduled-date: uint,
    completed-date: uint,
    technician: (string-ascii 100),
    vendor: (string-ascii 100),
    cost: uint,
    parts-replaced: (list 10 (string-ascii 100)),
    status: (string-ascii 20),
    priority: (string-ascii 20),
    downtime-hours: uint,
    created-by: principal,
    created-at: uint
  }
)

(define-map safety-inspections
  { inspection-id: uint }
  {
    equipment-id: uint,
    inspection-type: (string-ascii 50),
    inspector: (string-ascii 100),
    inspection-date: uint,
    next-inspection-due: uint,
    passed: bool,
    findings: (string-ascii 1000),
    corrective-actions: (list 5 (string-ascii 200)),
    certificate-number: (string-ascii 50),
    regulatory-body: (string-ascii 100),
    created-by: principal,
    created-at: uint
  }
)

(define-map maintenance-vendors
  { vendor-id: (string-ascii 50) }
  {
    name: (string-ascii 100),
    contact-info: (string-ascii 200),
    specialties: (list 10 (string-ascii 50)),
    rating: uint,
    active: bool,
    response-time-hours: uint,
    hourly-rate: uint
  }
)

(define-map equipment-warranties
  { equipment-id: uint }
  {
    warranty-type: (string-ascii 50),
    provider: (string-ascii 100),
    start-date: uint,
    end-date: uint,
    coverage-details: (string-ascii 500),
    claim-process: (string-ascii 300),
    contact-info: (string-ascii 200)
  }
)

(define-map authorized-users
  { user: principal }
  { role: (string-ascii 20), active: bool }
)

;; Authorization Functions
(define-private (is-authorized (user principal) (required-role (string-ascii 20)))
  (match (map-get? authorized-users { user: user })
    user-data (and (get active user-data)
                   (or (is-eq (get role user-data) required-role)
                       (is-eq (get role user-data) "admin")))
    false
  )
)

;; Admin Functions
(define-public (add-authorized-user (user principal) (role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-users { user: user } { role: role, active: true }))
  )
)

;; Equipment Management Functions
(define-public (register-equipment
  (name (string-ascii 100))
  (equipment-type (string-ascii 50))
  (manufacturer (string-ascii 100))
  (model-number (string-ascii 50))
  (serial-number (string-ascii 50))
  (purchase-date uint)
  (warranty-expiration uint)
  (location (string-ascii 100))
  (maintenance-interval-days uint)
  (purchase-cost uint)
  (energy-rating (string-ascii 10))
  (capacity (string-ascii 50))
)
  (let ((equipment-id (var-get next-equipment-id)))
    (asserts! (is-authorized tx-sender "facilities-manager") ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> maintenance-interval-days u0) ERR-INVALID-INPUT)
    (asserts! (< purchase-date warranty-expiration) ERR-INVALID-INPUT)

    (map-set kitchen-equipment
      { equipment-id: equipment-id }
      {
        name: name,
        equipment-type: equipment-type,
        manufacturer: manufacturer,
        model-number: model-number,
        serial-number: serial-number,
        purchase-date: purchase-date,
        warranty-expiration: warranty-expiration,
        location: location,
        status: "operational",
        last-maintenance: u0,
        next-maintenance-due: (+ block-height (* maintenance-interval-days u144)),
        maintenance-interval-days: maintenance-interval-days,
        purchase-cost: purchase-cost,
        energy-rating: energy-rating,
        capacity: capacity,
        created-by: tx-sender,
        created-at: block-height
      }
    )
    (var-set next-equipment-id (+ equipment-id u1))
    (ok equipment-id)
  )
)

(define-public (schedule-maintenance
  (equipment-id uint)
  (maintenance-type (string-ascii 50))
  (description (string-ascii 500))
  (scheduled-date uint)
  (technician (string-ascii 100))
  (vendor (string-ascii 100))
  (estimated-cost uint)
  (priority (string-ascii 20))
)
  (let ((maintenance-id (var-get next-maintenance-id)))
    (asserts! (is-authorized tx-sender "facilities-manager") ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? kitchen-equipment { equipment-id: equipment-id })) ERR-EQUIPMENT-NOT-FOUND)
    (asserts! (> scheduled-date block-height) ERR-INVALID-INPUT)

    (map-set maintenance-records
      { maintenance-id: maintenance-id }
      {
        equipment-id: equipment-id,
        maintenance-type: maintenance-type,
        description: description,
        scheduled-date: scheduled-date,
        completed-date: u0,
        technician: technician,
        vendor: vendor,
        cost: estimated-cost,
        parts-replaced: (list),
        status: "scheduled",
        priority: priority,
        downtime-hours: u0,
        created-by: tx-sender,
        created-at: block-height
      }
    )
    (var-set next-maintenance-id (+ maintenance-id u1))
    (ok maintenance-id)
  )
)

(define-public (complete-maintenance
  (maintenance-id uint)
  (actual-cost uint)
  (parts-replaced (list 10 (string-ascii 100)))
  (downtime-hours uint)
)
  (match (map-get? maintenance-records { maintenance-id: maintenance-id })
    maintenance-data (match (map-get? kitchen-equipment { equipment-id: (get equipment-id maintenance-data) })
      equipment-data (begin
        (asserts! (is-authorized tx-sender "technician") ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get status maintenance-data) "scheduled") ERR-INVALID-INPUT)

        ;; Update maintenance record
        (map-set maintenance-records
          { maintenance-id: maintenance-id }
          (merge maintenance-data {
            completed-date: block-height,
            cost: actual-cost,
            parts-replaced: parts-replaced,
            status: "completed",
            downtime-hours: downtime-hours
          })
        )

        ;; Update equipment record
        (map-set kitchen-equipment
          { equipment-id: (get equipment-id maintenance-data) }
          (merge equipment-data {
            last-maintenance: block-height,
            next-maintenance-due: (+ block-height (* (get maintenance-interval-days equipment-data) u144)),
            status: "operational"
          })
        )
        (ok true)
      )
      ERR-EQUIPMENT-NOT-FOUND
    )
    ERR-MAINTENANCE-NOT-FOUND
  )
)

(define-public (schedule-safety-inspection
  (equipment-id uint)
  (inspection-type (string-ascii 50))
  (inspector (string-ascii 100))
  (inspection-date uint)
  (regulatory-body (string-ascii 100))
)
  (let ((inspection-id (var-get next-inspection-id)))
    (asserts! (is-authorized tx-sender "safety-coordinator") ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? kitchen-equipment { equipment-id: equipment-id })) ERR-EQUIPMENT-NOT-FOUND)
    (asserts! (> inspection-date block-height) ERR-INVALID-INPUT)

    (map-set safety-inspections
      { inspection-id: inspection-id }
      {
        equipment-id: equipment-id,
        inspection-type: inspection-type,
        inspector: inspector,
        inspection-date: inspection-date,
        next-inspection-due: u0,
        passed: false,
        findings: "",
        corrective-actions: (list),
        certificate-number: "",
        regulatory-body: regulatory-body,
        created-by: tx-sender,
        created-at: block-height
      }
    )
    (var-set next-inspection-id (+ inspection-id u1))
    (ok inspection-id)
  )
)

(define-public (complete-safety-inspection
  (inspection-id uint)
  (passed bool)
  (findings (string-ascii 1000))
  (corrective-actions (list 5 (string-ascii 200)))
  (certificate-number (string-ascii 50))
  (next-inspection-due uint)
)
  (match (map-get? safety-inspections { inspection-id: inspection-id })
    inspection-data (begin
      (asserts! (is-authorized tx-sender "inspector") ERR-NOT-AUTHORIZED)
      (asserts! (> next-inspection-due block-height) ERR-INVALID-INPUT)

      (map-set safety-inspections
        { inspection-id: inspection-id }
        (merge inspection-data {
          passed: passed,
          findings: findings,
          corrective-actions: corrective-actions,
          certificate-number: certificate-number,
          next-inspection-due: next-inspection-due
        })
      )

      ;; Update equipment status if failed
      (if (not passed)
        (match (map-get? kitchen-equipment { equipment-id: (get equipment-id inspection-data) })
          equipment-data (map-set kitchen-equipment
            { equipment-id: (get equipment-id inspection-data) }
            (merge equipment-data { status: "out-of-service" })
          )
          false
        )
        true
      )
      (ok true)
    )
    ERR-MAINTENANCE-NOT-FOUND
  )
)

(define-public (add-maintenance-vendor
  (vendor-id (string-ascii 50))
  (name (string-ascii 100))
  (contact-info (string-ascii 200))
  (specialties (list 10 (string-ascii 50)))
  (response-time-hours uint)
  (hourly-rate uint)
)
  (begin
    (asserts! (is-authorized tx-sender "facilities-manager") ERR-NOT-AUTHORIZED)
    (asserts! (> (len vendor-id) u0) ERR-INVALID-INPUT)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)

    (ok (map-set maintenance-vendors
      { vendor-id: vendor-id }
      {
        name: name,
        contact-info: contact-info,
        specialties: specialties,
        rating: u5,
        active: true,
        response-time-hours: response-time-hours,
        hourly-rate: hourly-rate
      }
    ))
  )
)

;; Read-only Functions
(define-read-only (get-equipment (equipment-id uint))
  (map-get? kitchen-equipment { equipment-id: equipment-id })
)

(define-read-only (get-maintenance-record (maintenance-id uint))
  (map-get? maintenance-records { maintenance-id: maintenance-id })
)

(define-read-only (get-safety-inspection (inspection-id uint))
  (map-get? safety-inspections { inspection-id: inspection-id })
)

(define-read-only (get-maintenance-vendor (vendor-id (string-ascii 50)))
  (map-get? maintenance-vendors { vendor-id: vendor-id })
)

(define-read-only (check-maintenance-due (equipment-id uint))
  (match (map-get? kitchen-equipment { equipment-id: equipment-id })
    equipment-data (>= block-height (get next-maintenance-due equipment-data))
    false
  )
)

(define-read-only (get-equipment-status (equipment-id uint))
  (match (map-get? kitchen-equipment { equipment-id: equipment-id })
    equipment-data (get status equipment-data)
    "not-found"
  )
)
