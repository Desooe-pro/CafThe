/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.5.28-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: CafTheBDD
-- ------------------------------------------------------
-- Server version	10.5.28-MariaDB-0+deb11u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `adresse`
--

DROP TABLE IF EXISTS `adresse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `adresse` (
  `Id_Adresse` int(11) NOT NULL AUTO_INCREMENT,
  `Bis_Ter_Numero_de_voie` int(11) NOT NULL,
  `Nom_commune_Adresse` varchar(50) NOT NULL,
  `Nom_Type_Voie` varchar(50) NOT NULL,
  `Complement_Voie` varchar(50) DEFAULT NULL,
  `Code_postal_Voie` varchar(50) NOT NULL,
  `Numero_Voie` int(11) NOT NULL,
  `Id_Vendeur` int(11) DEFAULT NULL,
  `Adresse_Ville` int(11) NOT NULL,
  `Identifiant_Client` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id_Adresse`),
  KEY `Id_Vendeur` (`Id_Vendeur`),
  KEY `Adresse_Ville` (`Adresse_Ville`),
  KEY `Identifiant_Client` (`Identifiant_Client`),
  CONSTRAINT `adresse_ibfk_1` FOREIGN KEY (`Id_Vendeur`) REFERENCES `vendeur` (`Id_Vendeur`),
  CONSTRAINT `adresse_ibfk_2` FOREIGN KEY (`Adresse_Ville`) REFERENCES `ville` (`Adresse_Ville`),
  CONSTRAINT `adresse_ibfk_3` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `adresse`
--

