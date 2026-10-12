# Python Coach : base Android (WebView)

Base de travail Android pour Python Coach. **Ce n'est pas encore un APK validé** : le projet n'a été ni compilé ni testé sur un téléphone.

## Contenu
- `python-coach-source-original.html` : ton fichier HTML, **inchangé** (modules 1 à 7).
- `app/src/main/assets/index.html` : copie Android. Seules 4 lignes diffèrent de l'original : l'adresse de Pyodide (locale au lieu du CDN) et trois messages de texte.
- `MainActivity.java` : WebView + `WebViewAssetLoader`, qui sert les fichiers locaux en HTTPS (nécessaire à WebAssembly). Gère aussi les marges des barres système et du clavier sous Android 15.
- `scripts/` : téléchargement et vérification de Pyodide.

## Corrections apportées à la version précédente
- **`index.html` Android contenait une erreur JavaScript** (une apostrophe non échappée dans « dans l'application »). L'application aurait affiché une page vide. Corrigé, et la syntaxe a été revérifiée.
- Ajout d'un téléchargement **léger** de Pyodide (environ 12 Mo au lieu de plus de 200 Mo).
- Scripts PowerShell : TLS 1.2 forcé et barre de progression désactivée (sans cela, `Invoke-WebRequest` échoue ou est très lent sous PowerShell 5).
- Ajout de `gradle/wrapper/gradle-wrapper.properties` (Gradle 8.9, requis par le plugin Android 8.7.3).
- Affichage correct sous les barres système et au-dessus du clavier.

## Étape 1 : récupérer Pyodide (PowerShell, dossier du projet)
```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\Download-Pyodide-Light.ps1
.\scripts\Check-Pyodide.ps1
```
À la question sur la stratégie d'exécution, réponds `O` puis Entrée. Le changement ne vaut que pour cette fenêtre PowerShell.

Le script léger télécharge 5 fichiers (`pyodide.js`, `pyodide.asm.js`, `pyodide.asm.wasm`, `pyodide-lock.json`, `python_stdlib.zip`) depuis le CDN officiel. Python Coach n'utilise que la bibliothèque standard de Python, fournie par `python_stdlib.zip`.

Plan B, si tu veux la distribution complète (plus de 200 Mo, rarement utile ici) : `.\scripts\Download-Pyodide.ps1`.

## Étape 2 : compiler
1. Installe Android Studio **Ladybug (2024.2) ou plus récent**.
2. Ouvre le dossier du projet (celui qui contient `settings.gradle`) et laisse Gradle synchroniser (connexion requise la première fois ; le SDK Android 35 sera proposé au téléchargement).
3. Branche un téléphone (débogage USB) ou crée un émulateur, puis lance l'application.
4. Pour un APK : **Build > Build APK(s)**.

## Étape 3 : tests à faire
1. Ouvre le module 1 : le voyant doit passer à « Python 3.x prêt ». Exécute `print("Bonjour")`.
2. Valide un exercice, ferme complètement l'application (retire-la des applications récentes), rouvre-la : la progression et ton code doivent être conservés.
3. Active le **mode avion**, ferme et relance l'application : Python doit démarrer et les exercices fonctionner.
4. Teste le clavier (le champ de code reste visible), la rotation et un petit écran.
5. Fais l'exercice 5 du module 7 pour vérifier les vérifications automatiques.

## Si Python ne démarre pas
- Message « Impossible de charger les fichiers locaux » : relance `Check-Pyodide.ps1` et vérifie que le dossier `app/src/main/assets/pyodide/` contient les 5 fichiers, puis refais **Build > Clean Project** et relance.
- Page blanche : dans Chrome sur PC, ouvre `chrome://inspect`, sélectionne le WebView de l'application et lis la console (pour cela, on peut ajouter `WebView.setWebContentsDebuggingEnabled(true)` dans `MainActivity`, uniquement pour les tests).

## Limites connues
- Non compilé ni testé sur appareil : le démarrage hors ligne reste à confirmer sur téléphone.
- L'application suit un thème clair, quel que soit le réglage sombre du téléphone.
- Un paquet Python tiers (numpy, etc.) n'est pas inclus : seuls les exercices en bibliothèque standard fonctionnent.
- Avant diffusion publique : vérifier les licences et avis de Pyodide (Mozilla Public License 2.0) et de Python.
- Si tu modifies le HTML d'origine, refais la copie dans `assets/index.html` en reprenant les 4 lignes adaptées (adresse Pyodide et messages), sinon l'application chargerait Pyodide depuis Internet.
