-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : lun. 16 jan. 2023 à 11:24
-- Version du serveur : 5.7.36
-- Version de PHP : 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `vorpv2`
--

-- --------------------------------------------------------

--
-- Structure de la table `module_postmsg`
--

DROP TABLE IF EXISTS `module_postmsg`;
CREATE TABLE IF NOT EXISTS `module_postmsg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender` varchar(255) COLLATE latin1_general_ci NOT NULL,
  `rp_names` varchar(255) COLLATE latin1_general_ci NOT NULL,
  `sender_postbox` varchar(6) COLLATE latin1_general_ci NOT NULL,
  `postbox` varchar(255) COLLATE latin1_general_ci NOT NULL,
  `letter` mediumtext COLLATE latin1_general_ci NOT NULL,
  `subject` varchar(30) COLLATE latin1_general_ci NOT NULL,
  `read_letter` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=127 DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
