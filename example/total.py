from preprocess_0821 import process
from mask import mask
from predict_tsv_1_seq import impute
from refine_label import refine_label
from csv_to_tsv import to_tsv

refine_label()
process("0")
mask()
impute()
to_tsv()