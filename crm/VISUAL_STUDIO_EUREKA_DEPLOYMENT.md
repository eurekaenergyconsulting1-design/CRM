# GUIDE VISUAL STUDIO : Intégration & Déploiement CRM Eureka

> **Contexte** : Vous avez un CRM HTML/React monolithique (`EurekaCRM.html`) à finaliser et déployer en local.
> **Cible** : Visual Studio Code (ou Visual Studio 2022) pour dev, test, et déploiement sur IIS / http-server.
>
> **Livrable** : CRM production-ready, accessible via `http://localhost:8080` ou IIS, avec tous les fichiers de configuration.

---

## PARTIE 1 - SETUP INITIAL (Visual Studio + Node.js)

### 1.1 Prérequis

**Software à installer** :
1. **Visual Studio Code** (ou VS 2022) → https://code.visualstudio.com/
2. **Node.js 18+** → https://nodejs.org/
3. **Git** (optionnel mais recommandé)
4. **Python 3** (optionnel, pour serveur local simple)

**Vérification** :
```bash
node --version     # Should be v18+
npm --version      # Should be 9+
git --version      # (optionnel)
```

### 1.2 Importer le projet dans VS Code

```bash
# 1. Créer dossier projet
mkdir eureka-crm-local
cd eureka-crm-local

# 2. Initialiser repo (optionnel)
git init
git config user.name "Developer"
git config user.email "dev@eureka.local"

# 3. Ouvrir VS Code
code .

# 4. Créer arborescence initiale (voir section 1.3)
```

### 1.3 Créer l'arborescence projet

**Manuellement dans VS Code** (Explorer > New Folder) :

```
eureka-crm-local/
├── .vscode/                    # Configuration VS Code
│   ├── settings.json
│   ├── launch.json
│   ├── tasks.json
│   └── extensions.json
├── .claude/                    # Configuration Claude Cowork (optionnel)
│   ├── agents.yml
│   ├── hooks.yml
│   └── settings.yml
├── src/
│   ├── index.html              # Votre EurekaCRM.html (renommer)
│   ├── lib/
│   │   ├── storage.js          # Helper localStorage
│   │   ├── api.js              # Helper API (future Dataverse)
│   │   └── constants.js        # Couleurs, endpoints
│   └── assets/                 # Images, icones (si externes)
├── scripts/
│   ├── dev-server.js           # Dev server Node.js
│   ├── build.js                # Minify & bundle
│   └── deploy-local.sh         # Déploiement local
├── dist/                       # Build production (généré)
│   └── index.html
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATAVERSE_SCHEMA.md
│   └── DEPLOYMENT.md
├── package.json                # Dépendances Node
├── .gitignore
├── .env.example
└── README.md
```

---

## PARTIE 2 - CONFIGURATION VISUAL STUDIO CODE

### 2.1 Installer les extensions essentielles

**Via VS Code UI** :
1. Ouvrir **Extensions** (Ctrl+Shift+X)
2. Installer ces extensions :
   - `Prettier - Code formatter` (esbenp.prettier-vscode)
   - `ESLint` (dbaeumer.vscode-eslint)
   - `HTML Preview` (christopherjl.html-preview-vscode)
   - `Live Server` (ritwickdey.liveserver) — optionnel
   - `Tailwind CSS IntelliSense` (bradlc.vscode-tailwindcss)
   - `Git Graph` (mhutchie.git-graph) — optionnel

**Alternativement** :
```bash
# Copier extensions.json dans .vscode/
# VS Code les proposera automatiquement
```

### 2.2 Copier configuration VS Code

