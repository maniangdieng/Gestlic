#!/bin/bash

	chmod +x "$0"
# Vérification et ajout automatique des permissions d'exécution

	if ! test -x "$0"; then
	  echo "Accord des permissions d'exécution..."
	  chmod +x "$0"
	  exec "$0" "$@"
	fi


# Vérification si Gestlic est déjà désinstallé
	if [ ! -d ~/.gestlic ]; then
	  echo "Gestlic n'est pas installé. ."
	  exit 0
	fi
	
# Vérification si Gestlic est déjà désinstallé

	if [ ! -d ~/.gestlic ]; then
	  echo "Gestlic n'est pas installé. Aucune action requise pour la désinstallation."
	  exit 0
	fi
	

# Fonction pour demander la confirmation de la désinstallation

	demander_confirmation() {
	  echo "Êtes-vous sûr de vouloir désinstaller Gestlic? (Y/N)"
	  read -n 1 answer
	  

	  if [[ $answer != [Yy] ]]; then
	    echo
	    echo "Désinstallation annulée."
	    exit 0
	  fi
	  echo
	  echo "Confirmer avec votre mot de passe : "
	}
	
	
# Demander le mot de passe à chaque exécution

	sudo -k
	

# Fonction pour supprimer le répertoire caché .gestlic

	supprimer_repertoire_gestlic() {
	  rm -rf ~/.gestlic
	}

# Fonction pour supprimer les répertoires par classe
	

	supprimer_repertoires_des_classes() {
	  classes=("l12i" "l1mpi" "l22i" "l2mi" "l32i" "l3in")
	  for class in "${classes[@]}"; do
	    sudo rm -rf "/home/licence/licence1/$class"
	  done
	}

# Fonction pour supprimer les groupes d'utilisateurs

	supprimer_groupes_utilisateurs() {
	  groups=("licence" "l1" "l2" "l3" "l12i" "l1mpi" "l22i" "l2mi" "l32i" "l3in" "l2i" "lin")
	  for group in "${groups[@]}"; do
	    sudo groupdel "$group"  # Supprime le groupe
	  done
	}

# Fonction pour supprimer le répertoire de partages  et le repertoire licence  

	supprimer_repertoires_partages() {
	  sudo rm -rf /home/partages
	  sudo rm -rf /home/licence
	  
	}



# Appels aux fonctions
	
	demander_confirmation
	
	supprimer_repertoire_gestlic
	supprimer_repertoires_des_classes
	echo "Supression des repertoires ..."
	echo "Fait..."
	echo "Suppression des groupes ..."
	supprimer_groupes_utilisateurs
	echo "Fait..."
	supprimer_repertoires_partages
	
	
	echo "Gestlic a bien été désinstallé."

