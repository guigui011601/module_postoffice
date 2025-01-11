-- © 2023 ALTITUDE DEV
-- SUPPORT https://altitude-dev.com/fr/helpdesk
-- VERSION VORP
--- --- --- --- 

Config 					= {}
Config.Ressource        = "module_postoffice:" -- ne pas modifier

-- [[ OPTIONS GÉNÉRALES ]]
Config.KeyOpenMenu  	= 0xC7B5340A  -- Touche pour ouvrir le menu
Config.BlipsMap     	= true  -- Activer/désactiver les icônes sur la carte
Config.TimeNotice		= 5500  -- Temps d'affichage des notifications (en ms)
Config.DLC				= false -- Avez-vous module_nations ? Activez cette option pour que le maire collecte toutes les boîtes créées et les lettres envoyées par ville.

-- [[ OPTIONS PROMPT MOD BUTTON ]]
Config.PromptMode 				= true  -- Activer le mode prompt ? Changez Config.KeyOpenMenu pour modifier le bouton prompt.
Config.PromptTimer 				= 600  -- Temps pour maintenir le bouton pour ouvrir la banque (en ms)
Config.PromptPostOffice 		= true  -- Nom de la Poste (true) ou texte personnalisé (false)
Config.PromptNotice 			= "Bienvenue au Bureau de Poste"  -- Texte personnalisé si le mode prompt est activé
Config.PromptInfoBtn			= "ENTRER"  -- Bouton d'information prompt
Config.SubInfo					= "Ouvrez votre compte au Bureau de Poste"  -- Sous-texte prompt

-- [[ TRADUCTIONS ]]
Config.PostTitle    	= "Bureau de Poste"
Config.LetterDeleted 	= "Votre lettre a été supprimée !"
Config.LetterDeleteds 	= "Toutes les lettres ont été supprimées !"
Config.NoMoney          = "Vous avez besoin de "
Config.NoMoneyEnd       = "$ pour créer une boîte postale !"
Config.Created			= "Vous avez maintenant un compte au Bureau de Poste"
Config.LetterSended		= "Votre lettre a été envoyée à la boîte postale !"
Config.NoFound			= "La boîte postale est introuvable !"
Config.NoSendMoney01    = "Vous avez besoin de "
Config.NoSendMoney02    = "$ pour envoyer une lettre !"
Config.InfoPostBox01	= "Créer une boîte postale pour "
Config.InfoPostBox02	= "Prix d'envoi pour "
Config.Sign 			= "$"
Config.Icon				= "<img src='/html/design/b.png' class='icon_notif text-light'>"

-- [[ BUREAUX DE POSTE ]]
Config.PostsOffices     = 
{
	{ 
		sprite 	        = 587827268, 								-- Icône sur la carte
        RPName 	        = 'Bureau de Poste de Valentine',  			-- Nom RP
        RPNotice        = 'Créez/Ouvrez votre boîte avec <b>entrer</b>', -- Texte d'info
		databaseName 	= 'valentines',  							-- Pour DLC Nations (même nom pour toutes les villes dans les modules DLC)
		price			=  2,  		 							-- Prix pour ouvrir un compte boîte postale
		sendprice		=  2,  									-- Prix d'envoi d'une lettre
		x 		        = -178.96, y = 626.86,  z = 114.09 			-- Localisation du point d'interaction
	},
	{ 
		sprite 	        = 587827268,
        RPName 	        = 'Bureau de Poste de BlackWater',
        RPNotice        = 'Ouvrez votre boîte avec <b>entrer</b>',
		databaseName 	= 'blackwater',
		price			=  250,
		sendprice		=  50,
		x 		        = -875.13, y = -1328.77,  z = 43.96
	}
}
