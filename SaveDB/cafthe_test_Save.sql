-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : jeu. 16 jan. 2025 à 15:47
-- Version du serveur : 8.0.30
-- Version de PHP : 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cafthe_test`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`Sacha`@`%` PROCEDURE `After_Panier_Delete` (IN `id_sup` INT)   BEGIN 
	DELETE FROM ligne_de_panier AS LP
    WHERE LP.Id_Panier = id_sup;
    
    DELETE FROM panier AS P 
    WHERE P.Id_Panier = id_sup;
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `CreateNewPanierForClients` ()   BEGIN
    -- Crée un nouveau panier pour les clients dont le panier n'est plus ouvert
    INSERT INTO Panier (Identifiant_Client, Status, Prix_HT_Panier, Prix_TVA_Panier, Prix_TTC_Panier, Nombre_de_lignes_Panier, Montant_Panier)
    SELECT c.Identifiant_Client, 'Ouvert', 0, 0, 0, 0, 0
    FROM Client c
    WHERE NOT EXISTS (
        SELECT 1
        FROM Panier p
        WHERE p.Identifiant_Client = c.Identifiant_Client
          AND p.Status = 'Ouvert'
    );
    
    -- Vérifie si des paniers ont été créés
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aucun panier n\'a été créé pour les clients.';
    END IF;
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `UpdateAllClientsInPanier` ()   BEGIN
    -- Met à jour l'Identifiant_Client pour tous les paniers associés à une commande
    UPDATE Panier p
    JOIN Commande c ON p.Id_Panier = c.Id_Panier
    SET p.Identifiant_Client = c.Identifiant_Client;
    
    -- Vérifie si des paniers n'ont pas été mis à jour (cas où la commande n'a pas d'Identifiant_Client)
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aucun panier n\'a été mis à jour.';
    END IF;
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `UpdateAllPanierStatusFromCommande` ()   BEGIN
    -- Met à jour le Status des paniers en fonction du Status_Commande de la commande associée
    UPDATE Panier p
    JOIN Commande c ON p.Id_Panier = c.Id_Panier
    SET p.Status = 
        CASE
            WHEN c.Status_Commande IN ('En préparation', 'En cours', 'Validée') THEN 'En commande'
            WHEN c.Status_Commande = 'Livrée' THEN 'Fermé'
            ELSE 'Ouvert'
        END;
    
    -- Vérifie si des paniers n'ont pas été mis à jour
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Aucun panier n\'a été mis à jour.';
    END IF;
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `UpdatePrixLignePanier` ()   BEGIN
    -- Met à jour les prix unitaires des lignes de panier
    UPDATE Ligne_de_panier AS lp
    INNER JOIN Article AS a
        ON lp.Id_Article = a.Id_Article
    SET lp.Prix_unitaire_Ligne_de_panier = a.Prix_unitaire_Article
    WHERE lp.Prix_unitaire_Ligne_de_panier <> a.Prix_unitaire_Article;
    
    -- Optionnel : affichage des lignes modifiées (pour vérification)
    SELECT lp.Id_Ligne_de_panier, lp.Id_Article, lp.Prix_unitaire_Ligne_de_panier AS Nouveau_prix
    FROM Ligne_de_panier AS lp
    INNER JOIN Article AS a
        ON lp.Id_Article = a.Id_Article
    WHERE lp.Prix_unitaire_Ligne_de_panier = a.Prix_unitaire_Article;
    
    -- Appelle la procédure pour mettre à jour les prix des paniers
    CALL UpdatePrixPanier();
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `UpdatePrixPanier` ()   BEGIN
    -- Mise à jour des prix HT, TVA et TTC pour chaque panier
    UPDATE Panier AS p
    SET 
        -- Calcul du prix HT total
        p.Prix_HT_Panier = (
            SELECT IFNULL(SUM(lp.Prix_unitaire_Ligne_de_panier * 
                             CAST(lp.Quantite_Ligne_de_panier AS DECIMAL(15,2))), 0)
            FROM Ligne_de_panier AS lp
            WHERE lp.Id_Panier = p.Id_Panier
        ),
        
        -- Calcul de la TVA et du TTC
        p.Prix_TVA_Panier = p.Prix_HT_Panier * 0.20,  -- TVA à 20% (par exemple)
        p.Prix_TTC_Panier = p.Prix_HT_Panier + p.Prix_TVA_Panier,
        p.Montant_Panier = p.Prix_TTC_Panier;
    
    -- Optionnel : afficher les paniers mis à jour pour vérification
    SELECT Id_Panier, Prix_HT_Panier, Prix_TVA_Panier, Prix_TTC_Panier, Montant_Panier
    FROM Panier;
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `UpdateStockFromExistingCommandes` ()   BEGIN
    -- Met à jour les stocks en fonction des commandes existantes
    UPDATE Article AS a
    INNER JOIN (
        SELECT 
            lp.Id_Article, 
            SUM(lp.Quantite_Ligne_de_panier) AS TotalCommande,
            COUNT(DISTINCT c.Id_Commande) AS NombreCommandes
        FROM Ligne_de_panier AS lp
        INNER JOIN Commande AS c
            ON lp.Id_Panier = c.Id_Panier
        GROUP BY lp.Id_Article
    ) AS commandes
    ON a.Id_Article = commandes.Id_Article
    SET 
        a.Quantite_Article = a.Quantite_Article - commandes.TotalCommande,
        a.Quantite_vendu_Article = a.Quantite_vendu_Article + commandes.TotalCommande,
        a.Nombre_de_vente_Article = a.Nombre_de_vente_Article + commandes.NombreCommandes;

    -- Vérifie si des stocks deviennent négatifs
    IF EXISTS (SELECT 1 FROM Article WHERE Quantite_Article < 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuffisant après mise à jour des commandes existantes.';
    END IF;
END$$

CREATE DEFINER=`Sacha`@`%` PROCEDURE `VerifierDoublons` ()   BEGIN
    -- Variables pour stocker les résultats
    DECLARE doublons_trouves BOOLEAN DEFAULT FALSE;
    
    -- Vendeur : vérification email et téléphone
    IF EXISTS (
        SELECT Tel_Vendeur, COUNT(*) 
        FROM Vendeur 
        GROUP BY Tel_Vendeur 
        HAVING COUNT(*) > 1
    ) OR EXISTS (
        SELECT Mail_Vendeur, COUNT(*) 
        FROM Vendeur 
        GROUP BY Mail_Vendeur 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Vendeur (téléphone ou email)' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Ville : vérification du couple code postal/nom
    IF EXISTS (
        SELECT Nom_Ville, Adresse_Ville, COUNT(*) 
        FROM Ville 
        GROUP BY Nom_Ville, Adresse_Ville 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Ville' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Client : vérification email et téléphone
    IF EXISTS (
        SELECT Tel_Client, COUNT(*) 
        FROM Client 
        GROUP BY Tel_Client 
        HAVING COUNT(*) > 1
    ) OR EXISTS (
        SELECT Mail_Client, COUNT(*) 
        FROM Client 
        GROUP BY Mail_Client 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Client (téléphone ou email)' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Mesure : vérification désignation
    IF EXISTS (
        SELECT Designation_Mesure, COUNT(*) 
        FROM Mesure 
        GROUP BY Designation_Mesure 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Mesure' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Taxe : vérification désignation
    IF EXISTS (
        SELECT Designation_Taxe, COUNT(*) 
        FROM Taxe 
        GROUP BY Designation_Taxe 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Taxe' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Article : vérification désignation
    IF EXISTS (
        SELECT Designation_Article, COUNT(*) 
        FROM Article 
        GROUP BY Designation_Article 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Article' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Carte bancaire : vérification numéro de carte
    IF EXISTS (
        SELECT Numero_CB, COUNT(*) 
        FROM Carte_banquaire 
        GROUP BY Numero_CB 
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Carte_banquaire' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Adresse : vérification adresse complète
    IF EXISTS (
        SELECT Bis_Ter_Numero_de_voie, Nom_commune_Adresse, Numero_Voie, Type_Voie, Code_postal_Voie, COUNT(*) 
        FROM Adresse 
        GROUP BY Bis_Ter_Numero_de_voie, Nom_commune_Adresse, Numero_Voie, Type_Voie, Code_postal_Voie
        HAVING COUNT(*) > 1
    ) THEN
        SELECT 'ATTENTION: Doublons trouvés dans la table Adresse' AS Message;
        SET doublons_trouves = TRUE;
    END IF;

    -- Message si aucun doublon n'est trouvé
    IF NOT doublons_trouves THEN
        SELECT 'Aucun doublon trouvé dans la base de données' AS Message;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `adresse`
--

CREATE TABLE `adresse` (
  `Id_Adresse` int NOT NULL,
  `Bis_Ter_Numero_de_voie` int NOT NULL,
  `Nom_commune_Adresse` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Nom_Type_Voie` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Complement_Voie` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Code_postal_Voie` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Numero_Voie` int NOT NULL,
  `Type_Voie` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Id_Vendeur` int DEFAULT NULL,
  `Adresse_Ville` int NOT NULL,
  `Identifiant_Client` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `adresse`
