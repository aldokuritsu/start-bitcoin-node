#!/bin/bash

# Fonction pour afficher une barre de progression
show_progress() {
  local current=$1
  local total=$2

  # Calcul du pourcentage
  local percent=$((100 * current / total))

  # Calcul des caractères remplis
  local filled=$((percent / 2))

  local empty=$((50 - filled))

  printf "\rProgression: ["
  for ((i=0; i<filled; i++)); do printf "="; done
  for ((i=0; i<empty; i++)); do printf " "; done
  printf "] %d%%" $percent
}


# Demande à l'utilisateur s'il veut démarrer le nœud Bitcoin
read -p "Voulez-vous démarrer votre nœud Bitcoin ? (oui/non) " response
if [[ "$response" != "oui" && "$response" != "o" ]]; then
  echo "Opération annulée."
  exit 1
fi

# Démarre le service tor
echo "Démarrage du service Tor..."
sudo systemctl start tor
# Attend quelques secondes pour que bitcoind démarre
sleep 3

# Démarre bitcoind en mode daemon
echo "Démarrage de bitcoind..."
bitcoind -daemon

# Attend quelques secondes pour que bitcoind démarre
sleep 10

# Vérifie la synchronisation de la blockchain
echo "Vérification de la synchronisation de la blockchain... Merci de patienter"
sleep 20
while true; do
  blockchain_info=$(bitcoin-cli getblockchaininfo)
  blocks=$(echo "$blockchain_info" | grep -oP '"blocks":\s*\K\d+')
  headers=$(echo "$blockchain_info" | grep -oP '"headers":\s*\K\d+')

  if [[ "$blocks" -eq "$headers" ]]; then
    echo -e "\nLa blockchain est synchronisée."
    break
  else
    show_progress $blocks $headers
    sleep 5
  fi
done