**Créer fichier** : `.vscode/settings.json`
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.formatOnSave": true
  },
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 1000,
  "editor.rulers": [100, 120],
  "editor.wordWrap": "on",
  "editor.trimAutoWhitespace": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.git": true
  },
  "files.exclude": {
    "**/node_modules": true,
    "**/.next": true
  },
  "prettier.semi": true,
  "prettier.singleQuote": true,
  "prettier.tabWidth": 2,
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "html"
  ],
  "[html]": {
    "editor.formatOnPaste": true
  }
}
```

**Créer fichier** : `.vscode/launch.json` (Debug)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Dev Server",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/scripts/dev-server.js",
      "restart": true,
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "env": {
        "NODE_ENV": "development",
        "DEBUG": "eureka:*"
      }
    },
    {
      "name": "Attach to Chrome",
      "type": "chrome",
      "request": "attach",
      "port": 9222,
      "urlFilter": "http://localhost:*",
      "sourceMaps": true,
      "sourceMapPathOverride": {
        "webpack:///": "${workspaceFolder}/src/"
      }
    }
  ]
}
```

**Créer fichier** : `.vscode/tasks.json` (Build tasks)
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Install dependencies",
      "type": "shell",
      "command": "npm",
      "args": ["install"],
      "group": {
        "kind": "build",
        "isDefault": false
      },
      "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "shared"
      }
    },
    {
      "label": "Dev server (start)",
      "type": "shell",
      "command": "npm",
      "args": ["run", "dev"],
      "isBackground": true,
      "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "shared"
      },
      "problemMatcher": {
        "pattern": {
          "regexp": ".*listening.*",
          "line": 1
        },
        "background": {
          "activeOnStart": true,
          "watching": true
        }
      }
    },
    {
      "label": "Build production",
      "type": "shell",
      "command": "npm",
      "args": ["run", "build"],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Deploy local",
      "type": "shell",
      "command": "npm",
      "args": ["run", "deploy"],
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Serve with http-server",
      "type": "shell",
      "command": "npx",
      "args": ["http-server", "./dist", "-p", "8080", "-c-1"],
      "isBackground": true,
      "presentation": {
        "reveal": "always",
        "panel": "shared"
      },
      "problemMatcher": {
        "pattern": {
          "regexp": ".*Starting.*",
          "line": 1
        },
        "background": {
          "activeOnStart": true,
          "watching": false
        }
      }
    },
    {
      "label": "Lint code",
      "type": "shell",
      "command": "npm",
      "args": ["run", "lint"],
      "presentation": {
        "reveal": "always"
      }
    },
    {
      "label": "Run tests",
      "type": "shell",
      "command": "npm",
      "args": ["run", "test"],
      "presentation": {
        "reveal": "always"
      }
    }
  ]
}
```

**Créer fichier** : `.vscode/extensions.json`
```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next",
    "christopherjl.html-preview-vscode",
    "ritwickdey.liveserver",
    "bradlc.vscode-tailwindcss",
    "gruntfoss.auto-rename-tag",
    "mhutchie.git-graph",
    "eamodio.gitlens"
  ]
}
```

### 2.3 Utiliser les tasks dans VS Code

**Lancer task** (Ctrl+Shift+B ou Terminal > Run Task) :
```
Ctrl+Shift+B → Choisir "Dev server (start)"
```

Vous verrez l'output dans le terminal intégré VS Code.

---

## PARTIE 3 - INTÉGRATION DU CODE EUREKA CRM

### 3.1 Copier `EurekaCRM.html` → `src/index.html`

**Action** :
1. Copier votre fichier `EurekaCRM.html`
2. Le renommer en `index.html`
3. Le placer dans le dossier `src/`

**Vérifier contenu** (Vue > Command Palette > "Go to Line" pour checker structure).

### 3.2 Créer les fichiers helper (optionnel mais utile)

**Créer** : `src/lib/constants.js`
```javascript
// src/lib/constants.js
// Brand & app constants

export const BRAND = {
  name: 'eureka',
  fullName: 'Eureka Energy Consulting',
  colors: {
    primary: '#292A5F',      // Navy
    accent: '#F3E600',       // Yellow
    dark: '#07091a',
    light: '#f5f5f5'
  },
  font: 'Poppins'
};

