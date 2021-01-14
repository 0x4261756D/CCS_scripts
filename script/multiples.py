import os

folders = os.listdir('./')
contents = {}
for i in folders:
	if os.path.isdir(i):
		contents[i] = os.listdir(i)

# print(contents)

for i in contents:
#	print(contents[i])
	for j in contents:
		if i != j:
			for k in contents[j]:
				if k in contents[i]:
					print('Duplicate', i + '/' + k, j + '/' + k)
