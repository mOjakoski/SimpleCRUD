const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const bodyParser = require("body-parser");
const path = require("path");

const app = express();
const db = new sqlite3.Database("./database.db");

app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, "public")));

app.post("/api/items", (req, res) => {
    const { name, description } = req.body;
    db.run("INSERT INTO items (name, description) VALUES (?, ?)", [name, description], function (err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ id: this.lastID });
    });
});

app.get("/api/items", (req, res) => {
    db.all("SELECT * FROM items", [], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ items: rows });
    });
});

app.put("/api/items/:id", (req, res) => {
    const { id } = req.params;
    const { name, description } = req.body;
    db.run("UPDATE items SET name = ?, description = ? WHERE id = ?", [name, description, id], function (err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ changes: this.changes });
    });
});

app.delete("/api/items/:id", (req, res) => {
    const { id } = req.params;
    db.run("DELETE FROM items WHERE id = ?", id, function (err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ changes: this.changes });
    });
});

app.listen(3000, () => {
    console.log("Server is running on http://localhost:3000");
});