--

INSERT INTO `adresse` (`Id_Adresse`, `Bis_Ter_Numero_de_voie`, `Nom_commune_Adresse`, `Nom_Type_Voie`, `Complement_Voie`, `Code_postal_Voie`, `Numero_Voie`, `Type_Voie`, `Id_Vendeur`, `Adresse_Ville`, `Identifiant_Client`) VALUES
(11, 0, 'Paris', 'Rue de la Paix', 'Apt 3B', '75001', 15, 'rue', 1, 75001, 1),
(12, 1, 'Paris', 'Avenue des Champs-Élysées', 'Étage 4', '75002', 25, 'avenue', NULL, 75002, 2),
(13, 0, 'Lyon', 'Rue de la République', 'Bât A', '69001', 8, 'rue', 2, 69001, 3),
(14, 0, 'Marseille', 'Boulevard du Prado', 'Étage 1', '13001', 45, 'boulevard', 3, 13001, 4),
(15, 2, 'Bordeaux', 'Cours de l\'Intendance', 'Apt 2C', '33000', 12, 'cours', NULL, 33000, 5),
(16, 0, 'Nantes', 'Rue Crébillon', 'Rien', '44000', 33, 'rue', NULL, 44000, 6),
(17, 0, 'Toulouse', 'Rue Alsace-Lorraine', 'Étage 1', '31000', 18, 'rue', NULL, 31000, 7),
(18, 1, 'Lyon', 'Rue Mercière', 'Apt 5D', '69002', 22, 'rue', NULL, 69002, 8),
(19, 0, 'Marseille', 'Rue Paradis', 'Rien', '13002', 56, 'rue', NULL, 13002, 9),
(20, 0, 'Paris', 'Rue du Commerce', 'Bât B', '75003', 41, 'rue', NULL, 75003, 10),
(26, 0, 'Lille', 'Rue Nationale', 'Apt 4C', '59000', 28, 'rue', NULL, 59000, 11),
(27, 0, 'Strasbourg', 'Place Kléber', 'Étage 3', '67000', 15, 'place', NULL, 67000, 12),
(28, 1, 'Rennes', 'Rue de la Soif', 'Rien', '35000', 42, 'rue', NULL, 35000, 13),
(29, 0, 'Nice', 'Promenade des Anglais', 'Bât D', '06000', 156, 'promenade', NULL, 6000, 14),
(30, 2, 'Montpellier', 'Place de la Comédie', 'Apt 7B', '34000', 8, 'place', NULL, 34000, 15);

-- --------------------------------------------------------

--
-- Structure de la table `article`
--

