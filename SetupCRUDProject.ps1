
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
'@ | Out-File -Encoding utf8 "server.js"

Write-Host "Creating public/index.html..."
@'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Simple CRUD App</title>
    <link rel="stylesheet" href="styles.css">
    <script src="app.js" defer></script>
</head>
<body>
    <div class="container">
        <!-- Header Section -->
        <header class="header">
            <h1 class="title">Simple CRUD App</h1>
            <p class="description">A simple app for creating, reading, updating, and deleting items from a list. Using SQLite.</p>
        </header>
        
        <!-- Form Section -->
        <form id="item-form" class="form">
            <input type="text" id="name" placeholder="Name" required class="input-field" />
            <input type="text" id="description" placeholder="Description" required class="input-field" />
            <button type="submit" class="button">Add Item</button>
        </form>

        <!-- Item List Section -->
        <ul id="item-list" class="item-list"></ul>
    </div>
</body>
</html>
'@ | Out-File -Encoding utf8 "public\index.html"

Write-Host "Creating public/app.js..."
@'
document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("item-form");
    const itemList = document.getElementById("item-list");

    function fetchItems() {
        fetch("/api/items")
            .then(response => response.json())
            .then(data => {
                if (!data.items) {
                    console.error("No items found in response:", data);
                    return;
                }
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
            })
            .catch(error => console.error("Error fetching items:", error));
    }

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

    function deleteItem(id) {
        fetch(`/api/items/${id}`, { method: "DELETE" })
            .then(() => fetchItems());
    }

    fetchItems();
});
'@ | Out-File -Encoding utf8 "public\app.js"


Write-Host "Project setup complete! You can now run the server with 'node server.js'."
