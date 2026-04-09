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

let currentRGB = { r: 255, g: 255, b: 255 };
let currentHue = 0;
let isPickingColor = false;
let isPickingHue = false;

function renderLayer(data, label) {
    const container = document.getElementById('item-view');
    const pickerUI = document.getElementById('color-picker-ui');
    const mainView = document.getElementById('main-view');
    const backBtn = document.getElementById('back-btn');
    
    mainView.style.display = 'none';
    document.getElementById('category-title').innerText = label;
    backBtn.style.display = 'block';

    if (data.isSub) {
        // We have subcategories to show
        container.style.display = 'flex';
        
        // Show Picker for ALL Paint types (not just Classic)
        // We detect it's a paint menu if it has any of these labels in its subcategories
        const isPaintMenu = data.subCategories && data.subCategories[0] && 
            (data.subCategories[0].label === "Classic" || data.subCategories[0].label === "Matte" || data.subCategories[0].label === "Metals");

        if (isPaintMenu) {
            pickerUI.style.display = 'flex';
            initColorPicker(label);
        } else {
            pickerUI.style.display = 'none';
        }
        
        renderSubCategories(data);
    } else {
        // We have items to show
        pickerUI.style.display = 'none';
        container.style.display = 'flex';
        renderItems(data);
    }
}

function renderSubCategories(data) {
    const container = document.getElementById('item-view');
    container.innerHTML = '';
    data.subCategories.forEach(sub => {
        const row = document.createElement('div');
        row.className = 'item-row sub-row';
        row.innerHTML = `
            <div class="item-main-info"><h4>${sub.label}</h4></div>
            <div class="item-price-info"><i class="fa-solid fa-chevron-right"></i></div>
        `;
        row.onclick = () => {
            navigationStack.push({ data: data, label: document.getElementById('category-title').innerText });
            renderLayer(sub, sub.label);
        };
        container.appendChild(row);
    });
}

function renderItems(data) {
    const container = document.getElementById('item-view');
    container.innerHTML = '';
    const items = data.items || data;
    items.forEach(item => {
        const row = document.createElement('div');
        row.className = 'item-row';
        row.innerHTML = `
            <div class="item-main-info">
                <h4>${item.label}</h4>
                <p>${item.description || (item.level !== undefined ? 'Level ' + (item.level + 1) : '')}</p>
            </div>
            <div class="item-price-info"><span class="price">$${item.price}</span></div>
        `;
        row.onclick = () => selectItem(item);
        container.appendChild(row);
    });
}

// Color Picker Logic
let mapCtx, hueCtx, map, hue;
let pickerPaintLabel = 'Primary';

function initColorPicker(paintLabel) {
    map = document.getElementById('color-map');
    hue = document.getElementById('hue-bar');
    mapCtx = map.getContext('2d');
    hueCtx = hue.getContext('2d');
    pickerPaintLabel = paintLabel;

    drawPickerCanvases();
    
    map.onmousedown = (e) => { isPickingColor = true; updatePickerColor(e, false); };
    hue.onmousedown = (e) => { isPickingHue = true; updatePickerColor(e, true); };
}

function drawPickerCanvases() {
    if (!map || !hue) return;
    const mCtx = map.getContext('2d');
    const hCtx = hue.getContext('2d');

    // Draw Hue Bar
    const hGrad = hCtx.createLinearGradient(0, 0, 0, hue.height);
    for (let i = 0; i <= 360; i += 30) {
        hGrad.addColorStop(i / 360, `hsl(${i}, 100%, 50%)`);
    }
    hCtx.fillStyle = hGrad;
    hCtx.fillRect(0, 0, hue.width, hue.height);

    // Draw Color Map (Sat/Val)
    mCtx.fillStyle = `hsl(${currentHue}, 100%, 50%)`;
    mCtx.fillRect(0, 0, map.width, map.height);

    const whiteGrad = mCtx.createLinearGradient(0, 0, map.width, 0);
    whiteGrad.addColorStop(0, '#fff');
    whiteGrad.addColorStop(1, 'transparent');
    mCtx.fillStyle = whiteGrad;
    mCtx.fillRect(0, 0, map.width, map.height);

    const blackGrad = mCtx.createLinearGradient(0, 0, 0, map.height);
    blackGrad.addColorStop(0, 'transparent');
    blackGrad.addColorStop(1, '#000');
    mCtx.fillStyle = blackGrad;
    mCtx.fillRect(0, 0, map.width, map.height);
}

function updatePickerColor(e, isHue) {
    if (!map || !hue) return;
    const rect = isHue ? hue.getBoundingClientRect() : map.getBoundingClientRect();
    const x = Math.max(0, Math.min(rect.width-1, e.clientX - rect.left));
    const y = Math.max(0, Math.min(rect.height-1, e.clientY - rect.top));

    if (isHue) {
        currentHue = (y / rect.height) * 360;
    } else {
        try {
            const imageData = mapCtx.getImageData(x, y, 1, 1).data;
            currentRGB = { r: imageData[0], g: imageData[1], b: imageData[2] };
        } catch(err) {}
    }

    drawPickerCanvases();
    
    const hex = rgbToHex(currentRGB.r, currentRGB.g, currentRGB.b);
    const preview = document.getElementById('color-preview');
    const hexTxt = document.getElementById('color-hex');
    if (preview) preview.style.background = hex;
    if (hexTxt) hexTxt.innerText = hex.toUpperCase();

    fetch(`https://${GetParentResourceName()}/previewMod`, {
        method: 'POST',
        body: JSON.stringify({
            isColor: true, isCustom: true,
            r: currentRGB.r, g: currentRGB.g, b: currentRGB.b,
            paintType: getPaintTypeFromLabel(pickerPaintLabel || 'Primary')
        })
    });
}

function getPaintTypeFromLabel(label) {
    if (label.includes('Primary')) return 'primary';
    if (label.includes('Secondary')) return 'secondary';
    if (label.includes('Pearl')) return 'pearl';
    if (label.includes('Wheel')) return 'wheel';
    if (label.includes('Interior')) return 'interior';
    return 'primary';
}

function rgbToHex(r, g, b) {
    return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}

const applyBtn = document.getElementById('apply-color-btn');
if (applyBtn) {
    applyBtn.onclick = () => {
        const label = document.getElementById('category-title').innerText;
        const type = getPaintTypeFromLabel(label);
        const item = {
            label: `Custom ${label}`,
            price: 250, // Custom paint fixed price
            isColor: true,
            isCustom: true,
            r: currentRGB.r,
            g: currentRGB.g,
            b: currentRGB.b,
            paintType: type
        };
        selectItem(item);
    };
}

function selectItem(item) {
    let key = item.modId !== undefined ? item.modId : (item.colorId !== undefined ? 'color' : 'misc');
    if (item.isCustom) key = item.paintType;
    if (item.isExtra) key = `extra_${item.extraId}`;

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
    // 1. Color Picker interaction
    if (isPickingColor) updatePickerColor(e, false);
    if (isPickingHue) updatePickerColor(e, true);

    // 2. Camera Rotation interaction
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
    isPickingColor = false;
    isPickingHue = false;
});

dragArea.onwheel = (e) => {
    const zoom = e.deltaY > 0 ? 1 : -1;
    fetch(`https://${GetParentResourceName()}/zoomCamera`, {
        method: 'POST',
        body: JSON.stringify({ zoom: zoom })
    });
};
