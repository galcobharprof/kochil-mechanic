const basketItems = {};
let totalPrice = 0;
let categoryData = {};
let navigationStack = [];

// Listen for messages from client
window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'open') {
        // Reset Cart on every new brochure use
        for (let key in basketItems) delete basketItems[key];
        totalPrice = 0;
        updateBasketUI();

        categoryData = data.categories;
        document.getElementById('app').style.display = 'flex';
        renderMainCategories();
    } else if (data.action === 'close') {
        // ONLY hide the UI, do NOT call closeUI() to avoid infinite loop
        document.getElementById('app').style.display = 'none';
        document.getElementById('receipt-notepad').style.display = 'none';
    } else if (data.action === 'openReceipt') {
        document.getElementById('receipt-content').innerText = data.text;
        document.getElementById('receipt-notepad').style.display = 'flex';
    }
});

function closeReceipt() {
    document.getElementById('receipt-notepad').style.display = 'none';
    // Just hide it locally, the server/client state is handled if necessary
    // If you need the server to know, only call closeUI if the main app is also closing
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

document.getElementById('close-notepad').addEventListener('click', closeReceipt);

function renderMainCategories() {
    navigationStack = [];
    document.getElementById('main-view').style.display = 'grid';
    document.getElementById('item-view').style.display = 'none';
    document.getElementById('category-title').innerText = 'Select Category';
    document.getElementById('back-btn').style.display = 'none';
    setActiveNav('main');
}

function renderLayer(data, label) {
    const container = document.getElementById('item-view');
    const mainView = document.getElementById('main-view');
    const backBtn = document.getElementById('back-btn');
    
    mainView.style.display = 'none';
    container.style.display = 'flex';
    document.getElementById('category-title').innerText = label;
    backBtn.style.display = 'block';

    container.innerHTML = '';

    if (data.isSub) {
        // Render Sub-categories as text buttons
        data.subCategories.forEach(sub => {
            const row = document.createElement('div');
            row.className = 'item-row sub-row';
            row.innerHTML = `
                <div class="item-main-info">
                    <h4>${sub.label}</h4>
                </div>
                <div class="item-price-info">
                    <i class="fa-solid fa-chevron-right" style="color: var(--accent-blue); opacity: 0.5;"></i>
                </div>
            `;
            row.onclick = () => {
                navigationStack.push({ data: data, label: label });
                renderLayer(sub, sub.label);
            };
            container.appendChild(row);
        });
    } else {
        // Render Items
        const items = data.items || data;
        items.forEach(item => {
            const row = document.createElement('div');
            row.className = 'item-row';
            row.innerHTML = `
                <div class="item-main-info">
                    <h4>${item.label}</h4>
                    <p>${item.description || (item.level !== undefined ? 'Level ' + (item.level + 1) : '')}</p>
                </div>
                <div class="item-price-info">
                    <span class="price">$${item.price}</span>
                </div>
            `;
            row.onclick = () => selectItem(item);
            container.appendChild(row);
        });
    }
}

function selectItem(item) {
    const key = item.modId !== undefined ? item.modId : (item.colorId !== undefined ? 'color' : 'misc');
    basketItems[key] = item;
    updateBasketUI();
    
    fetch(`https://${GetParentResourceName()}/previewMod`, {
        method: 'POST',
        body: JSON.stringify(item)
    });
}

function goBack() {
    if (navigationStack.length > 0) {
        const last = navigationStack.pop();
        renderLayer(last.data, last.label);
    } else {
        renderMainCategories();
    }
}

function updateBasketUI() {
    const container = document.getElementById('basket-items');
    container.innerHTML = '';
    totalPrice = 0;

    Object.values(basketItems).forEach(item => {
        const div = document.createElement('div');
        div.className = 'basket-item';
        
        // Format label: Name + Small Sub-info if exists
        const label = item.label;
        const subInfo = item.level !== undefined ? ` (Lvl ${item.level + 1})` : '';

        div.innerHTML = `
            <span class="item-name">${label}${subInfo}</span>
            <span class="item-price">$${item.price}</span>
        `;
        container.appendChild(div);
        totalPrice += item.price;
    });

    document.getElementById('total-price').innerText = `$${totalPrice}`;
    
    const checkoutBtn = document.getElementById('checkout-btn');
    if (totalPrice > 0) {
        checkoutBtn.classList.remove('disabled');
        checkoutBtn.innerText = 'CHECKOUT';
    } else {
        checkoutBtn.classList.add('disabled');
        checkoutBtn.innerText = 'EMPTY CART';
    }
}

function setActiveNav(category) {
    document.querySelectorAll('.nav-item').forEach(el => {
        if (el.dataset.category === category) el.classList.add('active');
        else el.classList.remove('active');
    });
}

function closeUI() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Listeners
document.getElementById('close-btn').addEventListener('click', closeUI);
document.getElementById('back-btn').addEventListener('click', goBack);

document.querySelectorAll('.nav-item').forEach(el => {
    el.addEventListener('click', () => {
        const cat = el.dataset.category;
        if (cat === 'main') renderMainCategories();
        else {
            const data = categoryData[cat];
            navigationStack = [];
            renderLayer(data, data.label);
            setActiveNav(cat);
        }
    });
});

document.querySelectorAll('.category-card').forEach(el => {
    el.addEventListener('click', () => {
        const cat = el.dataset.category;
        const data = categoryData[cat];
        navigationStack = [];
        renderLayer(data, data.label);
        setActiveNav(cat);
    });
});

document.getElementById('checkout-btn').addEventListener('click', () => {
    if (totalPrice > 0) {
        fetch(`https://${GetParentResourceName()}/checkout`, {
            method: 'POST',
            body: JSON.stringify({ total: totalPrice, items: basketItems })
        });
        closeUI();
    }
});

window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeUI();
});

// Camera Controls
let isDragging = false;
let lastMouseX = 0;
let lastMouseY = 0;
let lastFetchTime = 0;

const dragArea = document.getElementById('camera-drag');

dragArea.onmousedown = (e) => {
    isDragging = true;
    lastMouseX = e.clientX;
    lastMouseY = e.clientY;
};

window.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    const now = Date.now();
    if (now - lastFetchTime < 16) return; // ~60fps throttle
    
    const deltaX = e.clientX - lastMouseX;
    const deltaY = e.clientY - lastMouseY;
    lastMouseX = e.clientX;
    lastMouseY = e.clientY;
    lastFetchTime = now;

    fetch(`https://${GetParentResourceName()}/rotateCamera`, {
        method: 'POST',
        body: JSON.stringify({ x: deltaX, y: deltaY })
    });
});

window.addEventListener('mouseup', () => {
    isDragging = false;
});

dragArea.onwheel = (e) => {
    const zoom = e.deltaY > 0 ? 1 : -1;
    fetch(`https://${GetParentResourceName()}/zoomCamera`, {
        method: 'POST',
        body: JSON.stringify({ zoom: zoom })
    });
};
