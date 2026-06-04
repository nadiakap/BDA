# -*- coding: utf-8 -*-
"""
Created on Thu Jun  4 07:32:42 2026

@author: Dimitry
"""

import pandas as pd

# Load the entire file into memory and immediately save it as CSV
df = pd.read_parquet(r"C:\Users\dmitr\OneDrive\Documents\MATLAB\Nadia\yellow_tripdata_2026-01.parquet")
df.to_csv(r"C:\Users\dmitr\OneDrive\Documents\MATLAB\Nadia\yellow_tripdata_2026-01.csv", index=False)

print("Conversion complete!")