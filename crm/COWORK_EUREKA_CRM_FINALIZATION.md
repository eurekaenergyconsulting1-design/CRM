# MISSION COWORK : Finalisation & Déploiement CRM Eureka

> **Contexte** : Le CRM Eureka est un SPA React/HTML monolithique en cours de développement.
> **Objectif** : Finaliser le code, préparer l'intégration Dataverse, configurer le déploiement local
> et les hooks d'orchestration pour Claude Cowork & Visual Studio.
>
> **Livrable** : Code production-ready, structure `.vscode/`, configuration déploiement local.

---

## PARTIE A - CONTEXTE TECHNIQUE EUREKA CRM (HTML/React/Dataverse)

### A1. État actuel du projet

**Stack existant (monolithique HTML)**:
- Framework : React 18 (via CDN) + Babel standalone
- Runtime : Browser (localStorage pour persistence)
- Couleurs brand : `#292A5F` (navy) + `#F3E600` (yellow)
- Domaine : Energy Consulting (téléprospection, BPO, RH, data)
- Langues : Français obligatoire (France, Benin, francophones)

**Structure du HTML actuel** :
```
<head>
  - Meta tags
  - React + ReactDOM (CDN)
  - Babel standalone
  - Styles inline
</head>
<body>
  - Loading screen (brand Eureka)
  - <script type="text/babel">
    - Hooks React (useState, useEffect, etc.)
    - CRM Source Code (monolithique, 4500+ lignes)
    - Export root component via ReactDOM.createRoot()
```

**Modules fonctionnels existants** :
- Dashboard / KPIs
- Gestion entreprises (Accounts)
- Gestion contacts
- Pipeline d'opportunités (Kanban)
- Devis / Commandes / Factures (si implémentés)
- Envoi emails
- Activités / Tâches
- Historique & Audit trail
- Import/Export

### A2. Transition vers architecture modern + Dataverse

**Si déploiement local uniquement** (localStorage) :
- Continuer avec HTML monolithique
- Ajouter Node.js dev server (Vite/live reload)
- Minifier avant production

**Si intégration Dataverse future** :
- Migrer vers structure Power Apps Code App officielle
- Tables Dataverse : 21 tables (accounts, contacts, deals, quotes, orders, invoices, etc.)
- Services générés via `pac code add-data-source`

**Decision point** : Voir section A4 ci-dessous.

### A3. Arborescence cible (déploiement local)

```
eureka-crm-local/
├── src/
│   ├── index.html              # SPA principale (HTML monolithique actuel)
│   ├── styles.css              # Styles séparés (optionnel, refactor)
│   ├── app.jsx                 # Code React extrait en JSX (optionnel, refactor)
│   └── lib/
│       ├── storage.js          # Storage wrapper (localStorage → Dataverse)
│       ├── api.js              # API helpers (Power Automate + Dataverse)
│       └── constants.js        # Brand colors, endpoints
├── .vscode/
│   ├── settings.json           # ESLint, Prettier, extensions
│   ├── launch.json             # Debug config
│   ├── tasks.json              # Build, serve, deploy tasks
│   └── extensions.json         # Recommended extensions
├── .claude/
│   ├── agents.yml              # Agents Claude Cowork
│   ├── hooks.yml               # Pre/post-commit hooks
│   └── settings.yml            # Config Claude Cowork
├── scripts/
│   ├── dev-server.js           # Node.js + Vite dev server
│   ├── build.js                # Minify + bundle production
│   └── deploy-local.sh         # Deploy vers dossier local (IIS, http-server)
├── tests/
│   └── crm.test.js             # Tests unitaires (optionnel)
├── docs/
│   ├── ARCHITECTURE.md         # Doc technique
│   ├── DATAVERSE_SCHEMA.md     # Schéma 21 tables
│   └── ENDPOINTS.md            # Power Automate endpoints
├── package.json                # Dépendances Node
├── vite.config.js              # Config Vite (si refactor)
├── .env.example                # Env vars template
└── README.md                   # Getting started
```

### A4. Décision : Dataverse ou localStorage ?

| Critère | localStorage | Dataverse |
|---------|-------------|-----------|
| **Déploiement** | Immédiat, local | Nécessite Power Platform |
| **Authentification** | Aucune | Via Power Apps context |
| **Persistance** | Navigateur uniquement | Cloud secure |
| **Scalabilité** | 1 utilisateur | Multi-users |
| **Coût** | 0€ | Licence Power Platform |
| **Timeline** | 1-2j finalization | 1-2 semaines |

