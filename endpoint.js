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
const { query } = require("express");
/* npm install --save-dev jest
 * npm install supertest
 */

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
 * Get /api/clients/pwmodif/:id
 */

router.put("/clients/pwmodif/:id", verifyToken, (req, res) => {
  const pw = req.body.pw;

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
          newPW: pw,
        });
      },
    );
  });
});

/* Route : Modification Nom et prénom client
 * Put /api/clients/nommodif/:id
 */

router.put("/clients/nommodif/:id", verifyToken, (req, res) => {
  const { nom } = req.body;
  const id = req.params.id;
  db.query(
    "UPDATE client SET Nom_Prenom_Client = ? WHERE Identifiant_Client = ?",
    [nom, id],
    (error, result) => {
      if (error) {
        console.log(error);
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      res
        .status(201)
        .json({ message: "Modification réussie", nouveauNom: nom });
    },
  );
});

/* Route : Modification Mail client
 * Put /api/clients/mailmodif/:id
 */

router.put("/clients/mailmodif/:id", verifyToken, (req, res) => {
  const { mail } = req.body;
  const id = req.params.id;

  db.query(
    "UPDATE client SET Mail_Client = ? WHERE Identifiant_Client = ?",
    [mail, id],
    (error, result) => {
      if (error) {
        console.log(error);
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      res
        .status(201)
        .json({ message: "Modification réussie", nouveauMail: mail });
    },
  );
});

/* Route : Modification Mail client
 * Put /api/clients/adressemodif/:id
 */

router.put("/clients/adressemodif/:id", verifyToken, (req, res) => {
  const { num, rue, ville, code } = req.body;
  const id = req.params.id;

  db.query(
    "UPDATE adresse SET Numero_Voie = ?, Nom_Type_Voie = ?, Nom_commune_Adresse = ?, Code_postal_Voie = ? WHERE Identifiant_Client = ?",
    [num, rue, ville, code, id],
    (error, result) => {
      if (error) {
        console.log(error);
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      res.status(201).json({
        message: "Modification réussie",
        num: num,
        rue: rue,
        ville: ville,
        code: code,
      });
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
    `SELECT *
     FROM client
     WHERE Mail_Client = ?`,
    [mail],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur 1" });
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
            .json({ message: "Erreur du serveur 2", error: error });
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
          { expiresIn: "30d" },
        );

        db.query(
          `SELECT * FROM adresse WHERE Identifiant_Client = ?`,
          [client.Identifiant_Client],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du server" });
            }
            if (result.length === 0) {
              return res.json({
                message: "Connexion sans adresse réussie",
                token,
                client: {
                  id: client.Identifiant_Client,
                  nom: client.Nom_Prenom_Client,
                  mail: client.Mail_Client,
                },
              });
            }

            const adresse = result[0];

            res.json({
              message: "Connexion avec adresse réussie",
              token,
              client: {
                id: client.Identifiant_Client,
                nom: client.Nom_Prenom_Client,
                mail: client.Mail_Client,
              },
              adresse: {
                id: adresse.Id_Adresse,
                NumeroVoie: adresse.Numero_Voie,
                NomVoie: adresse.Nom_Type_Voie,
                CodePostal: adresse.Code_postal_Voie,
                NomVille: adresse.Nom_commune_Adresse,
              },
            });
          },
        );
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
      db.query(
        `SELECT * FROM panier WHERE Identifiant_Client = ? AND Status = "Ouvert"`,
        [req.params.id],
        (error, result2) => {
          if (error) {
            return res.status(500).json({ message: "Erreur du serveur" });
          }
          if (result2.length === 0) {
            return res
              .status(404)
              .json({ message: `Pas de panier ouvert trouvé` });
          }
          res.json(result2[0]);
        },
      );
    },
  );
});

/* Route : Récupérer les paniers fermés par l'ID du client
 * Get /api/paniers/client/closed/:id
 */

router.get("/paniers/client/closed/:id", verifyToken, (req, res) => {
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
      db.query(
        `SELECT * FROM panier WHERE Identifiant_Client = ? AND Status = "Fermé"`,
        [req.params.id],
        (error, result2) => {
          if (error) {
            return res.status(500).json({ message: "Erreur du serveur" });
          }
          if (result2.length === 0) {
            return res
              .status(404)
              .json({ message: `Pas de panier fermé trouvé` });
          }
          res.json(result2);
        },
      );
    },
  );
});

