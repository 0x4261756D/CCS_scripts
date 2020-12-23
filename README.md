# CCS_scripts

**Hochladen neuer Karten**
Kleine Information wie das Hochladen von Dateien (scripts, cdb's und Bildern) via Pull Request aussehen sollte.
Scripte kommen in "script".
cdb's kommen in die Root.
Bilder kommen in "pics".
Wenn ein Archetype erweitert wird, sollen in der cdb *ausschließlich* die neuen Karten dieses Archetypes stehen und die cdb sollte so zu heißen, dass man sofort weiß um welchen Archetype es sich handelt (VirtualWorldExtension.cdb z.B.).
Pull Requests werden nur gemerged, wenn sie eine Info enthalten welche Person mit einem Sinn für Balancing (also nicht Rundas, aber z.B. Retrogamer) die Karte abgesegnet hat.

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
