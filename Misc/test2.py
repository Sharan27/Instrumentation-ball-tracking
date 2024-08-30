import pandas as pd
size = 300
df = pd.read_csv('/Users/sharan/PycharmProjects/Flask_Webpage/LoggedData_CalInertialAndMag.csv')

for i, g in df.groupby(df.index // size):
    g.to_csv(f'/Users/sharan/PycharmProjects/Flask_Webpage/split{i}.csv', index=True)
# import csv
#
# input_file = '/Users/sharan/PycharmProjects/Flask_Webpage/LoggedData_CalInertialAndMag.csv'
# with open(input_file, 'r') as f_in:
#     reader = csv.reader(f_in)
#     rows = [row for row in reader]
#
# # Duplicate the first 100 rows
# duplicated_rows = rows[1:100] * 5
#
# # Insert duplicated rows below the 100th row
# rows = rows[:100] + duplicated_rows + rows[100:]
#
# # Write modified rows back to the same CSV file
# with open('/Users/sharan/PycharmProjects/Flask_Webpage/modified.csv', 'w', newline='') as f_out:
#     writer = csv.writer(f_out)
#     writer.writerows(rows)