export const STORAGE_KEYS = {
  accounts: 'accounts_list',
  contacts: 'contacts_list',
  deals: 'deals_list',
  quotes: 'quotes_list',
  orders: 'orders_list',
  invoices: 'invoices_list',
  activities: 'activities_list',
  user: 'current_user',
  settings: 'app_settings'
};

export const API_ENDPOINTS = {
  // Future Dataverse endpoints
  dataverse: process.env.DATAVERSE_ENVIRONMENT_URL,
  powerAutomate: process.env.POWER_AUTOMATE_FLOW_URL
};

export const FEATURES = {
  // Feature flags
  dataverseEnabled: process.env.DATAVERSE_ENABLED === 'true',
  offlineMode: true,
  analyticsEnabled: false
};
```

**Créer** : `src/lib/storage.js`
```javascript
// src/lib/storage.js
// Storage abstraction (localStorage → Dataverse future)

import { STORAGE_KEYS } from './constants.js';

export class StorageManager {
  constructor(prefix = 'eureka_') {
    this.prefix = prefix;
  }

  getKey(key) {
    return `${this.prefix}${key}`;
  }

  async set(key, value) {
    try {
      const jsonValue = JSON.stringify(value);
      localStorage.setItem(this.getKey(key), jsonValue);
      return { success: true, key, value };
    } catch (error) {
      console.error('[StorageManager] Set failed:', error);
      return { success: false, error };
    }
  }

  async get(key) {
    try {
      const jsonValue = localStorage.getItem(this.getKey(key));
      return jsonValue ? JSON.parse(jsonValue) : null;
    } catch (error) {
      console.error('[StorageManager] Get failed:', error);
      return null;
    }
  }

  async delete(key) {
    try {
      localStorage.removeItem(this.getKey(key));
      return { success: true, key };
    } catch (error) {
      console.error('[StorageManager] Delete failed:', error);
      return { success: false, error };
    }
  }

  async list(prefix) {
    const keys = [];
    try {
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(this.getKey(prefix || ''))) {
          keys.push(key.replace(this.prefix, ''));
        }
      }
    } catch (error) {
      console.error('[StorageManager] List failed:', error);
    }
    return keys;
  }

  async clear() {
    try {
      const keys = await this.list('');
      keys.forEach(key => this.delete(key));
      return { success: true, cleared: keys.length };
    } catch (error) {
      console.error('[StorageManager] Clear failed:', error);
      return { success: false, error };
    }
  }

  // Export all data for backup
  async exportAll() {
    const data = {};
    const keys = await this.list('');
    for (const key of keys) {
      data[key] = await this.get(key);
    }
    return data;
  }

  // Import data from backup
  async importAll(data) {
    for (const [key, value] of Object.entries(data)) {
      await this.set(key, value);
    }
  }
}

// Export singleton
export const storage = new StorageManager();
```

**Créer** : `src/lib/api.js`
```javascript
// src/lib/api.js
// API helpers (future Dataverse + Power Automate)

import { API_ENDPOINTS, FEATURES } from './constants.js';

export class DataverseAPI {
  constructor(environmentUrl) {
    this.baseUrl = environmentUrl;
    this.isEnabled = FEATURES.dataverseEnabled;
  }

  async fetch(endpoint, options = {}) {
    if (!this.isEnabled) {
      console.warn('[DataverseAPI] Dataverse not enabled');
      return null;
    }

    try {
      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${await this.getToken()}`,
          ...options.headers
        }
      });

      if (!response.ok) {
        throw new Error(`API Error: ${response.status} ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error('[DataverseAPI] Fetch failed:', error);
      throw error;
    }
  }

  async getToken() {
    // Implement token retrieval from Power Apps context
    // window.__POWER_APPS_CONTEXT__ should contain auth tokens
    if (window.__POWER_APPS_CONTEXT__?.authentication?.token) {
      return window.__POWER_APPS_CONTEXT__.authentication.token;
    }
    throw new Error('Dataverse authentication not available');
  }

  // CRUD operations (placeholder)
  async create(table, data) {
    return this.fetch(`/api/data/v9.0/${table}`, {
      method: 'POST',
      body: JSON.stringify(data)
    });
  }

