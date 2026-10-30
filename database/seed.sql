-- Paws of Haven - fictional development/test data only
USE paws_of_haven;

-- Clear existing sample data in child-to-parent order.
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE treatments;
TRUNCATE TABLE medical_records;
TRUNCATE TABLE veterinary_visits;
TRUNCATE TABLE foster_assignments;
TRUNCATE TABLE foster_applications;
TRUNCATE TABLE foster_caregivers;
TRUNCATE TABLE adoptions;
TRUNCATE TABLE adoption_applications;
TRUNCATE TABLE adopters;
TRUNCATE TABLE rescue_records;
TRUNCATE TABLE animals;
TRUNCATE TABLE animal_categories;
TRUNCATE TABLE user_roles;
TRUNCATE TABLE roles;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO users (id, full_name, email, password_hash, account_status) VALUES
(1, 'Avery Santos', 'avery.admin@example.test', '$2b$12$DEMO_HASH_REPLACE_WITH_REAL_HASH', 'active'),
(2, 'Jamie Cruz', 'jamie.vet@example.test', '$2b$12$DEMO_HASH_REPLACE_WITH_REAL_HASH', 'active'),
(3, 'Morgan Reyes', 'morgan.staff@example.test', '$2b$12$DEMO_HASH_REPLACE_WITH_REAL_HASH', 'active');

INSERT INTO roles (id, role_name, description) VALUES
(1, 'admin', 'System administrator'),
(2, 'vet', 'Veterinary professional'),
(3, 'staff', 'Shelter staff member'),
(4, 'owner', 'Pet owner account');

INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), (2, 2), (3, 3);

INSERT INTO animal_categories (id, category_name, description) VALUES
(1, 'Dog', 'Domestic dogs'),
(2, 'Cat', 'Domestic cats'),
(3, 'Other', 'Other rescued animal types');

INSERT INTO animals (id, category_id, name, breed, estimated_age_months, sex, color_markings, intake_date, status, notes) VALUES
(1, 1, 'Bingo', 'Aspin mix', 18, 'male', 'Brown and white', '2026-10-01', 'fostered', 'Friendly and active.'),
(2, 2, 'Mimi', 'Domestic shorthair', 10, 'female', 'Gray tabby', '2026-10-03', 'available', 'Quiet around new people.'),
(3, 1, 'Patch', 'Mixed breed', 30, 'male', 'Black patch over one eye', '2026-10-05', 'available', 'Needs follow-up check.'),
(4, 2, 'Luna', 'Domestic shorthair', 8, 'female', 'White', '2026-10-08', 'adopted', 'Adoption completed in sample data.'),
(5, 1, 'Toby', 'Aspin', 24, 'unknown', 'Tan', '2026-10-12', 'medical_hold', 'Not yet cleared for foster placement.');

INSERT INTO rescue_records (id, animal_id, rescue_date, rescue_location, reported_by, condition_on_arrival, intake_notes, recorded_by) VALUES
(1, 1, '2026-10-01', 'Bais City public market', 'Community volunteer', 'stable', 'Brought to the shelter safely.', 3),
(2, 2, '2026-10-03', 'Barangay neighborhood', 'Resident report', 'stable', 'Found near a roadside.', 3),
(3, 3, '2026-10-05', 'Town plaza', 'Community volunteer', 'injured', 'Small wound; veterinary check needed.', 3),
(4, 4, '2026-10-08', 'Residential street', 'Resident report', 'stable', 'No owner identified at intake.', 3);

INSERT INTO adopters (id, user_id, full_name, email, phone, address) VALUES
(1, NULL, 'Taylor Dela Cruz', 'taylor.adopter@example.test', '09170000001', 'Bais City'),
(2, NULL, 'Jordan Flores', 'jordan.adopter@example.test', '09170000002', 'Manjuyod'),
(3, NULL, 'Casey Lim', 'casey.adopter@example.test', '09170000003', 'Tanjay City');

INSERT INTO adoption_applications (id, adopter_id, animal_id, application_date, status, household_notes, reviewed_by, reviewed_at) VALUES
(1, 1, 4, '2026-10-09', 'approved', 'Has experience caring for cats.', 3, '2026-10-10 10:00:00'),
(2, 2, 2, '2026-10-15', 'pending', 'First-time cat adopter.', NULL, NULL),
(3, 3, 3, '2026-10-16', 'under_review', 'Has a fenced yard.', 3, '2026-10-17 14:30:00');

INSERT INTO adoptions (id, application_id, animal_id, adopter_id, adoption_date, status, contract_notes, recorded_by) VALUES
(1, 1, 4, 1, '2026-10-11', 'completed', 'Sample completed adoption.', 3);

