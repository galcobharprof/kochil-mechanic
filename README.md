# Kochill Mechanic - Modular Tactical UI

Premium Mechanic Job resource for Qbox framework featuring a sleek Modular Tactical UI, high-contrast aesthetics, and an advanced modification workflow.

## 📦 Dependencies
- [qbx_core](https://github.com/Qbox-Project/qbx_core)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

## 🚀 Installation

### 1. Copy Files
- Drag and drop the `qbx_mechanicjob_custom` folder into your server's `resources` directory.
- Add `ensure qbx_mechanicjob_custom` to your `server.cfg`.

### 2. Register Items
Add the following items to your `ox_inventory/data/items.lua`:

```lua
['mechanic_brochure'] = {
    label = 'Mechanic Brochure',
    weight = 100,
    stack = false,
    close = true,
    description = 'A digital tuner brochure for previewing vehicle modifications.'
},

['mechanic_notes'] = {
    label = 'Mechanic Work Notes',
    weight = 50,
    stack = false,
    close = true,
    description = 'Contains precise tuning data for vehicle technical installation.'
},

['modif_notes'] = {
    label = 'Modification Receipt',
    weight = 10,
    stack = true,
    close = true,
    description = 'An official receipt detailing the installed modifications.'
},
```

### 3. Setup Icons
- Open the `/icons` folder provided in this package.
- Move the three `.png` files to: `ox_inventory/web/images/`.
- Ensure the filenames match the item names above (e.g., `mechanic_brochure.png`).

### 4. Database Setup (Self-Repair & State)
- This script uses the standard `player_vehicles` table from Qbox/QBCore.
- Ensure the `state` column exists for the impound feature functionality.

### 5. Config Customization
- Open `config.lua` to adjust:
    - **Self-Repair Stations**: Coordinate locations and pricing.
    - **Duty Locations**: Where mechanics can go On/Off duty.
    - **Job Settings**: Job name and grade requirements.

## 🎨 Design Features
- **Modular Tactical UI**: Decoupled panels (Sidebar, List, Cart) for zero-overlap.
- **Deep Satin Theme**: High-contrast white typography for 100% visibility.
- **Atomic Checkout**: Safe payment processing before item issuance.
- **Glassmorphism Redefined**: Professional edges with strict clipping (No artifacts).

## 🛠️ Credits
Created by **Kochill Project**.
Specializing in Premium FiveM Solutions.
