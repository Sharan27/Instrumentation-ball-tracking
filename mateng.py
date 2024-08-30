import matlab.engine

print('Data processing in Matlab ')
# print(sensor_data)
eng = matlab.engine.start_matlab()
tf = eng.Script(nargout=0)
print(tf)