**Recommandation** :
- **Étape 1** (Cowork) : Finaliser version localStorage (immédiat, live)
- **Étape 2** (futur) : Créer structure Power Apps Code App parallèle
- **Étape 3** : Migrer données localStorage → Dataverse

---

## PARTIE B - CONFIGURATION CLAUDE COWORK + VISUAL STUDIO

### B1. Agents Claude Cowork (.claude/agents.yml)

```yaml
# .claude/agents.yml
name: "Eureka CRM Development"
description: "Orchestration développement & déploiement CRM Eureka"
version: "1.0"

agents:
  - id: "frontend-dev"
    role: "Frontend Developer"
    goals:
      - "Finaliser composants React du CRM"
      - "Fixer bugs UI (modales, kanban, formulaires)"
      - "Optimiser performance (re-renders, localStorage queries)"
    tools:
      - "code-editor"
      - "bash"
      - "file-operations"
    watch_paths:
      - "src/**/*.jsx"
      - "src/**/*.html"
    triggers:
      - "on_file_change"
      - "manual"

  - id: "dataverse-integrator"
    role: "Backend / Dataverse Specialist"
    goals:
      - "Créer mapping localStorage → Dataverse tables"
      - "Implémenter API helpers (CRUD Dataverse)"
      - "Documenter endpoints Power Automate"
    tools:
      - "code-editor"
      - "documentation"
    dependencies:
      - "frontend-dev"
    disabled: false  # À activer si choix Dataverse

  - id: "devops-deployer"
    role: "DevOps / Deployment"
    goals:
      - "Minifier & bundle production"
      - "Configurer déploiement local (IIS / http-server)"
      - "Générer .env + secrets"
    tools:
      - "bash"
      - "file-operations"
      - "package-manager"
    watch_paths:
      - "scripts/"
      - "package.json"

  - id: "qa-tester"
    role: "QA / Testing"
    goals:
      - "Valider fonctionnalités critiques (dashboard, CRUD, exports)"
      - "Tester compatibilité navigateurs"
      - "Documenter test cases"
    tools:
      - "bash"
      - "file-operations"

hooks:
  pre-commit:
    - agent: "frontend-dev"
      command: "npm run lint"
    - agent: "qa-tester"
      command: "npm run test"

  post-merge:
    - agent: "dataverse-integrator"
      command: "npm run validate-schema"

workflows:
  - id: "daily-checkpoint"
    frequency: "manual"
    steps:
      - agent: "frontend-dev"
        action: "Review open issues"
      - agent: "devops-deployer"
        action: "Build & serve locally"
      - agent: "qa-tester"
        action: "Run smoke tests"

  - id: "release"
    frequency: "manual"
    steps:
      - agent: "frontend-dev"
        action: "Code freeze"
      - agent: "devops-deployer"
        action: "Production build"
      - agent: "qa-tester"
        action: "Final sign-off"
```

### B2. Configuration VS Code (.vscode/)

#### settings.json
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "editor.rulers": [100, 120],
  "editor.wordWrap": "on",
  "files.exclude": {
    "**/node_modules": true,
    "**/.next": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true
  },
  "eslint.run": "onSave",
  "eslint.validate": [
    "javascript",
    "javascriptreact"
  ],
  "[json]": {
    "editor.formatOnSave": true
  }
}
```

#### launch.json (Debug configuration)
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "CRM Dev Server",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/scripts/dev-server.js",
      "restart": true,
      "console": "integratedTerminal",
      "env": {
        "NODE_ENV": "development"
      }
    },
    {
      "name": "Chrome Debug",
      "type": "chrome",
      "request": "attach",
      "port": 9222,
      "urlFilter": "http://localhost:*"
    }
  ]
}
```

#### tasks.json (Build tasks)
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Install dependencies",
      "type": "shell",
      "command": "npm",
      "args": ["install"],
      "problemMatcher": []
    },
    {
      "label": "Start dev server",
      "type": "shell",
      "command": "npm",
      "args": ["run", "dev"],
      "isBackground": true,
      "problemMatcher": {
        "pattern": {
          "regexp": ".*",
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
      }
    },
    {
      "label": "Deploy local",
      "type": "shell",
      "command": "bash",
      "args": ["${workspaceFolder}/scripts/deploy-local.sh"],
      "problemMatcher": []
    },
    {
      "label": "Run tests",
      "type": "shell",
      "command": "npm",
      "args": ["run", "test"],
      "problemMatcher": []
    }
  ]
}
```

#### extensions.json (Recommended extensions)
```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next",
    "christopherjl.html-preview-vscode",
    "ritwickdey.liveserver",
    "wallabyjs.wallaby-vscode",
    "gruntfoss.auto-rename-tag",
    "bradlc.vscode-tailwindcss",
    "mhutchie.git-graph",
    "ms-vscode.makefile-tools"
  ]
}
```

### B3. Configuration Claude Cowork (.claude/hooks.yml)

```yaml
# .claude/hooks.yml
# Hooks pour intercepter & automatiser étapes clés