/* Route : Récupérer les paniers en commande par l'ID du client
 * Get /api/paniers/client/cammanded/:id
 */

router.get("/paniers/client/commanded/:id", verifyToken, (req, res) => {
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
      db.query(
        `SELECT * FROM panier WHERE Identifiant_Client = ? AND Status = "En commande"`,
        [req.params.id],
        (error, result2) => {
          if (error) {
            return res.status(500).json({ message: "Erreur du serveur" });
          }
          if (result2.length === 0) {
            return res
              .status(404)
              .json({ message: `Pas de panier en commande trouvé` });
          }
          res.json(result2);
        },
      );
    },
  );
});

// ======================== CB ======================== //

/* Route : Récupérer les CB
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
 * {
 *   "Type_CB": "",
 *   "Numero_CB": "",
 *   "Date_expiration_CB": "",
 *   "Nom_CB": "",
 *   "Identifiant_Client": ""
 * }
 */

router.post("/CB/register", verifyToken, (req, res) => {
  const { Type_CB, Numero_CB, Date_expiration_CB, Nom_CB, Identifiant_Client } =
    req.body;
  let New_Numero_CB = Numero_CB.slice(0, 4) + "XXXXXXXX" + Numero_CB.slice(-4);

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

/* Route : Récuperer une ligne de panier
 * Get /api/lignedepanier/:id
 */

router.get("/lignedepanier/:id", verifyToken, (req, res) => {
  const id = req.params.id;

  db.query(
    "SELECT * FROM ligne_de_panier WHERE Id_Panier = ?",
    [id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      res.json(result);
    },
  );
});

/* Route : Enregistrer ou ajouter à une ligne de panier
 * Post /api/lignedepanier/add
 * {
 *   "Id_Panier": "",
 *   "Id_Article": ""
 * }
 */

router.post("/lignedepanier/add", verifyToken, (req, res) => {
  const { Id_Panier, Id_Article } = req.body;
  let prix = 0;

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ?`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur 1" });
      }
      if (result.length === 0) {
        return res.status(404).json({ message: "Panier non trouvé 1" });
      } else {
        db.query(
          `SELECT * FROM article WHERE Id_Article = ?`,
          [Id_Article],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur 2" });
            }
            if (result.length === 0) {
              return res.status(404).json({ message: "Article non trouvé 2" });
            } else {
              prix = result[0].Prix_unitaire_Article;
              const nbArticle = result[0].Quantite_Article;
              db.query(
                `SELECT * FROM ligne_de_panier WHERE Id_Article = ? AND Id_Panier = ?`,
                [Id_Article, Id_Panier],
                (error, result) => {
                  if (error) {
                    return res
                      .status(500)
                      .json({ message: "Erreur du serveur 3" });
                  }
                  if (result.length === 0) {
                    if (nbArticle > 0) {
                      db.query(
                        `INSERT INTO ligne_de_panier (Id_Panier, Quantite_Ligne_de_panier, Prix_unitaire_Ligne_de_panier, Id_Article) VALUES (?, 1, ?, ?)`,
                        [Id_Panier, prix, Id_Article],
                        (error, result) => {
                          if (error) {
                            return res.status(500).json({
                              message:
                                "Erreur lors de la création de la ligne de panier 1",
                            });
                          }
                          res.status(201).json({
                            message: "Ajout réussie",
                            Ligne_Id: result.insertId,
                          });
                        },
                      );
                    }
                  } else {
                    db.query(
                      "SELECT * FROM ligne_de_panier WHERE Id_Article = ?",
                      [Id_Article],
                      (error, result) => {
                        if (error) {
                          return res
                            .status(500)
                            .json({ message: "Erreur du serveur 0" });
                        }
                        if (
                          result[0].Quantite_Ligne_de_panier + 1 <=
                          nbArticle
                        ) {
                          db.query(
                            "UPDATE ligne_de_panier SET Quantite_Ligne_de_panier = Quantite_Ligne_de_panier + 1 WHERE Id_Article = ? AND Id_Panier = ?",
                            [Id_Article, Id_Panier],
                            (req, res) => {
                              if (error) {
                                return res.status(500).json({
                                  message:
                                    "Erreur lors de la création de la ligne de panier 2",
                                });
                              }
                            },
                          );
                        } else {
                          return res.status(300).json({
                            message:
                              "Vous essayez de mettre plus d'articles dans votre panier qu'il n'y en a dans notre stock",
                          });
                        }
                      },
                    );
                  }
                },
              );
            }
          },
        );
      }
    },
  );
});

/* Route : Soustraire à ou supprimer une ligne de panier
 * POST /api/lignedepanier/sub
 * {
 *   "Id_Panier": "",
 *   "Id_Article": ""
 * }
 */

router.post("/lignedepanier/sub", verifyToken, (req, res) => {
  const { Id_Panier, Id_Article } = req.body;

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ?`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur 1" });
      }
      if (result.length === 0) {
        return res.status(404).json({ message: "Panier non trouvé 1" });
      } else {
        db.query(
          `SELECT * FROM article WHERE Id_Article = ?`,
          [Id_Article],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur 2" });
            }
            if (result.length === 0) {
              return res.status(404).json({ message: "Article non trouvé 2" });
            } else {
              db.query(
                `SELECT * FROM ligne_de_panier WHERE Id_Article = ? AND Id_Panier = ?`,
                [Id_Article, Id_Panier],
                (error, result) => {
                  if (error) {
                    return res
                      .status(500)
                      .json({ message: "Erreur du serveur 3" });
                  }
                  if (result[0].Quantite_Ligne_de_panier === "1") {
                    db.query(
                      `DELETE FROM ligne_de_panier WHERE Id_Panier = ? AND Id_Article = ?`,
                      [Id_Panier, Id_Article],
                      (error, result) => {
                        if (error) {
                          return res.status(500).json({
                            message:
                              "Erreur lors de la suppression de la ligne de panier",
                          });
                        }
                        res.status(201).json({
                          message: "Suppression réussie",
                          Ligne_Id: result.insertId,
                        });
                      },
                    );
                  } else {
                    db.query(
                      "UPDATE ligne_de_panier SET Quantite_Ligne_de_panier = Quantite_Ligne_de_panier - 1 WHERE Id_Article = ? AND Id_Panier = ?",
                      [Id_Article, Id_Panier],
                      (req, res) => {
                        if (error) {
                          return res.status(500).json({
                            message:
                              "Erreur lors de la soustraction à la ligne de panier",
                          });
                        }
                      },
                    );
                  }
                },
              );
            }
          },
        );
      }
    },
  );
});

