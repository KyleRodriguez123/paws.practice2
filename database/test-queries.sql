-- Paws of Haven - schema and report smoke tests
USE paws_of_haven;

-- 1. Verify all 15 tables exist.
SHOW TABLES;

-- 2. Verify row counts across all tables.
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

-- 3. INNER JOIN: animal, category, and rescue history.
SELECT a.id, a.name AS animal_name, c.category_name, rr.rescue_date, rr.rescue_location
FROM animals a
INNER JOIN animal_categories c ON c.id = a.category_id
INNER JOIN rescue_records rr ON rr.animal_id = a.id
ORDER BY rr.rescue_date;

-- 4. INNER JOIN: adoption applications and applicants.
SELECT aa.id AS application_id, ad.full_name AS adopter_name, a.name AS animal_name, aa.status
FROM adoption_applications aa
INNER JOIN adopters ad ON ad.id = aa.adopter_id
INNER JOIN animals a ON a.id = aa.animal_id
ORDER BY aa.application_date;

-- 5. LEFT JOIN: animals with no active foster assignment.
SELECT a.id, a.name, a.status
FROM animals a
LEFT JOIN foster_assignments fa
  ON fa.animal_id = a.id AND fa.status = 'active'
WHERE fa.id IS NULL
ORDER BY a.id;

-- 6. INNER JOIN: veterinary visit history.
SELECT a.name AS animal_name, vv.visit_date, u.full_name AS veterinarian, vv.reason, vv.follow_up_date
FROM veterinary_visits vv
INNER JOIN animals a ON a.id = vv.animal_id
LEFT JOIN users u ON u.id = vv.veterinarian_user_id
ORDER BY vv.visit_date;

-- 7. MySQL FULL OUTER JOIN equivalent: animals with rescue records plus unmatched rescue records.
-- The FK normally prevents orphan rescue records; the second side is included to demonstrate the pattern.
SELECT a.id AS animal_id, a.name AS animal_name, rr.id AS rescue_record_id, rr.rescue_location
FROM animals a
LEFT JOIN rescue_records rr ON rr.animal_id = a.id
UNION
SELECT a.id AS animal_id, a.name AS animal_name, rr.id AS rescue_record_id, rr.rescue_location
FROM animals a
RIGHT JOIN rescue_records rr ON rr.animal_id = a.id;

-- 8. Foster placement eligibility diagnostic: active placement, caregiver approval, and latest medical clearance.
-- This is a diagnostic report, not a replacement for backend validation/transaction logic.
SELECT a.id AS animal_id, a.name AS animal_name,
       fc.full_name AS caregiver_name, fc.approval_status,
       fa.status AS assignment_status, mr.clearance_status,
       CASE
         WHEN fc.approval_status <> 'approved' THEN 'BLOCK: caregiver not approved'
         WHEN mr.clearance_status IS NULL OR mr.clearance_status <> 'cleared' THEN 'BLOCK: no current clearance'
         ELSE 'PASS: checks shown are satisfied'
       END AS eligibility_check
FROM foster_assignments fa
INNER JOIN animals a ON a.id = fa.animal_id
INNER JOIN foster_caregivers fc ON fc.id = fa.caregiver_id
LEFT JOIN medical_records mr ON mr.animal_id = a.id
  AND mr.id = (
    SELECT MAX(mr2.id) FROM medical_records mr2 WHERE mr2.animal_id = a.id
  )
WHERE fa.status = 'active';

-- 9. Test a foreign-key failure safely by running this statement separately only if you want to see the error.
-- It should fail because category_id 999 does not exist. Keep commented during normal test runs.
-- INSERT INTO animals (category_id, name, intake_date) VALUES (999, 'Invalid Test', '2026-10-29');

-- 10. Check for animals with more than one active foster assignment.
-- Expected result: zero rows. The application must enforce this rule when creating assignments.
SELECT animal_id, COUNT(*) AS active_assignment_count
FROM foster_assignments
WHERE status = 'active'
GROUP BY animal_id
HAVING COUNT(*) > 1;