  async read(table, id, options = {}) {
    return this.fetch(`/api/data/v9.0/${table}(${id})`, { ...options });
  }

  async update(table, id, data) {
    return this.fetch(`/api/data/v9.0/${table}(${id})`, {
      method: 'PATCH',
      body: JSON.stringify(data)
    });
  }

  async delete(table, id) {
    return this.fetch(`/api/data/v9.0/${table}(${id})`, {
      method: 'DELETE'
    });
  }
}

export const dataverseAPI = new DataverseAPI(API_ENDPOINTS.dataverse);
```

### 3.3 Mise à jour `index.html` (optionnel : intégrer les helpers)

**Si vous voulez utiliser les helpers** dans votre HTML, ajouter avant `</body>` :

```html
<!-- Helpers (optionnel) -->
<script type="module">
  import { storage } from './lib/storage.js';
  import { BRAND, FEATURES } from './lib/constants.js';
  
  // Make available globally (optional)
  window.__EUREKA__ = {
    storage,
    BRAND,
    FEATURES
  };
  
  console.log('✅ Eureka helpers loaded');
</script>
```

Mais si votre code actuel fonctionne sans, **pas besoin de modifier**.

---

## PARTIE 4 - SETUP NODE.JS & DÉPLOIEMENT LOCAL

### 4.1 Initialiser package.json

**Créer** : `package.json` (à la racine)
```json
{
  "name": "eureka-crm",
  "version": "2.0.0",
  "description": "Eureka Energy Consulting CRM - React/HTML",
  "type": "module",
  "scripts": {
    "dev": "node scripts/dev-server.js",
    "build": "node scripts/build.js",
    "deploy": "bash scripts/deploy-local.sh",
    "start": "npx http-server ./dist -p 8080 -c-1",
    "serve": "python -m http.server 8000 --directory ./dist",
    "lint": "echo 'Lint pending'",
    "test": "echo 'Tests pending'",
    "clean": "rm -rf dist node_modules package-lock.json"
  },
  "keywords": ["crm", "energy", "consulting", "eureka"],
  "author": "Eureka Energy Consulting",
  "license": "PROPRIETARY",
  "engines": {
    "node": ">=18.0.0"
  },
  "devDependencies": {}
}
```

### 4.2 Créer scripts de déploiement

**Créer** : `scripts/dev-server.js`
```javascript
const fs = require('fs');
const path = require('path');
const http = require('http');

const PORT = process.env.PORT || 3000;
const SRC_DIR = path.join(__dirname, '../src');

