# 🚀 EUREKA CRM - GUIDE DÉMARRAGE RAPIDE

> Vous avez reçu **2 fichiers markdown adaptés** pour Claude Cowork et Visual Studio.
> Ce document vous guide pour les utiliser.

---

## 📦 Ce que vous avez reçu

### 1️⃣ `COWORK_EUREKA_CRM_FINALIZATION.md`
**Pour** : Claude Cowork (orchestration développement)
**Contient** :
- Configuration agents Claude Cowork (Frontend Dev, Dataverse, DevOps, QA)
- Fichiers `.claude/` à créer (agents.yml, hooks.yml, settings.yml)
- Architecture technique complète
- Checklist de finalisation (5 phases)
- Commandes d'orchestration

**À utiliser quand** : Vous lancez Claude Cowork pour automatiser la finalisation du CRM

---

### 2️⃣ `VISUAL_STUDIO_EUREKA_DEPLOYMENT.md`
**Pour** : Visual Studio Code / Visual Studio 2022 (déploiement local)
**Contient** :
- Setup initial (prérequis Node.js, extensions VS Code)
- Configuration `.vscode/` complète (settings, launch, tasks)
- Intégration du code `EurekaCRM.html`
- Scripts Node.js (dev-server.js, build.js, deploy-local.sh)
- Workflow développement (debug, build, déploiement)
- Dépannage courant

**À utiliser quand** : Vous travaillez en local avec VS Code pour finaliser le CRM

---

## 🎯 ROADMAP RECOMMANDÉE

### Phase 1 : Setup VS Code (1 jour)
```
✅ Installer extensions VS Code
✅ Copier configuration .vscode/
✅ Mettre EurekaCRM.html dans src/index.html
✅ Installer Node.js dépendances (npm install)
✅ Lancer dev server (npm run dev)
✅ Tester sur http://localhost:3000
```

**Fichier à consulter** : `VISUAL_STUDIO_EUREKA_DEPLOYMENT.md` (Parties 1-4)

---

### Phase 2 : Développement & Tests (3-5 jours)
```
✅ Fixer bugs UI (responsive, formulaires, modales)
✅ Optimiser localStorage
✅ Documenter flux CRUD
✅ Tests smoke (dashboard, exports)
✅ Vérifier cross-browser (Chrome, Firefox, Safari)
```

**Workflow** :
- Ouvrir Terminal dans VS Code
- Lancer `npm run dev`
- Modifier code
- F5 pour reload
- F12 pour debug

**Fichier à consulter** : `VISUAL_STUDIO_EUREKA_DEPLOYMENT.md` (Partie 5)

---

### Phase 3 : Déploiement Local (1 jour)
```
✅ Générer build production (npm run build)
✅ Servir via npm start ou script deploy
✅ Tester sur http://localhost:8080
✅ Vérifier tout fonctionne
```

**Commandes** :
```bash
npm run build        # Génère dist/index.html
npm start            # Serve sur http://localhost:8080
npm run deploy       # Build + deploy (bash script)
```

**Fichier à consulter** : `VISUAL_STUDIO_EUREKA_DEPLOYMENT.md` (Parties 4, 7-8)

---

### Phase 4 : Orchestration Claude Cowork (optionnel)
```
✅ Créer dossier .claude/ avec agents.yml
✅ Lancer agents Frontend Dev, QA, DevOps
✅ Automatiser tests & déploiement
✅ Générer rapport final
```

**Commandes Cowork** :
```bash
cowork init --template eureka-crm
cowork run --workflow release --all-agents
cowork status
```

**Fichier à consulter** : `COWORK_EUREKA_CRM_FINALIZATION.md` (Parties B-D)

---

### Phase 5 : Intégration Dataverse (futur, optionnel)
```
✅ Créer structure Power Apps Code App
✅ Ajouter tables Dataverse (21 tables)
✅ Migrer localStorage → Dataverse
✅ Tester authentification Power Platform
```

**Voir section A4** dans `COWORK_EUREKA_CRM_FINALIZATION.md`

---

## 📋 ARBORESCENCE FINALE

Après avoir suivi ce guide, votre projet ressemblera à :

```
eureka-crm-local/
├── .vscode/
│   ├── settings.json          ← Copier depuis VISUAL_STUDIO_EUREKA_DEPLOYMENT.md
│   ├── launch.json
│   ├── tasks.json
│   └── extensions.json
├── .claude/                    ← Créer si utilisant Cowork (optionnel)
│   ├── agents.yml
│   ├── hooks.yml
│   └── settings.yml
├── src/
│   ├── index.html              ← Votre EurekaCRM.html (renommé)
│   └── lib/
│       ├── constants.js
│       ├── storage.js
│       └── api.js
├── scripts/
│   ├── dev-server.js           ← Copier depuis VISUAL_STUDIO_EUREKA_DEPLOYMENT.md
│   ├── build.js
│   └── deploy-local.sh
├── dist/                       ← Généré après npm run build
│   └── index.html
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATAVERSE_SCHEMA.md
│   └── DEPLOYMENT.md
├── package.json                ← Copier depuis VISUAL_STUDIO_EUREKA_DEPLOYMENT.md
├── .gitignore
├── .env.example
└── README.md
```

