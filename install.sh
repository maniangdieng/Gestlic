#!/bin/bash

# Vérification et ajout automatique des permissions d'exécution

	if ! test -x "$0"; then
	  echo "Accord des permissions d'exécution..."
	  chmod +x "$0"
	  exec "$0" "$@"
	fi

# Fonction qui demande si vous voulez installer gestlic

	demande_permission() {
	  echo "Bienvenue sur gestlic. Voulez-vous installer l'application gestlic?"
	  echo "  "
	  echo "Êtes-vous sûr de vouloir installer Gestlic? (Y/N)"
	  read -n 1 answer
	  echo

	  if [[ $answer != [Yy] ]]; then
	    echo "Installation annulée."
	    exit 1
	  fi
	}
	
# Vérification si Gestlic est déjà installé
	if [ -d ~/.gestlic ]; then
	  echo "Gestlic est déjà installé. "
	  exit 0
	fi

# Fonction pour créer le répertoire caché .gestlic
 	
	  
	 sudo -k # Demander le mot de passe à chaque exécution
	creer_repertoire_gestlic() {
	  mkdir -p ~/.gestlic
	  touch ~/.gestlic/infos_comptes.txt
	  touch ~/.gestlic/fonctionnement_gestlic.txt
	  
	  sudo mkdir -p /home/archives #creer le repertoire archives dans home pour les comptes supprimer
	  
	}
	
	
	

# Fonction pour créer les répertoires par classe  

	creer_repertoires_des_classes() {
	  classes=("l12i" "l1mpi" "l22i" "l2mi" "l32i" "l3in")
	 
	  for class in "${classes[@]}"; do
	    if [[ "$class" =~ ^l1 ]]; then
	      sudo mkdir -p "/home/licence/licence1/$class"
	    elif [[ "$class" =~ ^l2 ]]; then
	      sudo mkdir -p "/home/licence/licence2/$class"
	    elif [[ "$class" =~ ^l3 ]]; then
	      sudo mkdir -p "/home/licence/licence3/$class"
	    fi
	  done
	}





# Fonction pour créer les groupes d'utilisateurs

	creer_groupes_utilisateurs() {
	  groups=("licence" "l1" "l2" "l3" "l12i" "l1mpi" "l22i" "l2mi" "l32i" "l3in" "l2i" "lin")

	  # Ajout des groupes
	  for group in "${groups[@]}"; do
	    sudo groupadd "$group"
	  done
	
	}






# Fonction pour créer le répertoire de partages


	creer_repertoires_partages() {
	  sudo mkdir -p /home/partages
# Création des répertoires de partage pour chaque groupe
	 for group in "${groups[@]}"; do
	    sudo mkdir -p "/home/partages/$group"
	    sudo chown root:"$group" "/home/partages/$group"
	    sudo chmod 770 "/home/partages/$group"
	  done
	}
	
	
