#!/bin/bash


# Vérification et ajout automatique des permissions d'exécution
	
			if ! test -x "$0"; then
			  echo "Accord des permissions d'exécution..."
			  chmod +x "$0"
			  exec "$0" "$@"
			fi

# Fonction pour ajouter un compte étudiant
	
			ajouter_compte_etudiant() {

			    local nom_compte="$1"  # Nom du compte à créer(obligatoire)
			    local prenom
			    local nom
			    
			   
		# Vérifier si le nom du compte est fourni
			    if [ -z "$nom_compte" ]; then
				echo "Erreur : Nom du compte manquant."
				echo "Syntaxe: $0 -a NOM_COMPTE"
				exit 1
			    fi


		 # Vérifier si le nom_compte existe déjà dans le fichier infos_comptes.txt
			    if grep -q "^$nom_compte "  ~/.gestlic/infos_comptes.txt; then
				echo "Erreur : Le compte $nom_compte existe déjà pour un autre étudiant."
				echo "veuillez donner un autre nom de compte pour l'étudiant."
				return 1
			    fi 
			    
		# Demander le prénom de l'étudiant
			    read -p "Entrez le prénom de l'étudiant : " prenom

		# Demander le nom de l'étudiant
			    read -p "Entrez le nom de l'étudiant : " nom

		# Liste des classes disponibles
			    local classes_disponibles="l12i, l1mpi, l22i, l2mi, l32i, l3in"

		# Demander la classe de l'étudiant jusqu'à ce qu'une classe valide soit saisie
			    while true; do
				read -p "Entrez la classe de l'étudiant ($classes_disponibles) : " classe
				case $classe in
				    l12i|l1mpi|l22i|l2mi|l32i|l3in)
					break
					;;
				    *)
					echo "Erreur : Classe non reconnue."
					echo "Classes disponibles : $classes_disponibles"
					;;
				esac
			    done

		# Ajouter les informations de l'étudiant au fichier infos_comptes.txt avec la date de création
			    echo "$nom_compte ${prenom} ${nom} $classe $(date +'%Y-%m-%d')" >>  ~/.gestlic/infos_comptes.txt

		# Calculer la date d'expiration dans le format requis (YYYY-MM-DD)
			    local expiration_date=$(date -d "+547 days" +"%Y-%m-%d")

		# Utiliser la commande adduser pour créer l'utilisateur nom_compte
			    sudo adduser --disabled-password --gecos "${prenom} ${nom}" ${nom_compte}
			     
			    
		# Définir la date d'expiration du mot de passe (expiredate)
			    sudo chage --expiredate "$expiration_date" ${nom_compte}

		# Créer le répertoire personnel de l'étudiant en fonction de sa classe
			    local repertoire
			    case $classe in
				l12i)
				    repertoire="/home/licence/licence1/l12i/${nom_compte}"
				    ;;
				l1mpi)
				    repertoire="/home/licence/licence1/l1mpi/${nom_compte}"
				    ;;
				l22i)
				    repertoire="/home/licence/licence2/l22i/${nom_compte}"
				    ;;
				l2mi)
				    repertoire="/home/licence/licence2/l2mi/${nom_compte}"
				    ;;
				l32i)
				    repertoire="/home/licence/licence3/l32i/${nom_compte}"
				    ;;
				l3in)
				    repertoire="/home/licence/licence3/l3in/${nom_compte}"
				    ;;
			    esac
		# Créer le répertoire personnel de l'étudiant
			    sudo mkdir -p "$repertoire"
			    sudo chown "${nom_compte}:${nom_compte}" "$repertoire"
			    sudo chmod 750 "$repertoire"
		# Ajouter l'étudiant aux groupes correspondants à sa classe
			    case $classe in
				l12i)
				    groupes="licence,l1,l2i,l12i"
				    ;;
				l1mpi)
				    groupes="licence,l1,lin,l1mpi"
				    ;;
				l22i)
				    groupes="licence,l2,l2i,l22i"
				    ;;
				l2mi)
				    groupes="licence,l2,lin,l2mi"
				    ;;
				l32i)
				    groupes="licence,l3,l2i,l32i"
				    ;;
				l3in)
				    groupes="licence,l3,lin,l3in"
				    ;;
			    esac

			    sudo usermod -aG "$groupes" "${nom_compte}"

			   

		# Afficher un message de succès
			    echo "Compte ${nom_compte} pour l'étudiant ${prenom} ${nom}  ajouté avec succès."
			    
		# Créer des liens symboliques vers les espaces de partage des groupes d'appartenance dans le répertoire personnel de l'étudiant
			    for groupe in $(echo "$groupes" | tr ',' ' '); do
			         sudo ln -s "/home/partages/$groupe" "$repertoire/$groupe"
			    
			    done


		# Créer des liens symboliques vers les espaces de partage des groupes d'appartenance dans le dossier  de l'étudiant dans home
			    for groupe in $(echo "$groupes" | tr ',' ' '); do
				sudo ln -s "/home/partages/$groupe" "/home/${nom_compte}/$groupe"
			    done        

			}

