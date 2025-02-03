const express = require("express");
const db = require("./DB");
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