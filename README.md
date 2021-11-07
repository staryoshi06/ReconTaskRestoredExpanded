This mod does many things to restore the recon task in PAYDAY 2. What is the recon task, you might ask? Essentially, it is a group of enemies that appears between assaults to rescue hostages and confiscate loot. In earlier versions of the game, this group would be made up of special enemies known as the Hostage Rescue Team, who were lightly armoured but very effective with their weapons. In the current version of the game, the recon task just uses the normal assault groups, and in higher difficulties the assault breaks are so short that they basically may as well not exist. This mod aims to fix both of these problems.

The main things this mod does is as follows:
* Adds "light" and "heavy" unit categories with unique units that differs between difficulty (Normal, Hard/Very Hard, Overkill/Mayhem, Death Wish/Death Sentence).
* Adds custom recon "rescue" and "rush" spawngroups that replace the current recon spawngroups. "Rescue" groups are larger with more light units, and attempt to flank. "Rush" groups are smaller with a more even distribution of light and heavy units (leaning a bit more towards heavy), and attempt to charge.
* Increases the recon spawncap so that they appear more often, while also reducing the time between spawns drastically (by default it can be up to 40 seconds before they spawn again).
* Makes it so that if the players have hostages, instead of the assault anticipation time being extended, the actual break will be extended so that the hostage rescue team has time to do their work. This does not apply to the first assault or holdout mode.
* Certain map archetypes will have unique changes to the units. Most of these only apply on lower difficulties, though.
* The mod is completely serverside; use it in a public lobby if you want! Of course, you must be the host for it to work.

# Faction-specific units

