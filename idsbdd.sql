-- --------------------------------------------------------
-- Hôte:                         127.0.0.1
-- Version du serveur:           10.4.32-MariaDB - mariadb.org binary distribution
-- SE du serveur:                Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Listage de la structure de la base pour idsbdd
CREATE DATABASE IF NOT EXISTS `idsbdd` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `idsbdd`;

-- Listage de la structure de table idsbdd. badges
CREATE TABLE IF NOT EXISTS `badges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `badge_id` varchar(50) NOT NULL,
  `niveau_acces` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `badge_id` (`badge_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `badges_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `utilisateurs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Listage des données de la table idsbdd.badges : ~4 rows (environ)
INSERT INTO `badges` (`id`, `user_id`, `badge_id`, `niveau_acces`) VALUES
	(26, 7, 'BADGE007', 2),
	(27, 10, 'BADGE010', 0),
	(28, 11, 'BADGE011', 1),
	(29, 12, 'BADGE012', 0);

-- Listage de la structure de table idsbdd. equipements
CREATE TABLE IF NOT EXISTS `equipements` (
  `id_equipement` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `date_installation` date DEFAULT NULL,
  PRIMARY KEY (`id_equipement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Listage des données de la table idsbdd.equipements : ~0 rows (environ)

-- Listage de la structure de table idsbdd. historique_acces
CREATE TABLE IF NOT EXISTS `historique_acces` (
  `id_acces` int(11) NOT NULL AUTO_INCREMENT,
  `id_utilisateur` int(11) DEFAULT NULL,
  `date_acces` datetime DEFAULT NULL,
  `type_acces` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id_acces`),
  KEY `id_utilisateur` (`id_utilisateur`),
  CONSTRAINT `historique_acces_fk_new` FOREIGN KEY (`id_utilisateur`) REFERENCES `utilisateurs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Listage des données de la table idsbdd.historique_acces : ~9 rows (environ)
INSERT INTO `historique_acces` (`id_acces`, `id_utilisateur`, `date_acces`, `type_acces`) VALUES
	(1, 7, '2025-04-11 11:13:16', 'Entrée'),
	(2, 7, '2025-04-11 13:13:16', 'Sortie'),
	(3, 10, '2025-04-10 11:13:16', 'Accès refusé'),
	(4, 7, '2025-04-11 13:22:51', 'Connexion'),
	(5, 7, '2025-04-11 13:27:06', 'Connexion'),
	(6, 7, '2025-04-11 13:29:59', 'Connexion'),
	(7, 7, '2025-04-11 13:34:11', 'Connexion'),
	(8, 7, '2025-04-11 13:40:44', 'Connexion'),
	(12, 7, '2025-04-11 13:52:30', 'Connexion');

-- Listage de la structure de table idsbdd. mesures
CREATE TABLE IF NOT EXISTS `mesures` (
  `id_mesure` int(11) NOT NULL AUTO_INCREMENT,
  `id_equipement` int(11) DEFAULT NULL,
  `temp` decimal(10,2) NOT NULL,
  `date_mesure` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id_mesure`),
  KEY `id_equipement` (`id_equipement`),
  CONSTRAINT `Mesures_ibfk_1` FOREIGN KEY (`id_equipement`) REFERENCES `equipements` (`id_equipement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Listage des données de la table idsbdd.mesures : ~0 rows (environ)

-- Listage de la structure de table idsbdd. sessions
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Listage des données de la table idsbdd.sessions : ~20 rows (environ)
INSERT INTO `sessions` (`id`, `token`, `created_at`, `expires_at`) VALUES
	(2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjozLCJlbWFpbCI6ImFlZ2dlYWdhZUBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDAzIiwiZXhwIjoxNzM5NDQxNDI1fQ.8lBvpHNHQOCbkXjtk0cvZFVTnSHj3ytqf3MpC6pX4-o', '2025-02-12 11:10:25', '2025-02-13 10:10:25'),
	(3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo0LCJlbWFpbCI6ImdyYWVAZ21haWwuY29tIiwiYmFkZ2VfaWQiOiJCQURHRTAwNCIsImV4cCI6MTczOTU0Mzg4MX0.WLhlaz8rOT0I3UATPCETVHnyPnmxHSSVYv9MlwHbehk', '2025-02-13 15:38:01', '2025-02-14 14:38:01'),
	(5, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMCwiZW1haWwiOiJtZWhkaS5uZXpkaXJAZ21haWwuY29tIiwiYmFkZ2VfaWQiOiJCQURHRTAxMCIsImV4cCI6MTc0MTA5NDY1NH0.yyGeT4DdM81pXx2VJ4WmAZProAabh6hZbsk0e-nqeio', '2025-03-03 14:24:14', '2025-03-04 13:24:14'),
	(7, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQyNTU5OTEwfQ.D9rGTXo3GHKemjhiS3U5gxBGeQ9EotZmBYnkY83SrTs', '2025-03-20 13:25:10', '2025-03-21 12:25:10'),
	(8, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQzMDYyODU1fQ.Qo8wtZ2rXJtxnufDWqlItLwd5aBAOwFc5dc_yTVFWNA', '2025-03-26 09:07:35', '2025-03-27 08:07:35'),
	(9, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQzMTY2NzEyfQ.Hc74sWv5_q0e1PZ-D26g3oVFoiDRZlZBaOR538QLhlE', '2025-03-27 13:58:32', '2025-03-28 12:58:32'),
	(10, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0MTE0NDc2fQ.61o1ArXTtLCkjyEVvRyv6bWxt9pzAWdFTVtEvszaoqA', '2025-04-07 14:14:36', '2025-04-08 12:14:36'),
	(11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0MTE0NDc3fQ.lPantJM7Tm0v-hqdROOOK_LsHl285w_n4XWHRNLcU50', '2025-04-07 14:14:37', '2025-04-08 12:14:37'),
	(12, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0MTE0NTc5fQ.DRQ8jcnzCGLTB3SJHR2BsR5U8mr2A4m7eZPJHoD8JCA', '2025-04-07 14:16:19', '2025-04-08 12:16:19'),
	(13, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0MTE5MzU0fQ.q0wb4vccaxRhp8ixyurnVIuqgOeQ4FRLQ2ZP2v2XMSs', '2025-04-07 15:35:54', '2025-04-08 13:35:54'),
	(14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU2NTg1fQ.VwlEPr5uVrGBPz1sVtWgzs5_00aGQnTUWrjEOurg71I', '2025-04-11 13:16:25', '2025-04-12 11:16:25'),
	(15, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU2OTcxfQ.qh9XaTJ8nBAvEQ1WMGUScNBKrM8NDY98VXyESGgNgPU', '2025-04-11 13:22:51', '2025-04-12 11:22:51'),
	(16, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU3MjI2fQ.UN_8aYgpdrtZ3WhmXG1cxAAHJ_jGhgsPydUQwlnzYb0', '2025-04-11 13:27:06', '2025-04-12 11:27:06'),
	(17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU3Mzk5fQ.oOzd5Jyv8qvI862PGAIFwhnJnBSYmznmzL3SjlYpezM', '2025-04-11 13:29:59', '2025-04-12 11:29:59'),
	(18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU3NjUxfQ.L4Ypm4Sx0OfLZhmS3hG7vyxHWDwjrb2bbLbHxKRyv9E', '2025-04-11 13:34:11', '2025-04-12 11:34:11'),
	(19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU4MDQ0fQ.r7VJDc0BVxIJaniH4pWdUErmC-2wJ5cuDsssRF959FA', '2025-04-11 13:40:44', '2025-04-12 11:40:44'),
	(20, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxNCwiZW1haWwiOiJtYXhhZWdnYUBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDE0IiwiZXhwIjoxNzQ0NDU4NTc4fQ.CbhU0KbrqUK2X-xz9dt7T4TKDLOawy9kzU1A-fWhpIo', '2025-04-11 13:49:38', '2025-04-12 11:49:38'),
	(21, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxNCwiZW1haWwiOiJtYXhhZWdnYUBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDE0IiwiZXhwIjoxNzQ0NDU4Njc2fQ.np692a4K9nYyeHG5O6PzYDZZg_bWJXJdIe9wIb6Wi30', '2025-04-11 13:51:16', '2025-04-12 11:51:16'),
	(22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxNSwiZW1haWwiOiJnYWdhQG1kci5mciIsImJhZGdlX2lkIjoiQkFER0UwMTUiLCJleHAiOjE3NDQ0NTg3MjR9.Rc2l7bjCC2yLDn1ZPrWLs_ldJG-KmkLEYEzbkS9rIz4', '2025-04-11 13:52:04', '2025-04-12 11:52:04'),
	(23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJlbWFpbCI6Ik1hdGhpZXUuYm91cmdvaW4xMkBnbWFpbC5jb20iLCJiYWRnZV9pZCI6IkJBREdFMDA3IiwiZXhwIjoxNzQ0NDU4NzUwfQ.gOwazVvGAZf-MIlYohrOq-Qx5gIUTepj0w94zISGuLw', '2025-04-11 13:52:30', '2025-04-12 11:52:30');

-- Listage de la structure de table idsbdd. utilisateurs
CREATE TABLE IF NOT EXISTS `utilisateurs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `mdp` varchar(255) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Listage des données de la table idsbdd.utilisateurs : ~4 rows (environ)
INSERT INTO `utilisateurs` (`id`, `email`, `mdp`, `nom`, `prenom`) VALUES
	(7, 'Mathieu.bourgoin12@gmail.com', 'Mimo123', 'Bourgoin', 'Mathieu'),
	(10, 'mehdi.nezdir@gmail.com', 'mdr1223', 'Nezdir', 'Mehdi'),
	(11, 'marko@gmail.com', 'mddr123', 'Marko', 'Marko'),
	(12, 'abdoulishak@gmail.com', 'Ishask436', 'Abdoul', 'Ishak');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
