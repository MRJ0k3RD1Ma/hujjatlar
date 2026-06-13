-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 24, 2026 at 08:56 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `md_powersunbonus`
--

-- --------------------------------------------------------

--
-- Table structure for table `action_logs`
--

CREATE TABLE `action_logs` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `entity_name` varchar(255) DEFAULT NULL,
  `data` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `login` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `auth_key` varchar(32) NOT NULL,
  `role` enum('superadmin','admin') NOT NULL DEFAULT 'admin',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `force_password_change` tinyint(1) DEFAULT 0,
  `last_login_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `login`, `password_hash`, `auth_key`, `role`, `status`, `force_password_change`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'superadmin', '$2y$13$AZF0kMBcijmG2q.RlLlI8uT35Cv3aQmyCx5bRBtt7fNC4nBxB7NNm', 'aIMznkYdWiTIJJTpQC80gY-UZ_NYsgnW', 'superadmin', 'active', 0, 1776865285, 1776699068, 1776699068);

-- --------------------------------------------------------

--
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `id` int(11) NOT NULL,
  `region_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`id`, `region_id`, `title`, `status`, `created_at`, `updated_at`) VALUES
(1703202, 1703, 'Oltinko`l tumani', 'active', 1776699069, 1776699069),
(1703203, 1703, 'Andijon tumani', 'active', 1776699069, 1776699069),
(1703206, 1703, 'Baliqchi tumani', 'active', 1776699069, 1776699069),
(1703209, 1703, 'Bo`ston tumani', 'active', 1776699069, 1776699069),
(1703210, 1703, 'Buloqboshi tumani', 'active', 1776699069, 1776699069),
(1703211, 1703, 'Jalolquduq tumani', 'active', 1776699069, 1776699069),
(1703214, 1703, 'Izboskan tumani', 'active', 1776699069, 1776699069),
(1703217, 1703, 'Ulug`nor tumani', 'active', 1776699069, 1776699069),
(1703220, 1703, 'Qo`rg`ontepa tumani', 'active', 1776699069, 1776699069),
(1703224, 1703, 'Asaka tumani', 'active', 1776699069, 1776699069),
(1703227, 1703, 'Marxamat tumani', 'active', 1776699069, 1776699069),
(1703230, 1703, 'Shahrixon tumani', 'active', 1776699069, 1776699069),
(1703232, 1703, 'Paxtaobod tumani', 'active', 1776699069, 1776699069),
(1703236, 1703, 'Xo`jaobod tumani', 'active', 1776699069, 1776699069),
(1703401, 1703, 'Andijon shahri', 'active', 1776699069, 1776699069),
(1703408, 1703, 'Xonobod shahri', 'active', 1776699069, 1776699069),
(1706204, 1706, 'Olot tumani', 'active', 1776699069, 1776699069),
(1706207, 1706, 'Buxoro tumani', 'active', 1776699069, 1776699069),
(1706212, 1706, 'Vobkent tumani', 'active', 1776699069, 1776699069),
(1706215, 1706, 'G`ijduvon tumani', 'active', 1776699069, 1776699069),
(1706219, 1706, 'Kogon tumani', 'active', 1776699069, 1776699069),
(1706230, 1706, 'Qorako`l tumani', 'active', 1776699069, 1776699069),
(1706232, 1706, 'Qorovulbozor tumani', 'active', 1776699069, 1776699069),
(1706240, 1706, 'Peshku tumani', 'active', 1776699069, 1776699069),
(1706242, 1706, 'Romitan tumani', 'active', 1776699069, 1776699069),
(1706246, 1706, 'Jondor tumani', 'active', 1776699069, 1776699069),
(1706258, 1706, 'Shofirkon tumani', 'active', 1776699069, 1776699069),
(1706401, 1706, 'Buxoro shahri', 'active', 1776699069, 1776699069),
(1706403, 1706, 'Kogon shahri', 'active', 1776699069, 1776699069),
(1708201, 1708, 'Arnasoy tumani', 'active', 1776699069, 1776699069),
(1708204, 1708, 'Baxmal tumani', 'active', 1776699069, 1776699069),
(1708209, 1708, 'G`allaorol tumani', 'active', 1776699069, 1776699069),
(1708212, 1708, 'Sharof Rashidov tumani', 'active', 1776699069, 1776699069),
(1708215, 1708, 'Do`stlik tumani', 'active', 1776699069, 1776699069),
(1708218, 1708, 'Zomin tumani', 'active', 1776699069, 1776699069),
(1708220, 1708, 'Zarbdor tumani', 'active', 1776699069, 1776699069),
(1708223, 1708, 'Mirzacho`l tumani', 'active', 1776699069, 1776699069),
(1708225, 1708, 'Zafarobod tumani', 'active', 1776699069, 1776699069),
(1708228, 1708, 'Paxtakor tumani', 'active', 1776699069, 1776699069),
(1708235, 1708, 'Forish tumani', 'active', 1776699069, 1776699069),
(1708237, 1708, 'Yangiobod tumani', 'active', 1776699069, 1776699069),
(1708401, 1708, 'Jizzax shahri', 'active', 1776699069, 1776699069),
(1710207, 1710, 'G`uzor tumani', 'active', 1776699069, 1776699069),
(1710212, 1710, 'Dehqonobod tumani', 'active', 1776699069, 1776699069),
(1710220, 1710, 'Qamashi tumani', 'active', 1776699069, 1776699069),
(1710224, 1710, 'Qarshi tumani', 'active', 1776699069, 1776699069),
(1710229, 1710, 'Koson tumani', 'active', 1776699069, 1776699069),
(1710232, 1710, 'Kitob tumani', 'active', 1776699069, 1776699069),
(1710233, 1710, 'Mirishkor tumani', 'active', 1776699069, 1776699069),
(1710234, 1710, 'Muborak tumani', 'active', 1776699069, 1776699069),
(1710235, 1710, 'Nishon tumani', 'active', 1776699069, 1776699069),
(1710237, 1710, 'Kasbi tumani', 'active', 1776699069, 1776699069),
(1710240, 1710, 'Ko\'kdala tumani', 'active', 1776699069, 1776699069),
(1710242, 1710, 'Chiroqchi tumani', 'active', 1776699069, 1776699069),
(1710245, 1710, 'Shahrisabz tumani', 'active', 1776699069, 1776699069),
(1710250, 1710, 'Yakkabog` tumani', 'active', 1776699069, 1776699069),
(1710401, 1710, 'Qarshi shahri', 'active', 1776699069, 1776699069),
(1710405, 1710, 'Shahrisabz shahri', 'active', 1776699069, 1776699069),
(1712211, 1712, 'Konimex tumani', 'active', 1776699069, 1776699069),
(1712216, 1712, 'Qiziltepa tumani', 'active', 1776699069, 1776699069),
(1712230, 1712, 'Navbahor tumani', 'active', 1776699069, 1776699069),
(1712234, 1712, 'Karmana tumani', 'active', 1776699069, 1776699069),
(1712238, 1712, 'Nurota tumani', 'active', 1776699069, 1776699069),
(1712244, 1712, 'Tomdi tumani', 'active', 1776699069, 1776699069),
(1712248, 1712, 'Uchquduq tumani', 'active', 1776699069, 1776699069),
(1712251, 1712, 'Xatirchi tumani', 'active', 1776699069, 1776699069),
(1712401, 1712, 'Navoiy shahri', 'active', 1776699069, 1776699069),
(1712408, 1712, 'Zarafshon shahri', 'active', 1776699069, 1776699069),
(1712412, 1712, 'G\'ozg\'on shahri', 'active', 1776699069, 1776699069),
(1714204, 1714, 'Mingbuloq tumani', 'active', 1776699069, 1776699069),
(1714207, 1714, 'Kosonsoy tumani', 'active', 1776699069, 1776699069),
(1714212, 1714, 'Namangan tumani', 'active', 1776699069, 1776699069),
(1714216, 1714, 'Norin tumani', 'active', 1776699069, 1776699069),
(1714219, 1714, 'Pop tumani', 'active', 1776699069, 1776699069),
(1714224, 1714, 'To`raqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1714229, 1714, 'Uychi tumani', 'active', 1776699069, 1776699069),
(1714234, 1714, 'Uchqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1714236, 1714, 'Chortoq tumani', 'active', 1776699069, 1776699069),
(1714237, 1714, 'Chust tumani', 'active', 1776699069, 1776699069),
(1714242, 1714, 'Yangiqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1714401, 1714, 'Namangan shahri', 'active', 1776699069, 1776699069),
(1718203, 1718, 'Oqdaryo tumani', 'active', 1776699069, 1776699069),
(1718206, 1718, 'Bulung`ur tumani', 'active', 1776699069, 1776699069),
(1718209, 1718, 'Jomboy tumani', 'active', 1776699069, 1776699069),
(1718212, 1718, 'Ishtixon tumani', 'active', 1776699069, 1776699069),
(1718215, 1718, 'Kattaqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1718216, 1718, 'Qo`shrabot tumani', 'active', 1776699069, 1776699069),
(1718218, 1718, 'Narpay tumani', 'active', 1776699069, 1776699069),
(1718224, 1718, 'Payariq tumani', 'active', 1776699069, 1776699069),
(1718227, 1718, 'Pastdarg`om tumani', 'active', 1776699069, 1776699069),
(1718230, 1718, 'Paxtachi tumani', 'active', 1776699069, 1776699069),
(1718233, 1718, 'Samarqand tumani', 'active', 1776699069, 1776699069),
(1718235, 1718, 'Nurobod tumani', 'active', 1776699069, 1776699069),
(1718236, 1718, 'Urgut tumani', 'active', 1776699069, 1776699069),
(1718238, 1718, 'Tayloq tumani', 'active', 1776699069, 1776699069),
(1718401, 1718, 'Samarqand shahri', 'active', 1776699069, 1776699069),
(1718406, 1718, 'Kattaqo`rg`on shahri', 'active', 1776699069, 1776699069),
(1722201, 1722, 'Oltinsoy tumani', 'active', 1776699069, 1776699069),
(1722202, 1722, 'Angor tumani', 'active', 1776699069, 1776699069),
(1722203, 1722, 'Bandixon tumani', 'active', 1776699069, 1776699069),
(1722204, 1722, 'Boysun tumani', 'active', 1776699069, 1776699069),
(1722207, 1722, 'Muzrabot tumani', 'active', 1776699069, 1776699069),
(1722210, 1722, 'Denov tumani', 'active', 1776699069, 1776699069),
(1722212, 1722, 'Jarqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1722214, 1722, 'Qumqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1722215, 1722, 'Qiziriq tumani', 'active', 1776699069, 1776699069),
(1722217, 1722, 'Sariosiyo tumani', 'active', 1776699069, 1776699069),
(1722220, 1722, 'Termiz tumani', 'active', 1776699069, 1776699069),
(1722221, 1722, 'Uzun tumani', 'active', 1776699069, 1776699069),
(1722223, 1722, 'Sherobod tumani', 'active', 1776699069, 1776699069),
(1722226, 1722, 'Sho`rchi tumani', 'active', 1776699069, 1776699069),
(1722401, 1722, 'Termiz shahri', 'active', 1776699069, 1776699069),
(1724206, 1724, 'Oqoltin tumani', 'active', 1776699069, 1776699069),
(1724212, 1724, 'Boyovut tumani', 'active', 1776699069, 1776699069),
(1724216, 1724, 'Sayxunobod tumani', 'active', 1776699069, 1776699069),
(1724220, 1724, 'Guliston tumani', 'active', 1776699069, 1776699069),
(1724226, 1724, 'Sardoba tumani', 'active', 1776699069, 1776699069),
(1724228, 1724, 'Mirzaobod tumani', 'active', 1776699069, 1776699069),
(1724231, 1724, 'Sirdaryo tumani', 'active', 1776699069, 1776699069),
(1724235, 1724, 'Xovos tumani', 'active', 1776699069, 1776699069),
(1724401, 1724, 'Guliston shahri', 'active', 1776699069, 1776699069),
(1724410, 1724, 'Shirin shahri', 'active', 1776699069, 1776699069),
(1724413, 1724, 'Yangiyer shahri', 'active', 1776699069, 1776699069),
(1726262, 1726, 'Uchtepa tumani', 'active', 1776699069, 1776699069),
(1726264, 1726, 'Bektemir tumani', 'active', 1776699069, 1776699069),
(1726266, 1726, 'Yunusobod tumani', 'active', 1776699069, 1776699069),
(1726269, 1726, 'Mirzo Ulug\'bek tumani', 'active', 1776699069, 1776699069),
(1726273, 1726, 'Mirobod tumani', 'active', 1776699069, 1776699069),
(1726277, 1726, 'Shayxontohur tumani', 'active', 1776699069, 1776699069),
(1726280, 1726, 'Olmazor tumani', 'active', 1776699069, 1776699069),
(1726283, 1726, 'Sergeli tumani', 'active', 1776699069, 1776699069),
(1726287, 1726, 'Yakkasaroy tumani', 'active', 1776699069, 1776699069),
(1726290, 1726, 'Yashnobod tumani', 'active', 1776699069, 1776699069),
(1726292, 1726, 'Yangihayot tumani', 'active', 1776699069, 1776699069),
(1726294, 1726, 'Chilonzor tumani', 'active', 1776699069, 1776699069),
(1727206, 1727, 'Oqqo`rg`on tumani', 'active', 1776699069, 1776699069),
(1727212, 1727, 'Ohangaron tumani', 'active', 1776699069, 1776699069),
(1727220, 1727, 'Bekobod tumani', 'active', 1776699069, 1776699069),
(1727224, 1727, 'Bo`stonliq tumani', 'active', 1776699069, 1776699069),
(1727228, 1727, 'Bo`ka tumani', 'active', 1776699069, 1776699069),
(1727233, 1727, 'Quyi Chirchiq tumani', 'active', 1776699069, 1776699069),
(1727237, 1727, 'Zangiota tumani', 'active', 1776699069, 1776699069),
(1727239, 1727, 'Yuqori Chirchiq tumani', 'active', 1776699069, 1776699069),
(1727248, 1727, 'Qibray tumani', 'active', 1776699069, 1776699069),
(1727249, 1727, 'Parkent tumani', 'active', 1776699069, 1776699069),
(1727250, 1727, 'Pskent tumani', 'active', 1776699069, 1776699069),
(1727253, 1727, 'O`rta Chirchiq tumani', 'active', 1776699069, 1776699069),
(1727256, 1727, 'Chinoz tumani', 'active', 1776699069, 1776699069),
(1727259, 1727, 'Yangiyo`l tumani', 'active', 1776699069, 1776699069),
(1727265, 1727, 'Toshkent tumani', 'active', 1776699069, 1776699069),
(1727401, 1727, 'Nurafshon shahri', 'active', 1776699069, 1776699069),
(1727404, 1727, 'Olmaliq shahri', 'active', 1776699069, 1776699069),
(1727407, 1727, 'Angren shahri', 'active', 1776699069, 1776699069),
(1727413, 1727, 'Bekobod shahri', 'active', 1776699069, 1776699069),
(1727415, 1727, 'Ohangaron shahri', 'active', 1776699069, 1776699069),
(1727419, 1727, 'Chirchiq shahri', 'active', 1776699069, 1776699069),
(1727424, 1727, 'Yangiyo`l shahri', 'active', 1776699069, 1776699069),
(1730203, 1730, 'Oltiariq tumani', 'active', 1776699069, 1776699069),
(1730206, 1730, 'Qo`shtepa tumani', 'active', 1776699069, 1776699069),
(1730209, 1730, 'Bog`dod tumani', 'active', 1776699069, 1776699069),
(1730212, 1730, 'Buvayda tumani', 'active', 1776699069, 1776699069),
(1730215, 1730, 'Beshariq tumani', 'active', 1776699069, 1776699069),
(1730218, 1730, 'Quva tumani', 'active', 1776699069, 1776699069),
(1730221, 1730, 'Uchko`prik tumani', 'active', 1776699069, 1776699069),
(1730224, 1730, 'Rishton tumani', 'active', 1776699069, 1776699069),
(1730226, 1730, 'So`x tumani', 'active', 1776699069, 1776699069),
(1730227, 1730, 'Toshloq tumani', 'active', 1776699069, 1776699069),
(1730230, 1730, 'O`zbekiston tumani', 'active', 1776699069, 1776699069),
(1730233, 1730, 'Farg`ona tumani', 'active', 1776699069, 1776699069),
(1730236, 1730, 'Dang`ara tumani', 'active', 1776699069, 1776699069),
(1730238, 1730, 'Furqat tumani', 'active', 1776699069, 1776699069),
(1730242, 1730, 'Yozyovon tumani', 'active', 1776699069, 1776699069),
(1730401, 1730, 'Farg`ona shahri', 'active', 1776699069, 1776699069),
(1730405, 1730, 'Qo`qon shahri', 'active', 1776699069, 1776699069),
(1730408, 1730, 'Quvasoy shahri', 'active', 1776699069, 1776699069),
(1730412, 1730, 'Marg`ilon shahri', 'active', 1776699069, 1776699069),
(1733204, 1733, 'Bog`ot tumani', 'active', 1776699069, 1776699069),
(1733208, 1733, 'Gurlan tumani', 'active', 1776699069, 1776699069),
(1733212, 1733, 'Qo`shko`pir tumani', 'active', 1776699069, 1776699069),
(1733217, 1733, 'Urganch tumani', 'active', 1776699069, 1776699069),
(1733220, 1733, 'Xazorasp tumani', 'active', 1776699069, 1776699069),
(1733221, 1733, 'Tuproqqal\'a tumani', 'active', 1776699069, 1776699069),
(1733223, 1733, 'Xonqa tumani', 'active', 1776699069, 1776699069),
(1733226, 1733, 'Xiva tumani', 'active', 1776699069, 1776699069),
(1733230, 1733, 'Shovot tumani', 'active', 1776699069, 1776699069),
(1733233, 1733, 'Yangiariq tumani', 'active', 1776699069, 1776699069),
(1733236, 1733, 'Yangibozor tumani', 'active', 1776699069, 1776699069),
(1733401, 1733, 'Urganch shahri', 'active', 1776699069, 1776699069),
(1733406, 1733, 'Xiva shahri', 'active', 1776699069, 1776699069),
(1735204, 1735, 'Amudaryo tumani', 'active', 1776699069, 1776699069),
(1735207, 1735, 'Beruniy tumani', 'active', 1776699069, 1776699069),
(1735209, 1735, 'Bo\'zatov tumani', 'active', 1776699069, 1776699069),
(1735211, 1735, 'Qorao`zak tumani', 'active', 1776699069, 1776699069),
(1735212, 1735, 'Kegeyli tumani', 'active', 1776699069, 1776699069),
(1735215, 1735, 'Qo`ng`irot tumani', 'active', 1776699069, 1776699069),
(1735218, 1735, 'Qanliko`l tumani', 'active', 1776699069, 1776699069),
(1735222, 1735, 'Mo`ynoq tumani', 'active', 1776699069, 1776699069),
(1735225, 1735, 'Nukus tumani', 'active', 1776699069, 1776699069),
(1735228, 1735, 'Taxiatosh tumani', 'active', 1776699069, 1776699069),
(1735230, 1735, 'Taxtako`pir tumani', 'active', 1776699069, 1776699069),
(1735233, 1735, 'To`rtko`l tumani', 'active', 1776699069, 1776699069),
(1735236, 1735, 'Xo`jayli tumani', 'active', 1776699069, 1776699069),
(1735240, 1735, 'Chimboy tumani', 'active', 1776699069, 1776699069),
(1735243, 1735, 'Shumanay tumani', 'active', 1776699069, 1776699069),
(1735250, 1735, 'Ellikqala tumani', 'active', 1776699069, 1776699069),
(1735401, 1735, 'Nukus shahri', 'active', 1776699069, 1776699069),
(1714401365, 1714, 'Davlatobod tumani', 'active', 1776699069, 1776699069),
(1714401367, 1714, 'Yangi Namangan tumani', 'active', 1776699069, 1776699069);

-- --------------------------------------------------------

--
-- Table structure for table `installations`
--

CREATE TABLE `installations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `inverter_id` int(11) NOT NULL,
  `location_lat` decimal(10,7) DEFAULT NULL,
  `location_lng` decimal(10,7) DEFAULT NULL,
  `address` text NOT NULL,
  `object_type` enum('house','factory','office','other') NOT NULL DEFAULT 'house',
  `kw` decimal(10,2) DEFAULT NULL,
  `inverter_count` int(11) NOT NULL DEFAULT 1,
  `panel_type_id` int(11) DEFAULT NULL,
  `panel_count` int(11) DEFAULT NULL,
  `total_kw` decimal(10,2) DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `points_per_unit_snapshot` int(11) NOT NULL,
  `base_points` int(11) NOT NULL,
  `material_bonus_points` int(11) NOT NULL DEFAULT 0,
  `total_points` int(11) NOT NULL,
  `point_value_snapshot` decimal(15,2) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `extra_materials_note` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `reject_reason` text DEFAULT NULL,
  `video_url` varchar(500) DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` int(11) DEFAULT NULL,
  `rejected_by` int(11) DEFAULT NULL,
  `rejected_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `installations`
--

INSERT INTO `installations` (`id`, `user_id`, `inverter_id`, `location_lat`, `location_lng`, `address`, `object_type`, `kw`, `inverter_count`, `panel_type_id`, `panel_count`, `total_kw`, `serial_number`, `points_per_unit_snapshot`, `base_points`, `material_bonus_points`, `total_points`, `point_value_snapshot`, `total_amount`, `paid_amount`, `extra_materials_note`, `notes`, `status`, `reject_reason`, `video_url`, `version`, `approved_by`, `approved_at`, `rejected_by`, `rejected_at`, `created_at`, `updated_at`) VALUES
(1, 1, 9, NULL, NULL, 'Xorazm viloyati, Urganch shahri, asdfsd sdfsdf', 'house', NULL, 1, NULL, NULL, NULL, NULL, 160, 160, 0, 160, 5000.00, 800000.00, 0.00, NULL, NULL, 'rejected', 'Takroriy ariza', 'tg_file_id:BAACAgIAAxkBAAOmaeZIFJ4DENQM-V1eCvLfHK1kpiYAAsWcAAK5JzBLvER9u7G6Efc7BA', 2, NULL, NULL, 1, 1776706970, 1776699446, 1776706970),
(3, 1, 9, NULL, NULL, 'Xorazm viloyati, Urganch shahri, 1212', 'house', NULL, 33, NULL, NULL, NULL, NULL, 160, 5280, 0, 5280, 5000.00, 26400000.00, 0.00, NULL, NULL, 'approved', NULL, 'tg_file_id:BAACAgIAAxkBAAPkaeZkAAEItA2_kYcNvCqafEDtrLoRAAK8ngACuScwS2LtQdRHIm5KOwQ', 4, 1, 1776709393, NULL, NULL, 1776706734, 1776709393),
(4, 1, 4, 67.1333640, 82.5278430, 'Xorazm viloyati, Urganch shahri, esdfs', 'house', NULL, 2, NULL, NULL, NULL, 'asda123123as', 150, 300, 0, 300, 5000.00, 1500000.00, 0.00, NULL, 'izoh', 'pending', NULL, 'tg_file_id:BAACAgIAAxkBAAIBmGnnJAABVWNZhXZqpMmux4J6U1fkUwAC2p4AArknOEu98ofEfvvF4DsE', 1, NULL, NULL, NULL, NULL, 1776755725, 1776755725),
(6, 1, 5, 68.8823930, 81.0000450, 'Xorazm viloyati, Urganch shahri, sdfsdf', 'factory', NULL, 2, 3, 2, 6.00, 'fdfg dfgdfg', 250, 500, 40, 540, 5000.00, 2700000.00, 0.00, NULL, NULL, 'pending', NULL, 'tg_file_id:BAACAgIAAxkBAAIB6WnnO2deOMQQmiRwvJhMKjipDuUlAAK0nwACuSc4S5K83_SlXKgUOwQ', 1, NULL, NULL, NULL, NULL, 1776761708, 1776761708),
(7, 2, 6, 41.5627120, 60.6309590, 'Xorazm viloyati, Shovot tumani, 34uy', 'house', NULL, 2, 2, 34, 10.00, 'SN-asaok\'okwoepk', 500, 1000, 510, 1510, 5000.00, 7550000.00, 0.00, NULL, 'Qoshimcha izoh yozim', 'approved', NULL, 'tg_file_id:BAACAgIAAxkBAAICD2nnfLpc4rWSNYZkFnw0xLr_GVlSAALxkgACfGdAS7A2-mq7wj9SOwQ', 2, 1, 1776779965, NULL, NULL, 1776778455, 1776779965),
(8, 2, 7, 41.5629030, 60.6311650, 'Xorazm viloyati, Xiva shahri, Voha 2', 'office', NULL, 2, 2, 20, 30.00, 'SN-56688554664', 130, 260, 300, 560, 5000.00, 2800000.00, 0.00, NULL, 'Subsidiya', 'pending', NULL, 'tg_file_id:BAACAgIAAxkBAAICYWnrEf4VnINZgJZgT42DRIHgAxnzAAJ6nwACRyRYS77vLBqbOG7pOwQ', 1, NULL, NULL, NULL, NULL, 1777013268, 1777013268);

-- --------------------------------------------------------

--
-- Table structure for table `installation_materials`
--

CREATE TABLE `installation_materials` (
  `id` int(11) NOT NULL,
  `installation_id` int(11) NOT NULL,
  `material_id` int(11) NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 1.00,
  `bonus_points` int(11) NOT NULL DEFAULT 0,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `installation_materials`
--

INSERT INTO `installation_materials` (`id`, `installation_id`, `material_id`, `quantity`, `bonus_points`, `created_at`, `updated_at`) VALUES
(1, 3, 1, 1.00, 0, 1776706734, 1776706734),
(2, 4, 1, 1.00, 0, 1776755725, 1776755725),
(4, 6, 1, 2.00, 0, 1776761708, 1776761708),
(5, 8, 1, 2.00, 0, 1777013268, 1777013268);

-- --------------------------------------------------------

--
-- Table structure for table `installation_photos`
--

CREATE TABLE `installation_photos` (
  `id` int(11) NOT NULL,
  `installation_id` int(11) NOT NULL,
  `photo_url` varchar(500) NOT NULL,
  `photo_type` enum('inverter_close','installed_view','cable_connection','other') DEFAULT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `installation_photos`
--

INSERT INTO `installation_photos` (`id`, `installation_id`, `photo_url`, `photo_type`, `created_at`) VALUES
(1, 1, 'tg_file_id:AgACAgIAAxkBAAN3aeZE3P2K0-6aWLNqMAwWj0iAY-sAAooXaxu5JzBLts0qvJFxBwsBAAMCAAN5AAM7BA', 'other', 1776699446),
(2, 1, 'tg_file_id:AgACAgIAAxkBAAN5aeZE372FP9F_80PSOLqU4mbUtf0AAosXaxu5JzBLfKkQ50jqyesBAAMCAAN5AAM7BA', 'other', 1776699446),
(3, 1, 'tg_file_id:AgACAgIAAxkBAAN7aeZE5UKQaYkUhXn5jsHtBcwOf-MAAowXaxu5JzBLynDr-bGsGxgBAAMCAAN5AAM7BA', 'other', 1776699446),
(4, 1, 'tg_file_id:AgACAgIAAxkBAAN9aeZE6yqmRRZPosGMOlzWxSRM_icAAo0Xaxu5JzBLyaiuz3KoHEsBAAMCAAN5AAM7BA', 'other', 1776699446),
(5, 3, 'tg_file_id:AgACAgIAAxkBAAPZaeZiv9QJqW2hD0NT5cL5Yew17vwAArkYaxu5JzBL593wSnBJbuYBAAMCAAN5AAM7BA', 'other', 1776706734),
(6, 3, 'tg_file_id:AgACAgIAAxkBAAPaaeZiv7ZrIW3tXn3dZeg8QfVWbLAAAroYaxu5JzBLVfUFnp0AAYX-AQADAgADeQADOwQ', 'other', 1776706734),
(7, 3, 'tg_file_id:AgACAgIAAxkBAAPbaeZiv3ZFl3uiYZIsAS6ciMdl7s8AArgYaxu5JzBLc7JmQLxox8MBAAMCAAN5AAM7BA', 'other', 1776706734),
(8, 3, 'tg_file_id:AgACAgIAAxkBAAPaaeZiv7ZrIW3tXn3dZeg8QfVWbLAAAroYaxu5JzBLVfUFnp0AAYX-AQADAgADeQADOwQ', 'other', 1776706734),
(9, 4, 'tg_file_id:AgACAgIAAxkBAAIBjWnnI-eT_cHAYwxKKUmaJRh1AtT3AAIiFWsbuSc4S6Xg0GKZ4LaCAQADAgADeQADOwQ', 'other', 1776755725),
(10, 4, 'tg_file_id:AgACAgIAAxkBAAIBjmnnI-fyMxDnXGzq6xtDklpzR9mnAAIjFWsbuSc4SwHfq3jwV0mYAQADAgADeQADOwQ', 'other', 1776755725),
(11, 4, 'tg_file_id:AgACAgIAAxkBAAIBj2nnI-eGAfRHYKNERsCyFSO8zBTGAAIkFWsbuSc4SzZobOuyg0ONAQADAgADeQADOwQ', 'other', 1776755725),
(12, 4, 'tg_file_id:AgACAgIAAxkBAAIBjWnnI-eT_cHAYwxKKUmaJRh1AtT3AAIiFWsbuSc4S6Xg0GKZ4LaCAQADAgADeQADOwQ', 'other', 1776755725),
(13, 4, 'tg_file_id:AgACAgIAAxkBAAIBj2nnI-eGAfRHYKNERsCyFSO8zBTGAAIkFWsbuSc4SzZobOuyg0ONAQADAgADeQADOwQ', 'other', 1776755725),
(19, 6, 'tg_file_id:AgACAgIAAxkBAAIBjWnnI-eT_cHAYwxKKUmaJRh1AtT3AAIiFWsbuSc4S6Xg0GKZ4LaCAQADAgADeQADOwQ', 'other', 1776761708),
(20, 6, 'tg_file_id:AgACAgIAAxkBAAIBjmnnI-fyMxDnXGzq6xtDklpzR9mnAAIjFWsbuSc4SwHfq3jwV0mYAQADAgADeQADOwQ', 'other', 1776761708),
(21, 6, 'tg_file_id:AgACAgIAAxkBAAIBj2nnI-eGAfRHYKNERsCyFSO8zBTGAAIkFWsbuSc4SzZobOuyg0ONAQADAgADeQADOwQ', 'other', 1776761708),
(22, 6, 'tg_file_id:AgACAgIAAxkBAAIBjWnnI-eT_cHAYwxKKUmaJRh1AtT3AAIiFWsbuSc4S6Xg0GKZ4LaCAQADAgADeQADOwQ', 'other', 1776761708),
(23, 6, 'tg_file_id:AgACAgIAAxkBAAIBj2nnI-eGAfRHYKNERsCyFSO8zBTGAAIkFWsbuSc4SzZobOuyg0ONAQADAgADeQADOwQ', 'other', 1776761708),
(24, 7, 'tg_file_id:AgACAgIAAxkBAAICCGnnfFhRGxHTeFtFdxGZPurh9F6cAAIdGWsbfGdAS5PgryJ8antsAQADAgADeQADOwQ', 'other', 1776778455),
(25, 7, 'tg_file_id:AgACAgIAAxkBAAICCGnnfFhRGxHTeFtFdxGZPurh9F6cAAIdGWsbfGdAS5PgryJ8antsAQADAgADeQADOwQ', 'other', 1776778455),
(26, 7, 'tg_file_id:AgACAgIAAxkBAAICCGnnfFhRGxHTeFtFdxGZPurh9F6cAAIdGWsbfGdAS5PgryJ8antsAQADAgADeQADOwQ', 'other', 1776778455),
(27, 8, 'tg_file_id:AgACAgIAAxkBAAICWmnrEc8ilw97tvHeGjstcdQqCF4QAAINE2sbRyRYS_ffCLBtxuVQAQADAgADdwADOwQ', 'other', 1777013268),
(28, 8, 'tg_file_id:AgACAgIAAxkBAAICXGnrEdewsKggognW-UC4YSIlxLxtAAIOE2sbRyRYS793-Sje8itrAQADAgADeAADOwQ', 'other', 1777013268),
(29, 8, 'tg_file_id:AgACAgIAAxkBAAICXmnrEdy3UnsvaHDXQiTjWbzhn9skAAIPE2sbRyRYS149ef4Ho_yxAQADAgADdwADOwQ', 'other', 1777013268);

-- --------------------------------------------------------

--
-- Table structure for table `installation_status_history`
--

CREATE TABLE `installation_status_history` (
  `id` int(11) NOT NULL,
  `installation_id` int(11) NOT NULL,
  `from_status` varchar(20) DEFAULT NULL,
  `to_status` varchar(20) NOT NULL,
  `comment` text DEFAULT NULL,
  `changed_by` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inverters`
--

CREATE TABLE `inverters` (
  `id` int(11) NOT NULL,
  `model` varchar(255) NOT NULL,
  `manufacturer` varchar(255) DEFAULT NULL,
  `power_kw` decimal(10,2) DEFAULT NULL,
  `points_per_unit` int(11) NOT NULL DEFAULT 1,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inverters`
--

INSERT INTO `inverters` (`id`, `model`, `manufacturer`, `power_kw`, `points_per_unit`, `status`, `created_at`, `updated_at`) VALUES
(1, 'SMA Sunny Boy 3.0', 'SMA', 3.00, 150, 'active', 1776699069, 1776699069),
(2, 'SMA Sunny Boy 5.0', 'SMA', 5.00, 250, 'active', 1776699069, 1776699069),
(3, 'SMA Sunny Boy 10.0', 'SMA', 10.00, 500, 'active', 1776699069, 1776699069),
(4, 'Huawei SUN2000-3KTL', 'Huawei', 3.00, 150, 'active', 1776699069, 1776699069),
(5, 'Huawei SUN2000-5KTL', 'Huawei', 5.00, 250, 'active', 1776699069, 1776699069),
(6, 'Huawei SUN2000-10KTL', 'Huawei', 10.00, 500, 'active', 1776699069, 1776699069),
(7, 'Growatt 3000TL', 'Growatt', 3.00, 130, 'active', 1776699069, 1776699069),
(8, 'Growatt 5000TL', 'Growatt', 5.00, 220, 'active', 1776699069, 1776699069),
(9, 'Fronius Primo 3.0', 'Fronius', 3.00, 160, 'active', 1776699069, 1776699069),
(10, 'Fronius Primo 5.0', 'Fronius', 5.00, 260, 'active', 1776699069, 1776699069);

-- --------------------------------------------------------

--
-- Table structure for table `materials`
--

CREATE TABLE `materials` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `unit` varchar(50) NOT NULL DEFAULT 'dona',
  `bonus_points` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `materials`
--

INSERT INTO `materials` (`id`, `name`, `unit`, `bonus_points`, `status`, `created_at`, `updated_at`) VALUES
(1, 'qo`shimcha material', 'piece', 0, 'active', 1776700832, 1776700832);

-- --------------------------------------------------------

--
-- Table structure for table `migration`
--

CREATE TABLE `migration` (
  `version` varchar(180) NOT NULL,
  `apply_time` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `migration`
--

INSERT INTO `migration` (`version`, `apply_time`) VALUES
('m000000_000000_base', 1776699067),
('m260420_000001_master_migration', 1776699069),
('m260420_000002_fix_installation_photos_table', 1776699069),
('m260421_000001_add_serial_number_to_installations', 1776755272),
('m260421_000002_add_panel_system_to_installations', 1776759109);

-- --------------------------------------------------------

--
-- Table structure for table `panel_types`
--

CREATE TABLE `panel_types` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `panel_types`
--

INSERT INTO `panel_types` (`id`, `name`, `points`, `status`, `created_at`, `updated_at`) VALUES
(1, 'JINKO', 10, 'active', 1776760017, 1776760017),
(2, 'LONGI', 15, 'active', 1776760028, 1776760028),
(3, 'ERA', 20, 'active', 1776760037, 1776760037);

-- --------------------------------------------------------

--
-- Table structure for table `regions`
--

CREATE TABLE `regions` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `regions`
--

INSERT INTO `regions` (`id`, `title`, `status`, `created_at`, `updated_at`) VALUES
(1703, 'Andijon viloyati', 'active', 1776699069, 1776699069),
(1706, 'Buxoro viloyati', 'active', 1776699069, 1776699069),
(1708, 'Jizzax viloyati', 'active', 1776699069, 1776699069),
(1710, 'Qashqadaryo viloyati', 'active', 1776699069, 1776699069),
(1712, 'Navoiy viloyati', 'active', 1776699069, 1776699069),
(1714, 'Namangan viloyati', 'active', 1776699069, 1776699069),
(1718, 'Samarqand viloyati', 'active', 1776699069, 1776699069),
(1722, 'Surxondaryo viloyati', 'active', 1776699069, 1776699069),
(1724, 'Sirdaryo viloyati', 'active', 1776699069, 1776699069),
(1726, 'Toshkent shahri', 'active', 1776699069, 1776699069),
(1727, 'Toshkent viloyati', 'active', 1776699069, 1776699069),
(1730, 'Farg`ona viloyati', 'active', 1776699069, 1776699069),
(1733, 'Xorazm viloyati', 'active', 1776699069, 1776699069),
(1735, 'Qoraqalpog`iston Respublikasi', 'active', 1776699069, 1776699069);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `key` varchar(100) NOT NULL,
  `value` text NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `key`, `value`, `description`, `updated_at`) VALUES
(1, 'point_value', '5000', '1 ball qiymati (so\'mda)', 1776699068),
(2, 'min_kw', '1', 'Minimal o\'rnatish quvvati (kW)', 1776699068),
(3, 'max_kw', '1000', 'Maksimal o\'rnatish quvvati (kW)', 1776699068),
(4, 'max_daily_apps', '10', 'Kunlik maksimal ariza soni', 1776699068),
(5, 'min_withdrawal_som', '100000', 'Minimal pul olish miqdori (so\'mda)', 1776699068),
(6, 'pin_length', '4', 'PIN kod uzunligi', 1776699068),
(7, 'pin_max_attempts', '3', 'Maksimal PIN urinish soni', 1776699068),
(8, 'pin_lockout_minutes', '30', 'PIN qulflanish davomiyligi (daqiqada)', 1776699068);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `telegram_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `customer_type` enum('individual','legal','sole_proprietor') NOT NULL DEFAULT 'individual',
  `legal_name` varchar(255) DEFAULT NULL,
  `region_id` int(11) NOT NULL,
  `district_id` int(11) NOT NULL,
  `status` enum('active','blocked') NOT NULL DEFAULT 'active',
  `block_reason` text DEFAULT NULL,
  `pin_hash` varchar(255) DEFAULT NULL,
  `pin_set_at` int(11) DEFAULT NULL,
  `pin_attempts` int(11) NOT NULL DEFAULT 0,
  `pin_locked_until` int(11) DEFAULT NULL,
  `last_active_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `telegram_id`, `name`, `phone`, `customer_type`, `legal_name`, `region_id`, `district_id`, `status`, `block_reason`, `pin_hash`, `pin_set_at`, `pin_attempts`, `pin_locked_until`, `last_active_at`, `created_at`, `updated_at`) VALUES
(1, 86419074, 'Dilmurod', '+998999670395', 'individual', NULL, 1733, 1733401, 'active', NULL, '$2y$13$f.skr9aZsuS27.8YdaATYelbqXvALxap5TLV1yFJPzYlantOhW4mK', 1776707462, 0, NULL, NULL, 1776699101, 1776707462),
(2, 236355688, 'Hakimov Sanjar', '+998914375838', 'individual', NULL, 1733, 1733401, 'active', NULL, '$2y$13$PID0ca7C/IFh5fd7PAPVJ.HEzUI6BowU1siOdNmeKvgZ3F6GIzbr6', 1776780079, 0, NULL, NULL, 1776712019, 1776780079);

-- --------------------------------------------------------

--
-- Table structure for table `withdrawal_requests`
--

CREATE TABLE `withdrawal_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `points_amount` int(11) NOT NULL,
  `amount_som` decimal(15,2) NOT NULL,
  `point_value_at_request` decimal(15,2) NOT NULL,
  `card_number_encrypted` varchar(500) NOT NULL,
  `card_masked` varchar(30) NOT NULL,
  `card_holder_name` varchar(255) NOT NULL,
  `card_type` enum('uzcard','humo','visa','mastercard') NOT NULL,
  `status` enum('pending','approved','paid','rejected') NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `transaction_reference` varchar(255) DEFAULT NULL,
  `balance_at_request` decimal(15,2) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `approved_at` int(11) DEFAULT NULL,
  `paid_confirmed_at` int(11) DEFAULT NULL,
  `rejected_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `withdrawal_requests`
--

INSERT INTO `withdrawal_requests` (`id`, `user_id`, `points_amount`, `amount_som`, `point_value_at_request`, `card_number_encrypted`, `card_masked`, `card_holder_name`, `card_type`, `status`, `rejection_reason`, `transaction_reference`, `balance_at_request`, `admin_id`, `approved_at`, `paid_confirmed_at`, `rejected_at`, `created_at`, `updated_at`) VALUES
(1, 1, 5280, 25000000.00, 5000.00, '1234123412341234', '1234 **** **** 1234', 'DILMUROD ALLABERGENOV', 'uzcard', 'paid', 'Karta raqami xato', NULL, 26400000.00, 1, 1776709172, 1776709172, 1776708531, 1776707501, 1776709172),
(3, 1, 280, 1400000.00, 5000.00, '1234123412341234', '1234 **** **** 1234', 'ASDASD ASDASD', 'uzcard', 'rejected', 'karta raqami xato', NULL, 1400000.00, 1, 1776709191, 1776709191, 1776709606, 1776709131, 1776709606),
(4, 1, 280, 1400000.00, 5000.00, '1234123412341234', '1234 **** **** 1234', 'SADFSDF SDFSDF', 'uzcard', 'rejected', 'sad', NULL, 1400000.00, 1, NULL, NULL, 1776709933, 1776709640, 1776709933),
(5, 1, 280, 1400000.00, 5000.00, '1234123412341234', '1234 **** **** 1234', 'ASDASD ASDASDAS', 'uzcard', 'paid', NULL, NULL, 1400000.00, 1, 1776865379, 1776865379, NULL, 1776709956, 1776865379);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `action_logs`
--
ALTER TABLE `action_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-action_logs-admin_id` (`admin_id`),
  ADD KEY `idx-action_logs-action` (`action`),
  ADD KEY `idx-action_logs-entity` (`entity_type`,`entity_id`),
  ADD KEY `idx-action_logs-created_at` (`created_at`);

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `login` (`login`),
  ADD KEY `idx-admins-login` (`login`),
  ADD KEY `idx-admins-role` (`role`),
  ADD KEY `idx-admins-status` (`status`);

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-districts-region_id` (`region_id`),
  ADD KEY `idx-districts-status` (`status`);

--
-- Indexes for table `installations`
--
ALTER TABLE `installations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-installations-user_id` (`user_id`),
  ADD KEY `idx-installations-inverter_id` (`inverter_id`),
  ADD KEY `idx-installations-status` (`status`),
  ADD KEY `idx-installations-created_at` (`created_at`),
  ADD KEY `idx-installations-approved_by` (`approved_by`),
  ADD KEY `idx-installations-rejected_by` (`rejected_by`),
  ADD KEY `fk_installations_panel_type` (`panel_type_id`);

--
-- Indexes for table `installation_materials`
--
ALTER TABLE `installation_materials`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-inst_materials-installation_id` (`installation_id`),
  ADD KEY `idx-inst_materials-material_id` (`material_id`);

--
-- Indexes for table `installation_photos`
--
ALTER TABLE `installation_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-inst_photos-installation_id` (`installation_id`);

--
-- Indexes for table `installation_status_history`
--
ALTER TABLE `installation_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-inst_history-installation_id` (`installation_id`),
  ADD KEY `idx-inst_history-changed_by` (`changed_by`);

--
-- Indexes for table `inverters`
--
ALTER TABLE `inverters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `model` (`model`),
  ADD KEY `idx-inverters-status` (`status`);

--
-- Indexes for table `materials`
--
ALTER TABLE `materials`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-materials-status` (`status`);

--
-- Indexes for table `migration`
--
ALTER TABLE `migration`
  ADD PRIMARY KEY (`version`);

--
-- Indexes for table `panel_types`
--
ALTER TABLE `panel_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-regions-status` (`status`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `key` (`key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `telegram_id` (`telegram_id`),
  ADD UNIQUE KEY `idx-users-telegram_id` (`telegram_id`),
  ADD KEY `idx-users-phone` (`phone`),
  ADD KEY `idx-users-status` (`status`),
  ADD KEY `idx-users-region_id` (`region_id`),
  ADD KEY `idx-users-district_id` (`district_id`),
  ADD KEY `idx-users-customer_type` (`customer_type`);

--
-- Indexes for table `withdrawal_requests`
--
ALTER TABLE `withdrawal_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx-withdrawals-user_id` (`user_id`),
  ADD KEY `idx-withdrawals-status` (`status`),
  ADD KEY `idx-withdrawals-admin_id` (`admin_id`),
  ADD KEY `idx-withdrawals-created_at` (`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `action_logs`
--
ALTER TABLE `action_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `districts`
--
ALTER TABLE `districts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1714401368;

--
-- AUTO_INCREMENT for table `installations`
--
ALTER TABLE `installations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `installation_materials`
--
ALTER TABLE `installation_materials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `installation_photos`
--
ALTER TABLE `installation_photos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `installation_status_history`
--
ALTER TABLE `installation_status_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inverters`
--
ALTER TABLE `inverters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `materials`
--
ALTER TABLE `materials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `panel_types`
--
ALTER TABLE `panel_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2000;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `withdrawal_requests`
--
ALTER TABLE `withdrawal_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `action_logs`
--
ALTER TABLE `action_logs`
  ADD CONSTRAINT `fk-action_logs-admin_id` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `districts`
--
ALTER TABLE `districts`
  ADD CONSTRAINT `fk-districts-region_id` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `installations`
--
ALTER TABLE `installations`
  ADD CONSTRAINT `fk-installations-approved_by` FOREIGN KEY (`approved_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-installations-inverter_id` FOREIGN KEY (`inverter_id`) REFERENCES `inverters` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-installations-rejected_by` FOREIGN KEY (`rejected_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-installations-user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_installations_panel_type` FOREIGN KEY (`panel_type_id`) REFERENCES `panel_types` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `installation_materials`
--
ALTER TABLE `installation_materials`
  ADD CONSTRAINT `fk-inst_materials-installation_id` FOREIGN KEY (`installation_id`) REFERENCES `installations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-inst_materials-material_id` FOREIGN KEY (`material_id`) REFERENCES `materials` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `installation_photos`
--
ALTER TABLE `installation_photos`
  ADD CONSTRAINT `fk-inst_photos-installation_id` FOREIGN KEY (`installation_id`) REFERENCES `installations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `installation_status_history`
--
ALTER TABLE `installation_status_history`
  ADD CONSTRAINT `fk-inst_history-changed_by` FOREIGN KEY (`changed_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-inst_history-installation_id` FOREIGN KEY (`installation_id`) REFERENCES `installations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk-users-district_id` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-users-region_id` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `withdrawal_requests`
--
ALTER TABLE `withdrawal_requests`
  ADD CONSTRAINT `fk-withdrawals-admin_id` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk-withdrawals-user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
