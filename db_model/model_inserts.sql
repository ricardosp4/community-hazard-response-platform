
BEGIN; -- we start a transaction to ensure all inserts succeed together

INSERT INTO app_user (username, email, hashed_password, firstname, surname, phone, is_verified)
VALUES
  ('andrea', 'andrea@example.com', '$2b$12$dummyhashandrea', 'Andrea', 'Cretu', '+351910000001', TRUE),
  ('mario',  'mario@example.com',  '$2b$12$dummyhashmario',  'Mario',  'Silva', '+351910000002', TRUE),
  ('ines',   'ines@example.com',   '$2b$12$dummyhashines',   'Ines',   'Costa', NULL, FALSE),
  ('rui',    'rui@example.com',    '$2b$12$dummyhashrui',    'Rui',    'Pereira', '+351910000004', TRUE);


INSERT INTO administrative_area (name_area, admin_level, geom)
VALUES
  (
    'Lisbon (test area)',
    8,
    ST_GeomFromText(
      'POLYGON(( -10000 -10000,  10000 -10000,  10000 10000,  -10000 10000, -10000 -10000 ))',
      3763
    )
  ),
  (
    'Oeiras (test area)',
    8,
    ST_GeomFromText(
      'POLYGON(( 12000 -8000,  26000 -8000,  26000 8000,  12000 8000, 12000 -8000 ))',
      3763
    )
  );


INSERT INTO facility (osm_id, name_fac, facility_type, geom)
VALUES
  (1000001, 'Central Hospital (test)', 'hospital',      ST_GeomFromText('POINT(2000 1500)', 3763)),
  (1000002, 'Fire Station (test)',    'fire_station',  ST_GeomFromText('POINT(-1500 1000)', 3763)),
  (1000003, 'Police Station (test)',  'police',        ST_GeomFromText('POINT(500 -2200)', 3763));


INSERT INTO need (user_id, title, descrip, category, urgency, geom, address_point, status_need)
VALUES
  (1, 'Need medication', 'I am out of medication and need it today.', 'medical', 'high',
      ST_GeomFromText('POINT(1000 1200)', 3763), 'Street A, No. 10', 'active'),

  (2, 'Ride to appointment', 'I need transportation to the hospital tomorrow.', 'transport', 'medium',
      ST_GeomFromText('POINT(-800 900)', 3763), 'Avenue B, No. 25', 'active'),

  (3, 'Food for two days', 'I cannot leave home and need basic groceries.', 'food', 'critical',
      ST_GeomFromText('POINT(300 -600)', 3763), 'Square C, Building 3', 'active'),

  (4, 'Companionship', 'I need someone to accompany me to an administrative office.', 'social', 'low',
      ST_GeomFromText('POINT(6000 1000)', 3763), 'Street D, No. 2', 'active');


INSERT INTO offer (user_id, descrip, category, available, geom, status_offer)
VALUES
  (2, 'I can drive people to medical appointments.', 'transport', 'today',
      ST_GeomFromText('POINT(-500 700)', 3763), 'available'),

  (4, 'I can buy and deliver groceries.', 'food', 'immediate',
      ST_GeomFromText('POINT(200 100)', 3763), 'available'),

  (1, 'I can provide phone check-ins and emotional support.', 'social', 'this_week',
      NULL, 'available'),

  (3, 'Basic medical training; I can help with non-critical cases.', 'medical', 'on_call',
      ST_GeomFromText('POINT(1200 1400)', 3763), 'available');


INSERT INTO assignments (need_id, offer_id, status_ass, notes)
VALUES
  (2, 1, 'accepted', 'Coordinated by phone, pickup at 09:00.'),
  (3, 2, 'proposed', 'Waiting for schedule confirmation.');

COMMIT;

-- Quick trigger test 
-- SELECT need_id, created_at, updated_at FROM need WHERE need_id = 2;
-- UPDATE need SET status_need = 'assigned' WHERE need_id = 2;
-- SELECT need_id, created_at, updated_at FROM need WHERE need_id = 2;

∫


