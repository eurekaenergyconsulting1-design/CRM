@echo off
title Eureka CRM — Setup et Deploiement
color 0A
echo.
echo  ╔══════════════════════════════════════════════════════╗
echo  ║   EUREKA CRM — Configuration et Déploiement         ║
echo  ╚══════════════════════════════════════════════════════╝
echo.

:: Aller dans le dossier du script
cd /d "%~dp0"

:: Vérifier Node.js
node --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
  color 0C
  echo  ❌ Node.js n'est pas installé.
  echo  → Téléchargez-le sur https://nodejs.org (version LTS)
  echo    puis relancez ce script.
  pause
  exit /b 1
)
echo  ✅ Node.js :
node --version

:: Créer le dossier lib/ pour les scripts locaux
if not exist "lib" mkdir lib

echo.
echo  📥 Téléchargement des scripts React/Babel en local...
echo  (Cela évite de dépendre d'un CDN externe)
echo.

:: Télécharger avec PowerShell (disponible sur tous les Windows modernes)
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://unpkg.com/react@18/umd/react.production.min.js' -OutFile 'lib\react.min.js' -UseBasicParsing }" 2>nul
IF %ERRORLEVEL% NEQ 0 (
  powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://cdn.jsdelivr.net/npm/react@18/umd/react.production.min.js' -OutFile 'lib\react.min.js' -UseBasicParsing }"
)
echo  ✅ react.min.js

powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://unpkg.com/react-dom@18/umd/react-dom.production.min.js' -OutFile 'lib\react-dom.min.js' -UseBasicParsing }" 2>nul
IF %ERRORLEVEL% NEQ 0 (
  powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://cdn.jsdelivr.net/npm/react-dom@18/umd/react-dom.production.min.js' -OutFile 'lib\react-dom.min.js' -UseBasicParsing }"
)
echo  ✅ react-dom.min.js

powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://unpkg.com/@babel/standalone/babel.min.js' -OutFile 'lib\babel.min.js' -UseBasicParsing }" 2>nul
IF %ERRORLEVEL% NEQ 0 (
  powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://cdn.jsdelivr.net/npm/@babel/standalone@7.24.7/babel.min.js' -OutFile 'lib\babel.min.js' -UseBasicParsing }"
)
echo  ✅ babel.min.js

:: Vérifier que les fichiers ont bien été téléchargés
if not exist "lib\react.min.js" goto ERREUR_DL
if not exist "lib\react-dom.min.js" goto ERREUR_DL
if not exist "lib\babel.min.js" goto ERREUR_DL

echo.
echo  ✅ Scripts téléchargés avec succès
echo.

:: Installer Vercel CLI si absent
vercel --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
  echo  📦 Installation Vercel CLI...
  npm install -g vercel
)

echo.
echo  🚀 Déploiement en production...
echo.
vercel --prod --yes

IF %ERRORLEVEL% EQU 0 (
  color 0A
  echo.
  echo  ✅ DÉPLOIEMENT RÉUSSI !
  echo.
  echo  → Ouvrez votre URL Vercel dans Chrome
  echo  → Faites Ctrl+Shift+R pour vider le cache
  echo  → Connectez-vous normalement
) ELSE (
  color 0E
  echo  ⚠ Erreur déploiement — si demande connexion,
  echo    entrez votre email Vercel et validez le lien reçu.
)
echo.
pause
exit /b 0

:ERREUR_DL
color 0C
echo.
echo  ❌ Impossible de télécharger les scripts.
echo  Vérifiez votre connexion internet et relancez.
echo.
pause
exit /b 1