CREATE TABLE `article` (
  `Id_Article` int NOT NULL,
  `Designation_Article` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Quantite_Article` int NOT NULL,
  `Prix_unitaire_Article` decimal(15,2) NOT NULL,
  `Description_Article` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Quantite_vendu_Article` int NOT NULL,
  `Nombre_de_vente_Article` int NOT NULL,
  `Id_Taxe` int NOT NULL,
  `Id_Mesure` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `article`
--

INSERT INTO `article` (`Id_Article`, `Designation_Article`, `Quantite_Article`, `Prix_unitaire_Article`, `Description_Article`, `Quantite_vendu_Article`, `Nombre_de_vente_Article`, `Id_Taxe`, `Id_Mesure`) VALUES
(1, 'Café Arabica Colombie', 498, 28.90, 'Café arabica de Colombie, notes florales et fruitées', 252, 126, 1, 1),
(2, 'Café Robusta Inde', 500, 22.50, 'Café robusta d\'Inde, corsé et puissant', 180, 90, 1, 1),
(3, 'Café Moka Éthiopie', 500, 32.00, 'Café moka d\'Éthiopie, notes de chocolat et d\'épices', 200, 100, 1, 1),
(4, 'Café Blue Mountain', 249, 89.90, 'Café premium de Jamaïque, équilibré et raffiné', 51, 26, 1, 1),
(5, 'Café Espresso Blend', 1000, 26.90, 'Mélange spécial pour espresso, intense et crémeux', 400, 200, 1, 1),
(6, 'Thé Earl Grey', 100, 12.90, 'Thé noir parfumé à la bergamote', 150, 75, 1, 1),
(7, 'Thé Vert Sencha', 97, 15.90, 'Thé vert japonais traditionnel', 123, 61, 1, 1),
(8, 'Thé Oolong', 100, 18.90, 'Thé semi-oxydé de Taiwan', 80, 40, 1, 1),
(9, 'Thé Darjeeling', 100, 16.90, 'Thé noir premium d\'Inde', 100, 50, 1, 1),
(10, 'Rooibos Vanilla', 100, 11.90, 'Infusion sud-africaine à la vanille', 90, 45, 1, 1),
(11, 'Machine Espresso Pro', 9, 599.00, 'Machine espresso semi-automatique 15 bars', 6, 6, 2, 3),
(12, 'Moulin à café électrique', 20, 89.90, 'Moulin à café avec meules coniques', 15, 15, 2, 3),
(13, 'French Press', 28, 34.90, 'Cafetière à piston en verre et inox', 27, 26, 2, 3),
(14, 'Théière en Fonte', 14, 79.90, 'Théière traditionnelle japonaise en fonte', 9, 9, 2, 3),
(15, 'Balance de précision', 25, 29.90, 'Balance digitale précision 0.1g', 20, 20, 2, 3),
(16, 'Filtre permanent inox', 45, 19.90, 'Filtre réutilisable pour dripper', 45, 42, 2, 3),
(17, 'Kit dégustation', 10, 49.90, 'Kit complet dégustation café', 6, 6, 2, 3),
(18, 'Tasses espresso x6', 28, 39.90, 'Set de 6 tasses espresso porcelaine', 27, 26, 2, 3),
(19, 'Bouilloire col de cygne', 19, 69.90, 'Bouilloire spéciale pour V60 et filtres', 16, 16, 2, 3),
(20, 'Boîte conservation 1kg', 36, 24.90, 'Boîte hermétique conservation café', 39, 36, 2, 3),
(21, 'Café Guatemala Antigua', 498, 31.90, 'Café d\'altitude aux notes de chocolat et d\'agrumes', 182, 91, 1, 1),
(22, 'Café Costa Rica Tarrazu', 499, 29.90, 'Notes de fruits rouges et de caramel', 161, 81, 1, 1),
(23, 'Café Kenya AA', 250, 27.90, 'Café corsé aux notes d\'agrumes', 140, 70, 1, 1),
(24, 'Café Sumatra Mandheling', 500, 26.90, 'Notes terreuses et épicées', 120, 60, 1, 1),
(25, 'Café Pérou Bio', 1000, 24.90, 'Café biologique aux notes douces et équilibrées', 200, 100, 1, 1),
(26, 'Thé Jasmin Imperial', 97, 16.90, 'Thé vert parfumé au jasmin', 113, 56, 1, 1),
(27, 'Thé Assam TGFOP', 100, 14.90, 'Thé noir indien corsé', 95, 47, 1, 1),
(28, 'Thé Long Jing', 50, 29.90, 'Thé vert chinois premium', 70, 35, 1, 1),
(29, 'Thé Blanc Bai Mu Dan', 50, 32.90, 'Thé blanc aux notes florales', 60, 30, 1, 1),
(30, 'Thé Pu Erh Vintage', 100, 45.90, 'Thé sombre affiné 5 ans', 40, 20, 1, 1),
(31, 'Dripper Céramique', 28, 29.90, 'Pour extraction manuelle V60', 27, 26, 2, 3),
(32, 'Grille-dosette ESE', 40, 19.90, 'Adaptateur pour machine espresso', 35, 35, 2, 3),
(33, 'Brosse à moulin', 50, 9.90, 'Brosse de nettoyage pour moulin à café', 45, 45, 2, 3),
(34, 'Set Cuillères Mesure', 60, 14.90, 'Set de 4 cuillères doseuses', 50, 50, 2, 3),
(35, 'Tasse Dégustation Pro', 39, 24.90, 'Tasse spéciale dégustation café', 31, 31, 2, 3);

-- --------------------------------------------------------

--
-- Structure de la table `carte_bancaire`
--

CREATE TABLE `carte_bancaire` (
  `Id_CB` int NOT NULL,
  `Type_CB` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Numero_CB` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Date_expiration_CB` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Nom_CB` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Cryptogramme_CB` int NOT NULL,
  `Identifiant_Client` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `carte_bancaire`
--

INSERT INTO `carte_bancaire` (`Id_CB`, `Type_CB`, `Numero_CB`, `Date_expiration_CB`, `Nom_CB`, `Cryptogramme_CB`, `Identifiant_Client`) VALUES
(1, 'Visa', '4532XXXXXXXX1234', '12/25', 'DURAND A', 123, 1),
(2, 'Mastercard', '5432XXXXXXXX5678', '09/24', 'LEFEBVRE M', 456, 2),
(3, 'Visa', '4556XXXXXXXX9012', '03/26', 'MARTIN P', 789, 3),
(4, 'Mastercard', '5187XXXXXXXX3456', '06/25', 'PETIT C', 234, 4),
(5, 'Visa', '4921XXXXXXXX7890', '11/24', 'ROUX F', 567, 5),
(6, 'Amex', '3782XXXXXXXX1234', '08/25', 'BLANC I', 890, 6),
(7, 'Visa', '4556XXXXXXXX5678', '04/26', 'GIRARD L', 123, 7),
(8, 'Mastercard', '5432XXXXXXXX9012', '07/25', 'ANDRE S', 456, 8),
(9, 'Visa', '4921XXXXXXXX3456', '10/24', 'MEYER N', 789, 9),
(10, 'Mastercard', '5187XXXXXXXX7890', '05/26', 'ROBERT C', 234, 10),
(11, 'Visa', '4539XXXXXXXX5678', '01/26', 'DUPUIS M', 345, 11),
(12, 'Mastercard', '5236XXXXXXXX1234', '03/25', 'MERCIER T', 678, 12),
(13, 'Visa', '4916XXXXXXXX9012', '07/26', 'LAMBERT J', 901, 13),
(14, 'Mastercard', '5137XXXXXXXX3456', '09/25', 'FOURNIER G', 234, 14),
(15, 'Visa', '4532XXXXXXXX7890', '11/25', 'ROUSSEAU E', 567, 15);

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

CREATE TABLE `client` (
  `Identifiant_Client` int NOT NULL,
  `Nom_Prenom_Client` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Date_de_naissance_Client` date NOT NULL,
  `Tel_Client` int NOT NULL,
  `Mail_Client` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `MDP_Client` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`Identifiant_Client`, `Nom_Prenom_Client`, `Date_de_naissance_Client`, `Tel_Client`, `Mail_Client`, `MDP_Client`) VALUES
(1, 'Alexandre Durand', '1985-07-12', 701020304, 'alex.durand@email.com', 'Cafe2024!'),
(2, 'Marie Lefebvre', '1990-09-25', 702030405, 'marie.lefebvre@email.com', 'The2024@'),
(3, 'Pierre Martin', '1988-03-18', 703040506, 'pierre.martin@email.com', 'Coffee2024#'),
(4, 'Céline Petit', '1992-11-30', 704050607, 'celine.petit@email.com', 'Tea2024$'),
(5, 'François Roux', '1987-04-15', 705060708, 'francois.roux@email.com', 'Espresso24!'),
(6, 'Isabelle Blanc', '1995-08-22', 706070809, 'isabelle.blanc@email.com', 'Latte2024@'),
(7, 'Laurent Girard', '1983-12-05', 707080910, 'laurent.girard@email.com', 'Mocha2024#'),
(8, 'Sophie Andre', '1993-06-28', 708091011, 'sophie.andre@email.com', 'Chai2024$'),
(9, 'Nicolas Meyer', '1989-02-14', 709101112, 'nicolas.meyer@email.com', 'Filter2024!'),
(10, 'Camille Robert', '1991-10-08', 710111213, 'camille.robert@email.com', 'Brew2024@'),
(11, 'Mathilde Dupuis', '1986-03-25', 711121314, 'mathilde.dupuis@email.com', 'Coffee25@'),
(12, 'Thomas Mercier', '1993-07-14', 712131415, 'thomas.mercier@email.com', 'Tea14Jul!'),
(13, 'Julie Lambert', '1990-12-08', 713141516, 'julie.lambert@email.com', 'JulieCafe#'),
(14, 'Gabriel Fournier', '1988-09-30', 714151617, 'gabriel.fournier@email.com', 'GabTea2024'),
(15, 'Emma Rousseau', '1995-01-17', 715161718, 'emma.rousseau@email.com', 'EmmaR2024!'),
(16, 'Louis Martin', '1987-06-22', 716171819, 'louis.martin@email.com', 'LouisM24@'),
(17, 'Sarah Cohen', '1992-04-11', 717181920, 'sarah.cohen@email.com', 'SarahTea#'),
(18, 'Hugo Bertrand', '1989-08-03', 718192021, 'hugo.bertrand@email.com', 'HugoCafe$'),
(19, 'Clara Dumont', '1994-11-28', 719202122, 'clara.dumont@email.com', 'ClaraTea!'),
(20, 'Antoine Moreau', '1991-02-15', 720212223, 'antoine.moreau@email.com', 'AntoineCafe@');

--
-- Déclencheurs `client`
--
DELIMITER $$
CREATE TRIGGER `CreatePanierForNewClient` AFTER INSERT ON `client` FOR EACH ROW BEGIN
    -- Crée un nouveau panier pour chaque nouveau client
    INSERT INTO Panier (Identifiant_Client, Status, Prix_HT_Panier, Prix_TVA_Panier, Prix_TTC_Panier, Nombre_de_lignes_Panier, Montant_Panier)
    VALUES (NEW.Identifiant_Client, 'Ouvert', 0, 0, 0, 0, 0);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

CREATE TABLE `commande` (
  `Id_Commande` int NOT NULL,
  `Nombre_Ligne_de_commande` int DEFAULT NULL,
  `Status_Commande` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Date_prise_Commande` date DEFAULT NULL,
  `Id_Adresse` int DEFAULT NULL,
  `Id_Adresse_1` int NOT NULL,
  `Id_Vendeur` int DEFAULT NULL,
  `Id_CB` int DEFAULT NULL,
  `Id_Panier` int NOT NULL,
  `Identifiant_Client` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`Id_Commande`, `Nombre_Ligne_de_commande`, `Status_Commande`, `Date_prise_Commande`, `Id_Adresse`, `Id_Adresse_1`, `Id_Vendeur`, `Id_CB`, `Id_Panier`, `Identifiant_Client`) VALUES
(11, 2, 'Livrée', '2025-01-13', 11, 11, 1, 1, 1, 1),
(12, 3, 'En cours', '2025-01-14', 12, 12, 2, 2, 2, 2),
(13, 4, 'En préparation', '2025-01-14', 13, 13, 3, 3, 3, 3),
(14, 1, 'Livrée', '2025-01-12', 14, 13, 1, 4, 4, 4),
(15, 2, 'En cours', '2025-01-14', 15, 11, 2, 5, 5, 5),
(16, 1, 'Validée', '2025-01-14', 16, 17, 3, 6, 6, 6),
(17, 3, 'En préparation', '2025-01-14', 17, 17, 1, 7, 7, 7),
(18, 2, 'Livrée', '2025-01-11', 18, 18, 2, 8, 8, 8),
(19, 2, 'En cours', '2025-01-14', 19, 19, 3, 9, 9, 9),
(20, 1, 'Validée', '2025-01-14', 20, 20, 1, 10, 10, 10),
(21, 2, 'En préparation', '2025-01-14', 11, 11, 1, 11, 11, 11),
(22, 3, 'Validée', '2025-01-14', 12, 12, 2, 12, 12, 12),
(23, 2, 'En cours', '2025-01-14', 13, 13, 3, 13, 13, 13),
(24, 4, 'En préparation', '2025-01-14', 14, 14, 4, 14, 14, 14),
(25, 3, 'Validée', '2025-01-14', 15, 15, 5, 15, 15, 15),
(27, 1, 'Livrée', '2025-01-16', 11, 15, NULL, 1, 16, 1);

--
-- Déclencheurs `commande`
--
DELIMITER $$
CREATE TRIGGER `After_Commande_Delete` AFTER DELETE ON `commande` FOR EACH ROW BEGIN
    UPDATE panier AS P 
    SET P.Status = 'Ouvert'
    WHERE P.Id_Panier = OLD.Id_Panier;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `After_Commande_Insert_Update` AFTER INSERT ON `commande` FOR EACH ROW BEGIN
    -- Met à jour l'Identifiant_Client dans le panier
    UPDATE Panier
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `After_Commande_Update` AFTER UPDATE ON `commande` FOR EACH ROW BEGIN
    IF NEW.Status_Commande != OLD.Status_Commande THEN
        UPDATE Panier
        SET Status = CASE 
            WHEN NEW.Status_Commande IN ('En préparation', 'En cours', 'Validée') THEN 'En commande'
            WHEN NEW.Status_Commande = 'Livrée' THEN 'Fermé'
            WHEN NEW.Status_Commande = 'terminée' THEN 'terminé'
            ELSE 'Ouvert'
        END
        WHERE Id_Panier = NEW.Id_Panier;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `InsertCommandeWithDefaults` BEFORE INSERT ON `commande` FOR EACH ROW BEGIN
    -- Vérifie et récupère Identifiant_Client depuis le panier si nécessaire
    IF NEW.Identifiant_Client IS NULL THEN
        SELECT Identifiant_Client INTO @Identifiant_Client
        FROM Panier
        WHERE Id_Panier = NEW.Id_Panier;

        IF @Identifiant_Client IS NULL THEN
            SET @error_message = CONCAT('Identifiant_Client manquant pour le panier Id_Panier = ', CAST(NEW.Id_Panier AS CHAR));
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = @error_message;
        ELSE
            SET NEW.Identifiant_Client = @Identifiant_Client;
        END IF;
    END IF;

    -- Définit le statut par défaut si non fourni
    IF NEW.Status_Commande IS NULL THEN
        SET NEW.Status_Commande = 'En préparation';
    END IF;

    -- Récupère l'adresse de facturation
    IF NEW.Id_Adresse IS NULL THEN
        SELECT Id_Adresse INTO @Id_Adresse
        FROM Adresse
        WHERE Identifiant_Client = NEW.Identifiant_Client
        LIMIT 1;

        IF @Id_Adresse IS NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Id_Adresse (facturation) manquant pour le client';
        ELSE
            SET NEW.Id_Adresse = @Id_Adresse;
        END IF;
    END IF;

    -- Calcule le nombre de lignes de panier
    SELECT COUNT(*) INTO @Nombre_Ligne_de_commande
    FROM Ligne_de_panier
    WHERE Id_Panier = NEW.Id_Panier;

    SET NEW.Nombre_Ligne_de_commande = @Nombre_Ligne_de_commande;

    -- Définit la date de commande
    SET NEW.Date_prise_Commande = CURDATE();

    -- Récupère la carte bancaire
    SELECT Id_CB INTO @Id_CB
    FROM Carte_bancaire
    WHERE Identifiant_Client = NEW.Identifiant_Client
    LIMIT 1;

    IF @Id_CB IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Carte bancaire manquante pour le client';
    ELSE
        SET NEW.Id_CB = @Id_CB;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `NewPanierAfterCommande` AFTER UPDATE ON `commande` FOR EACH ROW BEGIN 
    IF NEW.Status_Commande = 'Livrée' THEN
        INSERT INTO Panier (Identifiant_Client, Status, Prix_HT_Panier, Prix_TVA_Panier, Prix_TTC_Panier, Nombre_de_lignes_Panier, Montant_Panier)
        VALUES (NEW.Identifiant_Client, 'Ouvert', 0, 0, 0, 0, 0);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateStockOnNewCommande` AFTER INSERT ON `commande` FOR EACH ROW BEGIN
    -- Met à jour les stocks et les quantités vendues pour chaque article dans la commande
    UPDATE Article AS a
    INNER JOIN (
        SELECT 
            lp.Id_Article, 
            SUM(lp.Quantite_Ligne_de_panier) AS Quantite_Commandee,
            COUNT(DISTINCT NEW.Id_Commande) AS NombreCommandes
        FROM Ligne_de_panier AS lp
        WHERE lp.Id_Panier = NEW.Id_Panier
        GROUP BY lp.Id_Article
    ) AS commandes
    ON a.Id_Article = commandes.Id_Article
    SET 
        a.Quantite_Article = a.Quantite_Article - commandes.Quantite_Commandee,
        a.Quantite_vendu_Article = a.Quantite_vendu_Article + commandes.Quantite_Commandee,
        a.Nombre_de_vente_Article = a.Nombre_de_vente_Article + commandes.NombreCommandes;

    -- Vérifie si des stocks deviennent négatifs
    IF EXISTS (SELECT 1 FROM Article WHERE Quantite_Article < 0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuffisant pour compléter cette commande.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `ligne_de_panier`
--

CREATE TABLE `ligne_de_panier` (
  `Id_Panier` int NOT NULL,
  `Id_Ligne_de_panier` int NOT NULL,
  `Quantite_Ligne_de_panier` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Prix_unitaire_Ligne_de_panier` decimal(15,2) DEFAULT NULL,
  `Id_Article` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `ligne_de_panier`
--

INSERT INTO `ligne_de_panier` (`Id_Panier`, `Id_Ligne_de_panier`, `Quantite_Ligne_de_panier`, `Prix_unitaire_Ligne_de_panier`, `Id_Article`) VALUES
(1, 1, '2', 28.90, 1),
(2, 2, '1', 89.90, 4),
(3, 3, '3', 15.90, 7),
(4, 4, '1', 599.00, 11),
(5, 5, '2', 34.90, 13),
(6, 6, '1', 79.90, 14),
(7, 7, '3', 19.90, 16),
(8, 8, '2', 39.90, 18),
(9, 9, '1', 69.90, 19),
(10, 10, '4', 24.90, 20),
(11, 11, '2', 31.90, 21),
(12, 12, '1', 29.90, 22),
(13, 13, '3', 16.90, 26),
(14, 14, '2', 29.90, 31),
(15, 15, '1', 24.90, 35),
(16, 16, '2', 19.90, 16);

--
-- Déclencheurs `ligne_de_panier`
--
DELIMITER $$
CREATE TRIGGER `Recherche_Prix_Unitaire_Ligne_Panier` BEFORE INSERT ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Si le prix unitaire est NULL, on va chercher le prix dans la table article
    IF NEW.Prix_unitaire_Ligne_de_panier IS NULL THEN
        SET NEW.Prix_unitaire_Ligne_de_panier = (
            SELECT Prix_unitaire_Article
            FROM article
            WHERE Id_Article = NEW.Id_Article
            LIMIT 1
        );
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Update_Prix_Panier_After_Delete` AFTER DELETE ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Variables pour stocker les calculs intermédiaires
    DECLARE total_ht DECIMAL(15,2);
    DECLARE total_tva DECIMAL(15,2);
    DECLARE total_ttc DECIMAL(15,2);
    DECLARE taux_tva DECIMAL(15,2);
    
    -- Calcul du prix HT pour toutes les lignes restantes du panier
    SELECT COALESCE(SUM(lp.Prix_unitaire_Ligne_de_panier * CAST(lp.Quantite_Ligne_de_panier AS DECIMAL)), 0)
    INTO total_ht
    FROM ligne_de_panier lp
    WHERE lp.Id_Panier = OLD.Id_Panier;
    
    -- Récupération du taux de TVA de l'article
    SELECT t.Pourcentage_Taxe 
    INTO taux_tva
    FROM article a
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Update_Prix_Panier_After_Insert` AFTER INSERT ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Variables pour stocker les calculs intermédiaires
    DECLARE total_ht DECIMAL(15,2);
    DECLARE total_tva DECIMAL(15,2);
    DECLARE total_ttc DECIMAL(15,2);
    DECLARE taux_tva DECIMAL(15,2);
    
    -- Calcul du prix HT pour toutes les lignes du panier
    SELECT SUM(lp.Prix_unitaire_Ligne_de_panier * CAST(lp.Quantite_Ligne_de_panier AS DECIMAL))
    INTO total_ht
    FROM ligne_de_panier lp
    WHERE lp.Id_Panier = NEW.Id_Panier;
    
    -- Récupération du taux de TVA de l'article
    SELECT t.Pourcentage_Taxe 
    INTO taux_tva
    FROM article a
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Update_Prix_Panier_After_Update` AFTER UPDATE ON `ligne_de_panier` FOR EACH ROW BEGIN
    -- Variables pour stocker les calculs intermédiaires
    DECLARE total_ht DECIMAL(15,2);
    DECLARE total_tva DECIMAL(15,2);
    DECLARE total_ttc DECIMAL(15,2);
    DECLARE taux_tva DECIMAL(15,2);
    
    -- Calcul du prix HT pour toutes les lignes du panier
    SELECT SUM(lp.Prix_unitaire_Ligne_de_panier * CAST(lp.Quantite_Ligne_de_panier AS DECIMAL))
    INTO total_ht
    FROM ligne_de_panier lp
    WHERE lp.Id_Panier = NEW.Id_Panier;
    
    -- Récupération du taux de TVA de l'article
    SELECT t.Pourcentage_Taxe 
    INTO taux_tva
    FROM article a
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `mesure`
--

CREATE TABLE `mesure` (
  `Id_Mesure` int NOT NULL,
  `Designation_Mesure` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `mesure`
--

INSERT INTO `mesure` (`Id_Mesure`, `Designation_Mesure`) VALUES
(1, 'Poids'),
(3, 'Boîte');

-- --------------------------------------------------------

--
-- Structure de la table `panier`
--

CREATE TABLE `panier` (
  `Id_Panier` int NOT NULL,
  `Prix_HT_Panier` decimal(15,2) NOT NULL,
  `Prix_TVA_Panier` decimal(15,2) NOT NULL,
  `Prix_TTC_Panier` decimal(15,2) NOT NULL,
  `Nombre_de_lignes_Panier` int DEFAULT NULL,
  `Montant_Panier` decimal(15,2) NOT NULL,
  `Status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'actif',
  `Identifiant_Client` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `panier`
--

INSERT INTO `panier` (`Id_Panier`, `Prix_HT_Panier`, `Prix_TVA_Panier`, `Prix_TTC_Panier`, `Nombre_de_lignes_Panier`, `Montant_Panier`, `Status`, `Identifiant_Client`) VALUES
(1, 57.80, 11.56, 69.36, 2, 69.36, 'Fermé', 1),
(2, 89.90, 17.98, 107.88, 3, 107.88, 'En commande', 2),
(3, 47.70, 9.54, 57.24, 4, 57.24, 'En commande', 3),
(4, 599.00, 119.80, 718.80, 1, 718.80, 'Fermé', 4),
(5, 69.80, 13.96, 83.76, 2, 83.76, 'En commande', 5),
(6, 79.90, 15.98, 95.88, 1, 95.88, 'En commande', 6),
(7, 59.70, 11.94, 71.64, 3, 71.64, 'En commande', 7),
(8, 79.80, 15.96, 95.76, 2, 95.76, 'Fermé', 8),
(9, 69.90, 13.98, 83.88, 2, 83.88, 'En commande', 9),
(10, 99.60, 19.92, 119.52, 1, 119.52, 'En commande', 10),
(11, 63.80, 12.76, 76.56, 2, 76.56, 'En commande', 11),
(12, 29.90, 5.98, 35.88, 3, 35.88, 'En commande', 12),
(13, 50.70, 10.14, 60.84, 2, 60.84, 'En commande', 13),
(14, 59.80, 11.96, 71.76, 4, 71.76, 'En commande', 14),
(15, 24.90, 4.98, 29.88, 3, 29.88, 'En commande', 15),
(16, 39.80, 7.96, 47.76, 1, 47.76, 'Fermé', 1),
(17, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 2),
(18, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 3),
(19, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 4),
(20, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 5),
(21, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 6),
(22, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 7),
(23, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 8),
(24, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 9),
(25, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 10),
(26, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 11),
(27, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 12),
(28, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 13),
(29, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 14),
(30, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 15),
(31, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 16),
(32, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 17),
(33, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 18),
(34, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 19),
(35, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 20),
(47, 0.00, 0.00, 0.00, 0, 0.00, 'Ouvert', 1);

-- --------------------------------------------------------

--
-- Structure de la table `taxe`
--

CREATE TABLE `taxe` (
  `Id_Taxe` int NOT NULL,
  `Designation_Taxe` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Pourcentage_Taxe` decimal(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `taxe`
--

INSERT INTO `taxe` (`Id_Taxe`, `Designation_Taxe`, `Pourcentage_Taxe`) VALUES
(1, 'TVA Alimentaire', 5.50),
(2, 'TVA Standard', 20.00);

-- --------------------------------------------------------

--
-- Structure de la table `vendeur`
--

CREATE TABLE `vendeur` (
  `Id_Vendeur` int NOT NULL,
  `Nom_Prenom_Vendeur` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Tel_Vendeur` int NOT NULL,
  `Mail_Vendeur` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `MDP_Vendeur` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `Salaire_Vendeur` decimal(15,2) NOT NULL,
  `Date_de_naissace_Vendeur` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `vendeur`
--

INSERT INTO `vendeur` (`Id_Vendeur`, `Nom_Prenom_Vendeur`, `Tel_Vendeur`, `Mail_Vendeur`, `MDP_Vendeur`, `Salaire_Vendeur`, `Date_de_naissace_Vendeur`) VALUES
(1, 'Emma Laurent', 601020304, 'emma.laurent@cafetheshop.fr', 'EmL2024#', 2200.00, '1992-05-15'),
(2, 'Thomas Dubois', 602030405, 'thomas.dubois@cafetheshop.fr', 'ThD2024!', 2100.00, '1995-03-22'),
(3, 'Sophie Moreau', 603040506, 'sophie.moreau@cafetheshop.fr', 'SoM2024@', 2300.00, '1988-11-30'),
(4, 'Lucas Martin', 604050607, 'lucas.martin@cafetheshop.fr', 'LuM2024$', 2150.00, '1990-07-18'),
(5, 'Julie Bernard', 605060708, 'julie.bernard@cafetheshop.fr', 'JuB2024%', 2250.00, '1993-09-25'),
(11, 'Antoine Richard', 606070809, 'antoine.richard@cafetheshop.fr', 'AnR2024#', 2180.00, '1991-08-12'),
(12, 'Marie Lefevre', 607080910, 'marie.lefevre@cafetheshop.fr', 'MaL2024!', 2220.00, '1994-02-28'),
(13, 'Hugo Martinez', 608091011, 'hugo.martinez@cafetheshop.fr', 'HuM2024@', 2160.00, '1989-11-15'),
(14, 'Léa Dubois', 609101112, 'lea.dubois@cafetheshop.fr', 'LeD2024$', 2280.00, '1993-06-20'),
(15, 'Paul Simon', 610111213, 'paul.simon@cafetheshop.fr', 'PaS2024%', 2190.00, '1990-04-05');

-- --------------------------------------------------------

--
-- Structure de la table `ville`
--

CREATE TABLE `ville` (
  `Adresse_Ville` int NOT NULL,
  `Nom_Ville` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `ville`
--

INSERT INTO `ville` (`Adresse_Ville`, `Nom_Ville`) VALUES
(6000, 'Nice'),
(13001, 'Marseille'),
(13002, 'Marseille'),
(31000, 'Toulouse'),
(33000, 'Bordeaux'),
(34000, 'Montpellier'),
(35000, 'Rennes'),
(44000, 'Nantes'),
(59000, 'Lille'),
(67000, 'Strasbourg'),
(69001, 'Lyon'),
(69002, 'Lyon'),
(75001, 'Paris'),
(75002, 'Paris'),
(75003, 'Paris');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `adresse`
--
ALTER TABLE `adresse`
  ADD PRIMARY KEY (`Id_Adresse`),
  ADD KEY `Id_Vendeur` (`Id_Vendeur`),
  ADD KEY `Adresse_Ville` (`Adresse_Ville`),
  ADD KEY `Identifiant_Client` (`Identifiant_Client`);

--
-- Index pour la table `article`
--
ALTER TABLE `article`
  ADD PRIMARY KEY (`Id_Article`),
  ADD KEY `Id_Taxe` (`Id_Taxe`),
  ADD KEY `Id_Mesure` (`Id_Mesure`);

--
-- Index pour la table `carte_bancaire`
--
ALTER TABLE `carte_bancaire`
  ADD PRIMARY KEY (`Id_CB`),
  ADD KEY `Identifiant_Client` (`Identifiant_Client`);

--
-- Index pour la table `client`
--
ALTER TABLE `client`
  ADD PRIMARY KEY (`Identifiant_Client`);

--
-- Index pour la table `commande`
--
ALTER TABLE `commande`
  ADD PRIMARY KEY (`Id_Commande`),
  ADD KEY `Id_Adresse` (`Id_Adresse`),
  ADD KEY `Id_Adresse_1` (`Id_Adresse_1`),
  ADD KEY `Id_Vendeur` (`Id_Vendeur`),
  ADD KEY `Id_CB` (`Id_CB`),
  ADD KEY `Id_Panier` (`Id_Panier`),
  ADD KEY `Identifiant_Client` (`Identifiant_Client`);

--
-- Index pour la table `ligne_de_panier`
--
ALTER TABLE `ligne_de_panier`
  ADD PRIMARY KEY (`Id_Ligne_de_panier`),
  ADD KEY `Id_Panier` (`Id_Panier`),
  ADD KEY `Id_Article` (`Id_Article`);

--
-- Index pour la table `mesure`
--
ALTER TABLE `mesure`
  ADD PRIMARY KEY (`Id_Mesure`);

--
-- Index pour la table `panier`
--
ALTER TABLE `panier`
  ADD PRIMARY KEY (`Id_Panier`),
  ADD KEY `Identifiant_Client` (`Identifiant_Client`);

--
-- Index pour la table `taxe`
--
ALTER TABLE `taxe`
  ADD PRIMARY KEY (`Id_Taxe`);

--
-- Index pour la table `vendeur`
--
ALTER TABLE `vendeur`
  ADD PRIMARY KEY (`Id_Vendeur`);

--
-- Index pour la table `ville`
--
ALTER TABLE `ville`
  ADD PRIMARY KEY (`Adresse_Ville`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `adresse`
--
ALTER TABLE `adresse`
  MODIFY `Id_Adresse` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT pour la table `article`
--
ALTER TABLE `article`
  MODIFY `Id_Article` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT pour la table `carte_bancaire`
--
ALTER TABLE `carte_bancaire`
  MODIFY `Id_CB` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `client`
--
ALTER TABLE `client`
  MODIFY `Identifiant_Client` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `commande`
--
ALTER TABLE `commande`
  MODIFY `Id_Commande` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT pour la table `ligne_de_panier`
--
ALTER TABLE `ligne_de_panier`
  MODIFY `Id_Ligne_de_panier` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `mesure`
--
ALTER TABLE `mesure`
  MODIFY `Id_Mesure` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `panier`
--
ALTER TABLE `panier`
  MODIFY `Id_Panier` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT pour la table `taxe`
--
ALTER TABLE `taxe`
  MODIFY `Id_Taxe` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `vendeur`
--
ALTER TABLE `vendeur`
  MODIFY `Id_Vendeur` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `adresse`
--
ALTER TABLE `adresse`
  ADD CONSTRAINT `adresse_ibfk_1` FOREIGN KEY (`Id_Vendeur`) REFERENCES `vendeur` (`Id_Vendeur`),
  ADD CONSTRAINT `adresse_ibfk_2` FOREIGN KEY (`Adresse_Ville`) REFERENCES `ville` (`Adresse_Ville`),
  ADD CONSTRAINT `adresse_ibfk_3` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`);

--
-- Contraintes pour la table `article`
--
ALTER TABLE `article`
  ADD CONSTRAINT `article_ibfk_1` FOREIGN KEY (`Id_Taxe`) REFERENCES `taxe` (`Id_Taxe`),
  ADD CONSTRAINT `article_ibfk_2` FOREIGN KEY (`Id_Mesure`) REFERENCES `mesure` (`Id_Mesure`);

--
-- Contraintes pour la table `carte_bancaire`
--
ALTER TABLE `carte_bancaire`
  ADD CONSTRAINT `carte_bancaire_ibfk_1` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`);

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `commande_ibfk_1` FOREIGN KEY (`Id_Adresse`) REFERENCES `adresse` (`Id_Adresse`),
  ADD CONSTRAINT `commande_ibfk_2` FOREIGN KEY (`Id_Adresse_1`) REFERENCES `adresse` (`Id_Adresse`),
  ADD CONSTRAINT `commande_ibfk_3` FOREIGN KEY (`Id_Vendeur`) REFERENCES `vendeur` (`Id_Vendeur`),
  ADD CONSTRAINT `commande_ibfk_4` FOREIGN KEY (`Id_CB`) REFERENCES `carte_bancaire` (`Id_CB`),
  ADD CONSTRAINT `commande_ibfk_5` FOREIGN KEY (`Id_Panier`) REFERENCES `panier` (`Id_Panier`),
  ADD CONSTRAINT `commande_ibfk_6` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`);

--
-- Contraintes pour la table `ligne_de_panier`
--
ALTER TABLE `ligne_de_panier`
  ADD CONSTRAINT `ligne_de_panier_ibfk_1` FOREIGN KEY (`Id_Panier`) REFERENCES `panier` (`Id_Panier`),
  ADD CONSTRAINT `ligne_de_panier_ibfk_2` FOREIGN KEY (`Id_Article`) REFERENCES `article` (`Id_Article`);

--
-- Contraintes pour la table `panier`
--
ALTER TABLE `panier`
  ADD CONSTRAINT `panier_ibfk_1` FOREIGN KEY (`Identifiant_Client`) REFERENCES `client` (`Identifiant_Client`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
