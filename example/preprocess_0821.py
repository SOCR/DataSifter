import csv
import re
from autocorrect import Speller
import sys
# sys.path.append("/home/wuqiuche/.local/lib/python3.6/site-packages")

def process(param):
	print(param)
	spell = Speller(lang='en')
	rows = []
	with open('processed_' + str(param) + '.csv', 'r') as f:
		reader = csv.reader(f)
		i = -1 # iteration counter
		for row in reader:
			i += 1
			if i == 0:
				rows.append(row)
				continue

			j = 0

			# Remove characters that are not in alphabets, numerics or space
			row[j] = row[j].replace("\n", " ")
			tmp = list([val for val in row[j] if val.isalpha() or val==' ' or val == ',' or val == '.'])
			row[j] = "".join(tmp)

			if row[j] == " ":
				continue

			# All lower case
			row[j] = row[j].lower()

			# Autocorrect for each word
			words = row[j].split()
			for k in range(len(words)):
				words[k] = spell(words[k])

			tmp = ""
			if len(words) == 0:
				continue
			for k in range(len(words)-1):
				tmp += words[k]
				tmp += " "
			tmp += words[-1]
			row[j] = tmp
			rows.append(row)

	with open('processed_done_' + str(param) + '.csv', 'w') as f_write:
		csv_writer = csv.writer(f_write)
		for row in rows:
			csv_writer.writerow(row)

if __name__ == "__main__":
	process(sys.argv[1])

