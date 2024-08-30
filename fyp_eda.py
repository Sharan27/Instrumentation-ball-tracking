import pandas as pd
import seaborn as sns
from sklearn.preprocessing import minmax_scale
import matplotlib.pyplot as plt
from skcriteria import Data, MIN, MAX
import sys

df = pd.read_excel("variables.xlsx")
df.to_csv("variables.csv", sep=",",index=False, header=True)



param_data = pd.read_csv("variables.csv")
# param_data = param_data.loc[:, ['Ball No.', 'Flight time(s)',	'Avergae speed(m\s)', 'Spin X(rps)', 'Spin Y(rps)',	'Spin Z(rps)', 'Release speed(Rs)', 'Release angle(Alpha)',	'Release angle(Beta)', 'Release angle(Gamma)',	'Speed after Pitch(Rp)',	'Pitch Angle(Alpha)', 'Pitch Angle(Beta)',	'Pitch Angle(Gamma)',	'Pitch Distance(m)',	'Pitch Width(m)', 'Total Time(s)']]
param_data = param_data.loc[:, ['Ball No.', 'Flight time(s)',	'Avergae speed(m\s)', 'Spin X(rps)', 'Release speed(Rs)', 'Speed after Pitch(Rp)']]

print(sys.argv[1:])
weightage = [eval(i) for i in sys.argv[1:6]]
minmax = sys.argv[6:]
crit = []
for i in minmax:
    if i == 'Min':
        crit.append(-1)
    else:
        crit.append(1)



criteria_data = Data(
    param_data.iloc[:, 1:],          # the pandas dataframe
    criteria = crit,      # direction of goodness for each column
    anames = param_data['Ball No.'], # each entity's name, here car name
    cnames = param_data.columns[1:], # attribute/column name
    weights= weightage         # weights for each attribute
    )


criteria_data.plot("violin")
plt.savefig('/Users/sharan/PycharmProjects/Flask_Webpage/static/violinplot.png')


def normalize_data(logic="minmax"):
  df = param_data.iloc[:, 1:].values.copy()
  if logic == "minmax":
    normalized_data = minmax_scale(df)
    normalized_data[:, 2] = 1 - normalized_data[:, 2]
    normalized_data[:, 4] = 1 - normalized_data[:, 4]
  elif logic == "sumNorm":
    normalized_data = df / df.sum(axis=0)
    normalized_data[:, 2] = 1 / normalized_data[:, 2]
    normalized_data[:, 4] = 1 / normalized_data[:, 4]
  elif logic == "maxNorm":
    normalized_data = df / df.max(axis=0)
    normalized_data[:, 2] = 1 / normalized_data[:, 2]
    normalized_data[:, 4] = 1 / normalized_data[:, 4]
  return normalized_data

def plot_heatmap(logic="minmax"):
  plot_data = normalize_data(logic)
  car_model_names = param_data['Ball No.']
  attribute_names = param_data.columns[1:]
  hm = sns.heatmap(plot_data, annot=True, yticklabels = car_model_names, xticklabels = attribute_names, fmt='.3g')
  plt.tight_layout()
  # plt.show()
  plt.savefig('/Users/sharan/PycharmProjects/Flask_Webpage/static/heatmap.png')

plot_heatmap("minmax")

#USING MINMAX METHOD


from skcriteria.madm import simple
# weighted sum
dm = simple.WeightedSum(mnorm="sum")
dec = dm.decide(criteria_data)
original_stdout = sys.stdout
with open('Analysed_Output.txt', 'w') as f:
    sys.stdout = f
    print(dec)