INSERT INTO foster_caregivers (id, user_id, full_name, email, phone, address, capacity, approval_status) VALUES
(1, NULL, 'Riley Navarro', 'riley.foster@example.test', '09171110001', 'Bais City', 2, 'approved'),
(2, NULL, 'Sam Bautista', 'sam.foster@example.test', '09171110002', 'Manjuyod', 1, 'pending'),
(3, NULL, 'Alex Mendoza', 'alex.foster@example.test', '09171110003', 'Tanjay City', 1, 'approved');

INSERT INTO foster_applications (id, caregiver_id, animal_id, application_date, planned_start_date, planned_end_date, status, notes, reviewed_by, reviewed_at) VALUES
(1, 1, 1, '2026-10-06', '2026-10-07', '2026-11-07', 'approved', 'Approved after home check.', 3, '2026-10-06 15:00:00'),
(2, 2, 3, '2026-10-18', '2026-10-20', '2026-11-20', 'pending', 'Pending caregiver approval.', NULL, NULL),
(3, 3, 5, '2026-10-19', '2026-10-21', '2026-11-21', 'under_review', 'Animal clearance not confirmed.', 3, '2026-10-20 09:00:00');

INSERT INTO foster_assignments (id, application_id, animal_id, caregiver_id, start_date, expected_end_date, actual_end_date, status, placement_notes, assigned_by) VALUES
(1, 1, 1, 1, '2026-10-07', '2026-11-07', NULL, 'active', 'Sample active foster placement.', 3);

INSERT INTO veterinary_visits (id, animal_id, veterinarian_user_id, visit_date, reason, findings, follow_up_date) VALUES
(1, 1, 2, '2026-10-06 09:00:00', 'Routine health check', 'No major concerns observed.', '2026-11-06'),
(2, 3, 2, '2026-10-06 10:30:00', 'Wound examination', 'Wound cleaned; monitor healing.', '2026-10-30'),
(3, 4, 2, '2026-10-09 11:00:00', 'Pre-adoption check', 'Healthy at examination.', NULL),
(4, 5, 2, '2026-10-19 13:00:00', 'Initial examination', 'Needs further assessment before placement.', '2026-10-29');

INSERT INTO medical_records (id, animal_id, veterinary_visit_id, record_date, diagnosis, medical_notes, clearance_status, next_check_date, recorded_by) VALUES
(1, 1, 1, '2026-10-06', 'Routine examination', 'No concerns recorded.', 'cleared', '2026-11-06', 2),
(2, 3, 2, '2026-10-06', 'Minor wound', 'Monitor the wound and keep it clean.', 'not_cleared', '2026-10-30', 2),
(3, 4, 3, '2026-10-09', 'Healthy', 'Suitable for adoption based on this check.', 'cleared', NULL, 2),
(4, 5, 4, '2026-10-19', 'Assessment pending', 'Do not place in foster care until cleared.', 'pending', '2026-10-29', 2);

INSERT INTO treatments (id, medical_record_id, treatment_name, instructions, start_date, end_date, status) VALUES
(1, 2, 'Wound cleaning', 'Clean as instructed by the veterinarian.', '2026-10-06', '2026-10-13', 'completed'),
(2, 4, 'Follow-up assessment', 'Return for veterinary review.', '2026-10-19', NULL, 'ongoing');

-- Expected sample counts: 3 users, 4 roles, 3 categories, 5 animals, 4 rescue records.
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'roles', COUNT(*) FROM roles
UNION ALL SELECT 'user_roles', COUNT(*) FROM user_roles
UNION ALL SELECT 'animal_categories', COUNT(*) FROM animal_categories
UNION ALL SELECT 'animals', COUNT(*) FROM animals
UNION ALL SELECT 'rescue_records', COUNT(*) FROM rescue_records
UNION ALL SELECT 'adopters', COUNT(*) FROM adopters
UNION ALL SELECT 'adoption_applications', COUNT(*) FROM adoption_applications
UNION ALL SELECT 'adoptions', COUNT(*) FROM adoptions
UNION ALL SELECT 'foster_caregivers', COUNT(*) FROM foster_caregivers
UNION ALL SELECT 'foster_applications', COUNT(*) FROM foster_applications
UNION ALL SELECT 'foster_assignments', COUNT(*) FROM foster_assignments
UNION ALL SELECT 'veterinary_visits', COUNT(*) FROM veterinary_visits
UNION ALL SELECT 'medical_records', COUNT(*) FROM medical_records
UNION ALL SELECT 'treatments', COUNT(*) FROM treatments;
