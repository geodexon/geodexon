-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.5.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table geodexon.bank
CREATE TABLE IF NOT EXISTS `bank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creator` int(11) NOT NULL DEFAULT 0,
  `acro` varchar(50) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `access` longtext NOT NULL DEFAULT '{}',
  `name` varchar(46) DEFAULT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  `account_type` varchar(50) DEFAULT 'Personal',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=269 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.bank_log
CREATE TABLE IF NOT EXISTS `bank_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account` int(11) NOT NULL DEFAULT 0,
  `data` longtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2220 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.bans
CREATE TABLE IF NOT EXISTS `bans` (
  `banid` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(100) NOT NULL DEFAULT '0',
  `reason` longtext NOT NULL DEFAULT '0',
  `active` tinyint(4) NOT NULL DEFAULT 1,
  `author` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`banid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.characters
CREATE TABLE IF NOT EXISTS `characters` (
  `user` int(11) DEFAULT 0,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first` varchar(20) NOT NULL DEFAULT '0',
  `last` varchar(20) NOT NULL DEFAULT '0',
  `dob` varchar(20) NOT NULL DEFAULT '0',
  `sex` tinyint(4) DEFAULT 0,
  `clothing` longtext NOT NULL DEFAULT '{}',
  `dead` tinyint(4) NOT NULL DEFAULT 0,
  `account` int(11) NOT NULL DEFAULT 0,
  `default` int(11) DEFAULT NULL,
  `pos` longtext DEFAULT '{}',
  `callsign` varchar(10) DEFAULT '',
  `skills` longtext DEFAULT '{}',
  `username` varchar(50) DEFAULT NULL,
  `walkstyle` varchar(50) DEFAULT 'move_f@multiplayer',
  `lastproperty` longtext DEFAULT NULL,
  `home` varchar(50) DEFAULT NULL,
  `lastlogin` datetime DEFAULT current_timestamp(),
  `job` varchar(50) DEFAULT NULL,
  `phone_number` bigint(20) DEFAULT NULL,
  `data` longtext NOT NULL DEFAULT '{}',
  `tattoos` longtext DEFAULT '{}',
  `dna` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=392 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.crafting_log
CREATE TABLE IF NOT EXISTS `crafting_log` (
  `cid` int(11) NOT NULL DEFAULT 0,
  `data` longtext DEFAULT '{}',
  PRIMARY KEY (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.death_queue
CREATE TABLE IF NOT EXISTS `death_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.gathering_log
CREATE TABLE IF NOT EXISTS `gathering_log` (
  `cid` int(11) NOT NULL DEFAULT 0,
  `data` longtext DEFAULT '{}',
  PRIMARY KEY (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.guilds
CREATE TABLE IF NOT EXISTS `guilds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ident` varchar(6) DEFAULT NULL,
  `ranks` longtext DEFAULT '{}',
  `guild` varchar(50) NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL DEFAULT 0,
  `members` longtext NOT NULL DEFAULT '{}',
  `funds` int(11) NOT NULL DEFAULT 0,
  `keycard` longtext DEFAULT '{}',
  `image` varchar(200) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.guild_invites
CREATE TABLE IF NOT EXISTS `guild_invites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char` int(11) DEFAULT NULL,
  `guild` varchar(50) DEFAULT NULL,
  `rank` varchar(50) DEFAULT NULL,
  `author` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.inventories
CREATE TABLE IF NOT EXISTS `inventories` (
  `type` varchar(40) NOT NULL,
  `inventoryid` varchar(60) NOT NULL,
  `content` longtext NOT NULL DEFAULT '{}',
  `charid` int(11) DEFAULT NULL,
  `stringid` varchar(50) DEFAULT NULL,
  `slot` int(11) DEFAULT NULL,
  KEY `Index 2` (`slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.jail
CREATE TABLE IF NOT EXISTS `jail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL DEFAULT 0,
  `time` int(11) NOT NULL DEFAULT 0,
  `start` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=159 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.jobs
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `business` varchar(50) DEFAULT '0',
  `cid` int(11) DEFAULT 0,
  `rank` int(11) NOT NULL DEFAULT 1,
  `time` float NOT NULL DEFAULT 0,
  `count` int(11) DEFAULT 0,
  `pay` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_jobs_characters` (`cid`),
  CONSTRAINT `FK_jobs_characters` FOREIGN KEY (`cid`) REFERENCES `characters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=637 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.k5_documents
CREATE TABLE IF NOT EXISTS `k5_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext DEFAULT NULL,
  `ownerId` varchar(50) DEFAULT NULL,
  `isCopy` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.k5_document_templates
CREATE TABLE IF NOT EXISTS `k5_document_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext DEFAULT NULL,
  `job` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.log
CREATE TABLE IF NOT EXISTS `log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) NOT NULL,
  `data` longtext NOT NULL DEFAULT '{}',
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `cid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=140573 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.luxury_apartment
CREATE TABLE IF NOT EXISTS `luxury_apartment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `deposit` int(11) NOT NULL DEFAULT 0,
  `active` bit(1) NOT NULL DEFAULT b'1',
  `date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_luxury_apartment_characters` (`cid`),
  CONSTRAINT `FK_luxury_apartment_characters` FOREIGN KEY (`cid`) REFERENCES `characters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_chargelist
CREATE TABLE IF NOT EXISTS `mdt_chargelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_chargelist_ems
CREATE TABLE IF NOT EXISTS `mdt_chargelist_ems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_charges
CREATE TABLE IF NOT EXISTS `mdt_charges` (
  `charge_id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_report` int(11) DEFAULT NULL,
  `cid` int(11) DEFAULT NULL,
  `charge` int(11) DEFAULT NULL,
  `warrant` int(11) DEFAULT 0,
  `active` int(11) DEFAULT 1,
  PRIMARY KEY (`charge_id`)
) ENGINE=InnoDB AUTO_INCREMENT=645 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_charges_ems
CREATE TABLE IF NOT EXISTS `mdt_charges_ems` (
  `charge_id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_report` int(11) DEFAULT NULL,
  `cid` int(11) DEFAULT NULL,
  `charge` int(11) DEFAULT NULL,
  `warrant` int(11) DEFAULT 0,
  `active` int(11) DEFAULT 1,
  PRIMARY KEY (`charge_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=244 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_profiles
CREATE TABLE IF NOT EXISTS `mdt_profiles` (
  `profile_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT '0',
  `cid` int(11) DEFAULT 0,
  `image` varchar(100) DEFAULT '0',
  `dob` varchar(100) DEFAULT '0',
  `notes` longtext DEFAULT '0',
  `licenses` longtext DEFAULT '{}',
  PRIMARY KEY (`profile_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_profiles_ems
CREATE TABLE IF NOT EXISTS `mdt_profiles_ems` (
  `profile_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT '0',
  `cid` int(11) DEFAULT 0,
  `image` varchar(100) DEFAULT '0',
  `dob` varchar(100) DEFAULT '0',
  `notes` longtext DEFAULT '0',
  `licenses` longtext DEFAULT '{}',
  PRIMARY KEY (`profile_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_reports
CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `author` int(11) NOT NULL DEFAULT 0,
  `title` varchar(75) DEFAULT NULL,
  `body` longtext DEFAULT NULL,
  `people` longtext DEFAULT '[]',
  `officers` longtext DEFAULT '[]',
  `locked` int(11) DEFAULT 0,
  `evidence` longtext DEFAULT '[]',
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=223 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.mdt_reports_ems
CREATE TABLE IF NOT EXISTS `mdt_reports_ems` (
  `report_id` int(11) NOT NULL AUTO_INCREMENT,
  `author` int(11) NOT NULL DEFAULT 0,
  `title` varchar(75) DEFAULT NULL,
  `body` longtext DEFAULT NULL,
  `people` longtext DEFAULT '[]',
  `officers` longtext DEFAULT '[]',
  `locked` int(11) DEFAULT 0,
  `evidence` longtext DEFAULT '[]',
  PRIMARY KEY (`report_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.outfits
CREATE TABLE IF NOT EXISTS `outfits` (
  `outfit` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL DEFAULT 0,
  `clothing` longtext NOT NULL DEFAULT '{}',
  `guild` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`outfit`)
) ENGINE=InnoDB AUTO_INCREMENT=197 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.phone_contacts
CREATE TABLE IF NOT EXISTS `phone_contacts` (
  `contact_id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `number` bigint(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`contact_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.phone_photos
CREATE TABLE IF NOT EXISTS `phone_photos` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `photo` varchar(200) NOT NULL,
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.phone_tentac
CREATE TABLE IF NOT EXISTS `phone_tentac` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL DEFAULT 0,
  `name` varchar(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.phone_text
CREATE TABLE IF NOT EXISTS `phone_text` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `from_number` bigint(20) NOT NULL,
  `to_number` bigint(20) NOT NULL,
  `message` varchar(256) NOT NULL,
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  `hiddenfor` longtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`message_id`)
) ENGINE=InnoDB AUTO_INCREMENT=641 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.police_actions
CREATE TABLE IF NOT EXISTS `police_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `officer` int(11) NOT NULL DEFAULT 0,
  `subject` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL DEFAULT '0',
  `data` longtext NOT NULL DEFAULT '{}',
  `amount` int(11) NOT NULL,
  `paid` tinyint(4) NOT NULL DEFAULT 0,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_police_actions_characters` (`officer`),
  KEY `FK_police_actions_characters_2` (`subject`),
  CONSTRAINT `FK_police_actions_characters` FOREIGN KEY (`officer`) REFERENCES `characters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `FK_police_actions_characters_2` FOREIGN KEY (`subject`) REFERENCES `characters` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=359 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.properties
CREATE TABLE IF NOT EXISTS `properties` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT 0,
  `renter` int(11) DEFAULT 0,
  `price` int(11) DEFAULT 0,
  `buyable` tinyint(4) DEFAULT 1,
  `title` varchar(50) DEFAULT '0',
  `interior` varchar(50) DEFAULT NULL,
  `doors` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}',
  `garage` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}',
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}',
  `tenants` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{}',
  `owed` int(11) DEFAULT 0,
  `lastpay` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `guild` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`pid`),
  UNIQUE KEY `Index 2` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.quests
CREATE TABLE IF NOT EXISTS `quests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL DEFAULT 0,
  `qid` varchar(50) NOT NULL DEFAULT '0',
  `data` longtext NOT NULL DEFAULT '{}',
  `stage` int(11) NOT NULL DEFAULT 1,
  `complete` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=534 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.rpg_jobtime
CREATE TABLE IF NOT EXISTS `rpg_jobtime` (
  `jid` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) DEFAULT NULL,
  `jtime` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`jid`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.staff_actions
CREATE TABLE IF NOT EXISTS `staff_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `extra` longtext NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_staff_actions_users` (`user`),
  CONSTRAINT `FK_staff_actions_users` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=703 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.state
CREATE TABLE IF NOT EXISTS `state` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT '0',
  `ident` varchar(50) DEFAULT '0',
  `stat` varchar(50) DEFAULT '0',
  `data` longtext DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.status_life
CREATE TABLE IF NOT EXISTS `status_life` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) DEFAULT 0,
  `remaining` int(11) DEFAULT 100000,
  KEY `Index 1` (`id`),
  KEY `FK_status_life_characters` (`cid`),
  CONSTRAINT `FK_status_life_characters` FOREIGN KEY (`cid`) REFERENCES `characters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=216 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.stores
CREATE TABLE IF NOT EXISTS `stores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `propertyId` int(11) DEFAULT NULL,
  `storeType` varchar(50) DEFAULT NULL,
  `storeIndex` int(11) DEFAULT NULL,
  `data` longtext DEFAULT '{}',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL DEFAULT '0',
  `steam` varchar(100) NOT NULL DEFAULT '0',
  `license` varchar(100) NOT NULL DEFAULT '0',
  `staff` tinyint(4) DEFAULT 0,
  `whitelist` int(11) DEFAULT 0,
  `discord` text DEFAULT NULL,
  `data` longtext NOT NULL DEFAULT '{}',
  `fivem` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `garage` varchar(100) DEFAULT 'Legion',
  `data` longtext DEFAULT '{}',
  `model` varchar(50) DEFAULT '{}',
  `plate` varchar(8) DEFAULT '{}',
  `parked` tinyint(4) DEFAULT 1,
  `owner` int(11) DEFAULT 0,
  `flags` longtext DEFAULT '{"Fuel":100.0}',
  `location` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.vehicles_2
CREATE TABLE IF NOT EXISTS `vehicles_2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `garage` varchar(100) DEFAULT 'Legion',
  `data` longtext DEFAULT '{}',
  `model` int(11) DEFAULT 0,
  `plate` varchar(8) DEFAULT '{}',
  `parked` tinyint(4) DEFAULT 1,
  `owner` int(11) DEFAULT 0,
  `flags` longtext DEFAULT '{"Fuel":100.0}',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table geodexon.weapons
CREATE TABLE IF NOT EXISTS `weapons` (
  `weapon_id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL DEFAULT 0,
  `serial_number` varchar(100) NOT NULL DEFAULT '0',
  `extra` longtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`weapon_id`),
  KEY `FK_weapons_characters` (`cid`)
) ENGINE=InnoDB AUTO_INCREMENT=484 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