# Fonction pour migrer un compte étudiant
			
			migrer_etudiant() {
			    local nom_compte="$1"  # Nom du compte de l'étudiant à migrer (paramètre obligatoire)
			    
		# Vérifier si le nom du compte est fourni
			    if [ -z "$nom_compte" ]; then
				echo "Erreur : Nom du compte manquant."
				echo "Usage: $0 -m NOM_COMPTE"
				exit 1
			    fi

		# Vérifier si l'étudiant existe dans le fichier d'informations des comptes
			    if ! grep -q "^$nom_compte " ~/.gestlic/infos_comptes.txt; then
				echo "Erreur : L'étudiant $nom_compte n'existe pas."
				return 1
			    fi

		# Récupérer la classe actuelle de l'étudiant
			    local classe_actuelle=$(awk -v compte="$nom_compte" '$1 == compte {print $4}' ~/.gestlic/infos_comptes.txt)

		# Afficher la classe actuelle de l'étudiant
			    echo "Classe actuelle de l'étudiant $nom_compte : $classe_actuelle"

		# la classe de migration de l'étudiant
			    local nouvelle_classe
			    case $classe_actuelle in
				l12i)
				    nouvelle_classe="l22i"
				    ;;
				l1mpi)
				    nouvelle_classe="l2mi"
				    ;;
				l22i)
				    nouvelle_classe="l32i"
				    ;;
				l2mi)
				    nouvelle_classe="l3in"
				    ;;
				l32i)
				   echo "Erreur : Les étudiants de niveau Licence 3 ne peuvent pas être migrés vers une classe supérieure."
				    return 1
				    ;;
				l3in)
				    echo "Erreur : Les étudiants de niveau Licence 3 ne peuvent pas être migrés vers une classe supérieure."
				    return 1
				    ;;
				*)
				    echo "Erreur : Classe actuelle non reconnue pour la migration."
				    return 1
				    ;;
			    esac

			# Afficher les options de classe de migration disponibles
			    echo "Classes de migration disponibles pour l'étudiant $nom_compte : $nouvelle_classe"

			   
			# Mettre à jour le répertoire personnel de l'étudiant
			local ancien_repertoire="/home/licence/licence${classe_actuelle:1:1}/$classe_actuelle/${nom_compte}"
			local nouveau_repertoire="/home/licence/licence${nouvelle_classe:1:1}/$nouvelle_classe/${nom_compte}"


			# Mettre à jour le répertoire personnel de l'étudiant
			sudo mv "$ancien_repertoire" "$nouveau_repertoire"


			# Supprimer le contenu du nouveau répertoire
			sudo rm -r "$nouveau_repertoire"

			# Assurer que le répertoire cible existe encore après la suppression
			sudo mkdir -p "$nouveau_repertoire"

 
			# Ajouter l'étudiant aux groupes correspondants à sa classe
			    case $nouvelle_classe in
			       
				l22i)
				    groupes="licence,l2,l22i,l2i"
				    ;;
				l2mi)
				    groupes="licence,l2,l2mi,lin"
				    ;;
				l32i)
				    groupes="licence,l3,l32i,l2i"
				    ;;
				l3in)
				    groupes="licence,l3,l3in,lin"
				    ;;
			    esac

			    sudo usermod -G "$groupes" "${nom_compte}"
			    
			    
			   
	# Créer des nouveaux liens symboliques vers les espaces de partage des nouveaux groupes d'appartenance dans le répertoire de etudiant
			for groupe in $(echo "$groupes" | tr ',' ' '); do
			    sudo ln -s "/home/partages/$groupe" "${nouveau_repertoire}/$groupe"
			done
	# Créer des liens symboliques vers les espaces de partage des groupes d'appartenance dans le dossier  de l'étudiant dans home
			    sudo rm -r /home/${nom_compte}
			    sudo mkdir -p /home/${nom_compte}
			    for groupe in $(echo "$groupes" | tr ',' ' '); do
				sudo ln -s "/home/partages/$groupe" "/home/${nom_compte}/$groupe"
			    done    
			   
	  # Mettre à jour la classe de l'étudiant dans le fichier infos_comptes.txt

			awk -v nom_compte="$nom_compte" -v nouvelle_classe="$nouvelle_classe" '$1 == nom_compte { $4 = nouvelle_classe } 1' ~/.gestlic/infos_comptes.txt > ~/.gestlic/infos_comptes_tmp.txt && mv ~/.gestlic/infos_comptes_tmp.txt ~/.gestlic/infos_comptes.txt
			   

	  # Afficher un message de succès
			    echo "L'étudiant $nom_compte a été migré vers la classe $nouvelle_classe avec succès."
			}



	  # Fonction pour mettre a jour  un compte étudiant
	  
			mettre_a_jour_compte() {
			    local nom_compte="$1"  # Nom du compte à mettre à jour (paramètre obligatoire)
			    
	  # Vérifier si le nom du compte est fourni
			    if [ -z "$nom_compte" ]; then
				echo "Erreur : Nom du compte manquant."
				echo "Usage: $0 -u NOM_COMPTE"
				exit 1
			    fi

	 # Vérifier si le compte existe dans le fichier infos_comptes.txt
			    if grep -q "^$nom_compte " ~/.gestlic/infos_comptes.txt; then
			    
	# Récupérer le prénom et le nom actuels à partir du fichier infos_comptes.txt
				prenom=$(grep "^$nom_compte " ~/.gestlic/infos_comptes.txt | awk '{print $2}')
				nom=$(grep "^$nom_compte " ~/.gestlic/infos_comptes.txt | awk '{print $3}')

	# Afficher le prénom et le nom avant la mise à jour
				echo "Prénom actuel de l'étudiant : $prenom"
				echo "Nom actuel de l'étudiant : $nom"

	# Demander les nouvelles informations sur l'étudiant
				read -p "Entrez le nouveau prénom de l'étudiant : " nouveau_prenom
				read -p "Entrez le nouveau nom de l'étudiant : " nouveau_nom

	# Afficher les nouvelles informations après la lecture
				echo "Nouveau prénom de l'étudiant : $nouveau_prenom"
				echo "Nouveau nom de l'étudiant : $nouveau_nom"



	# Mettre à jour les informations dans le fichier infos_comptes.txt
				 
			      awk -v nom_compte="$nom_compte" -v nouveau_prenom="$nouveau_prenom" -v nouveau_nom="$nouveau_nom" '$1 == nom_compte { $2 =  nouveau_prenom; $3 = nouveau_nom } 1' ~/.gestlic/infos_comptes.txt > ~/.gestlic/infos_comptes_tmp.txt && mv ~/.gestlic/infos_comptes_tmp.txt ~/.gestlic/infos_comptes.txt

	# Mettre à jour les informations dans le fichier /etc/passwd
	
        sudo usermod -c "$nouveau_prenom $nouveau_nom" "$nom_compte"


				
	# Afficher un message de succès
				echo "Les informations du compte $nom_compte ont été mises à jour avec succès."
				echo "Le nouveau propriétaire du compte est ${nouveau_prenom} ${nouveau_nom}"
			    else
				echo "Le compte $nom_compte n'existe pas."
			    fi
			}


