# CCS_scripts

**Hochladen neuer Karten:**
Kleine Information wie das Hochladen von Dateien (scripts, cdb's und Bildern) via Pull Request aussehen sollte.
Scripte kommen in "script/Archetype Unterordner" oder "script/Set Unterordner" (je nachdem ob ein Archetype oder ein "Custom Booster Pack" hochgeladen wird).
cdb's kommen in die Root wobei der Eintrag "ot" 32 (bzw. 0x20) sein sollte um alle Customs auch als solche zu deklarieren. Macht die Suche nach Customs einfacher und es ist irgendwie falsch Customs als offizielle Karten zu deklarieren.
Bilder kommen in "pics" und NICHT in "pics/Unterordner", da der pics Ordner das nicht supported.
Wenn ein Archetype erweitert wird, sollen in der cdb *ausschließlich* die neuen Karten dieses Archetypes stehen und die cdb sollte so heißen, dass man sofort weiß um welchen Archetype es sich handelt (VirtualWorldExtension.cdb z.B.).

**Neue Archetypes/Counter hinzufügen:**
Wenn ein neuer Archetype oder ein neuer Counter-Typ hinzugefügt wird, soll die Datei "strings.conf" aus der Root im PR editiert werden:

!counter freie hex ID Counter Name (für Counter)

!setname freie hex ID Archetype Name (für Archetypes)

**How to upload new cards:**
Here's a little info on how to upload new files (scripts, databases or pics) via PR.
Scripts belong in "script/archetype"- or "script/set"- subfolder (depending on whether a custom archetype or a "custom booster pack" is uploaded).
cdb files belong in the root and the entry "ot" should be 32 (or 0x20).
Pics belong in "pics" and NOT in "pics/subfolder", since "pics" doesn't support subfolders.
If an archetype is extended, the cdb is supposed to *exclusively* contain the new cards of said archetype. The file should also have a name which makes it easy to know what is expanded (like VirtualWorldExtension.cdb for example).

**Add new archetypes/counters:**
An archetype/counter is added by editing "strings.conf" from the root:

!counter free hex ID counter name (for counters)

!setname free hex ID archetype name (for archetypes)

**Automatic Client Updates:**
For keeping the cards up-to-date you should add 
```json
        {
            "url": "https://github.com/0x4261756D/CCS_scripts",
            "repo_name": "CCS Scripts",
            "repo_path": "./repositories/ccs",
            "script_path": "script",
            "should_update": true,
            "should_read": true
        },
``` 
to /config/configs.json in your ProjectIgnis folder after this part
```json
{
    "repos": [
        {
            "url": "https://github.com/ProjectIgnis/DeltaHopeHarbinger",
            "repo_name": "Project Ignis updates",
            "repo_path": "./repositories/delta",
            "has_core": true,
            "core_path": "bin",
            "data_path": "",
            "script_path": "script",
            "should_update": true,
            "should_read": true
        },
```
and for field-arts you also have to add
```json
        {
            "url": "https://raw.githubusercontent.com/0x4261756D/CCS_scripts/master/pics/field/{}.png",
            "type": "field"
        },
        {
            "url": "https://raw.githubusercontent.com/0x4261756D/CCS_scripts/master/pics/field/{}.jpg",
            "type": "field"
        }
```
after this part
```json
	}
		],
		"urls": [

```
**Playing with other people using Custom Cards:**
Add
```json
		{
            "name": "CCS",
            "address": "85.214.233.223",
            "duelport": 7911,
            "roomaddress": "85.214.233.223",
            "roomlistport": 7922
    	},
```
to /config/configs.json in your ProjectIgnis folder after this part
```json
	"servers": [
		{
			"name": "EU Central (Casual)",
			"address": "185.227.110.90",
			"duelport": 7912,
			"roomaddress": "185.227.110.90",
			"roomlistport": 7923
		},
```
