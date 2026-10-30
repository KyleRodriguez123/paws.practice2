-- Paws of Haven - Stage 3 schema
-- MySQL 8.0.16+ recommended (enforced CHECK constraints)
-- Review and adapt this learning scaffold with your team before submission.

CREATE DATABASE IF NOT EXISTS paws_of_haven
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE paws_of_haven;

-- Drop child tables first so this script can be rerun during development.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS treatments;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS veterinary_visits;
DROP TABLE IF EXISTS foster_assignments;
DROP TABLE IF EXISTS foster_applications;
DROP TABLE IF EXISTS foster_caregivers;
DROP TABLE IF EXISTS adoptions;
DROP TABLE IF EXISTS adoption_applications;
DROP TABLE IF EXISTS adopters;
DROP TABLE IF EXISTS rescue_records;
DROP TABLE IF EXISTS animals;
DROP TABLE IF EXISTS animal_categories;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. User accounts. Never store plaintext passwords; password_hash is for a hash.
CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  account_status ENUM('active', 'inactive', 'locked') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Role lookup table.
CREATE TABLE roles (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(40) NOT NULL UNIQUE,
  description VARCHAR(255) NULL
) ENGINE=InnoDB;

-- 3. Many-to-many user/role relationship.
CREATE TABLE user_roles (
  user_id INT UNSIGNED NOT NULL,
  role_id INT UNSIGNED NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Animal type lookup table.
CREATE TABLE animal_categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(60) NOT NULL UNIQUE,
  description VARCHAR(255) NULL
) ENGINE=InnoDB;

