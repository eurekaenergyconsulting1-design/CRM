@echo off
title Déploiement Eureka CRM → Vercel
color 0A
echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   EUREKA CRM — Déploiement Vercel        ║
echo  ╚══════════════════════════════════════════╝
echo.

:: Vérifier Node.js
node --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
  color 0C
  echo  ❌ Node.js n'est pas installé sur ce PC.
  echo.
  echo  → Téléchargez Node.js ici : https://nodejs.org
  echo    Choisissez la version LTS, installez-la,
  echo    puis relancez ce script.
  echo.
  pause
  exit /b 1
)

echo  ✅ Node.js détecté :
node --version
echo.

:: Installer Vercel CLI si absent
vercel --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
  echo  📦 Installation de Vercel CLI...
  npm install -g vercel
  IF %ERRORLEVEL% NEQ 0 (
    color 0C
    echo  ❌ Erreur installation Vercel CLI.
    pause
    exit /b 1
  )
)

echo  ✅ Vercel CLI prêt
echo.
echo  🚀 Déploiement en production...
echo.

:: Déployer depuis le dossier du script
cd /d "%~dp0"
vercel --prod --yes

IF %ERRORLEVEL% EQU 0 (
  echo.
  color 0A
  echo  ✅ Déploiement RÉUSSI !
  echo  → Votre CRM est en ligne sur Vercel.
  echo.
  echo  Après le déploiement :
  echo  - Ouvrez votre URL Vercel dans Chrome
  echo  - Faites Ctrl+Shift+R pour vider le cache
  echo  - Connectez-vous normalement
) ELSE (
  color 0E
  echo.
  echo  ⚠ Erreur lors du déploiement.
  echo  Si demande de connexion → entrez votre email Vercel
  echo  puis validez le lien envoyé par email.
)

echo.
pause