hooks:
  on_file_save:
    - path: "src/**/*.jsx"
      actions:
        - validate_jsx_syntax
        - run_eslint
        - suggest_optimizations

  on_error:
    - pattern: "localStorage undefined"
      agent: "frontend-dev"
      auto_fix: true
      
    - pattern: "Dataverse (401|403)"
      agent: "dataverse-integrator"
      slack: "#eureka-crm"

  on_merge:
    - branch: "develop"
      actions:
        - run_tests
        - generate_changelog

  on_deployment:
    - environment: "local"
      actions:
        - build_production
        - copy_to_www_root
        - smoke_tests
```

### B4. Configuration Claude Cowork (.claude/settings.yml)

```yaml
# .claude/settings.yml
# Settings globales pour orchestration

project:
  name: "Eureka CRM"
  language: "Français (obligatoire)"
  version: "2.0"
  status: "Finalization"

tech_stack:
  framework: "React 18"
  ui: "HTML monolithique + Babel"
  storage: "localStorage (→ Dataverse future)"
  build: "Vite v7 (optionnel) ou Node.js server"
  deployment: "Local IIS / http-server / Docker"

brand:
  colors:
    primary: "#292A5F"      # Navy
    accent: "#F3E600"       # Yellow
  font: "Poppins"
  markets: ["France", "Bénin", "Francophones"]
  tone: "Professional, results-oriented, burden-relieving"

dataverse:
  enabled: false            # À activer ultérieurement
  tables: 21
  environment: "placeholder"
  future_migration: true

environments:
  development:
    host: "localhost:3000"
    browser: "Chrome"
    debugging: "enabled"
    
  local:
    host: "http://localhost:8080"
    server: "http-server / IIS"
    
  production:
    host: "eureka-crm.internal"  # À définir
    minified: true
    analytics: "enabled"

cowork:
  auto_detect_issues: true
  suggest_refactoring: false  # À l'activation
  language: "Français"
  slack_integration: false
  max_concurrent_agents: 3

content_rules:
  mandatory:
    - "Mention téléprospection avant inbound/SAV"
    - "Pair CNSS + URSSAF when referencing social"
    - "No em-dashes in copy"
    - "No flag emojis"
  tone:
    - "Results-oriented"
    - "Burden-relieving"
    - "Pour vous / avec vous"
```

---

## PARTIE C - FICHIERS À CRÉER / MODIFIER

### C1. Fichiers Node.js pour dev server & build

#### scripts/dev-server.js
```javascript
// scripts/dev-server.js
const fs = require('fs');
const path = require('path');
const http = require('http');
const { createReadStream } = require('fs');

const PORT = process.env.PORT || 3000;
const SRC_DIR = path.join(__dirname, '../src');

