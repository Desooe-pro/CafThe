const express = require("express");
const db = require("./DB");
const { verifyToken } = require("./middleware");
// npm install bcrypt
const bcrypt = require("bcrypt");
const mysql = require("mysql2/promise");
const router = express.Router();
require("dotenv").config();
// npm install jsonwebtoken
const jwt = require("jsonwebtoken");
const { sign } = require("jsonwebtoken");

module.exports = router;

// ======================== PRODUITS ======================== //

/* Route : lister les produits
 * Get /api/produits
 */

router.get("/produits", (req, res) => {
  db.query("SELECT * FROM article", (error, result) => {
    if (error) {
      return res.status(500).json({ message: "Erreur du serveur" });
    }
    res.json(result);
  });
});

/* Route : Récupérer un produit par son ID
 * Get /api/produits/:id
 */

router.get("/produits/:id", (req, res) => {
  db.query(
    `SELECT * FROM article WHERE Id_Article = ${req.params.id}`,
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result[0]);
    },
  );
});

/* Route : Récupérer une fiche produit par son ID
 * Get /api/produits/fiche/:id
 */

router.get("/produits/fiche/:id", (req, res) => {
  db.query(
    `SELECT A.Designation_Article, A.Prix_unitaire_Article, A.Description_Article, M.Designation_Mesure
              FROM article AS A
              INNER JOIN mesure AS M ON M.Id_Mesure = A.Id_Mesure 
              WHERE Id_Article = ${req.params.id}`,
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result[0]);
    },
  );
});

// ======================== CLIENT ======================== //

/* Route : Récupérer un client par son ID
 * Get /api/clients/:id
 */

router.get("/clients/:id", (req, res) => {
  db.query(
    `SELECT * FROM client WHERE Identifiant_Client = ?`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result[0]);
    },
  );
});

/* Route : Récupérer un client par son ID LIKE
 * Get /api/clients/:id
 */

router.get("/clients/like/:nom", (req, res) => {
  db.query(
    `SELECT * FROM client WHERE Nom_Prenom_Client LIKE "%${req.params.nom}%"`,
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Client ${req.params.nom} non trouvé` });
      }
      res.json(result);
    },
  );
});

/* Route : Enregistrer un client
 * Get /api/client/register
 * date : date de naissance
 * {
 *   "nomPrenom": "",
 *   "date": "",
 *   "Tel": "",
 *   "Mail": "",
 *   "MDP": ""
 * }
 */

router.post("/clients/register", (req, res) => {
  const { nomPrenom, date, Tel, Mail, MDP } = req.body;
  console.log(nomPrenom, date, Tel, Mail, MDP);

  // Vérifie que l'adresse mail n'est pas déjà utilisé
  db.query(
    "SELECT * FROM client WHERE Mail_Client = ?",
    [Mail],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length > 0) {
        return res
          .status(400)
          .json({ message: "Cette adresse mail est déjà utilisée" });
      } else {
        bcrypt.hash(MDP, 10, (error, hash) => {
          if (error) {
            return res.status(500).json({ message: "Erreur de hash" });
          }

          // Insertion du nouveau client
          db.query(
            "INSERT INTO client (Nom_Prenom_Client, Date_de_naissance_Client, Tel_Client, Mail_Client, MDP_Client) VALUES (?, ?, ?, ?, ?)",
            [nomPrenom, date, Tel, Mail, hash],
            (error, result) => {
              if (error) {
                console.log(hash);
                return res
                  .status(500)
                  .json({ message: "Erreur lors de l'inscription" });
              }
              res.status(201).json({
                message: "Inscription réussie",
                client_id: result.insertId,
              });
            },
          );
        });
      }
    },
  );
});

/* Route : Modification du mot de passe d'un client
 * Get /api/client/pwmodif/:id
 */

router.put("/clients/pwmodif/:id", verifyToken, (req, res) => {
  const pw = req.body.pw;

  db.query(
    `SELECT * FROM client WHERE Identifiant_Client = ?`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length < 1) {
        return res.status(400).json({ message: "Client non trouvé" });
      } else {
        bcrypt.hash(pw, 10, (error, hash) => {
          if (error) {
            return res.status(500).json({ message: "Erreur de hash" });
          }
          db.query(
            `UPDATE client SET MDP_Client = ? WHERE Identifiant_Client = ?`,
            [hash, req.params.id],
            (error, result) => {
              if (error) {
                return res.status(500).json({
                  message: "Erreur lors de la modification du mot de passe",
                });
              }
              res.status(201).json({
                message: "Modification du mot de passe réussie",
                nouveau_mot_de_passe: pw,
              });
            },
          );
        });
      }
    },
  );
});

/* Route : Connexion d'un client (Génération de JWT)
 * Get /api/clients/connexion
 * {
 *   "mail": "jean.dupont@email.com",
 *   "pw": "hashpassword1"
 * }
 */

router.post("/clients/login/connexion", (req, res) => {
  const { mail, pw } = req.body;

  db.query(
    // Requête préparée
    `SELECT * FROM client WHERE Mail_Client = ?`,
    [mail],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Identifiant ou mot de passe incorrect` });
      }

      const client = result[0];

      /* Vérification du mot de passe */
      bcrypt.compare(pw, client.MDP_Client, (error, isMatch) => {
        if (error) {
          return res
            .status(500)
            .json({ message: "Erreur du serveur", error: error });
        }
        if (!isMatch) {
          return res
            .status(401)
            .json({ message: "Identifiant ou mot de passe incorrect" });
        }

        // Génération d'un token JWT
        const token = sign(
          { id: client.Identifiant_Client, mail: client.Mail_Client },
          process.env.JWT_SECRET,
          { expiresIn: "2h" },
        );

        res.json({
          message: "Connexion réussie",
          token,
          client: {
            id: client.Identifiant_Client,
            nom: client.Nom_Prenom_Client,
            mail: client.Mail_Client,
          },
        });
      });
    },
  );
});