# Fonction pour désactiver un compte étudiant
	
			desactiver_compte() {
			    local nom_compte="$1"  # Nom du compte à désactiver (paramètre obligatoire)
			    
	 # Vérifier si le nom du compte est fourni
			    if [ -z "$nom_compte" ]; then
				echo "Erreur : Nom du compte manquant."
				echo "Usage: $0 -L NOM_COMPTE"
				exit 1
			    fi

	# Vérifier si le compte existe dans le fichier infos_comptes.txt
			    if grep -q "^$nom_compte " ~/.gestlic/infos_comptes.txt; then
			    	
			    	sudo usermod -L "$1"
			    	echo "le compte a ete desactiver avec succes"
			    else 
			    	echo "ce compte n'exite pas"	
			    fi
			}

# Fonction pour réactiver un compte étudiant
			reactiver_compte() {
			    local nom_compte="$1"  # Nom du compte à réactiver (paramètre obligatoire)
			    
			       # Vérifier si le nom du compte est fourni
			    if [ -z "$nom_compte" ]; then
				echo "Erreur : Nom du compte manquant."
				echo "Usage: $0 -U NOM_COMPTE"
				exit 1
			    fi

			    # Vérifier si le compte existe dans le fichier infos_comptes.txt
			    if grep -q "^$nom_compte " ~/.gestlic/infos_comptes.txt; then
			    	
			    	sudo passwd -U "$1"
			    	echo "le compte a ete reactiver avec succes"
			    else 
			    	echo "ce compte n'exite pas"	
			    fi
			}


