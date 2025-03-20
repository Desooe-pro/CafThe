const express = require("express");
// mpn install cors
const cors = require("cors");
// npm install dotenv

const db = require("./DB"); // Connexion à MySQL
const routes = require("./endpoint"); // Les routes de l'API

const app = express();
app.use(express.json());
app.use(cors());

app.use(
  cors({
    origin: "https://cafthe.sacha.allardin.dev-campus.fr",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  }),
);

// Utilisation des routes
app.use("/api", routes);

// Démarrer le serveur
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`L'API CafThé est démarrée sur http://localhost:${PORT}`);
});
