# Obtenir l'APK sans Android Studio (via GitHub)

Prérequis : le dossier `app\src\main\assets\pyodide` contient bien les 5 fichiers Pyodide (c'est déjà le cas chez toi, 13,1 Mo).

## 1. Créer un compte et un dépôt
1. Crée un compte gratuit sur github.com.
2. Bouton **New repository** : nom `python-coach`, choisis **Private**, puis **Create repository**.

## 2. Envoyer le projet
1. Dans le dépôt vide, clique sur **uploading an existing file**.
2. Dans l'Explorateur Windows, ouvre `python-coach-android`, sélectionne **tout son contenu** (pas le dossier lui-même) et glisse-le dans la page. Attends la fin de l'envoi (quelques minutes à cause des fichiers Pyodide).
3. Clique **Commit changes**.

## 3. Vérifier le fichier de construction
Dans le dépôt, tu dois voir un dossier `.github/workflows` avec `build-apk.yml`. S'il manque (les dossiers commençant par un point sont parfois ignorés) :
1. **Add file > Create new file**.
2. Dans le nom, tape `.github/workflows/build-apk.yml` (les `/` créent les dossiers).
3. Colle le contenu du fichier `build-apk.yml` de ton projet, puis **Commit changes**.

## 4. Lancer la construction
1. Onglet **Actions**. Si GitHub demande d'activer les workflows, accepte.
2. Clique sur « Construire l'APK Python Coach » (à gauche), puis **Run workflow** (ou attends : l'envoi précédent la lance déjà).
3. Attends 5 à 10 minutes : pastille verte = réussi, rouge = échec.

## 5. Télécharger l'APK
Clique sur l'exécution réussie, descends à **Artifacts**, clique sur `python-coach-apk` : tu télécharges un ZIP qui contient `app-debug.apk`.

## 6. Installer sur le téléphone
1. Décompresse le ZIP, envoie `app-debug.apk` sur le téléphone (câble USB, Google Drive...).
2. Ouvre-le, autorise l'installation depuis cette source quand Android le demande.
3. Lance l'appli, ouvre un module, attends « Python prêt ».
4. Test final : mode avion, fermeture complète, réouverture.

## Si la construction échoue (pastille rouge)
Ouvre l'exécution, clique sur l'étape en rouge et copie les dernières lignes du message d'erreur : envoie-les moi pour que je corrige.
