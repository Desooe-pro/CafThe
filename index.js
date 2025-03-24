const express = require("express");
// mpn install cors
const cors = require("cors");
// npm install dotenv

const db = require("./DB"); // Connexion à MySQL
const routes = require("./endpoint"); // Les routes de l'API

const app = express();
app.use(express.json());

app.use(
  cors({
    origin: [
      "http://localhost:3001",
      "https://cafthe.sacha.allardin.dev-campus.fr",
    ], // Remplacez par les URLs de votre front-end
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

// Utilisation des routes
app.use("/api", routes);

// Démarrer le serveur
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`L'API CafThé est démarrée sur http://localhost:${PORT}`);
});