// ======================== VENDEUR ======================== //

/* Route : Récupérer un vendeur
 * Get /api/vendeur
 */

router.get("/vendeur", verifyToken, (req, res) => {
  db.query(`SELECT * FROM vendeur`, (error, result) => {
    if (error) {
      return res.status(500).json({ message: "Erreur du serveur" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: `Vendeurs non trouvé` });
    }
    res.json(result);
  });
});

/* Route : Récupérer un vendeur par son ID
 * Get /api/vendeur/:id
 */

router.get("/vendeur/:id", verifyToken, (req, res) => {
  db.query(
    `SELECT * FROM vendeur WHERE Id_Vendeur = ?`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Vendeur ${req.params.id} non trouvé` });
      }
      res.json(result[0]);
    },
  );
});

/* Route : Récupérer un vendeur par son ID LIKE
 * Get /api/vendeur/:id
 */

router.get("/vendeur/like/:id", verifyToken, (req, res) => {
  db.query(
    `SELECT * FROM vendeur WHERE Id_Vendeur LIKE "%${req.params.id}%"`,
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result);
    },
  );
});

/* Route : Enregistrer un vendeur
 * Get /api/vendeur/register
 * date : date de naissance
 * {
 *   "nomPrenom": "",
 *   "date": "",
 *   "Tel": "",
 *   "Mail": "",
 *   "MDP": "",
 *   "Salaire": ""
 * }
 */

router.post("/vendeur/register", verifyToken, (req, res) => {
  const { nomPrenom, date, Tel, Mail, MDP, Salaire } = req.body;
  console.log(nomPrenom, date, Tel, Mail, MDP, Salaire);

  // Vérifie que l'adresse mail n'est pas déjà utilisé
  db.query(
    "SELECT * FROM vendeur WHERE Mail_Vendeur = ?",
    [Mail],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length > 0) {
        return res
          .status(400)
          .json({ message: "Cette adresse mail est déjà utilisée" });
      } else {
        bcrypt.hash(MDP, 10, (error, hash) => {
          if (error) {
            return res.status(500).json({ message: "Erreur de hash" });
          }

          // Insertion du nouveau client
          db.query(
            "INSERT INTO vendeur (Nom_Prenom_Vendeur, Tel_Vendeur, Mail_Vendeur, MDP_Vendeur, Salaire_Vendeur, Date_de_naissance_Vendeur) VALUES (?, ?, ?, ?, ?, ?)",
            [nomPrenom, Tel, Mail, hash, Salaire, date],
            (error, result) => {
              if (error) {
                console.log(hash);
                return res
                  .status(500)
                  .json({ message: "Erreur lors de l'inscription" });
              }
              res.status(201).json({
                message: "Inscription réussie",
                vendeur_id: result.insertId,
              });
            },
          );
        });
      }
    },
  );
});

// ======================== PANIER ======================== //

/* Route : lister les paniers
 * Get /api/paniers
 */

router.get("/paniers", verifyToken, (req, res) => {
  db.query("SELECT * FROM panier", (error, result) => {
    if (error) {
      return res.status(500).json({ message: "Erreur du serveur" });
    }
    res.json(result);
  });
});

/* Route : Récupérer un panier par son ID
 * Get /api/paniers/:id
 */

router.get("/paniers/:id", verifyToken, (req, res) => {
  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ?`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result[0]);
    },
  );
});