Each faction, for the most part, has its own units which, as mentioned before, differ between difficulties. For some clarification on the units:
* Field Agent: Blue-jacketed FBI guy.
* Hostage Rescue Team: FBI guys with green ballistic vests and balaclavas.
* Veteran Agent: White-shirt FBI guys.
* Murky Secret Service: The guards that appear on the White House heist, who wear glasses and vests. I decided these guys were appropriate for light recon units. They aren't available on the Hell's Island heist (more on this below).
* Murky Soldier: The murkywater units that usually appear as pre-determined spawns on murkywater heists. They look identical to heavy murky assault units but do not have the chest armour and only have the health of a light swat. For recon I am using variants that have damage scaling, which were used on Henry's Rock and Hell's Island. You can tell the smg guys and rifle guys apart due to the rifle guys having flashlights (mostly because there isn't a non-flashlight variation). The riflemen are not available on Beneath The Mountain, Hell's Island and The White House.


Here are all the units per faction and per difficulty. In brackets their gun is listed with both its ingame name and the name in the game files.

### America
This is the 'default' faction that appears in most heists, so you will be seeing these guys the most often.

##### Normal
Light: Cops with pistols (chimano 88/c45) or revolvers (bronco/raging_bull).
Heavy: Cops with smgs (compact-5/mp5) or shotguns (reinfield/r870).

##### Hard/Very Hard
Light: Cops with smgs (compact-5/mp5) or shotguns (reinfield/r870).
Heavy: Cops with revolvers (bronco/raging_bull) and hostage rescue team (compact-5/mp5).

##### Overkill/Mayhem
Light: Field agents (chimano 88/c45) and hostage rescue team (compact-5/mp5).
Heavy: Hostage rescue team (compact-5/mp5) and veteran agents (car-4/m4).

##### Death Wish/Death Sentence
Light: Hostage rescue team (compact-5/mp5).
Heavy: Veteran agents (car-4/m4).

### Russia
This is the faction used for Boiling Point. The folder for this dlc contains unique "cop" units that aren't actually used (although I believe they used to be a part of the assault force back when the heist released). The same units are used for all difficulties, which are as follows:

Light: Cops with smgs (krinkov/akmsu and krinkov/asval. I don't actually know if the asval units are different because despite their name they actually just use the akmsu).
Heavy: Cops with rifles (AK.762/ak47_ass) or shotguns (reinfield/r870)

### Zombie
This faction uses zombiefied versions of the appropriate America faction units for the difficulty. Zombiefied versions of all those units exist in the game files, even though I'm pretty sure those guys were already removed from all spawngroups. I cannot actually test if this works because Cursed Kill Room doesn't have assault breaks. If you have a custom heist that uses zombie units and has assault breaks, lemme know how it goes (and give me the heist).

### Murkywater
This faction is used for murkywater heists where the murky units replace the assault force, mostly the endgame heists in murkywater facilities and also Beneath the Mountain. Note that the following units are not actually available in every murkywater heist. If a particular unit is unavailable, it will be replaced with a murky smg unit (which is available in all base-game heists). If the murky smg unit is unavailable (i.e. new murkywater heist releases, or custom heist that uses a custom package), it will fall back to a light murkywater assault unit who wields a compact-5/smg, who should always be available on any murkywater faction heist (if they aren't available and crash your game, it is probably not this mod's fault).

##### Normal
Both Light and Heavy: Murky secret service (chimano 88/c45).

##### Hard/Very Hard
Light: Murky secret service (chimano 88/c45).
Heavy: Murky soldiers with smgs (jackal/ump).

##### Overkill/Mayhem
Light: Murky secret service (chimano 88/c45) and murky soldiers with smgs (jackal/ump).
Heavy: Murky soldiers with smgs (jackal/ump) and rifles (eagle heavy/scar_murky).

##### Death Wish/Death Sentence
Light: Murky soldiers with smgs (jackal/ump).
Heavy: Murky soldiers with rifles (eagle heavy/scar_murky).

### Federales
This faction is used for the Mexico heists (except Border Crossing and Border Crystals, which use murkywater). On Overkill and above they are the same as America. The reason for this is that there are simply not many light Federales units to choose from, and most of them do not work on every heist (e.g. bank guards, the only units with smgs, crash the game on Breakfast in Tijuana). My in-universe excuse for this is "After hearing rumours that some of the PAYDAY gang crossed the border into mexico, the FBI sent some of their veteran agents to help out. The Policia Federales mostly use them for rescuing hostages, as the FBI did not send any of their heavy units and the Federales already have their own militarised police force to fight the PAYDAY gang with."

##### Normal
Both Light and Heavy: Policia with pistols (chimano 88/c45).

##### Hard/Very Hard
Light: Policia with pistols (chimano 88/c45).
Heavy: Field agents (chimano 88/c45) and hostage rescue team (compact-5/mp5).

# Map-specific units.
There are a couple of map archetypes that will change the units that spawn. Most of these apply to difficulties below Overkill.

### Los Angeles
Reservoir Dogs, which takes place in LA, will replace the cops that spawn on Very Hard and below with the LA variants. No changes are made to composition because the weapons they wield are the same. This does not happen on Aftershock because it released before Reservoir Dogs and, as far as I know, has not retroactively had the LA cops added (if I'm wrong, let me know).

### San Francisco
The recent City of Light Heists (Dragon Heist and Ukranian Prisoner) have unique san francisco police enemies, so the cops on Very Hard and below are replaced with them. The SF cops only have pistols, so the replacement is similar to the Federales.

##### Normal
Both Light and Heavy: SF cops with pistols (chimano 88/c45).

##### Hard/Very Hard
Light: SF cops with pistols (chimano 88/c45).
Heavy: Field agents (chimano 88/c45) and hostage rescue team (compact-5/mp5).

### Remote Heists
Certain heists (Black Cat, Big Oil Day 2, Biker Heist Day 2) I consider to be "too remote" to have regular cops spawn. So on Very Hard and below I simply replace them with fbi units. Note that while White Xmas/Train Heist may seem remote, police lights/cars do appear on them so they do not count as remote.

##### Normal
Light: Field agents (chimano 88/c45).
Heavy: Veteran agents (car-4/m4).

##### Hard/Very Hard
Light: Field agents (chimano 88/c45) and veteran agents (car-4/m4).
Heavy: Veteran agents (car-4/m4) and hostage rescue team (compact-5/mp5).

### FBI Heists
Certain heists (Firestarter Day 2, Hoxton Breakout Day 2, Hoxton Revenge) have you actually entering FBI buildings. On these heists, the FBI ramps up their response, sending their recon units on all difficulties and sending more of their dangerous units on higher difficulties. The spawncap is also increased slightly. Note that the weird compositions is due to veteran agents mostly being worse than hostage rescue team, but having their damage suddenly ramp up on Death Wish, making them more effective on Death wish and Death Sentence.

##### Normal
Light: Field agents (chimano 88/c45) and veteran agents (car-4/m4).
Heavy: Veteran agents (car-4/m4) and hostage rescue team (compact-5/mp5).

##### Hard/Very Hard
Light: Field agents (chimano 88/c45) and hostage rescue team (compact-5/mp5).
Heavy: Hostage rescue team (compact-5/mp5) and veteran agents (car-4/m4).

##### Overkill/Mayhem
Light: Hostage rescue team (compact-5/mp5) and veteran agents (car-4/m4).
Heavy: Hostage rescue team (compact-5/mp5).

##### Death Wish/Death Sentence
Light: Hostage rescue team (compact-5/mp5) and veteran agents (car-4/m4).
Heavy: Veteran agents (car-4/m4).

# BYA (Before You Ask)
(I'm not calling this an FAQ because I'm writing this before I release the mod)

##### Q: Have you tried adding [heist-specific units]?
A: I welcome suggestions for this! However, there are two I have already considered so please don't ask me about these:

Murkywater recon on Meltdown and Slaughterhouse: I originally wanted to do this, however these heists simply don't load the packages containing the units that I want. The units that are available on these heists either have no damage scaling or only scale up to Very Hard, so they do either average or a lot of damage on normal (relatively), and pitiful damage on Death Sentence.

Gangster recon: While it would be cool to have, say, mendozas or commissar's mobsters return on their respective heists between assaults to attack you, I just don't think it would work. Recon's main job is to rescue hostages and confiscate loot, I don't even know if the gangster AI can do this. If it can't, I'd have to add regular recon as well, which would then fight the gangsters, possibly making both enemy types ineffective at actually fighting the player. Also, it's possible the gangsters would just be assigned to the police team, which would be even weirder.

##### Q: My game crashed!
A: Before reporting this to me, please confirm that it is this mod that is causing it. Try and replicate the crash conditions, both with and without the mod. If you can confirm that it is indeed this mod, send me the crash log with info about what heist you were playing and what difficulty. If it's a custom heist, give me a trustworthy link to it and the faction that you fight in that heist.

##### Q: Why are regular cops so acrobatic?
A: I want units to be able to reach the player on all heists quickly. In some heists I think that units actually need to be acrobatic to traverse the map at all (even with this change, there are still some places where I've found units have difficulty traversing). I could have vetted this more but like, there are a lot of heists in this game. I just decided to make *all* recon units acrobatic instead.

##### Q: Why can't you just add custom enemies or load in missing units on certain heists?
A: I adamantly want this mod to be serverside, i.e. only the host needs it. The original purpose of this mod was to restore missing content that is still in the game files, in a way that works for newly added stuff (like the murky faction) that did not exist when the content was "removed". It is designed to be something that fits into a normal game such that most people would not mind the host using it when joining a random lobby (and possibly would not even be noticed).

As for the murkywater units that are missing on certain heists, I can load them in to prevent the host from crashing. However, any client who does not have the mod will not be able to actually see the enemies, so I chose to just swap out the enemies instead.

##### Q: I play on [low difficulty] and the assault breaks are so long!
A: This was mostly balanced around Overkill. The reason I moved hostage hesitation time from the anticipation period to the break period is because Overkill's assault breaks are so short that the recon barely has time to spawn and reach the hostages. Plus, it makes sense that delaying the assault would be to give more time to rescue hostages, rather than give the assault units more time to prepare. Now taking hostages is more important because the spawning of the assault units is actually delayed. Unfortunately, this does mean that breaks on low difficulties are abnormally long, however I didn't want to make a special exception because that would be inconsistent.

##### Q: I play on [high difficulty] and barely see the recon units!
A: The hostage hesitation time on Mayhem and above is reduced from 30 seconds to 10 seconds. I did not change this, only where it is applied, as I do not intend to significantly change the difficulty of the game. If you want to change this, you could look for another mod to do this (or quickly make it if you have the knowledge to do so, because it only takes about a minute. The hostage hesitation time is contained in groupaitweakdata.lua).