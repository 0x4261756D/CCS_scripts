# CCS_scripts

**Hochladen neuer Karten**
Kleine Information wie das Hochladen von Dateien (scripts, cdb's und Bildern) via Pull Request aussehen sollte.
Scripte kommen in "script/Archetype Unterordner" oder "script/Set Unterordner" (je nachdem ob ein Archetype oder ein "Custom Booster Pack" hochgeladen wird).
cdb's kommen in die Root wobei das Feld "ot" für jede Karte mit 32 (bzw. 0x20) ausgefüllt sein sollte, da dies Custom Karten darstellt und so das Filtern einfacher macht.
(Außerdem ist es schlicht und ergreifend falsch, Custom Karten als TCG/OCG zu deklarieren).
Bilder kommen in "pics" und NICHT in "pics/Unterordner", da der pics Ordner das nicht supported.
Wenn ein Archetype erweitert wird, sollen in der cdb *ausschließlich* die neuen Karten dieses Archetypes stehen und die cdb sollte so zu heißen, dass man sofort weiß um welchen Archetype es sich handelt (VirtualWorldExtension.cdb z.B.).
Pull Requests werden nur gemerged, wenn sie eine Info enthalten welche Person mit einem Sinn für Balancing (also nicht Rundas, aber z.B. Retrogamer) die Karte abgesegnet hat.

**Neue Archetypes/Counter hinzufügen**
Wenn ein neuer Archetype oder ein neuer Counter Type hinzugefügt wird, soll die Datei "strings.conf" aus der Root im PR editiert werden:
!counter freie hex ID Counter Name
!setname freie hex ID Archetype Name

**Automatisches Update für den Client**
Damit die Karten in eurem EDOPro-Client immer aktuell sind solltet ihr in eurem ProjectIgnis-Ordner in /config/configs.json unter

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
eine neue Zeile und 
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
einfügt.