/* Route : Récupérer les paniers par l'ID du client
 * Get /api/paniers/:id
 */

router.get("/paniers/client/:id", verifyToken, (req, res) => {
  db.query(
    `SELECT * FROM panier WHERE Identifiant_Client = ?`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result);
    },
  );
});

/* Route : Récupérer le panier ouvert par l'ID du client
 * Get /api/paniers/client/open/:id
 */

router.get("/paniers/client/open/:id", verifyToken, (req, res) => {
  db.query(
    `SELECT * FROM panier WHERE Identifiant_Client = ? AND Status = "Ouvert"`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Produit ${req.params.id} non trouvé` });
      }
      res.json(result);
    },
  );
});

// ======================== CB ======================== //

/* Route : Récupérer une CB
 * Get /api/CB
 */

router.get("/CB", verifyToken, (req, res) => {
  db.query(`SELECT * FROM carte_bancaire`, (error, result) => {
    if (error) {
      return res.status(500).json({ message: "Erreur du serveur" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: `Vendeurs non trouvé` });
    }
    res.json(result);
  });
});

/* Route : Récupérer une CB d'un client par son ID
 * Get /api/CB/client/:id
 */

router.get("/CB/client/:id", verifyToken, (req, res) => {
  db.query(
    `SELECT *FROM carte_bancaire AS C WHERE C.Identifiant_Client = ?`,
    [req.params.id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Vendeur ${req.params.id} non trouvé` });
      }
      res.json(result);
    },
  );
});

/* Route : Récupérer une CB d'un client LIKE son nom
 * Get /api/CB/client/like/:nom
 */

router.get("/CB/client/like/:nom", verifyToken, (req, res) => {
  db.query(
    `SELECT * FROM carte_bancaire AS C WHERE C.Identifiant_Client = (SELECT CL.Identifiant_Client FROM client AS CL WHERE CL.Nom_Prenom_Client LIKE "%${req.params.nom}%")`,
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: `Vendeur ${req.params.id} non trouvé` });
      }
      res.json(result);
    },
  );
});

/* Route : Enregistrer une CB
 * Get /api/CB/register
 */

router.post("/CB/register", verifyToken, (req, res) => {
  const { Type_CB, Numero_CB, Date_expiration_CB, Nom_CB, Identifiant_Client } =
    req.body;
  console.log(
    Type_CB,
    Numero_CB,
    Date_expiration_CB,
    Nom_CB,
    Identifiant_Client,
  );
  let New_Numero_CB = Numero_CB.slice(0, 4) + "XXXXXXXX" + Numero_CB.slice(-4);
  console.log(New_Numero_CB);

  // Vérifie que l'adresse mail n'est pas déjà utilisé
  db.query(
    "SELECT * FROM carte_bancaire WHERE Numero_CB = ?",
    [New_Numero_CB],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length > 0) {
        return res
          .status(400)
          .json({ message: "Cette carte bancaire est déjà enregistrée" });
      } else {
        db.query(
          "INSERT INTO carte_bancaire (Type_CB, Numero_CB, Date_expiration_CB, Nom_CB, Identifiant_Client) VALUES (?, ?, ?, ?, ?)",
          [
            Type_CB,
            New_Numero_CB,
            Date_expiration_CB,
            Nom_CB,
            Identifiant_Client,
          ],
          (error, result) => {
            if (error) {
              console.log(error);
              return res
                .status(500)
                .json({ message: "Erreur lors de l'inscription" });
            }
            res
              .status(201)
              .json({ message: "Inscription réussie", CB_ID: result.insertId });
          },
        );
      }
    },
  );
});