# Fonction pour supprimer un compte étudiant

			supprimer_compte() {
			    local nom_compte="$1"  # Nom du compte à supprimer (paramètre obligatoire)
			    
			       # Vérifier si le nom du compte est fourni
			    if [ -z "$nom_compte" ]; then
				echo "Erreur : Nom du compte manquant."
				echo "Usage: $0 -d NOM_COMPTE"
				exit 1
			    fi

	# Vérifier si l'étudiant existe dans le fichier d'informations des comptes
			    if ! grep -q "^$nom_compte " ~/.gestlic/infos_comptes.txt; then
				echo "Erreur : Le compte  $nom_compte n'existe pas dans Gestlic."
				return 1
			    fi

	# Récupérer la classe actuelle de l'étudiant
			    local classe_actuelle=$(awk -v compte="$nom_compte" '$1 == compte {print $4}' ~/.gestlic/infos_comptes.txt)


	# Supprimer l'étudiant des anciens groupes correspondants à sa classe actuelle
			case $classe_actuelle in
			    l12i)
				groupes_actuels=("licence" "l1" "l12i" "l2i")
				repertoire="/home/licence/licence1/l12i/${nom_compte}"
				;;
			    l1mpi)
				groupes_actuels=("licence" "l1" "l1mpi" "lin")
				repertoire="/home/licence/licence1/l1mpi/${nom_compte}"
				;;
			    l22i)
				groupes_actuels=("licence" "l2" "l22i" "l2i")
				repertoire="/home/licence/licence2/l22i/${nom_compte}"
				;;
			    l2mi)
				groupes_actuels=("licence" "l2" "l2mi" "lin")
				repertoire="/home/licence/licence2/l2mi/${nom_compte}"
				;;
			    l32i)
				groupes_actuels=("licence" "l3" "l32i" "l2i")
				 repertoire="/home/licence/licence3/l32i/${nom_compte}"
				;;
			    l3in)
				groupes_actuels=("licence" "l3" "l3in" "lin")
				 repertoire="/home/licence/licence3/l3in/${nom_compte}"
				;;
			esac		

	# Supprimer l'utilisateur des anciens groupes
			for groupe in "${groupes_actuels[@]}"; do
			    
	# Vérifier si le groupe existe avant de tenter de supprimer l'utilisateur
			    if getent group "$groupe" >/dev/null; then
				sudo deluser "$nom_compte" "$groupe"
			    else
				echo "Le groupe $groupe n'existe pas. L'utilisateur n'a pas été supprimé de ce groupe."
			    fi
			done

	# Supprimer l'entrée du compte dans le fichier des informations des comptes
			    
			 sed -i "/^$nom_compte/d" ~/.gestlic/infos_comptes.txt

	#supprimer le repertoire personnel de l'etudiant de gestlic 
			sudo rm -r "$repertoire"
	
	# Déplacer le home de l'étudiant dans /home/archives
				local rep="/home/${nom_compte}"
				sudo mv "$rep" "/home/archives/${nom_compte}"

	# Désactiver le compte
				sudo usermod -L "$nom_compte"




	# Afficher un message de succès
				echo "Le compte $nom_compte a été supprimé de gestlic avec succès."

			       
			}