---

## ⚡ COMMANDES ESSENTIELLES

### Développement
```bash
npm install          # Installer dépendances
npm run dev          # Lancer dev server (localhost:3000)
npm run lint         # Vérifier code
npm run test         # Lancer tests
```

### Build & Deploy
```bash
npm run build        # Générer production (dist/)
npm start            # Servir production (localhost:8080)
npm run deploy       # Build + deploy local
npm run clean        # Nettoyer dist/ et node_modules/
```

### VS Code Tasks (Ctrl+Shift+B)
- "Dev server (start)" → Lance npm run dev
- "Build production" → Lance npm run build
- "Deploy local" → Lance npm run deploy
- "Serve with http-server" → Alterne vers port 8080

---

## 🔗 LIENS CLÉS DANS LES DOCS

### VISUAL_STUDIO_EUREKA_DEPLOYMENT.md

| Partie | Sujet | Usage |
|--------|-------|-------|
| 1 | Setup initial | Prérequis, installer Node.js |
| 2 | Configuration VS Code | Extensions, settings.json, tasks |
| 3 | Intégration EurekaCRM.html | Copier code HTML |
| 4 | Setup Node.js | package.json, scripts |
| 5 | Workflow développement | Debug, build, deploy |
| 6 | Fichiers config additionnels | .gitignore, .env, README |
| 7 | Checklist déploiement | Validation avant prod |
| 8 | Dépannage | Erreurs communes |
| 9 | Next steps | Dataverse, sécurité, monitoring |

### COWORK_EUREKA_CRM_FINALIZATION.md

| Partie | Sujet | Usage |
|--------|-------|-------|
| A | Contexte technique | Architecture CRM + Dataverse |
| B | Configuration Cowork | agents.yml, hooks.yml, settings.yml |
| C | Fichiers à créer | Scripts, docs, .env |
| D | Checklist finalisation | 5 phases développement |
| E | Commandes Cowork | npm + cowork commands |
| F | Success criteria | Validation finale |

---

## ✅ CHECKLIST AVANT DE COMMENCER

### Prérequis
- [ ] Node.js 18+ installé (`node --version`)
- [ ] npm installé (`npm --version`)
- [ ] Visual Studio Code installé
- [ ] Fichier `EurekaCRM.html` disponible

### Préparation
- [ ] Créer dossier projet `eureka-crm-local/`
- [ ] Lire partie 1 de `VISUAL_STUDIO_EUREKA_DEPLOYMENT.md`
- [ ] Copier configuration `.vscode/` (section 2)
- [ ] Copier `package.json` (section 4.1)
- [ ] Créer arborescence src/, scripts/, dist/

### Démarrage
- [ ] `npm install`
- [ ] `npm run dev`
- [ ] Ouvrir http://localhost:3000 dans browser
- [ ] Tester quelques features

### Déploiement
- [ ] `npm run build`
- [ ] `npm start`
- [ ] Vérifier http://localhost:8080
- [ ] Valider checklist partie 7

---

## 🆘 AIDE RAPIDE

**Q: Erreur lors de `npm run dev`?**
→ Vérifier Node.js version, `npm install`, rechecker chemin fichiers

**Q: Comment déboguer?**
→ Voir Partie 5.2 dans VISUAL_STUDIO_EUREKA_DEPLOYMENT.md (F9 breakpoints, F5 debug)

**Q: IIS vs npm start?**
→ Pour simple local : `npm start`
→ Pour production serveur : Partie 5.4 (copier dist/ vers IIS)

**Q: Utiliser Claude Cowork?**
→ Après Phase 3 complétée, voir COWORK_EUREKA_CRM_FINALIZATION.md Partie B

**Q: Comment intégrer Dataverse?**
→ Futur (Phase 5), voir COWORK_EUREKA_CRM_FINALIZATION.md section A4 + Partie D4

---

## 📞 PROCHAINES ÉTAPES

1. **Aujourd'hui** : Installer Node.js, ouvrir VS Code
2. **Jour 1-2** : Setup VS Code + premiers tests
3. **Jour 3-5** : Développement & fixes bugs
4. **Jour 6** : Build production + déploiement local
5. **Jour 7+** : Claude Cowork + Dataverse (optionnel)

---

## 📁 FICHIERS À GARDER À PORTÉE

Pendant le développement, gardez ces 2 fichiers ouverts :

1. **VISUAL_STUDIO_EUREKA_DEPLOYMENT.md** (workflow local)
2. **COWORK_EUREKA_CRM_FINALIZATION.md** (contexte tech + futur)

Pour référence rapide, imprimer les **sections clés** :
- Settings VS Code (JSON)
- Package.json
- Scripts Node.js
- Commandes essentielles

---

**Version** : 2.0 - Mars 2026
**Statut** : Production-ready
**Support** : Consulter sections dépannage dans docs