const mimeTypes = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
  let filePath = path.join(SRC_DIR, req.url === '/' ? 'index.html' : req.url);
  const ext = path.extname(filePath);
  const contentType = mimeTypes[ext] || 'text/plain';

  fs.stat(filePath, (err) => {
    if (err) {
      res.writeHead(404);
      res.end('404 - Not Found');
      return;
    }

    res.writeHead(200, { 'Content-Type': contentType });
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Eureka CRM dev server running`);
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`📂 Serving from: ${SRC_DIR}`);
  console.log(`⏹️  Press Ctrl+C to stop\n`);
});
```

**Créer** : `scripts/build.js`
```javascript
const fs = require('fs-extra');
const path = require('path');

const SRC_FILE = path.join(__dirname, '../src/index.html');
const DIST_DIR = path.join(__dirname, '../dist');
const OUTPUT_FILE = path.join(DIST_DIR, 'index.html');

async function build() {
  console.log('\n🔨 Building Eureka CRM...\n');

  try {
    await fs.ensureDir(DIST_DIR);
    let html = await fs.readFile(SRC_FILE, 'utf-8');
    
    // Optionnel : minifier / optimiser
    // html = html.replace(/<!--[\s\S]*?-->/g, ''); // Remove comments
    
    await fs.writeFile(OUTPUT_FILE, html);
    const sizeKb = (html.length / 1024).toFixed(2);
    
    console.log(`✅ Build complete!`);
    console.log(`📦 Output: ${OUTPUT_FILE}`);
    console.log(`📊 Size: ${sizeKb} KB\n`);
  } catch (err) {
    console.error('❌ Build failed:', err.message);
    process.exit(1);
  }
}

build();
```

**Créer** : `scripts/deploy-local.sh`
```bash
#!/bin/bash
set -e

DIST_DIR="./dist"
DEPLOY_PATH="${EUREKA_DEPLOY_PATH:-./.local-server}"
SERVER_PORT="${EUREKA_PORT:8080}"

echo ""
echo "🔨 Building CRM..."
node scripts/build.js

echo "📂 Creating deployment directory at: $DEPLOY_PATH"
mkdir -p "$DEPLOY_PATH"

echo "📋 Copying files..."
cp -r dist/* "$DEPLOY_PATH"

echo ""
echo "✅ Deployment ready!"
echo ""
echo "To serve locally, choose one:"
echo ""
echo "  1️⃣  Node.js http-server:"
echo "     npx http-server $DEPLOY_PATH -p $SERVER_PORT -c-1"
echo ""
echo "  2️⃣  Python (if installed):"
echo "     cd $DEPLOY_PATH && python -m http.server $SERVER_PORT"
echo ""
echo "  3️⃣  IIS (Windows):"
echo "     Copy files to: C:\\inetpub\\wwwroot\\eureka-crm"
echo ""
echo "  4️⃣  Via npm script:"
echo "     npm start"
echo ""
echo "Then open your browser:"
echo "  🌐 http://localhost:$SERVER_PORT"
echo ""
```

**Rendre exécutable** (Linux/Mac) :
```bash
chmod +x scripts/deploy-local.sh
```

---

## PARTIE 5 - WORKFLOW DE DÉVELOPPEMENT (Visual Studio)

### 5.1 Premier démarrage

**Étape 1** : Installation dépendances
```bash
npm install
```

**Étape 2** : Lancer dev server (Terminal > Run Task)
```
Ctrl+Shift+B → "Dev server (start)"
```

**Étape 3** : Ouvrir browser
```
http://localhost:3000
```

**Étape 4** : Code & reload automatique
- Modifier `src/index.html` → F5 (reload page)
- Modifier code React → reload auto (si hot reload activé)

### 5.2 Debugging

**Mode debug VS Code** :
1. Placer breakpoint (F9 sur ligne)
2. **Debug > Start Debugging** (F5)
3. Choisir "Launch Dev Server"
4. Page s'ouvre avec debugger actif

**Chrome DevTools** (alternative) :
1. Dev server running
2. Ouvrir Chrome DevTools (F12)
3. Console, Elements, Network tabs disponibles

### 5.3 Build production

**Via Command Palette** :
```
Ctrl+Shift+P → "Run Task" → "Build production"
```

Ou terminal direct :
```bash
npm run build
```

Output dans `dist/index.html` (prêt pour production).

### 5.4 Déploiement local

**Option 1 : Via npm** (simple)
```bash
npm start
# Sert `dist/` sur http://localhost:8080
```

**Option 2 : Via script bash** (complet)
```bash
npm run deploy
# Lance build + déploie vers dossier configurable
```

**Option 3 : IIS (Windows)** :
1. Copier `dist/index.html` vers `C:\inetpub\wwwroot\eureka-crm\`
2. Configurer site IIS
3. Accès via `http://localhost/eureka-crm` (ou domaine configuré)

---

## PARTIE 6 - FICHIERS DE CONFIGURATION ADDITIONNELS

### 6.1 .gitignore

**Créer** : `.gitignore`
```
# Dependencies
node_modules/
package-lock.json
yarn.lock

# Build outputs
dist/
build/
.local-server/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*

# Misc
.cache/
.temp/
```

### 6.2 .env.example

**Créer** : `.env.example`
```env
# Development
DEV_PORT=3000
DEV_HOST=localhost

# Dataverse (future)
DATAVERSE_ENABLED=false
DATAVERSE_ENVIRONMENT_URL=https://your-env.crm.dynamics.com
DATAVERSE_CLIENT_ID=xxxxx
DATAVERSE_CLIENT_SECRET=xxxxx

# Deployment
DEPLOY_PATH=./dist
DEPLOY_PORT=8080
EUREKA_PORT=8080

# Storage
STORAGE_TYPE=localStorage
```

### 6.3 README.md

**Créer** : `README.md`
```markdown
# Eureka CRM v2.0

> CRM de suivi d'affaires pour Eureka Energy Consulting

## 🚀 Quick Start

### Prérequis
- Node.js 18+
- npm ou yarn
- Visual Studio Code (optionnel)

### Installation

\`\`\`bash
npm install
\`\`\`

### Développement

\`\`\`bash
npm run dev
# Ouvrir http://localhost:3000
\`\`\`

### Build Production

\`\`\`bash
npm run build
npm start
# Ouvrir http://localhost:8080
\`\`\`

## 📁 Structure

- **src/** - Code source (HTML, React, assets)
- **dist/** - Build production
- **scripts/** - Scripts build/deploy
- **.vscode/** - Configuration VS Code
- **docs/** - Documentation

## 🛠️ Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Démarrer dev server (localhost:3000) |
| `npm run build` | Build production |
| `npm start` | Servir production (localhost:8080) |
| `npm run deploy` | Build + deploy local |
| `npm run lint` | Vérifier code |
| `npm run test` | Lancer tests |

## 🔐 Dataverse Integration (Future)

Structure compatible Dataverse avec 21 tables (accounts, contacts, deals, etc.).

Voir `docs/DATAVERSE_SCHEMA.md` pour détails.

## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Dataverse Schema](docs/DATAVERSE_SCHEMA.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## ⚖️ License

PROPRIETARY - Eureka Energy Consulting
```

---

## PARTIE 7 - CHECKLIST DÉPLOIEMENT

### ✅ Pré-déploiement
- [ ] Code `src/index.html` testé en dev server
- [ ] Pas d'erreurs console (F12)
- [ ] Responsive testée (mobile/tablet/desktop)
- [ ] localStorage persiste correctement

### ✅ Build
- [ ] `npm run build` réussit sans erreur
- [ ] `dist/index.html` généré et valide
- [ ] Fichiers assets copiés (si existants)

### ✅ Déploiement local
- [ ] `npm start` ou script deploy fonctionne
- [ ] Application accessible via http://localhost:8080
- [ ] Tous les features testés (dashboard, CRUD, exports)
- [ ] Performance acceptable (< 3s load time)

### ✅ Production
- [ ] IIS configuré (si applicable)
- [ ] SSL/HTTPS en place (si accès externe)
- [ ] Monitoring & logging configurés
- [ ] Backup localStorage en place

---

## PARTIE 8 - DÉPANNAGE COURANT

| Erreur | Solution |
|--------|----------|
| `Cannot find module` | Vérifier `npm install`, chemin import |
| `localhost refused` | Dev server pas lancé, port occupé |
| `localStorage quota` | Limiter taille données, implémenter compression |
| `CORS error` | Si Power Automate future, configurer CORS |
| `Blank page` | Vérifier HTML valide, React CDN chargé |

---

## PARTIE 9 - NEXT STEPS

### Après déploiement local réussi :

1. **Intégration Dataverse** (optionnel)
   - Créer structure Power Apps Code App
   - Migrer localStorage → Dataverse
   - Déployer via `pac code push`

2. **Sécurité**
   - Ajouter authentification
   - Chiffrer données sensibles
   - Implémenter rate limiting (APIs)

3. **Monitoring**
   - Ajouter logging
   - Analytics utilisation
   - Error tracking

4. **Documentation**
   - Finaliser architecture guide
   - User guide en français
   - Runbook déploiement

---

**Statut** : Configuration complète pour déploiement local réussi. 
**Date** : Mars 2026
**Prochaine révision** : Après first deployment en production
