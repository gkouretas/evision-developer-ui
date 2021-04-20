Introduction
------------

This repository contains all the necessary files to run our eVision developer user interface. Current features include:

* Influenza and COVID case predictions
* Ability to either upload your own test dataset or scrape data over any time interval
* Download results in graphical or spreadsheet form
* Granulation to improve predictions

Dependencies
------------

The dependencies for this app include:

* MATLAB r2020a (will likely also work with older version)
* Python 3.7 or 3.8 (download libraries using requirements.txt file)
* Google Chrome
* chromedriver (can download <a href="https://chromedriver.chromium.org/">here</a>)

Steps to Deploy
---------------

1. Install Google Chrome and chromedriver if you have not and make sure the versions correspond with one another.

2. Make sure that you have all the Python libraries installed

3. Insert correct paths within the system. 

* Will need to add the path to your chromedriver on line 147 of case_scraper.py.

* Will need to make sure your MATLAB is able to find the system path to your version of Python (information concerning this can be found <a href="https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html?s_tid=mwa_osa_a">here</a>).  Also be sure to add the path in line 3 of the file py_init.m.

4. (Optional) Save your MATLAB app onto your desktop

* Open the .mlapp file in the MATLAB App Designer and got to Share -> MATLAB App
* Make sure all the files are included in the "files included through analysis" (should all include by default)
* Press package


