from flask import Flask, render_template
import datetime
import pytz
from prometheus_flask_exporter import PrometheusMetrics



app = Flask(__name__)
metrics = PrometheusMetrics(app)

# static information as metric
metrics.info('app_info', 'Application info', version='1.0.3')


@app.route("/")
@metrics.do_not_track()
def index():
    return "This Webapp show Homer Simpson picture by accessing /homersimpson & the time in the moment og requestin Covilha City (Portugal) when accessing /covilha."

@app.route("/homersimpson")
#PrometheusMetrics(app, group_by='endpoint')
def homersimpson():
    print ("Showing Images")
    return render_template('index.html')

@app.route("/covilha")
#PrometheusMetrics(app, group_by='endpoint')
def covilha():
    print ("Printing Portugal Time")
    tz = pytz.timezone('Portugal')
    ct = datetime.datetime.now(tz=tz)
    return ct.isoformat() 


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)
