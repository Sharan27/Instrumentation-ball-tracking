from flask import Flask,render_template, request,jsonify, url_for
import subprocess
import time
import os

global weightage
global minmax

app = Flask(__name__,template_folder="templates", static_folder="static")
# app = Flask(__name__, static_folder="static")


# Webpage routes
@app.route("/")
def index():
	return render_template('index.html')
@app.route("/recordedlog.html")
def recordedlog():
	return render_template('recordedlog.html')
@app.route("/newlog.html")
def newlog():
	return render_template('newlog.html')
@app.route("/rawdata.html")
def rawdata():
	return render_template('rawdata.html')
@app.route("/motionvisuals.html")
def motionvisuals():
	return render_template('motionvisuals.html')
@app.route("/analysedata.html")
def analysedata():
	return render_template('analysedata.html')


@app.route('/process', methods=['POST'])
def process():
	data = request.get_json() # retrieve the data sent from JavaScript
	# process the data using Python code
	result = data['value'] * 2
	return jsonify(result=result) # return the result to JavaScript



@app.route('/getData', methods=['POST'])
def getData():
	with open('params.txt') as f:
		line = f.readline()
	return line.strip()

@app.route('/postTime', methods=['POST'])
def postTime():
	data = request.get_json()
	arr_length = data['Length']
	elapsed_time = (data['End'] - data['Start'])/1000
	freq = arr_length/elapsed_time
	with open('timing.txt', 'w') as f:
		f.writelines([str(freq), "\n", str(elapsed_time), "\n", str(arr_length)])
	time.sleep(3)
	subprocess.run(["python", "mateng.py"])
	return "OK"

@app.route('/analyse', methods=['POST'])
def analyse():
	data = request.get_json()
	weightage =	[str(x) for x in data["Weightage"]]
	minmax = data["Minmax"]
	l1 = weightage + minmax
	print(weightage,minmax)
	# cwd = os.path.join(os.getcwd(), "fyp_eda.py" + ' ' + str(weightage) + "  " + str(minmax))
	# print(cwd)
	# os.system('{} {}'.format('python', cwd))
	os.system('python /Users/sharan/PycharmProjects/Flask_Webpage/fyp_eda.py %s' % ' '.join(l1))
	return "OK"







if __name__ == '__main__':
	app.run(debug=True)