/* Route : Mettre à jour la quantité d'une ligne de panier
 * POST /api/lignedepanier/maj
 * {
 *   "Id_Panier": "",
 *   "Id_Article": "",
 *   "nouveauNombre": "",
 * }
 */

router.post("/lignedepanier/maj", verifyToken, (req, res) => {
  const { Id_Panier, Id_Article, nouveauNombre } = req.body;

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ?`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur 1" });
      }
      if (result.length === 0) {
        return res.status(404).json({ message: "Panier non trouvé 1" });
      } else {
        db.query(
          `SELECT * FROM article WHERE Id_Article = ?`,
          [Id_Article],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur 2" });
            }
            if (result.length === 0) {
              return res.status(404).json({ message: "Article non trouvé 2" });
            }
            if (result[0].Quantite_Article < nouveauNombre) {
              return res
                .status(300)
                .json({ message: "Pas assez d'aticles en stock" });
            } else {
              db.query(
                `SELECT * FROM ligne_de_panier WHERE Id_Article = ? AND Id_Panier = ?`,
                [Id_Article, Id_Panier],
                (error, result) => {
                  if (error) {
                    return res
                      .status(500)
                      .json({ message: "Erreur du serveur 3" });
                  }
                  if (nouveauNombre === "0" || nouveauNombre === 0) {
                    db.query(
                      `DELETE FROM ligne_de_panier WHERE Id_Panier = ? AND Id_Article = ?`,
                      [Id_Panier, Id_Article],
                      (error, result) => {
                        if (error) {
                          return res.status(500).json({
                            message:
                              "Erreur lors de la suppression de la ligne de panier",
                          });
                        }
                        res.status(201).json({
                          message: "Suppression réussie",
                          Ligne_Id: result.insertId,
                        });
                      },
                    );
                  }
                  db.query(
                    "UPDATE ligne_de_panier SET Quantite_Ligne_de_panier = ? WHERE Id_Article = ? AND Id_Panier = ?",
                    [nouveauNombre, Id_Article, Id_Panier],
                    (req, res) => {
                      if (error) {
                        return res.status(500).json({
                          message:
                            "Erreur lors de la soustraction à la ligne de panier",
                        });
                      }
                    },
                  );
                },
              );
            }
          },
        );
      }
    },
  );
});

/* Route : Supprimer une ligne de panier
 * POST /api/lignedepanier/supr
 * {
 *   "Id_Panier": "",
 *   "Id_Article": ""
 * }
 */

router.post("/lignedepanier/supr", verifyToken, (req, res) => {
  const { Id_Panier, Id_Article } = req.body;

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ?`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur 1" });
      }
      if (result.length === 0) {
        return res.status(404).json({ message: "Panier non trouvé 1" });
      } else {
        db.query(
          `SELECT * FROM article WHERE Id_Article = ?`,
          [Id_Article],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur 2" });
            }
            if (result.length === 0) {
              return res.status(404).json({ message: "Article non trouvé 2" });
            } else {
              db.query(
                `SELECT * FROM ligne_de_panier WHERE Id_Article = ? AND Id_Panier = ?`,
                [Id_Article, Id_Panier],
                (error, result) => {
                  if (error) {
                    return res
                      .status(500)
                      .json({ message: "Erreur du serveur 3" });
                  }
                  if (result.length === 0) {
                    return res
                      .status(404)
                      .json({ message: "Ligne non trouvé" });
                  } else {
                    db.query(
                      `DELETE FROM ligne_de_panier WHERE Id_Panier = ? AND Id_Article = ?`,
                      [Id_Panier, Id_Article],
                      (error, result) => {
                        if (error) {
                          return res.status(500).json({
                            message:
                              "Erreur lors de la suppression de la ligne de panier",
                          });
                        }
                        res.status(201).json({
                          message: "Suppression réussie",
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
      }
    },
  );
});

// ======================== COMMANDE ======================== //

/* Route : Enregistrer une commande
 * POST /api/commande/register
 * {
 *   "Numero_de_voie": "15",
 *   "Adresse": "Rue de la Paix",
 *    "Ville": "Paris",
 *   "Code_Postale": "75001",
 *   "Id_Panier": "17",
 *   "Identifiant_Client": "1",
 *   "adresse": "11",
 *   "type": "CB",
 *   "CB": "1",
 *   "nbLignes": "2"
 * }
 */

router.post("/commande/register", verifyToken, (req, res) => {
  const {
    Numero_de_voie,
    Adresse,
    Ville,
    Code_Postale,
    Id_Panier,
    Identifiant_Client,
    adresse,
    type,
    CB,
    nbLignes,
  } = req.body;
  let Id_Adresse_1 = "";

  db.query(
    `SELECT * FROM ville WHERE Adresse_Ville = ? AND Nom_Ville = ?`,
    [Code_Postale, Ville],
    (error, result) => {
      if (error) {
        console.log(error);
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        db.query(
          `INSERT INTO ville (Adresse_Ville, Nom_Ville) VALUES (?, ?)`,
          [Code_Postale, Ville],
          (error, result) => {
            if (error) {
              console.log(error);
              return res.status(500).json({ message: "Erreur du serveur" });
            }
          },
        );
      }
      db.query(
        `SELECT * FROM panier WHERE Id_Panier = ? AND Status = "Ouvert"`,
        [Id_Panier],
        (error, result) => {
          if (error) {
            return res.status(500).json({ message: "Erreur du serveur 1" });
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
                  return res
                    .status(500)
                    .json({ message: "Erreur du serveur 2" });
                }
                if (result.length === 0) {
                  db.query(
                    `INSERT INTO adresse (Bis_Ter_Numero_de_voie, Nom_commune_Adresse, Nom_Type_Voie, Code_postal_Voie, Numero_Voie, Identifiant_Client, Adresse_Ville)
                   VALUES (0, ?, ?, ?, ?, ?, ?)`,
                    [
                      Ville,
                      Adresse,
                      Code_Postale,
                      Numero_de_voie,
                      Identifiant_Client,
                      Code_Postale,
                    ],
                    (error, result) => {
                      if (error) {
                        console.log(error);
                        return res
                          .status(500)
                          .json({ message: "Erreur du serveur 3" });
                      }
                      Id_Adresse_1 = result.insertId;
                      db.query(
                        `INSERT INTO payement (Type, idCB) VALUES (?, ?)`,
                        [type, CB],
                        (error, result) => {
                          if (error) {
                            return res.status(500).json({
                              message:
                                "Erreur lors de la création de la ligne de payment",
                            });
                          } else {
                            let idPayement = result.insertId;
                            db.query(
                              `INSERT INTO commande (Nombre_Ligne_de_commande, Status_Commande, Id_Adresse, Id_Adresse_1, idPayement, Id_Panier, Identifiant_Client, Date_prise_Commande) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                              [
                                nbLignes,
                                "Validée",
                                adresse,
                                Id_Adresse_1,
                                idPayement,
                                Id_Panier,
                                Identifiant_Client,
                                new Date(),
                              ],
                              (error, result) => {
                                if (error) {
                                  return res.status(500).json({
                                    message:
                                      "Erreur lors de la création de la commande 1",
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
                    },
                  );
                } else {
                  Id_Adresse_1 = result[0].Id_Adresse;
                  db.query(
                    `INSERT INTO payement (Type, idCB) VALUES (?, ?)`,
                    [type, CB],
                    (error, result) => {
                      if (error) {
                        return res.status(500).json({
                          message:
                            "Erreur lors de la création de la ligne de payment",
                        });
                      } else {
                        let idPayement = result.insertId;
                        db.query(
                          `INSERT INTO commande (Nombre_Ligne_de_commande, Status_Commande, Id_Adresse, Id_Adresse_1, idPayement, Id_Panier, Identifiant_Client, Date_prise_Commande) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                          [
                            nbLignes,
                            "Validée",
                            adresse,
                            Id_Adresse_1,
                            idPayement,
                            Id_Panier,
                            Identifiant_Client,
                            new Date(),
                          ],
                          (error, result) => {
                            if (error) {
                              return res.status(500).json({
                                message:
                                  "Erreur lors de la création de la commande 1",
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
          }
        },
      );
    },
  );
});

/* Route d'enregistrement d'une commande à régler en Boutique
 * POST /api/commande/boutique/register
 *  {
 *   "Id_Panier": "17",
 *   "Identifiant_Client": "1",
 *   "adresse": "11",
 *   "nbLignes": "2"
 */

router.post("/commande/boutique/register", verifyToken, (req, res) => {
  const { Id_Panier, Identifiant_Client, adresse, nbLignes } = req.body;

  db.query(
    `SELECT * FROM panier WHERE Id_Panier = ? AND Status = "Ouvert"`,
    [Id_Panier],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur 1" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: "Panier non trouvé ou déjà commandé" });
      } else {
        db.query(
          `INSERT INTO commande (Nombre_Ligne_de_commande, Status_Commande, Id_Adresse, Id_Adresse_1, idPayement, Id_Panier, Identifiant_Client, Date_prise_Commande, Id_Vendeur) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL)`,
          [
            nbLignes,
            "Validée",
            adresse,
            1,
            0,
            Id_Panier,
            Identifiant_Client,
            new Date(),
          ],
          (error, result) => {
            if (error) {
              return res.status(500).json({
                message: "Erreur lors de la création de la commande 1",
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
});

/* Route d'annulation d'une commande
 * POST /api/commande/annule/:id
 */

router.post("/commande/annule/:id", verifyToken, (req, res) => {
  const { id } = req.params;
  const { userId } = req.body;

  db.query(
    "SELECT * FROM commande WHERE Id_Panier = ?",
    [id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res.status(404).json({ message: "Commande non trouvée" });
      } else {
        console.log(result);
        let idPayement = result[0].idPayement;
        db.query(
          "DELETE FROM commande WHERE Id_Panier = ?",
          [id],
          (error, result) => {
            if (error) {
              return res.status(500).json({ message: "Erreur du serveur" });
            } else {
              if (!idPayement == 0) {
                db.query(
                  "DELETE FROM payement WHERE idPayement = ?",
                  [idPayement],
                  (error, result) => {
                    if (error) {
                      return res.status(500).json({
                        message: "Erreur du serveur",
                      });
                    }
                  },
                );
              }
              db.query(
                "SELECT Id_Panier FROM panier WHERE Status = 'Ouvert' AND Identifiant_Client = ?",
                [userId],
                (error, result) => {
                  if (error) {
                    return res
                      .status(500)
                      .json({ message: "Erreur du serveur" });
                  }
                  if (result.length === 0) {
                    return res
                      .status(404)
                      .json({ message: "Panier non trouvée" });
                  } else {
                    const panierSupr = result[1].Id_Panier;
                    db.query(
                      "DELETE FROM ligne_de_panier WHERE Id_Panier = ?",
                      [panierSupr],
                      (error, result) => {
                        if (error) {
                          return res
                            .status(500)
                            .json({ message: "Erreur du serveur" });
                        } else {
                          db.query(
                            "DELETE FROM panier WHERE Id_Panier = ?",
                            [panierSupr],
                            (error, result) => {
                              if (error) {
                                return res
                                  .status(500)
                                  .json({ message: "Erreur du serveur" });
                              } else {
                                db.query(
                                  "UPDATE panier SET Status = 'Ouvert' WHERE Id_Panier = ?",
                                  [id],
                                  (error, result) => {
                                    if (error) {
                                      return res
                                        .status(500)
                                        .json({ message: "Erreur du serveur" });
                                    }
                                  },
                                );
                              }
                            },
                          );
                        }
                      },
                    );
                  }
                },
              );
            }
          },
        );
      }
    },
  );
});

// ======================== ADRESSE ======================== //

/* Route pour récupérer l'adresse d'un client par son Id
 * GET /api/adresse/client/:id
 */

router.get("/adresse/client/:id", verifyToken, (req, res) => {
  const { id } = req.params;

  db.query(
    "SELECT * FROM adresse WHERE Identifiant_Client = ?",
    [id],
    (error, result) => {
      if (error) {
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      if (result.length === 0) {
        return res
          .status(404)
          .json({ message: "Adresse introuvable lors de la vérification" });
      }
      res.json(result);
    },
  );
});

/* Route : Enregistrer une adresse
 * POST /api/adresse/register
 * {
 *   "Numero_de_voie": "",
 *   "Adresse": "",
 *    "Ville": "",
 *   "Code_Postale": "",
 *   "Id_Client": ""
 * }
 */

router.post("/adresse/register", (req, res) => {
  const { Numero_de_voie, Adresse, Ville, Code_Postale, Id_Client } = req.body;

  db.query(
    `SELECT * FROM ville WHERE Adresse_Ville = ?`,
    [Code_Postale],
    (error, result) => {
      if (result.length === 0) {
        db.query(
          `INSERT INTO ville (Adresse_Ville, Nom_Ville) VALUES (?, ?)`,
          [Code_Postale, Ville],
          (error, result) => {
            if (error) {
              console.log(error);
              return res.status(500).json({ message: "Erreur du serveur" });
            }
          },
        );
      }
      if (error) {
        console.log(error);
        return res.status(500).json({ message: "Erreur du serveur" });
      }
      db.query(
        `SELECT * FROM adresse WHERE Identifiant_Client = ?`,
        [Id_Client],
        (error, resu) => {
          if (resu.length === 0) {
            db.query(
              `INSERT INTO adresse (Bis_Ter_Numero_de_voie, Nom_commune_Adresse, Nom_Type_Voie, Code_postal_Voie, Numero_Voie, Identifiant_Client, Adresse_Ville)
         VALUES (0, ?, ?, ?, ?, ?, ?)`,
              [
                Ville,
                Adresse,
                Code_Postale,
                Numero_de_voie,
                Id_Client,
                Code_Postale,
              ],
              (error, result) => {
                if (error) {
                  return res.status(500).json({ message: "Erreur du serveur" });
                }
                res.status(201).json({
                  message: "Adresse enregistrée",
                });
              },
            );
          }
          if (error) {
            return res.status(500).json({ message: "Erreur du serveur" });
          }
        },
      );
    },
  );
});
