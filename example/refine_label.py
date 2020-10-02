import csv


def refine_label():
	rows = []
	with open('processed_0_prepare.csv', 'r') as f:
		reader = csv.reader(f)
		i = -1
		for row in reader:
			i += 1
			if i == 0:
				rows.append(row)
				continue
			if row[1] == '62':
				row[1] = 0
			elif row[1] == '42':
				row[1] = 1
			elif row[1] == '55':
				row[1] = 2
			elif row[1] == '63':
				row[1] = 3
			elif row[1] == '71':
				row[1] = 4
			rows.append(row)
	
	with open('processed_0.csv', 'w') as f_write:
		csv_writer = csv.writer(f_write)
		for row in rows:
			csv_writer.writerow(row)

if __name__ == "__main__":
	process()