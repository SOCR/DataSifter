import csv

def to_tsv():
	rows = []
	with open('bert_test_f1_seq.tsv', 'r') as f:
		reader = csv.reader(f, delimiter = '\t')
		for row in reader:
			rows.append(row)

	with open('bert_test_f1_seq.csv', 'w') as f_write:
		csv_writer = csv.writer(f_write)
		for row in rows:
			csv_writer.writerow(row)

if __name__ == "__main__":
	to_tsv()