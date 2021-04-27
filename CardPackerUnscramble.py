import sqlite3
from sys import argv

if len(argv) != 2:
	print('Usage: python3 CardPackerUnscramble.py <Path to cdb>')
else:
	con = sqlite3.connect(argv[1])
	con.execute('''
		CREATE TABLE temp (
												id	integer,
												ot	integer,
												alias	integer,
												setcode	integer,
												type	integer,
												atk	integer,
												def	integer,
												level	integer,
												race	integer,
												attribute	integer,
												category	integer,
												PRIMARY KEY(id)
										);
	''')
	con.execute('INSERT INTO main.temp SELECT id, ot, alias, setcode, type, atk, def, level, race, attribute, category FROM main.datas;')
	con.execute('DROP TABLE main.datas;')
	con.execute('ALTER TABLE main.temp RENAME TO datas;')

	con.execute('''CREATE TABLE temp2 (
			id	integer,
			name	TEXT,
			desc	TEXT,
			str1	TEXT,
			str2	TEXT,
			str3	TEXT,
			str4	TEXT,
			str5	TEXT,
			str6	TEXT,
			str7	TEXT,
			str8	TEXT,
			str9	TEXT,
			str10	TEXT,
			str11	TEXT,
			str12	TEXT,
			str13	TEXT,
			str14	TEXT,
			str15	TEXT,
			str16	TEXT,
			PRIMARY KEY(id)
	);
	''')

	con.execute('INSERT INTO main.temp2 SELECT id, desc, name, str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15, str16 FROM main.texts;')
	con.execute('DROP TABLE main.texts;')
	con.execute('ALTER TABLE main.temp2 RENAME TO texts;')
	con.commit()
