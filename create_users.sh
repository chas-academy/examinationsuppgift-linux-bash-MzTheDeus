#!/bin/bash
# Script för att skapa användare, mappar och välkomstfil


#-------------------------------------------------- SÄKERHETS CHECK -------------------------------------------------#

# Ser till att det endast går att köra scriptet som root.
if [ "$EUID" -ne 0 ]; then
	echo "ERROR: Måste köras som root"
	exit 1
fi

# Kontrollerar att minst en användare skickas in.
if [ "$#" -eq 0 ]; then
	echo "ERROR: Du måste skriva minst ett användarnamn"
	exit 1
fi

#---------------------------------------------------------------------------------------------------------------------#


# Loopar igenom alla användare
for username in "$@"; do

	# Skapar användare om den inte redan finns.
	if id "$username" &>/dev/null; then
		echo "Användaren $username finns redan"
	else
		echo "----------------------------"
		echo "Skapar användare: $username"
		echo "----------------------------"	
		useradd -m "$username"
	fi

#------------------------------------------------ MAPPAR & RÄTTIGHETER -----------------------------------------------#

	# Skapar mappar.	
	mkdir -p "/home/$username/Documents" "/home/$username/Downloads" "/home/$username/Work"

	# Sätter ägare.
	chown -R "$username:$username" "/home/$username/Documents" "/home/$username/Downloads" "/home/$username/Work"
			
	# Ger rättigheter.
	chmod 700 "/home/$username/Documents" "/home/$username/Downloads" "/home/$username/Work"

#---------------------------------------------------------------------------------------------------------------------#

done
#----------------------------------------- SKAPAR / UPPDATERAR WELCOME FILEN -----------------------------------------#

for username in "$@"; do
	welcome_file="/home/$username/welcome.txt"
	echo "Välkommen $username" > "$welcome_file"

	for user in $(cut -d: -f1 /etc/passwd); do 
		if [ "$user" != "$username" ]; then
			echo "$user" >> "$welcome_file"
		fi
	done
	chown "$username:$username" "$welcome_file"
	chmod 600 "$welcome_file"
done

#--------------------------------------------------------------------------------------------------------------------#