-- 5. Animal master records.
CREATE TABLE animals (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  breed VARCHAR(100) NULL,
  estimated_age_months SMALLINT UNSIGNED NULL,
  sex ENUM('male', 'female', 'unknown') NOT NULL DEFAULT 'unknown',
  color_markings VARCHAR(150) NULL,
  intake_date DATE NOT NULL,
  status ENUM('available', 'reserved', 'fostered', 'adopted', 'medical_hold', 'deceased') NOT NULL DEFAULT 'available',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_animals_category FOREIGN KEY (category_id) REFERENCES animal_categories(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_animals_age CHECK (estimated_age_months IS NULL OR estimated_age_months >= 0),
  INDEX idx_animals_status (status),
  INDEX idx_animals_intake_date (intake_date)
) ENGINE=InnoDB;

-- 6. Rescue/intake history. One animal may have multiple rescue events over time.
CREATE TABLE rescue_records (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  animal_id INT UNSIGNED NOT NULL,
  rescue_date DATE NOT NULL,
  rescue_location VARCHAR(180) NOT NULL,
  reported_by VARCHAR(120) NULL,
  condition_on_arrival ENUM('stable', 'injured', 'critical', 'unknown') NOT NULL DEFAULT 'unknown',
  intake_notes TEXT NULL,
  recorded_by INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rescue_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_rescue_recorded_by FOREIGN KEY (recorded_by) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_rescue_date (rescue_date)
) ENGINE=InnoDB;

-- 7. People who may adopt an animal.
CREATE TABLE adopters (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL UNIQUE,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  phone VARCHAR(30) NULL,
  address VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_adopters_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- 8. Applications to adopt a particular animal.
CREATE TABLE adoption_applications (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  adopter_id INT UNSIGNED NOT NULL,
  animal_id INT UNSIGNED NOT NULL,
  application_date DATE NOT NULL,
  status ENUM('pending', 'under_review', 'approved', 'rejected', 'withdrawn') NOT NULL DEFAULT 'pending',
  household_notes TEXT NULL,
  reviewed_by INT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_adoption_app_adopter FOREIGN KEY (adopter_id) REFERENCES adopters(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoption_app_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoption_app_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_adoption_app_status (status)
) ENGINE=InnoDB;

-- 9. Completed adoption/placement record. Each application can produce at most one adoption.
CREATE TABLE adoptions (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  application_id INT UNSIGNED NOT NULL UNIQUE,
  animal_id INT UNSIGNED NOT NULL,
  adopter_id INT UNSIGNED NOT NULL,
  adoption_date DATE NOT NULL,
  status ENUM('completed', 'returned') NOT NULL DEFAULT 'completed',
  contract_notes TEXT NULL,
  recorded_by INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_adoptions_application FOREIGN KEY (application_id) REFERENCES adoption_applications(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoptions_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoptions_adopter FOREIGN KEY (adopter_id) REFERENCES adopters(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adoptions_recorded_by FOREIGN KEY (recorded_by) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_adoptions_date (adoption_date)
) ENGINE=InnoDB;

-- 10. Approved or prospective foster caregivers.
CREATE TABLE foster_caregivers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL UNIQUE,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  phone VARCHAR(30) NULL,
  address VARCHAR(255) NULL,
  capacity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  approval_status ENUM('pending', 'approved', 'suspended', 'rejected') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_foster_caregiver_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_foster_capacity CHECK (capacity >= 0)
) ENGINE=InnoDB;

-- 11. Applications to foster an animal.
CREATE TABLE foster_applications (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  caregiver_id INT UNSIGNED NOT NULL,
  animal_id INT UNSIGNED NOT NULL,
  application_date DATE NOT NULL,
  planned_start_date DATE NULL,
  planned_end_date DATE NULL,
  status ENUM('pending', 'under_review', 'approved', 'rejected', 'withdrawn') NOT NULL DEFAULT 'pending',
  notes TEXT NULL,
  reviewed_by INT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_foster_app_caregiver FOREIGN KEY (caregiver_id) REFERENCES foster_caregivers(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_foster_app_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_foster_app_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_foster_app_dates CHECK (planned_end_date IS NULL OR planned_start_date IS NULL OR planned_end_date >= planned_start_date),
  INDEX idx_foster_app_status (status)
) ENGINE=InnoDB;

-- 12. Actual foster placements. The API business logic must prevent conflicting active placements.
CREATE TABLE foster_assignments (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  application_id INT UNSIGNED NULL UNIQUE,
  animal_id INT UNSIGNED NOT NULL,
  caregiver_id INT UNSIGNED NOT NULL,
  start_date DATE NOT NULL,
  expected_end_date DATE NULL,
  actual_end_date DATE NULL,
  status ENUM('active', 'completed', 'cancelled') NOT NULL DEFAULT 'active',
  placement_notes TEXT NULL,
  assigned_by INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_foster_assignment_application FOREIGN KEY (application_id) REFERENCES foster_applications(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_foster_assignment_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_foster_assignment_caregiver FOREIGN KEY (caregiver_id) REFERENCES foster_caregivers(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_foster_assignment_user FOREIGN KEY (assigned_by) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_foster_assignment_dates CHECK (expected_end_date IS NULL OR expected_end_date >= start_date),
  CONSTRAINT chk_foster_actual_end CHECK (actual_end_date IS NULL OR actual_end_date >= start_date),
  INDEX idx_foster_assignment_status (status),
  INDEX idx_foster_assignment_animal_status (animal_id, status),
  INDEX idx_foster_assignment_caregiver_status (caregiver_id, status)
) ENGINE=InnoDB;

-- 13. Veterinary appointments/visits. The application must ensure the selected user is a veterinarian.
CREATE TABLE veterinary_visits (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  animal_id INT UNSIGNED NOT NULL,
  veterinarian_user_id INT UNSIGNED NULL,
  visit_date DATETIME NOT NULL,
  reason VARCHAR(180) NOT NULL,
  findings TEXT NULL,
  follow_up_date DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vet_visit_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_vet_visit_veterinarian FOREIGN KEY (veterinarian_user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_vet_visit_date (visit_date),
  INDEX idx_vet_follow_up_date (follow_up_date)
) ENGINE=InnoDB;

-- 14. Medical findings and clearance. Clearance must be verified by the backend before foster placement.
CREATE TABLE medical_records (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  animal_id INT UNSIGNED NOT NULL,
  veterinary_visit_id INT UNSIGNED NULL,
  record_date DATE NOT NULL,
  diagnosis VARCHAR(180) NULL,
  medical_notes TEXT NULL,
  clearance_status ENUM('pending', 'cleared', 'not_cleared') NOT NULL DEFAULT 'pending',
  next_check_date DATE NULL,
  recorded_by INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_medical_record_animal FOREIGN KEY (animal_id) REFERENCES animals(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medical_record_visit FOREIGN KEY (veterinary_visit_id) REFERENCES veterinary_visits(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_medical_record_user FOREIGN KEY (recorded_by) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_medical_clearance (clearance_status),
  INDEX idx_medical_next_check (next_check_date)
) ENGINE=InnoDB;

-- 15. Treatments connected to medical records.
CREATE TABLE treatments (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  medical_record_id INT UNSIGNED NOT NULL,
  treatment_name VARCHAR(150) NOT NULL,
  instructions TEXT NULL,
  start_date DATE NULL,
  end_date DATE NULL,
  status ENUM('planned', 'ongoing', 'completed', 'stopped') NOT NULL DEFAULT 'planned',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_treatment_medical_record FOREIGN KEY (medical_record_id) REFERENCES medical_records(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_treatment_dates CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
  INDEX idx_treatment_status (status)
) ENGINE=InnoDB;

-- Confirm the table count after execution.
SHOW TABLES;