const server = http.createServer((req, res) => {
  let filePath = path.join(SRC_DIR, req.url === '/' ? 'index.html' : req.url);
  const ext = path.extname(filePath);
  
  let contentType = 'text/html';
  if (ext === '.css') contentType = 'text/css';
  if (ext === '.js') contentType = 'application/javascript';
  if (ext === '.json') contentType = 'application/json';

  fs.stat(filePath, (err) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/html' });
      res.end('<h1>404 - Not Found</h1>', 'utf-8');
      return;
    }

    res.writeHead(200, { 'Content-Type': contentType });
    createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, () => {
  console.log(`\n🚀 Eureka CRM dev server running at http://localhost:${PORT}`);
  console.log(`📂 Serving from: ${SRC_DIR}\n`);
});
```

#### scripts/build.js
```javascript
// scripts/build.js
const fs = require('fs-extra');
const path = require('path');
const UglifyJS = require('uglify-js');

const SRC_FILE = path.join(__dirname, '../src/index.html');
const DIST_DIR = path.join(__dirname, '../dist');
const OUTPUT_FILE = path.join(DIST_DIR, 'index.html');

async function build() {
  try {
    // Créer dossier dist
    await fs.ensureDir(DIST_DIR);
    
    // Lire HTML
    let html = await fs.readFile(SRC_FILE, 'utf-8');
    
    // Minifier code JavaScript inline (optionnel)
    // html = html.replace(/<script[^>]*>([\s\S]*?)<\/script>/g, (match, code) => {
    //   const minified = UglifyJS.minify(code);
    //   return minified.error ? match : `<script>${minified.code}</script>`;
    // });
    
    // Écrire output
    await fs.writeFile(OUTPUT_FILE, html);
    
    console.log(`✅ Build complete: ${OUTPUT_FILE}`);
    console.log(`📦 Size: ${(html.length / 1024).toFixed(2)} KB`);
  } catch (err) {
    console.error('❌ Build failed:', err.message);
    process.exit(1);
  }
}

build();
```

#### scripts/deploy-local.sh
```bash
#!/bin/bash
# scripts/deploy-local.sh
# Deploy local version (IIS / http-server)

set -e

DIST_DIR="./dist"
DEPLOY_PATH="${EUREKA_DEPLOY_PATH:-./.local-server}"
SERVER_PORT="${EUREKA_PORT:8080}"

echo "🔨 Building CRM..."
npm run build

echo "📂 Creating deployment directory..."
mkdir -p "$DEPLOY_PATH"

echo "📋 Copying files..."
cp -r "$DIST_DIR"/* "$DEPLOY_PATH"

echo "✅ Deployment ready at: $DEPLOY_PATH"
echo ""
echo "To serve locally:"
echo "  Option 1 (Python): python -m http.server 8000 --directory $DEPLOY_PATH"
echo "  Option 2 (Node): npx http-server $DEPLOY_PATH -p $SERVER_PORT"
echo "  Option 3 (IIS): Copy files to C:\\inetpub\\wwwroot\\eureka-crm"
echo ""
echo "Then open: http://localhost:8000 (or configured port)"
```

#### package.json
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
    "lint": "eslint src/ --ext .js,.jsx",
    "test": "echo 'Tests pending'",
    "serve": "python -m http.server 8000 --directory ./dist"
  },
  "keywords": ["crm", "energy", "consulting", "eureka"],
  "author": "Eureka Energy Consulting",
  "license": "PROPRIETARY",
  "devDependencies": {
    "eslint": "^9.0.0",
    "prettier": "^3.0.0",
    "fs-extra": "^11.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### C2. Documentation Dataverse (future)

#### docs/DATAVERSE_SCHEMA.md
```markdown
# Schéma Dataverse - Eureka CRM (v2.0)

## 21 Tables métier

### Bloc 1 : Fondamentaux (3 tables)
- **cds_accounts** : Entreprises clientes
- **cds_contacts** : Contacts rattachés
- **cds_activities** : Historique interactions

### Bloc 2 : Commercial (6 tables)
- **cds_deals** : Opportunités
- **cds_quotes** : Devis
- **cds_quote_lines** : Lignes devis
- **cds_orders** : Commandes
- **cds_order_lines** : Lignes commandes
- **cds_invoices** : Factures
- **cds_invoice_lines** : Lignes factures

### Bloc 3 : Suivi & Tâches (3 tables)
- **cds_tasks** : Tâches
- **cds_payments** : Suivi paiements
- **cds_reminders** : Rappels

### Bloc 4 : Communications (4 tables)
- **cds_email_templates** : Templates emails
- **cds_email_logs** : Historique envois
- **cds_phone_logs** : Historique appels
- **cds_attachments** : Documents

### Bloc 5 : Automatisation & Analytics (5 tables)
- **cds_workflow_rules** : Règles workflows
- **cds_workflow_executions** : Exécutions
- **cds_goals** : Objectifs commerciaux
- **cds_achievements** : Achievements/Gamification
- **cds_audit_entries** : Audit trail

## Commandes Dataverse (CLI)

```bash
# Une fois structure Power Apps Code App prête

# Bloc 1
pac code add-data-source -a dataverse -t cds_accounts
pac code add-data-source -a dataverse -t cds_contacts
pac code add-data-source -a dataverse -t cds_activities

# Bloc 2
pac code add-data-source -a dataverse -t cds_deals
pac code add-data-source -a dataverse -t cds_quotes
pac code add-data-source -a dataverse -t cds_quote_lines
# ... etc

# Services générés automatiquement
# Ne PAS modifier: CdsAccountsModel.ts, CdsAccountsService.ts, etc.
```

## Migration données localStorage → Dataverse

```javascript
// Stratégie : Dual-write temporaire
// 1. Écrire dans localStorage (pour offline)
// 2. Simultanément sync vers Dataverse (via Power Automate)

// Exemple : saveAccount()
async function saveAccount(account) {
  // localStorage (current)
  localStorage.setItem(`account_${account.id}`, JSON.stringify(account));
  
  // Dataverse (future)
  if (window.__DATAVERSE_ENABLED__) {
    await CdsAccountsService.create({
      cds_name: account.name,
      cds_siren: account.siren,
      // ... mapping des champs
    });
  }
}
```
```

### C3. .env template

#### .env.example
```env
# .env.example (rename to .env pour dev local)

# Dev Server
DEV_PORT=3000
DEV_HOST=localhost

# Dataverse (future)
DATAVERSE_ENABLED=false
DATAVERSE_ENVIRONMENT_URL=https://your-env.crm.dynamics.com
DATAVERSE_CLIENT_ID=xxxxx
DATAVERSE_CLIENT_SECRET=xxxxx

# Power Automate (future)
POWER_AUTOMATE_FLOW_URL=https://prod-XX.logic.azure.com/workflows/xxxxx

# Storage
STORAGE_TYPE=localStorage  # localStorage | dataverse
STORAGE_PREFIX=eureka_

# Brand
BRAND_PRIMARY_COLOR=#292A5F
BRAND_ACCENT_COLOR=#F3E600
BRAND_NAME=Eureka

# Deployment
DEPLOY_TARGET=local  # local | iis | docker
DEPLOY_PATH=./dist
DEPLOY_PORT=8080
```

---

## PARTIE D - CHECKLIST FINALISATION (Cowork)

### Phase 1 : Code cleanup (Frontend Dev Agent - 2j)
- [ ] Valider tous composants React (no console errors)
- [ ] Fixer bugs affichage (responsive, modales, formulaires)
- [ ] Optimiser localStorage queries (indexing, caching)
- [ ] Documenter flux principaux (CRUD, exports)
- [ ] Ajouter loading states manquants

### Phase 2 : Configuration déploiement (DevOps Agent - 1j)
- [ ] Créer `.vscode/` (settings + tasks)
- [ ] Créer `.claude/` (agents + hooks)
- [ ] Setup `scripts/` (dev-server, build, deploy)
- [ ] Générer `.env.example`
- [ ] Tester dev server en local

### Phase 3 : Tests & QA (QA Agent - 2j)
- [ ] Smoke tests (login si appliqué, dashboard, CRUD)
- [ ] Cross-browser (Chrome, Firefox, Safari)
- [ ] Performance (Lighthouse, localStorage ops)
- [ ] Documenter résultats

### Phase 4 : Dataverse prep (Backend Agent - optionnel, 3j)
- [ ] Créer doc DATAVERSE_SCHEMA.md complet
- [ ] Écrire mapping localStorage → Dataverse
- [ ] Créer Power Automate templates (emails, webhooks)
- [ ] Tester connexion Dataverse (si env disponible)

### Phase 5 : Documentation & Release (1j)
- [ ] README.md + Getting Started
- [ ] ARCHITECTURE.md (diagram + explications)
- [ ] DEPLOYMENT.md (local + future cloud)
- [ ] Version bump (2.0.0)
- [ ] Tag release git

---

## PARTIE E - COMMANDES COWORK (exemples)

```bash
# Démarrer dev server avec hot reload
npm run dev

# Build production (minifié)
npm run build

# Déployer en local
npm run deploy

# Linter code
npm run lint

# Orchestrer tous les agents (final release)
cowork run --workflow release --all-agents

# Afficher status agents
cowork status

# Logs temps réel
cowork logs --tail -f
```

---

## PARTIE F - SUCCESS CRITERIA

✅ **Code production-ready**
- Zéro erreur console
- Zéro warning ESLint
- localStorage stable
- Responsive (mobile/tablet/desktop)

✅ **Déploiement local fonctionnel**
- Dev server tourne sans erreur
- Production build < 1MB
- Déploiement en IIS / http-server réussi
- Tests de smoke passent

✅ **Dataverse-ready** (optionnel phase 2)
- Mapping localStorage → Dataverse documenté
- Power Automate flows template créés
- Authentification Power Apps testée

✅ **Documentation complète**
- Architecture diagram
- Deployment guide
- API endpoints
- Troubleshooting guide

---

**Prochaines étapes** : Exécuter cette mission via Claude Cowork en assignant agents & workflows.