#Fonction pour verifier la configuration de Gestlic

			verifier_configuration() {
			    local erreurs=0

	# Vérifier l'existence des groupes
			    echo "Vérification des groupes :"
			    local groups=("licence" "l1" "l2" "l3" "l12i" "l1mpi" "l22i" "l2mi" "l32i" "l3in" "l2i" "lin")
			    for group in "${groups[@]}"; do
				if grep -q "^$group:" /etc/group; then
				    echo " - Groupe '$group' existe : OK"
				else
				    echo " - Groupe '$group' n'existe pas : ERREUR"
				    erreurs=$((erreurs + 1))
				fi
			    done

	# Vérifier l'existence des répertoires
			    echo "Vérification des répertoires :"
			    local directories=("/home/licence" "/home/partages")
			    for directory in "${directories[@]}"; do
				if [ -d "$directory" ]; then
				    echo " - Répertoire '$directory' existe : OK"
				else
				    echo " - Répertoire '$directory' n'existe pas : ERREUR"
				    erreurs=$((erreurs + 1))
				fi
			    done

	# Vérifier l'existence des fichiers
			    echo "Vérification des fichiers :"
			    local files=("${HOME}/.gestlic/infos_comptes.txt" "${HOME}/.gestlic/fonctionnement_gestlic.txt")
			    for file in "${files[@]}"; do
				if [ -f "$file" ]; then
				    echo " - Fichier '$file' existe : OK"
				else
				    echo " - Fichier '$file' n'existe pas : ERREUR"
				    erreurs=$((erreurs + 1))
				fi
			    done

	# Afficher le résultat global
			    if [ "$erreurs" -eq 0 ]; then
				echo "La configuration de gestlic est correcte."
			    else
				echo "La configuration de gestlic comporte des erreurs."
			    fi
			}




# Fonction pour afficher l'aide
			afficher_aide() {
			    echo "Usage: gestlic [OPTION] [NOM_COMPTE]"
			    echo "Options:"
			    echo "  -a, --add NOM_COMPTE           Ajouter un nouveau compte étudiant."
			    echo "  -m, --migrate NOM_COMPTE       Migrer un étudiant vers une classe supérieure."
			    echo "  -u, --update NOM_COMPTE        Mettre à jour les informations d'un compte étudiant."
			    echo "  -L, --Lock NOM_COMPTE          Désactiver un compte étudiant."
			    echo "  -U, --Unlock NOM_COMPTE        Réactiver un compte étudiant."
			    echo "  -d, --delete NOM_COMPTE        Supprimer un compte étudiant de gestlic."
			    echo "  -c, --check                   Vérifier la configuration de gestlic."
			    echo "  --help                        Afficher cette aide."
			}
	# Vérifier si une option valide a été spécifiée
			if [[ $# -eq 0 ]]; then
			    echo "Erreur : Aucune option spécifiée."
			    exit 1
			fi

# Analyser les options
			while [[ $# -gt 0 ]]; do
			    option="$1"
			    case $option in
				-a|--add)
				    shift
				    ajouter_compte_etudiant "$1"
				    ;;
				-m|--migrate)
				    shift
				    migrer_etudiant "$1"
				    ;;
				-u|--update)
				    shift
				    mettre_a_jour_compte "$1"
				    ;;
				-L|--Lock)
				    shift
				    desactiver_compte "$1"
				    ;;
				-U|--Unlock)
				    shift
				    reactiver_compte "$1"
				    ;;
				-d|--delete)
				    shift
				    supprimer_compte "$1"
				    ;;
				-c|--check)
				    verifier_configuration
				    ;;
				--help)
				    afficher_aide
				    ;;
				*)
				    echo "Erreur : Option non reconnue : $option"
				    afficher_aide
				    exit 1
				    ;;
			    esac
			    shift
			done