LOCK TABLES `adresse` WRITE;
/*!40000 ALTER TABLE `adresse` DISABLE KEYS */;
INSERT INTO `adresse` VALUES (1,0,'Blois','Rue du Commerce',NULL,'41000',14,NULL,41000,NULL),(11,0,'Blois','Rue des hautes granges','Apt 3B','41000',21,1,41000,1),(12,1,'Paris','Avenue des Champs-Élysées','Étage 4','75002',25,NULL,75002,2),(13,0,'Lyon','Rue de la République','Bât A','69001',8,2,69001,3),(14,0,'Marseille','Boulevard du Prado','Étage 1','13001',45,3,13001,4),(15,2,'Bordeaux','Cours de l\'Intendance','Apt 2C','33000',12,NULL,33000,5),(16,0,'Nantes','Rue Crébillon','Rien','44000',33,NULL,44000,6),(17,0,'Toulouse','Rue Alsace-Lorraine','Étage 1','31000',18,NULL,31000,7),(18,1,'Lyon','Rue Mercière','Apt 5D','69002',22,NULL,69002,8),(19,0,'Marseille','Rue Paradis','Rien','13002',56,NULL,13002,9),(20,0,'Paris','Rue du Commerce','Bât B','75003',41,NULL,75003,10),(26,0,'Lille','Rue Nationale','Apt 4C','59000',28,NULL,59000,11),(27,0,'Strasbourg','Place Kléber','Étage 3','67000',15,NULL,67000,12),(28,1,'Rennes','Rue de la Soif','Rien','35000',42,NULL,35000,13),(29,0,'Nice','Promenade des Anglais','Bât D','06000',156,NULL,6000,14),(30,2,'Montpellier','Place de la Comédie','Apt 7B','34000',8,NULL,34000,15),(41,0,'Paris','Rue de la Paix',NULL,'75001',16,NULL,75001,NULL),(56,0,'Villemandeur','rue du haut de ris',NULL,'41900',30,NULL,41900,42),(59,0,'Blois','Rue des hautes granges',NULL,'41000',21,NULL,41000,45),(60,0,'contres','rue du pres',NULL,'41700',3,NULL,41700,46),(61,0,'Blois','rue des hautes granges',NULL,'41000',21,NULL,41000,47),(86,0,'Paris','rue de la paix',NULL,'75000',15,NULL,75000,47),(87,0,'Saint-Pierre','rue de la vie',NULL,'32500',15,NULL,32500,47),(88,0,'36100',' rue des rues',NULL,'Issoudun',23,NULL,0,48),(89,0,'Blois','Rue des hautes granges',NULL,'41000',21,NULL,41000,49);
/*!40000 ALTER TABLE `adresse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `article`
--

DROP TABLE IF EXISTS `article`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `article` (
  `Id_Article` int(11) NOT NULL AUTO_INCREMENT,
  `Designation_Article` varchar(50) NOT NULL,
  `Quantite_Article` int(11) NOT NULL,
  `Prix_unitaire_Article` decimal(15,2) NOT NULL,
  `Description_Article` varchar(200) NOT NULL,
  `Quantite_vendu_Article` int(11) NOT NULL,
  `Nombre_de_vente_Article` int(11) NOT NULL,
  `Id_Taxe` int(11) NOT NULL,
  `Id_Mesure` int(11) NOT NULL,
  `lienImg` varchar(255) DEFAULT 'NULL',
  PRIMARY KEY (`Id_Article`),
  KEY `Id_Taxe` (`Id_Taxe`),
  KEY `Id_Mesure` (`Id_Mesure`),
  CONSTRAINT `article_ibfk_1` FOREIGN KEY (`Id_Taxe`) REFERENCES `taxe` (`Id_Taxe`),
  CONSTRAINT `article_ibfk_2` FOREIGN KEY (`Id_Mesure`) REFERENCES `mesure` (`Id_Mesure`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `article`
--

LOCK TABLES `article` WRITE;
/*!40000 ALTER TABLE `article` DISABLE KEYS */;
INSERT INTO `article` VALUES (1,'Café Arabica Colombie',486,28.90,'Café arabica de Colombie, notes florales et fruitées',277,139,1,1,'Arabica.jpg'),(2,'Café Robusta Inde',500,22.50,'Café robusta d\'Inde, corsé et puissant',180,90,1,1,'Robusta.jpg'),(3,'Café Moka Éthiopie',490,32.00,'Café moka d\'Éthiopie, notes de chocolat et d\'épices',212,108,1,3,'Moka.jpg'),(4,'Café Blue Mountain',247,89.90,'Café premium de Jamaïque, équilibré et raffiné',53,28,1,3,'BlueMountain.jpg'),(5,'Café Espresso Blend',985,26.90,'Mélange spécial pour espresso, intense et crémeux',415,205,1,3,'ExpressoBlend.jpg'),(6,'Thé Earl Grey',32,12.90,'Thé noir parfumé à la bergamote',235,120,1,3,'EarlGrey.jpg'),(7,'Thé Vert Sencha',29,15.90,'Thé vert japonais traditionnel',241,89,1,1,'VertSencha.jpg'),(8,'Thé Oolong',98,18.90,'Thé semi-oxydé de Taiwan',82,42,1,3,'ThéOolong.jpg'),(9,'Thé Darjeeling',98,16.90,'Thé noir premium d\'Inde',102,52,1,1,'ThéDarjeeling.jpg'),(10,'Rooibos Vanilla',99,11.90,'Infusion sud-africaine à la vanille',103,51,2,2,NULL),(11,'Machine Espresso Pro',5,599.00,'Machine espresso semi-automatique 15 bars',12,10,2,2,NULL),(12,'Moulin à café électrique',10,89.90,'Moulin à café avec meules coniques',39,21,2,2,NULL),(13,'French Press',26,34.90,'Cafetière à piston en verre et inox',29,28,2,2,NULL),(14,'Théière en Fonte',12,79.90,'Théière traditionnelle japonaise en fonte',13,11,2,2,'Théière.jpg'),(15,'Balance de précision',25,29.90,'Balance digitale précision 0.1g',20,20,2,2,NULL),(16,'Filtre permanent inox',43,19.90,'Filtre réutilisable pour dripper',47,43,2,2,NULL),(17,'Kit dégustation',10,49.90,'Kit complet dégustation café',6,6,2,2,NULL),(18,'Tasses espresso x6',28,39.90,'Set de 6 tasses espresso porcelaine',27,26,2,2,NULL),(19,'Bouilloire col de cygne',19,69.90,'Bouilloire spéciale pour V60 et filtres',16,16,2,2,NULL),(20,'Boîte conservation 1kg',36,24.90,'Boîte hermétique conservation café',39,36,2,2,NULL),(21,'Café Guatemala Antigua',498,31.90,'Café d\'altitude aux notes de chocolat et d\'agrumes',182,91,1,1,'GuatemalaAntigua.jpg'),(22,'Café Costa Rica Tarrazu',499,29.90,'Notes de fruits rouges et de caramel',161,81,1,1,'CostaRicaTarrazu.jpg'),(23,'Café Kenya AA',250,27.90,'Café corsé aux notes d\'agrumes',140,70,1,3,'KenyaAA.jpg'),(24,'Café Sumatra Mandheling',496,26.90,'Notes terreuses et épicées',124,62,1,3,'SumatraMandheling.jpg'),(25,'Café Pérou Bio',1000,24.90,'Café biologique aux notes douces et équilibrées',200,100,1,1,'PerouBio.jpg'),(26,'Thé Jasmin Imperial',77,16.90,'Thé vert parfumé au jasmin',138,65,1,1,'ThéJasminImperial.jpg'),(27,'Thé Assam TGFOP',99,14.90,'Thé noir indien corsé',96,48,1,1,'TGFOP.jpg'),(28,'Thé Long Jing',50,29.90,'Thé vert chinois premium',70,35,1,1,'LongJing.jpg'),(29,'Thé Blanc Bai Mu Dan',28,32.90,'Thé blanc aux notes florales',84,39,1,3,'BaiMuDan.jpg'),(30,'Thé Pu Erh Vintage',100,45.90,'Thé sombre affiné 5 ans',40,20,1,1,'PuErhVintage.jpg'),(31,'Dripper Céramique',28,29.90,'Pour extraction manuelle V60',27,26,2,2,NULL),(32,'Grille-dosette ESE',40,19.90,'Adaptateur pour machine espresso',35,35,2,2,NULL),(33,'Brosse à moulin',50,9.90,'Brosse de nettoyage pour moulin à café',45,45,2,2,NULL),(34,'Set Cuillères Mesure',60,14.90,'Set de 4 cuillères doseuses',50,50,2,2,NULL),(35,'Tasse Dégustation Pro',39,24.90,'Tasse spéciale dégustation café',31,31,2,2,NULL);
/*!40000 ALTER TABLE `article` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carte_bancaire`
--

DROP TABLE IF EXISTS `carte_bancaire`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `carte_bancaire` (
  `Id_CB` int(11) NOT NULL AUTO_INCREMENT,
  `Type_CB` varchar(50) NOT NULL,
  `Numero_CB` varchar(50) NOT NULL,
  `Date_expiration_CB` varchar(50) NOT NULL,
  `Nom_CB` varchar(50) NOT NULL,
  `Identifiant_Client` int(11) NOT NULL,
  PRIMARY KEY (`Id_CB`),
  KEY `Identifiant_Client` (`Identifiant_Client`),
  CONSTRAINT `carte_bancaire_ibfk_1` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carte_bancaire`
--

LOCK TABLES `carte_bancaire` WRITE;
/*!40000 ALTER TABLE `carte_bancaire` DISABLE KEYS */;
INSERT INTO `carte_bancaire` VALUES (1,'Visa','4532XXXXXXXX1234','12/25','DURAND A',1),(2,'Mastercard','5432XXXXXXXX5678','09/24','LEFEBVRE M',2),(3,'Visa','4556XXXXXXXX9012','03/26','MARTIN P',3),(4,'Mastercard','5187XXXXXXXX3456','06/25','PETIT C',4),(5,'Visa','4921XXXXXXXX7890','11/24','ROUX F',5),(6,'Amex','3782XXXXXXXX1234','08/25','BLANC I',6),(7,'Visa','4556XXXXXXXX5678','04/26','GIRARD L',7),(8,'Mastercard','5432XXXXXXXX9012','07/25','ANDRE S',8),(9,'Visa','4921XXXXXXXX3456','10/24','MEYER N',9),(10,'Mastercard','5187XXXXXXXX7890','05/26','ROBERT C',10),(11,'Visa','4539XXXXXXXX5678','01/26','DUPUIS M',11),(12,'Mastercard','5236XXXXXXXX1234','03/25','MERCIER T',12),(13,'Visa','4916XXXXXXXX9012','07/26','LAMBERT J',13),(14,'Mastercard','5137XXXXXXXX3456','09/25','FOURNIER G',14),(15,'Visa','4532XXXXXXXX7890','11/25','ROUSSEAU E',15),(16,'Visa','0123XXXXXXXX1112','12/25','STACY G.',21),(20,'Visa','1234XXXXXXXX1121','12/26','ALLA S',47),(21,'Visa','1234XXXXXXXX1234','11/26','AL S',49);
/*!40000 ALTER TABLE `carte_bancaire` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client`
--

DROP TABLE IF EXISTS `client`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `client` (
  `Identifiant_Client` int(11) NOT NULL AUTO_INCREMENT,
  `Nom_Prenom_Client` varchar(50) NOT NULL,
  `Date_de_naissance_Client` date NOT NULL,
  `Tel_Client` int(11) DEFAULT NULL,
  `Mail_Client` varchar(50) NOT NULL,
  `MDP_Client` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Identifiant_Client`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client`
--

LOCK TABLES `client` WRITE;
/*!40000 ALTER TABLE `client` DISABLE KEYS */;
INSERT INTO `client` VALUES (1,'Sacha Allardin','1985-07-12',701020304,'sacha.allardin@gmail.com','$2b$10$gA1vnf8DcCLVSgJegyuQtOtNAceBKdHZ9K/gjskod1gCuolL5XN.a'),(2,'Marie Lefebvre','1990-09-25',702030405,'marie.lefebvre@email.com','The2024@'),(3,'Pierre Martin','1988-03-18',703040506,'pierre.martin@email.com','Coffee2024#'),(4,'Céline Petit','1992-11-30',704050607,'celine.petit@email.com','$2b$10$K9q2MCAjAaZCMbr6RVXlzuixLas3YqfPCR9vjkUv9abR5vnKwCOSW'),(5,'François Roux','1987-04-15',705060708,'francois.roux@email.com','Espresso24!'),(6,'Isabelle Blanc','1995-08-22',706070809,'isabelle.blanc@email.com','Latte2024@'),(7,'Laurent Girard','1983-12-05',707080910,'laurent.girard@email.com','Mocha2024#'),(8,'Sophie Andre','1993-06-28',708091011,'sophie.andre@email.com','Chai2024$'),(9,'Nicolas Meyer','1989-02-14',709101112,'nicolas.meyer@email.com','Filter2024!'),(10,'Camille Robert','1991-10-08',710111213,'camille.robert@email.com','Brew2024@'),(11,'Mathilde Dupuis','1986-03-25',711121314,'mathilde.dupuis@email.com','Coffee25@'),(12,'Thomas Mercier','1993-07-14',712131415,'thomas.mercier@email.com','Tea14Jul!'),(13,'Julie Lambert','1990-12-08',713141516,'julie.lambert@email.com','JulieCafe#'),(14,'Gabriel Fournier','1988-09-30',714151617,'gabriel.fournier@email.com','GabTea2024'),(15,'Emma Rousseau','1995-01-17',715161718,'emma.rousseau@email.com','EmmaR2024!'),(16,'Louis Martin','1987-06-22',716171819,'louis.martin@email.com','LouisM24@'),(17,'Sarah Cohen','1992-04-11',717181920,'sarah.cohen@email.com','SarahTea#'),(18,'Hugo Bertrand','1989-08-03',718192021,'hugo.bertrand@email.com','HugoCafe$'),(19,'Clara Dumont','1994-11-28',719202122,'clara.dumont@email.com','$2b$10$IwSoKKUvzpvtX/FTkaGkGOvUXHaSkOrAuYj9TKNSJZh9XW2Ao51Pi'),(20,'Antoine Moreau','1991-02-15',720212223,'antoine.moreau@email.com','AntoineCafe@'),(21,'Pierre Dupont','1985-06-18',123456789,'contact.dupond@gmail.com','$2b$10$NBTDI.YeWBGJAZfIrr9KUeYwWsB1Ut4Hirgfzw2i8PQ2RG.GSAphm'),(42,'Benjamin Bidou','2009-09-09',NULL,'benjamin.bidou@campus-centre.fr','$2b$10$a8L/NJoOH3iBInqpXmGcMOIRFIqX94GV.kxWaIBV7tfd3Seywin/.'),(45,'Sacha Allar','2006-06-22',NULL,'sacha.allar@gmail.com','$2b$10$zRcgTeA6QHKDVQfvEcYI/.4fozxx/Wr/kjS1jBBLlGYSCHvp3iGNu'),(46,'Mathieu Houbron','1988-12-02',600000000,'mathieu@test.com','$2b$10$VbaNERYs4NXO7G1f/cGXquJRddAw17CCj/0vaFWww.CyjB9xFYAZC'),(47,'S Alla','1999-01-01',NULL,'alla.s@gmail.com','$2b$10$nVhhiDUblYrQLP.a8r0jduTtz0IH7Uf6KUjV9MLgjrtNJ4lIcR7aS'),(48,'Olivier L','0000-00-00',605040302,'olivier@email.com','$2b$10$foSYN3euAM3rv7mZN.tF8.hHRYnu7F5FgXUdvGnkRrKnVRoM38HrS'),(49,'Sa Al','2006-06-22',NULL,'sa.al@email.com','$2b$10$4YOpejzcGmmYVvXlf9S26O1zbELyusJgK7FuQ8hct5C842ficmHN.');
/*!40000 ALTER TABLE `client` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `CreatePanierForNewClient` AFTER INSERT ON `client` FOR EACH ROW BEGIN
    -- Crée un nouveau panier pour chaque nouveau client
    INSERT INTO panier (Identifiant_Client, Status, Prix_HT_Panier, Prix_TVA_Panier, Prix_TTC_Panier, Nombre_de_lignes_Panier, Montant_Panier)
    VALUES (NEW.Identifiant_Client, 'Ouvert', 0, 0, 0, 0, 0);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `commande`
--

DROP TABLE IF EXISTS `commande`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `commande` (
  `Id_Commande` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre_Ligne_de_commande` int(11) DEFAULT NULL,
  `Status_Commande` varchar(50) NOT NULL,
  `Date_prise_Commande` date DEFAULT NULL,
  `Id_Adresse` int(11) DEFAULT NULL,
  `Id_Adresse_1` int(11) NOT NULL,
  `Id_Vendeur` int(11) DEFAULT NULL,
  `idPayement` int(11) NOT NULL,
  `Id_Panier` int(11) NOT NULL,
  `Identifiant_Client` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id_Commande`),
  KEY `Id_Adresse` (`Id_Adresse`),
  KEY `Id_Adresse_1` (`Id_Adresse_1`),
  KEY `Id_Vendeur` (`Id_Vendeur`),
  KEY `Id_Panier` (`Id_Panier`),
  KEY `Identifiant_Client` (`Identifiant_Client`),
  KEY `idPayement` (`idPayement`),
  CONSTRAINT `commande_ibfk_1` FOREIGN KEY (`Id_Adresse`) REFERENCES `adresse` (`Id_Adresse`),
  CONSTRAINT `commande_ibfk_2` FOREIGN KEY (`Id_Adresse_1`) REFERENCES `adresse` (`Id_Adresse`),
  CONSTRAINT `commande_ibfk_3` FOREIGN KEY (`Id_Vendeur`) REFERENCES `vendeur` (`Id_Vendeur`),
  CONSTRAINT `commande_ibfk_5` FOREIGN KEY (`Id_Panier`) REFERENCES `panier` (`Id_Panier`),
  CONSTRAINT `commande_ibfk_6` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`),
  CONSTRAINT `commande_ibfk_7` FOREIGN KEY (`idPayement`) REFERENCES `payement` (`idPayement`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `commande`
--

LOCK TABLES `commande` WRITE;
/*!40000 ALTER TABLE `commande` DISABLE KEYS */;
INSERT INTO `commande` VALUES (11,1,'Livrée','2025-01-13',11,11,1,1,1,1),(12,3,'En cours','2025-01-14',12,12,2,2,2,2),(13,4,'En préparation','2025-01-14',13,13,3,3,3,3),(14,1,'Livrée','2025-01-12',14,13,1,4,4,4),(15,2,'En cours','2025-01-14',15,11,2,5,5,5),(16,1,'Validée','2025-01-14',16,17,3,6,6,6),(17,3,'En préparation','2025-01-14',17,17,1,7,7,7),(18,2,'Livrée','2025-01-11',18,18,2,8,8,8),(19,2,'En cours','2025-01-14',19,19,3,9,9,9),(20,1,'Validée','2025-01-14',20,20,1,10,10,10),(21,2,'En préparation','2025-01-14',11,11,1,11,11,11),(22,3,'Validée','2025-01-14',12,12,2,12,12,12),(23,2,'En cours','2025-01-14',13,13,3,13,13,13),(24,4,'En préparation','2025-01-14',14,14,4,14,14,14),(25,3,'Validée','2025-01-14',15,15,5,15,15,15),(28,1,'Livrée','2025-01-17',11,13,NULL,16,16,1),(29,1,'En préparation','2025-02-06',12,11,NULL,17,17,2),(31,1,'Validée','2025-02-06',13,41,NULL,18,18,3),(32,2,'Validée','2025-03-14',61,86,NULL,19,78,47),(33,3,'Validée','2025-03-14',61,87,NULL,20,79,47),(117,1,'Validée','2025-03-20',NULL,1,NULL,0,90,1);
/*!40000 ALTER TABLE `commande` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `After_Commande_Insert_Update` AFTER INSERT ON `commande` FOR EACH ROW BEGIN
    -- Met à jour l'Identifiant_Client dans le panier
    UPDATE panier
    SET Identifiant_Client = NEW.Identifiant_Client,
        Status = CASE 
            WHEN NEW.Status_Commande IN ('En préparation', 'En cours', 'Validée') THEN 'En commande'
            WHEN NEW.Status_Commande = 'Livrée' THEN 'Fermé'
            WHEN NEW.Status_Commande = 'terminée' THEN 'terminé'
            ELSE 'Ouvert'
        END
    WHERE Id_Panier = NEW.Id_Panier;

    -- Vérifie si la mise à jour a réussi
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Échec de la mise à jour du panier';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `NewPanierAfterCommande` AFTER INSERT ON `commande` FOR EACH ROW BEGIN 
    INSERT INTO panier (Identifiant_Client, Status, Prix_HT_Panier, Prix_TVA_Panier, Prix_TTC_Panier, Nombre_de_lignes_Panier, Montant_Panier)
        VALUES (NEW.Identifiant_Client, 'Ouvert', 0, 0, 0, 0, 0);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `UpdateStockOnNewCommande` AFTER INSERT ON `commande` FOR EACH ROW BEGIN
    -- Met à jour les stocks et les quantités vendues pour chaque article dans la commande
    UPDATE article AS a
    INNER JOIN (
        SELECT 
            lp.Id_Article, 
            SUM(lp.Quantite_Ligne_de_panier) AS Quantite_Commandee,
            COUNT(DISTINCT NEW.Id_Commande) AS NombreCommandes
        FROM ligne_de_panier AS lp
        WHERE lp.Id_Panier = NEW.Id_Panier
        GROUP BY lp.Id_Article
    ) AS commandes
    ON a.Id_Article = commandes.Id_Article
    SET 
        a.Quantite_Article = a.Quantite_Article - commandes.Quantite_Commandee,
        a.Quantite_vendu_Article = a.Quantite_vendu_Article + commandes.Quantite_Commandee,
        a.Nombre_de_vente_Article = a.Nombre_de_vente_Article + commandes.NombreCommandes;

    -- Vérifie si des stocks deviennent négatifs
    IF EXISTS (SELECT 1 FROM article WHERE Quantite_Article < 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuffisant pour compléter cette commande.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `After_Commande_Update` AFTER UPDATE ON `commande` FOR EACH ROW BEGIN
    IF NEW.Status_Commande != OLD.Status_Commande THEN
        UPDATE panier
        SET Status = CASE 
            WHEN NEW.Status_Commande IN ('En préparation', 'En cours', 'Validée') THEN 'En commande'
            WHEN NEW.Status_Commande = 'Livrée' THEN 'Fermé'
            WHEN NEW.Status_Commande = 'terminée' THEN 'terminé'
            ELSE 'Ouvert'
        END
        WHERE Id_Panier = NEW.Id_Panier;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `After_Commande_Delete` AFTER DELETE ON `commande` FOR EACH ROW BEGIN
    UPDATE panier AS P 
    SET P.Status = 'Ouvert'
    WHERE P.Id_Panier = OLD.Id_Panier;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER after_commande_annulation
AFTER DELETE ON commande
FOR EACH ROW
BEGIN
    -- Restaurer le stock des articles avant suppression de la commande
    UPDATE article AS a
    JOIN ligne_de_panier AS lp ON a.Id_Article = lp.Id_Article
    SET a.Quantite_Article = a.Quantite_Article + lp.Quantite_Ligne_de_panier
    WHERE lp.Id_Panier = OLD.Id_Panier;
    
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `ligne_de_panier`
--

DROP TABLE IF EXISTS `ligne_de_panier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ligne_de_panier` (
  `Id_Panier` int(11) NOT NULL,
  `Id_Ligne_de_panier` int(11) NOT NULL AUTO_INCREMENT,
  `Quantite_Ligne_de_panier` varchar(50) NOT NULL,
  `Prix_unitaire_Ligne_de_panier` decimal(15,2) DEFAULT NULL,
  `Id_Article` int(11) NOT NULL,
  PRIMARY KEY (`Id_Ligne_de_panier`),
  KEY `Id_Panier` (`Id_Panier`),
  KEY `Id_Article` (`Id_Article`),
  CONSTRAINT `ligne_de_panier_ibfk_1` FOREIGN KEY (`Id_Panier`) REFERENCES `panier` (`Id_Panier`),
  CONSTRAINT `ligne_de_panier_ibfk_2` FOREIGN KEY (`Id_Article`) REFERENCES `article` (`Id_Article`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ligne_de_panier`
--

LOCK TABLES `ligne_de_panier` WRITE;
/*!40000 ALTER TABLE `ligne_de_panier` DISABLE KEYS */;
INSERT INTO `ligne_de_panier` VALUES (1,1,'2',28.90,1),(2,2,'1',89.90,4),(3,3,'3',15.90,7),(4,4,'1',599.00,11),(5,5,'2',34.90,13),(6,6,'1',79.90,14),(7,7,'3',19.90,16),(8,8,'2',39.90,18),(9,9,'1',69.90,19),(10,10,'4',24.90,20),(11,11,'2',31.90,21),(12,12,'1',29.90,22),(13,13,'3',16.90,26),(14,14,'2',29.90,31),(15,15,'1',24.90,35),(16,16,'2',19.90,16),(17,17,'3',15.90,7),(18,18,'1',12.90,6),(19,19,'1',69.90,19),(19,20,'1',69.90,20),(78,59,'1',12.90,6),(78,60,'1',15.90,7),(79,61,'1',12.90,6),(79,62,'1',16.90,26),(79,63,'1',18.90,8),(90,80,'11',15.90,7),(148,95,'2',28.90,1),(148,96,'1',11.90,10);
/*!40000 ALTER TABLE `ligne_de_panier` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `Recherche_Prix_Unitaire_Ligne_Panier` BEFORE INSERT ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Si le prix unitaire est NULL, on va chercher le prix dans la table article
    IF NEW.Prix_unitaire_Ligne_de_panier IS NULL THEN
        SET NEW.Prix_unitaire_Ligne_de_panier = (
            SELECT Prix_unitaire_Article
            FROM article
            WHERE Id_Article = NEW.Id_Article
            LIMIT 1
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `Update_Prix_Panier_After_Insert` AFTER INSERT ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Variables pour stocker les calculs intermédiaires
    DECLARE total_ht DECIMAL(15,2);
    DECLARE total_tva DECIMAL(15,2);
    DECLARE total_ttc DECIMAL(15,2);
    DECLARE taux_tva DECIMAL(15,2);
    
    -- Calcul du prix HT pour toutes les lignes du panier
    SELECT SUM(lp.Prix_unitaire_Ligne_de_panier * CAST(lp.Quantite_Ligne_de_panier AS DECIMAL))
    INTO total_ht
    FROM ligne_de_panier as lp
    WHERE lp.Id_Panier = NEW.Id_Panier;
    
    -- Récupération du taux de TVA de l'article
    SELECT t.Pourcentage_Taxe 
    INTO taux_tva
    FROM article as a
    JOIN taxe t ON a.Id_Taxe = t.Id_Taxe
    WHERE a.Id_Article = NEW.Id_Article;
    
    -- Calcul de la TVA et du TTC
    SET total_tva = total_ht * (taux_tva / 100);
    SET total_ttc = total_ht + total_tva;
    
    -- Mise à jour du panier
    UPDATE panier
    SET Prix_HT_Panier = total_ht,
        Prix_TVA_Panier = total_tva,
        Prix_TTC_Panier = total_ttc,
        Montant_Panier = total_ttc,
        Nombre_de_lignes_Panier = (
            SELECT COUNT(*)
            FROM ligne_de_panier
            WHERE Id_Panier = NEW.Id_Panier
        )
    WHERE Id_Panier = NEW.Id_Panier;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `Update_Prix_Panier_After_Update` AFTER UPDATE ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Variables pour stocker les calculs intermédiaires
    DECLARE total_ht DECIMAL(15,2);
    DECLARE total_tva DECIMAL(15,2);
    DECLARE total_ttc DECIMAL(15,2);
    DECLARE taux_tva DECIMAL(15,2);
    
    -- Calcul du prix HT pour toutes les lignes du panier
    SELECT SUM(lp.Prix_unitaire_Ligne_de_panier * CAST(lp.Quantite_Ligne_de_panier AS DECIMAL))
    INTO total_ht
    FROM ligne_de_panier as lp
    WHERE lp.Id_Panier = NEW.Id_Panier;
    
    -- Récupération du taux de TVA de l'article
    SELECT t.Pourcentage_Taxe 
    INTO taux_tva
    FROM article as a
    JOIN taxe t ON a.Id_Taxe = t.Id_Taxe
    WHERE a.Id_Article = NEW.Id_Article;
    
    -- Calcul de la TVA et du TTC
    SET total_tva = total_ht * (taux_tva / 100);
    SET total_ttc = total_ht + total_tva;
    
    -- Mise à jour du panier
    UPDATE panier
    SET Prix_HT_Panier = total_ht,
        Prix_TVA_Panier = total_tva,
        Prix_TTC_Panier = total_ttc,
        Montant_Panier = total_ttc,
        Nombre_de_lignes_Panier = (
            SELECT COUNT(*)
            FROM ligne_de_panier
            WHERE Id_Panier = NEW.Id_Panier
        )
    WHERE Id_Panier = NEW.Id_Panier;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /* 50017 DEFINER=`SALLARDIN`@`%`*/ /*!50003 TRIGGER `Update_Prix_Panier_After_Delete` AFTER DELETE ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Variables pour stocker les calculs intermédiaires
    DECLARE total_ht DECIMAL(15,2);
    DECLARE total_tva DECIMAL(15,2);
    DECLARE total_ttc DECIMAL(15,2);
    DECLARE taux_tva DECIMAL(15,2);
    
    -- Calcul du prix HT pour toutes les lignes restantes du panier
    SELECT COALESCE(SUM(lp.Prix_unitaire_Ligne_de_panier * CAST(lp.Quantite_Ligne_de_panier AS DECIMAL)), 0)
    INTO total_ht
    FROM ligne_de_panier as lp
    WHERE lp.Id_Panier = OLD.Id_Panier;
    
    -- Récupération du taux de TVA de l'article
    SELECT t.Pourcentage_Taxe 
    INTO taux_tva
    FROM article AS a
    JOIN taxe t ON a.Id_Taxe = t.Id_Taxe
    WHERE a.Id_Article = OLD.Id_Article;
    
    -- Calcul de la TVA et du TTC
    SET total_tva = total_ht * (taux_tva / 100);
    SET total_ttc = total_ht + total_tva;
    
    -- Mise à jour du panier
    UPDATE panier
    SET Prix_HT_Panier = total_ht,
        Prix_TVA_Panier = total_tva,
        Prix_TTC_Panier = total_ttc,
        Montant_Panier = total_ttc,
        Nombre_de_lignes_Panier = (
            SELECT COUNT(*)
            FROM ligne_de_panier
            WHERE Id_Panier = OLD.Id_Panier
        )
    WHERE Id_Panier = OLD.Id_Panier;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `mesure`
--

DROP TABLE IF EXISTS `mesure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mesure` (
  `Id_Mesure` int(11) NOT NULL AUTO_INCREMENT,
  `Designation_Mesure` varchar(50) NOT NULL,
  PRIMARY KEY (`Id_Mesure`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mesure`
--

LOCK TABLES `mesure` WRITE;
/*!40000 ALTER TABLE `mesure` DISABLE KEYS */;
INSERT INTO `mesure` VALUES (1,'Poids'),(2,'Unité'),(3,'Boîte');
/*!40000 ALTER TABLE `mesure` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `panier`
--

DROP TABLE IF EXISTS `panier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `panier` (
  `Id_Panier` int(11) NOT NULL AUTO_INCREMENT,
  `Prix_HT_Panier` decimal(15,2) NOT NULL,
  `Prix_TVA_Panier` decimal(15,2) NOT NULL,
  `Prix_TTC_Panier` decimal(15,2) NOT NULL,
  `Nombre_de_lignes_Panier` int(11) DEFAULT NULL,
  `Montant_Panier` decimal(15,2) NOT NULL,
  `Status` varchar(20) DEFAULT 'actif',
  `Identifiant_Client` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id_Panier`),
  KEY `Identifiant_Client` (`Identifiant_Client`),
  CONSTRAINT `panier_ibfk_1` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `panier`
--

LOCK TABLES `panier` WRITE;
/*!40000 ALTER TABLE `panier` DISABLE KEYS */;
INSERT INTO `panier` VALUES (1,57.80,11.56,69.36,1,69.36,'Fermé',1),(2,89.90,17.98,107.88,3,107.88,'En commande',2),(3,47.70,9.54,57.24,4,57.24,'En commande',3),(4,599.00,119.80,718.80,1,718.80,'Fermé',4),(5,69.80,13.96,83.76,2,83.76,'En commande',5),(6,79.90,15.98,95.88,1,95.88,'En commande',6),(7,59.70,11.94,71.64,3,71.64,'En commande',7),(8,79.80,15.96,95.76,2,95.76,'Fermé',8),(9,69.90,13.98,83.88,2,83.88,'En commande',9),(10,99.60,19.92,119.52,1,119.52,'En commande',10),(11,63.80,12.76,76.56,2,76.56,'En commande',11),(12,29.90,5.98,35.88,3,35.88,'En commande',12),(13,50.70,10.14,60.84,2,60.84,'En commande',13),(14,59.80,11.96,71.76,4,71.76,'En commande',14),(15,24.90,4.98,29.88,3,29.88,'En commande',15),(16,39.80,7.96,47.76,1,47.76,'Fermé',1),(17,47.70,9.54,57.24,1,57.24,'En commande',2),(18,12.90,2.58,15.48,1,15.48,'En commande',3),(19,139.80,27.96,167.76,2,167.76,'Ouvert',4),(20,0.00,0.00,0.00,0,0.00,'Ouvert',5),(21,0.00,0.00,0.00,0,0.00,'Ouvert',6),(22,0.00,0.00,0.00,0,0.00,'Ouvert',7),(23,0.00,0.00,0.00,0,0.00,'Ouvert',8),(24,0.00,0.00,0.00,0,0.00,'Ouvert',9),(25,0.00,0.00,0.00,0,0.00,'Ouvert',10),(26,0.00,0.00,0.00,0,0.00,'Ouvert',11),(27,0.00,0.00,0.00,0,0.00,'Ouvert',12),(28,0.00,0.00,0.00,0,0.00,'Ouvert',13),(29,0.00,0.00,0.00,0,0.00,'Ouvert',14),(30,0.00,0.00,0.00,0,0.00,'Ouvert',15),(31,0.00,0.00,0.00,0,0.00,'Ouvert',16),(32,0.00,0.00,0.00,0,0.00,'Ouvert',17),(33,0.00,0.00,0.00,0,0.00,'Ouvert',18),(34,0.00,0.00,0.00,0,0.00,'Ouvert',19),(35,0.00,0.00,0.00,0,0.00,'Ouvert',20),(49,0.00,0.00,0.00,0,0.00,'Ouvert',21),(50,0.00,0.00,0.00,0,0.00,'Ouvert',2),(51,0.00,0.00,0.00,0,0.00,'Ouvert',3),(52,0.00,0.00,0.00,0,0.00,'Ouvert',3),(73,0.00,0.00,0.00,0,0.00,'Ouvert',42),(76,0.00,0.00,0.00,0,0.00,'Ouvert',45),(77,0.00,0.00,0.00,0,0.00,'Ouvert',46),(78,28.80,1.58,30.38,2,30.38,'En commande',47),(79,48.70,2.68,51.38,3,51.38,'En commande',47),(80,0.00,0.00,0.00,0,0.00,'Ouvert',47),(90,174.90,9.62,184.52,1,184.52,'En commande',1),(148,69.70,3.83,73.53,2,73.53,'Ouvert',1),(155,0.00,0.00,0.00,0,0.00,'Ouvert',48),(156,0.00,0.00,0.00,0,0.00,'Ouvert',49);
/*!40000 ALTER TABLE `panier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payement`
--

DROP TABLE IF EXISTS `payement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payement` (
  `idPayement` int(11) NOT NULL AUTO_INCREMENT,
  `Type` varchar(50) NOT NULL,
  `idCB` int(11) DEFAULT NULL,
  PRIMARY KEY (`idPayement`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payement`
--

LOCK TABLES `payement` WRITE;
/*!40000 ALTER TABLE `payement` DISABLE KEYS */;
INSERT INTO `payement` VALUES (0,'Boutique',NULL),(1,'CB',1),(2,'CB',2),(3,'CB',3),(4,'CB',4),(5,'CB',5),(6,'CB',6),(7,'CB',7),(8,'CB',8),(9,'CB',9),(10,'CB',10),(11,'CB',11),(12,'CB',12),(13,'CB',13),(14,'CB',14),(15,'CB',15),(16,'CB',1),(17,'CB',2),(18,'CB',3),(19,'CB',20),(20,'CB',20);
/*!40000 ALTER TABLE `payement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxe`
--

DROP TABLE IF EXISTS `taxe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxe` (
  `Id_Taxe` int(11) NOT NULL AUTO_INCREMENT,
  `Designation_Taxe` varchar(50) NOT NULL,
  `Pourcentage_Taxe` decimal(15,2) NOT NULL,
  PRIMARY KEY (`Id_Taxe`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxe`
--

LOCK TABLES `taxe` WRITE;
/*!40000 ALTER TABLE `taxe` DISABLE KEYS */;
INSERT INTO `taxe` VALUES (1,'TVA Alimentaire',5.50),(2,'TVA Standard',20.00);
/*!40000 ALTER TABLE `taxe` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendeur`
--

DROP TABLE IF EXISTS `vendeur`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendeur` (
  `Id_Vendeur` int(11) NOT NULL AUTO_INCREMENT,
  `Nom_Prenom_Vendeur` varchar(50) NOT NULL,
  `Tel_Vendeur` int(11) NOT NULL,
  `Mail_Vendeur` varchar(50) NOT NULL,
  `MDP_Vendeur` varchar(255) NOT NULL,
  `Salaire_Vendeur` decimal(15,2) NOT NULL,
  `Date_de_naissance_Vendeur` date NOT NULL,
  PRIMARY KEY (`Id_Vendeur`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendeur`
--

LOCK TABLES `vendeur` WRITE;
/*!40000 ALTER TABLE `vendeur` DISABLE KEYS */;
INSERT INTO `vendeur` VALUES (1,'Emma Laurent',601020304,'emma.laurent@cafetheshop.fr','EmL2024#',2200.00,'1992-05-15'),(2,'Thomas Dubois',602030405,'thomas.dubois@cafetheshop.fr','ThD2024!',2100.00,'1995-03-22'),(3,'Sophie Moreau',603040506,'sophie.moreau@cafetheshop.fr','SoM2024@',2300.00,'1988-11-30'),(4,'Lucas Martin',604050607,'lucas.martin@cafetheshop.fr','LuM2024$',2150.00,'1990-07-18'),(5,'Julie Bernard',605060708,'julie.bernard@cafetheshop.fr','JuB2024%',2250.00,'1993-09-25'),(11,'Antoine Richard',606070809,'antoine.richard@cafetheshop.fr','AnR2024#',2180.00,'1991-08-12'),(12,'Marie Lefevre',607080910,'marie.lefevre@cafetheshop.fr','MaL2024!',2220.00,'1994-02-28'),(13,'Hugo Martinez',608091011,'hugo.martinez@cafetheshop.fr','HuM2024@',2160.00,'1989-11-15'),(14,'Léa Dubois',609101112,'lea.dubois@cafetheshop.fr','LeD2024$',2280.00,'1993-06-20'),(15,'Paul Simon',610111213,'paul.simon@cafetheshop.fr','PaS2024%',2190.00,'1990-04-05'),(21,'Gwen Stacy',123456789,'gwen.stacy99@gmail.com','$2b$10$OEO4PT8dvSPidqxKaS6S4eoh0LFW0ssnSZqytFAqFPZksGjgE8Vzq',3200.00,'1999-06-18');
/*!40000 ALTER TABLE `vendeur` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ville`
--

DROP TABLE IF EXISTS `ville`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ville` (
  `Adresse_Ville` int(11) NOT NULL,
  `Nom_Ville` varchar(50) NOT NULL,
  PRIMARY KEY (`Adresse_Ville`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ville`
--

LOCK TABLES `ville` WRITE;
/*!40000 ALTER TABLE `ville` DISABLE KEYS */;
INSERT INTO `ville` VALUES (0,'36100'),(6000,'Nice'),(13001,'Marseille'),(13002,'Marseille'),(31000,'Toulouse'),(32500,'Saint-Pierre'),(33000,'Bordeaux'),(34000,'Montpellier'),(35000,'Rennes'),(41000,'Blois'),(41700,'contres'),(41900,'Villemandeur'),(44000,'Nantes'),(59000,'Lille'),(67000,'Strasbourg'),(69001,'Lyon'),(69002,'Lyon'),(75000,'Paris'),(75001,'Paris'),(75002,'Paris'),(75003,'Paris');
/*!40000 ALTER TABLE `ville` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'CafTheBDD'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-24  8:11:01
