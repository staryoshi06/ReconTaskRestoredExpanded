This mod does many things to restore the recon task in PAYDAY 2. What is the recon task, you might ask? Essentially, it is a group of enemies that appears between assaults to rescue hostages and confiscate loot. In earlier versions of the game, this group would be made up of special enemies known as the Hostage Rescue Team, who were lightly armoured but very effective with their weapons. In the current version of the game, the recon task just uses the normal assault groups, and in higher difficulties the assault breaks are so short that they basically may as well not exist. This mod aims to fix both of these problems.

## Basic Idea

By default, this mod restores the original enemies of the recon task using custom unit groups. In addition, where having a hostage would normally increase the anticipation period of the assault (where the music starts ramping up and assault enemies start spawning), this mod changes it so that, outside of the first assault, having a hostage will increase the break time instead. If the break time is lower than 60, you also gain an extra 5 seconds per additional hostage, up to a total break time of 60. Conversely, if the break time is greater than 60 (on lower difficulties mainly), then the extra time is added back to anticipation. This mod also fixes plenty of bugs with the recon task, such as not varying their objectives and map-scripted spawns getting stuck and counting towards the spawncap.

## Menu options
Coming with v2.0, this mod has a menu, allowing you to customise your experience! More in-detail explanation in the mod folder. The following options are available:

### Enemy Set
This determines what enemies appear for the recon task. There are five options:

##### Normal
The primary enemy set, mostly the same as v1 of the mod. Normally, there will be cops on lower difficulties, and hostage rescue team on higher ones. Certain heists may modify this (e.g. "remote" heists have only hostage rescue team). Heists with different factions also use their own units.

##### No Cops
If you don't want regular cops as recon enemies, either because they're too weak, get stuck sometimes or you just want only the hostage rescue team, this option is for you. It is functionally like the "Normal" set but removes all regular cop enemies (excluding the ones used for the russia faction, and the security guards on the murkywater faction).

##### Classic
Attempts to emulate pre-Hoxton's-Housewarming recon, by varying units based on the "diff" value (see The Long Guide). On lower difficulties, it will start with regular cops and move over to light smg swat. On Very Hard, it starts with regular cops and light smg swat (although this part isn't in most heists because of how "diff" works), moves over to just light smg swat, and then moves to hostage rescue team. Higher difficulties are mostly the same, but on heists where recon spawns at low diff you can see light smg swat and the occasional regular cops (the reinforce team will also include modified assault groups, more on that later).

##### SMG Swats
Uses light smg swat groups that are also used in Classic.

##### Assault
Uses the assault team as recon. If reinforce is enabled, reinforce will use modified assault teams that have one less heavy unit and no medics (these are also used for Classic at higher difficulties).

### Murky equivalents
Picks the "light", "medium" and "heavy" units that are used for certain enemy sets in murkywater faction levels. "Old" is what was used in v1 of the mod (v2 changed them slightly), and "Flashlight Heavies" simply adds flashlight heavy murky guards (with damage scaling) wielding both smgs and rifles to levels that support them.

### Bronco Guy
Bronco Guy
(Adds a very small chance for a singular cop with a revolver (or other glass cannon weapon, depending on what is available for a particular level/faction) to spawn as a recon group.

### Spawn During Assault
Determines under what condition recon enemies will spawn during an assault wave.

##### Never
Default, and self-explanatory. Use this if you don't want to significantly expand the recon task and would rather just "restore" it to it's intended purpose.

##### If Hostages
If players have any hostages (tied civilians or cuffed cops, **not** converted cops), then recon will spawn during the assault. They will not necessarily assign their tasks to said hostages, but once they are rescued they will leave again.

##### If Any Objective
If there is any valid recon objective during the assault, they will spawn. This functionally just enables them, but recon will not spawn unless they have a valid objective normally.

##### Always
Recon will always spawn. If they have no objectives, YOU become their objective.

### Enable Reinforce
Restore the reinforce task as well. Unlike recon, this task was *entirely* cut (although weirdly enough Overkill placed some reinforce points in Black Cat, which makes me think that some of them aren't even aware the task was removed). The intention of this task was to send units to specified areas up to a specific quota, and defend them until they die, or until the area's defending force is large enough that they can retire. The reinforce task's units will be based on what you set your recon enemy set to. Also note that I have not modified any maps, so they will only appear on heists that actually have reinforce points.

(Also a note: the screenshots are from v1. I couldn't be bothered to take new ones, and they're still mostly accurate).