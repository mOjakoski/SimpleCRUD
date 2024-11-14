const express = require("express");
const mysql = require("mysql2");

const app = express();
app.use(express.json());

const db = mysql.createConnection({
    host: "localhost",
    user: "crud_user",
    password: "your_password",
    database: "crud_app",
});

db.connect((err) => {
    if (err) throw err;
    console.log("Connected to MySQL database");
});

// Routes

// GET all items
app.get("/api/items", (req, res) => {
    db.query("SELECT * FROM items", (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ items: results });
    });
});

// POST a new item
app.post("/api/items", (req, res) => {
    const { name, description } = req.body;
    db.query("INSERT INTO items (name, description) VALUES (?, ?)", [name, description], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ id: results.insertId });
    });
});

// DELETE an item
app.delete("/api/items/:id", (req, res) => {
    const { id } = req.params;
    db.query("DELETE FROM items WHERE id = ?", [id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: "Item deleted" });
    });
});

app.listen(3000, () => {
    console.log("Server is running on http://localhost:3000");
});