#création du fichier de description de gestlic .
	creer_fchier_description(){
description="
       				**********Ce projet a été développé par les étudiants MANIANG DIENG et YAYA DRAME.**********
       
  Bienvenue sur Gestlic et merci de l'avoir installer!!
  
  Gestlic est projet basé sur les scripts shell pour la gestion des comptes d'un serveur dédié aux étudiants d'informatique de licence de l'UASZ.

					**********PRINCIPE DE FONCTIONNEMENT DE GESTLIC**********
			
  Comme expliquer plutôt, Le fonctionnement de Gestlic repose sur un ensemble de scripts shell qui automatisent la gestion des comptes des
  étudiants en informatique de licence à l'UASZ. Pour ce faire le projet Gestlic suit les étapes  suivantes :
    *Installation : Lors de l'installation de Gestlic, le script crée un répertoire caché ~/.gestlic où il stocke les informations des comptes
     ainsi que ce fichier de description.

    *Ajout de comptes : Le script permet d'ajouter de nouveaux comptes étudiants en demandant les informations nécessaires telles que le nom, le
     prénom et la classe. Il crée ensuite un compte utilisateur sur le système, configure les permissions appropriées et crée les répertoires
     personnels de l'étudiant selon sa classe.

    *Migration de comptes : Gestlic offre la possibilité de migrer un compte étudiant d'une classe à une autre. Par exemple, un étudiant de
    première année peut être migré vers une classe supérieure lors de sa progression dans le cursus.

    *Mise à jour de comptes : Il est possible de mettre à jour les informations des comptes existants, telles que le nom et le prénom de
     l'étudiant. 
    
    *Désactivation et réactivation de comptes : Gestlic permet de désactiver temporairement un compte étudiant, ce qui le rend inaccessible, tout
    en conservant ses informations. 

    *Suppression de comptes : Enfin, Gestlic permet de supprimer définitivement un compte étudiant de la base de données, ce qui entraîne la
     suppression de toutes ses données au niveau de gestlic mais son repertoire personnel est archivé dans le dossier /home/archives .

    En résumé, Gestlic simplifie et automatise la gestion des comptes des étudiants, en offrant un ensemble d'outils pour créer, mettre à jour,
  migrer, désactiver, réactiver et supprimer les comptes, tout en assurant la cohérence et la sécurité du système

					**********COMMENT UTILISER GESTLIC ?? **********
			
  Pour utiliszer Gestlic, vous devrez ouvrir un terminal et vous deplacer dans le répertoire contenant gestlic .

---> Pour installer gestlic, executer dans la consolle la commande ./install.sh 

---> Pour desinstaller gestlic, executer dans la consolle la commande ./desinstall.sh 

---> Pour ajouter un nouveau compte étudiant(option --add),executer la commande ./gestlic.sh -a <nom_du_compte_a_créer>  

---> Pour migrer compte étudiant vers une classe supérieure (option --migrate),executer la commande ./gestlic.sh -m <nom_du_compte_a_migrer> .

---> Pour modifier les infos d'un compte étudiant (nom et prenom) (option --update),executer la commande ./gestlic.sh -u <nom_du_compte_a_modifier> 

---> Pour verouiller un compte étudiant  (option --Lock),executer la commande ./gestlic.sh -L <nom_du_compte_à_verouiller> .

---> Pour déverouiller un compte étudiant  (option --Unlock),executer la commande ./gestlic.sh -U <nom_du_compte_à_déverouiller> .

---> Pour supprimer un compte étudiant de Gestlic  (option --delete),executer la commande ./gestlic.sh -d <nom_du_compte_à_supprimer> .

--->Pour verifier si l'installation de Gestlic ne comporte aucune erreur  (option --check),executer la commande ./gestlic.sh -c .

---> Pour obtenir de l'aide sur les commandes ainsi que leurs syntaxes(option --help),executer la commande ./gestlic.sh --help.
	Taper q pour quitter.

"

# Ajouter le contenu au fichier fonctionnement_gestlic.txt
    echo "$description" >> ~/.gestlic/fonctionnement_gestlic.txt

	}





# Appels aux fonctions
	
	demande_permission
	creer_repertoire_gestlic
	
	creer_repertoires_des_classes
	echo "Creation des repertoires..."
	echo "Fait..."
	echo "Creation des groupes..."
	creer_groupes_utilisateurs 
	echo "Fait..."
	creer_repertoires_partages
	creer_fchier_description


	echo "Gestlic a bien été installer !! ."
	
	
	
# Demander à l'utilisateur s'il souhaite ouvrir le fichier fonctionnement_gestlic.txt
	read -p "Voulez-vous découvrir le fonctionnement de gestlic ? (Y/N): " answer

	# Vérifier la réponse de l'utilisateur
	if [[ $answer =~ ^[Yy]$ ]]; then
	    
	    less -R ~/.gestlic/fonctionnement_gestlic.txt
	fi