// ======================== LIGNE DE PANIER ======================== //

/* Route : Enregistrer une ligne de panier
 * Get /api/lignedepanier/register
 * {
 *   "Id_Panier": "",
 *   "Quantite_Ligne_de_panier": "",
 *   "Id_Article": ""
 * }
 */

router.post("/lignedepanier/register", verifyToken, (req, res) => {
  const { Id_Panier, Quantite_Ligne_de_panier, Id_Article } = req.body;

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ?`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res.status(404).json({ message: "Panier non trouvé" });
      } else {
        db.query(
          `SELECT * FROM article WHERE Id_Article = ?`,
          [Id_Article],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur" });
            }
            if (result.length === 0) {
              return res.status(404).json({ message: "Article non trouvé" });
            } else {
              db.query(
                `INSERT INTO ligne_de_panier (Id_Panier, Quantite_Ligne_de_panier, Prix_unitaire_Ligne_de_panier, Id_Article) VALUES (?, ?, 0, ?)`,
                [Id_Panier, Quantite_Ligne_de_panier, Id_Article],
                (error, result) => {
                  if (error) {
                    return res.status(500).json({
                      message:
                        "Erreur lors de la création de la ligne de panier",
                    });
                  }
                  res.status(201).json({
                    message: "Inscription réussie",
                    Ligne_Id: result.insertId,
                  });
                },
              );
            }
          },
        );
      }
    },
  );
});

// ======================== COMMANDE ======================== //

/* Route : Enregistrer une commande
 * Get /api/commande/register
 * {
 *   "Numero_de_voie": "15",
 *   "Adresse": "Rue de la Paix",
 *    "Ville": "Paris",
 *   "Code_Postale": "75001",
 *   "Id_Panier": "17"
 * }
 */

router.post("/commande/register", verifyToken, (req, res) => {
  const { Numero_de_voie, Adresse, Ville, Code_Postale, Id_Panier } = req.body;
  let Id_Adresse_1 = "";

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ? AND Status = "Ouvert"`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: "Panier non trouvé ou déjà commandé" });
      } else {
        db.query(
          `SELECT * FROM adresse WHERE Numero_Voie = ? AND Nom_Type_Voie = ? AND Nom_commune_Adresse = ? AND Code_postal_Voie = ?`,
          [Numero_de_voie, Adresse, Ville, Code_Postale],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur" });
            }
            if (result.length === 0) {
              db.query(
                `INSERT INTO adresse (Bis_Ter_Numero_de_voie, Nom_commune_Adresse, Nom_Type_Voie, Code_postal_Voie, Numero_Voie, Type_Voie, Adresse_Ville)
                                VALUES (0, ?, ?, ?, ?, ?, ?)`,
                [
                  Ville,
                  Adresse,
                  Code_Postale,
                  Numero_de_voie,
                  Adresse.split(" ")[0],
                  Code_Postale,
                ],
                (error, result) => {
                  if (error) {
                    return res
                      .status(500)
                      .json({ message: "Erreur du serveur" });
                  }
                  Id_Adresse_1 = result.insertId;
                  db.query(
                    `INSERT INTO commande (Id_Panier, Id_Adresse_1) VALUES (?, ?)`,
                    [Id_Panier, Id_Adresse_1],
                    (error, result) => {
                      if (error) {
                        return res.status(500).json({
                          message: "Erreur lors de la création de la commande",
                        });
                      }
                      res.status(201).json({
                        message: "Commande réussie",
                        Commande_Id: result.insertId,
                      });
                    },
                  );
                },
              );
            } else {
              Id_Adresse_1 = result[0].Id_Adresse;
              db.query(
                `INSERT INTO commande (Id_Panier, Id_Adresse_1) VALUES (?, ?)`,
                [Id_Panier, Id_Adresse_1],
                (error, result) => {
                  if (error) {
                    return res.status(500).json({
                      message: "Erreur lors de la création de la commande",
                    });
                  }
                  res.status(201).json({
                    message: "Commande réussie",
                    Commande_Id: result.insertId,
                  });
                },
              );
            }
          },
        );
      }
    },
  );
});
