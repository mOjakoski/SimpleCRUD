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
