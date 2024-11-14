
$projectName = "simple-crud-app"
$dependencies = @("express", "sqlite3", "body-parser")

Write-Host "Setting up project directory..."

New-Item -ItemType Directory -Path $projectName
New-Item -ItemType Directory -Path "$projectName\public"

Set-Location -Path $projectName

Write-Host "Initializing Node.js project..."
npm init -y

Write-Host "Installing dependencies: $($dependencies -join ', ')..."
npm install $dependencies

Write-Host "Creating server.js..."
@'
const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const bodyParser = require("body-parser");
const path = require("path");

const app = express();
const db = new sqlite3.Database("./database.db");

app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, "public")));

// Create an item (C)
app.post("/api/items", (req, res) => {
    const { name, description } = req.body;
    db.run("INSERT INTO items (name, description) VALUES (?, ?)", [name, description], function (err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ id: this.lastID });
    });
});

// Read all items (R)
app.get("/api/items", (req, res) => {
    db.all("SELECT * FROM items", [], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ items: rows });
    });
});

// Update an item (U)
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

// Delete an item (D)
app.delete("/api/items/:id", (req, res) => {
    const { id } = req.params;
    db.run("DELETE FROM items WHERE id = ?", id, function (err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ changes: this.changes });
    });
});

// Start the server
app.listen(3000, () => {
    console.log("Server is running on http://localhost:3000");
});
'@ | Out-File -Encoding utf8 "server.js"

Write-Host "Creating public/index.html..."
@'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Simple CRUD App</title>
    <script src="app.js" defer></script>
</head>
<body>
    <h1>Item Management</h1>
    <form id="item-form">
        <input type="text" id="name" placeholder="Name" required />
        <input type="text" id="description" placeholder="Description" required />
        <button type="submit">Add Item</button>
    </form>
    <ul id="item-list"></ul>
</body>
</html>
'@ | Out-File -Encoding utf8 "public\index.html"

Write-Host "Creating public/app.js..."
@'
document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("item-form");
    const itemList = document.getElementById("item-list");

    // Fetch and display items
    function fetchItems() {
        fetch("/api/items")
            .then(response => response.json())
            .then(data => {
                itemList.innerHTML = "";
                data.items.forEach(item => {
                    const li = document.createElement("li");
                    li.textContent = `${item.name}: ${item.description}`;
                    const deleteBtn = document.createElement("button");
                    deleteBtn.textContent = "Delete";
                    deleteBtn.onclick = () => deleteItem(item.id);
                    li.appendChild(deleteBtn);
                    itemList.appendChild(li);
                });
            });
    }

    // Add a new item
    form.addEventListener("submit", event => {
        event.preventDefault();
        const name = document.getElementById("name").value;
        const description = document.getElementById("description").value;

        fetch("/api/items", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ name, description })
        })
        .then(response => response.json())
        .then(() => {
            form.reset();
            fetchItems();
        });
    });

    // Delete an item
    function deleteItem(id) {
        fetch(`/api/items/${id}`, { method: "DELETE" })
            .then(() => fetchItems());
    }

    fetchItems();
});
'@ | Out-File -Encoding utf8 "public\app.js"


Write-Host "Project setup complete! You can now run the server with 'node server.js'."
