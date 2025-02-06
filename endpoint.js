const express = require("express");
const db = require("./DB");
// npm install bcrypt
const bcrypt = require("bcrypt");
const router = express.Router();

module.exports = router;

/* Route : lister les produits
* Get /api/produits
*/

router.get("/produits", (req, res) => {
    db.query("SELECT * FROM article", (error, result) => {
        if (error){
            return(res.status(500).json({message : "Erreur du serveur"}));
        }
        res.json(result);
    });
});

/* Route : Récupérer un produit par son ID
* Get /api/produits/:id
*/

router.get("/produits/:id", (req, res) => {
    db.query(`SELECT * FROM article WHERE Id_Article = ${req.params.id}`, (error, result) => {
        if (error){
            return(res.status(500).json({message : "Erreur du serveur"}));
        }
        if (result.length === 0){
            return(res.status(404).json({message : `Produit ${req.params.id} non trouvé`}))
        }
        res.json(result);
    });
});

/* Route : Récupérer un client par son ID
* Get /api/clients/:id
*/

router.get("/clients/:id", (req, res) => {
    db.query(`SELECT * FROM client WHERE Identifiant_Client = ?`, [req.params.id], (error, result) => {
        if (error){
            return(res.status(500).json({message : "Erreur du serveur"}));
        }
        if (result.length === 0){
            return(res.status(404).json({message : `Produit ${req.params.id} non trouvé`}))
        }
        res.json(result);
    });
});

/* Route : Récupérer un client par son ID LIKE
* Get /api/clients/:id
*/

router.get("/clients/like/:id", (req, res) => {
    db.query(`SELECT * FROM client WHERE Identifiant_Client LIKE "%${req.params.id}%"`, (error, result) => {
        if (error){
            return(res.status(500).json({message : "Erreur du serveur"}));
        }
        if (result.length === 0){
            return(res.status(404).json({message : `Produit ${req.params.id} non trouvé`}))
        }
        res.json(result);
    });
});

/* Route : Enregistrer un client
* Get /api/client/register
*/

router.post("/clients/register", (req, res) => {
    const {nomPrenom, date, Tel, Mail, MDP} = req.body;
    console.log(nomPrenom, date,Tel, Mail, MDP)

    // Vérifie que l'adresse mail n'est pas déjà utilisé
    db.query("SELECT * FROM client WHERE Mail_Client = ?", [Mail], (error, result) => {
        if (error){
            return(res.status(500).json({message : "Erreur du serveur"}));
        }
        if (result.length > 0){
            return(res.status(400).json({message : "Cette adresse mail est déjà utilisée"}));
        }
    })

    // Hachage du mot de passe pour plus de sécurité
    bcrypt.hash(MDP, 10, (error, hash) => {
        if (error){
            return(res.status(500).json({message : "Erreur de hash"}));
        }

        // Insertion du nouveau client
        db.query(
            "INSERT INTO client (Nom_Prenom_Client, Date_de_naissance_Client, Tel_Client, Mail_Client, MDP_Client) VALUES (?, ?, ?, ?, ?)",
            [nomPrenom, date, Tel, Mail, hash],
            (error, result) => {
            if (error){
                console.log(hash)
                return(res.status(500).json({message : "Erreur lors de l'inscription"}));
            }
            res.status(201).json({message : "Inscription réussie", client_id : result.insertId})
        })
    })
})