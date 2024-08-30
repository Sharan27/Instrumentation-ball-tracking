# import
import pandas as pd
import seaborn as sns
from sklearn.preprocessing import minmax_scale
# %matplotlib inline
import matplotlib.pyplot as plt
from skcriteria import Data, MIN, MAX
# read
param_data = pd.read_csv("param.csv")
param_data = param_data.loc[:, ['Ball No.', 'Flight time(s)', 'Avergae speed(m\s)', 'Spin X(rps)', 'Release speed(Rs)', 'Speed after Pitch(Rp)']]

print(param_data)
criteria_data = Data(
    param_data.iloc[:, 1:],          # the pandas dataframe
    [MIN, MAX, MIN, MAX, MAX],      # direction of goodness for each column
    anames = param_data['Ball No.'], # each entity's name, here car name
    cnames = param_data.columns[1:], # attribute/column name
    # weights=[1,1,1,1,1]           # weights for each attribute
    )
print(criteria_data)
criteria_data.plt("violin")