import os
import time
import zipfile
import datetime as dt
import pandas as pd
import shutil
from git import Repo
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import Select

def whoflunet(name, week):
    # reads list of countries that who flnet data exists for
    # dir = create_dir(dir + '/cdc_who_data' + '/International')
    driver = chromeSetUp()
    driver.get("https://apps.who.int/flumart/Default?ReportNo=12")
    # scraping data
    # prev_name = ''
    # for name in country_list: # loops through list of countries
    #     if name == 'Montserrat': continue # montserrat is not compatible for some reason
    # DOWNLOAD_PATH = create_dir(dir + '/' + name) # adds a directory for given country
    params = {'behavior': 'allow', 'downloadPath': directory()}
    driver.execute_cdp_cmd('Page.setDownloadBehavior', params) # changes download path to chosen directory
    filter = Select(driver.find_element_by_id("lstSearchBy")) # finds html element where countries are
    filter.select_by_visible_text(name) # selects country for given iteration of loop
    # if prev_name != '':
    #     filter.deselect_by_visible_text(prev_name) # deselects previous country used
    # else: # selects date range for the first iteration (isn't needed after first time)
    year_from = Select(driver.find_element_by_id("ctl_list_YearFrom")) # finds html element where start year is
    year_from.select_by_visible_text("2015") # selects start year
    week_from = Select(driver.find_element_by_id("ctl_list_WeekFrom")) # finds html element where start week is
    week_from.select_by_visible_text(f"{week}") # selects current week
    # week_from.select_by_visible_text("8")
    year_to = Select(driver.find_element_by_id("ctl_list_YearTo")) # finds html element where end year is
    year_to.select_by_visible_text("2021") # finds html area where end year is
    week_to = Select(driver.find_element_by_id("ctl_list_WeekTo"))  # finds html element where end week is
    week_to.select_by_visible_text("53") # selects end week (doing 53 will give you most recent year)
    display_report = driver.find_element_by_name("ctl_ViewReport") # finds html element for button that loads spreadsheet
    display_report.click() # click button
    # print("Downloading data from " + name + " at " + datetime.now().strftime('%H:%M:%S'))
    # print(DOWNLOAD_PATH)
    start = time.time() # setting the time when the download starts
    while(True):
        try: # continually attempts while loading; will execute when spreadsheet gets loaded. time varies depending on how much data you're attempting to extract
            find_download = driver.find_element_by_id("ctl_ReportViewer_ctl05_ctl04_ctl00_ButtonLink") # finds dropdown element that allows for desired download format
            find_download.click() # selects dropdown
            download = driver.find_element_by_xpath("//a[@title='CSV (comma delimited)']") # finds element of desired download format (CSV in this case)
            download.click() # click button to download data
            break
        except Exception:
            end = time.time() # sets time of failure (failure meaning the page is still loading)
            if end - start > 300: # if page is still buffering after 5 minutes, it refreshes page
                refresh(driver)
                start = time.time() # resets start time to correspond with the page getting refreshed
            pass
    print('Starting sleep')
    time.sleep(5)
    # prev_name = name # stores value of name to deselect for next iteration
    # print(name + "'s data has downloaded (Time elapsed: ~" + str(round(time.time() - start, 1)) + " sec.)")
    driver.close()

def cdcwho(level, states = 'all'):
    print("Scraping CDC ILI and WHO NREVSS Data")
    # dir = create_dir(dir + '/cdc_who_data' + '/United States') # creates directory for cdc/who data
    driver = chromeSetUp()
    driver.get("https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html")
    while(True):
        try:
            disclaimer = driver.find_element_by_xpath("//button[@aria-label='Click to run the application.']")
            break
        except Exception:
            pass
    disclaimer.click()
    get_to_download(driver)
    params = {'behavior': 'allow', 'downloadPath': directory()}
    driver.execute_cdp_cmd('Page.setDownloadBehavior', params) # changes download path to chosen directory
    if level == 'National':
        download_data = driver.find_element_by_xpath("//button[@aria-label='Click to download the data and leave the data download panel.']")
        download_data.click()
        print("National data downloaded")
    else:
        select_state = driver.find_element_by_id("5")
        select_state.click()
        if(states == 'all'):
            while(True):
                try:
                    select_all_regions = driver.find_element_by_xpath("//input[@ng-model='isAllRegions']")
                    break
                except Exception:
                    time.sleep(0.1)
                    pass
            select_all_regions.click()
        else:
            state_data = pd.read_csv('state_codes.csv').States
            codes = pd.read_csv('state_codes.csv').Codes
            print(states)
            print(codes)
            while(True):
                try:
                    select_regions = driver.find_element_by_xpath("//button[@tabindex='921']")
                    select_regions.click()
                    try:
                        alabama = driver.find_element_by_xpath("//input[@tabindex='921']")
                        alabama.click()
                        break
                    except Exception:
                        time.sleep(.1)
                        pass
                except Exception:
                    time.sleep(.1)
                    pass
            for state in states:
                for i in range(0, len(state_data)):
                    if state == state_data[i]:
                        code = str(codes[i])
                        break
                while(True):
                    try:
                        test = driver.find_element_by_xpath(f"//input[@tabindex='{code}']")
                        test.click()
                        break
                    except Exception:
                        time.sleep(.1)
                        print('failed')
                        pass
            select_regions.click()
        download_data = driver.find_element_by_xpath("//button[@aria-label='Click to download the data and leave the data download panel.']")
        download_data.click()
        print("State data downloaded")
    dir_exists('FluViewPhase2Data.zip')
    driver.close()
    extract_zip('FluViewPhase2Data.zip')

def extract_zip(zip):
    with zipfile.ZipFile(zip, "r") as zip_ref:
        zip_ref.extractall(zip.split('FluViewPhase2Data.zip')[0])
        os.remove(zip)

def chromeSetUp():
    chromeOptions = Options()
    if bool(os.environ.get("GOOGLE_CHROME_BIN")): chromeOptions.binary_location = os.environ.get("GOOGLE_CHROME_BIN")
    chromeOptions.headless = False
    chromeOptions.add_argument("--disable-dev-shm-usage")
    chromeOptions.add_argument("--no-sandbox")
    # webdriver executes chrome and goes to flunet app
    try:
        PATH = '/Users/georgekouretas/Desktop/Random/chromedriver' # path to location of your chromedriver goes here
        driver = webdriver.Chrome(PATH, options=chromeOptions)
    except Exception:
        driver = webdriver.Chrome(os.environ.get("CHROMEDRIVER_PATH"), options=chromeOptions)
    return driver

def directory(): # creates necessary directory for
    current_dir = os.getcwdb().decode() # gets current directory
    return current_dir

def dir_exists(dir): # checks to see if file downloaded before resuming
    while(True):
        if os.path.exists(dir): # resumes when .csv is downloaded to desired directory
            break
        else:
            time.sleep(1)

def refresh(driver): # refreshes webpage
    try:
        cancel = driver.find_element_by_link_text('Cancel')
        cancel.click()
    except Exception:
        pass
    print("Cancelled download: Process frozen. Refreshing page in five seconds.")
    time.sleep(5)
    driver.refresh()
    print("Refreshed")

def get_to_download(driver):
    while(True):
        try:
            download = driver.find_element_by_xpath("//button[@aria-label='Click to download the flu data for the selected season.']")
            download.click()
            break
        except Exception:
            time.sleep(.1)
            pass
    while(True):
        try:
            select_all_seasons = driver.find_element_by_xpath("//input[@ng-model='isAllSeasons']")
            select_all_seasons.click()
            break
        except Exception:
            time.sleep(.1)
            pass

def get_covid_data():
    try:
        dir = os.getcwdb().decode() + '/covid-19-data' # current directory + path to folder",
    except Exception:
        dir = os.getcwdb().decode() + '\covid-19-data' # support for other directory pathing syntax
    url = "https://github.com/nytimes/covid-19-data"
    if os.listdir(dir): # clears git repo in order to extract updated content",
        content = [(dir + '/') + x for x in os.listdir(dir)]
        for files in content:
            try:
                shutil.rmtree(files) # removes directories",
            except Exception:
                os.remove(files) # removes files",
    Repo.clone_from(url, dir)
# dir = directory() # creates base directory
# whoflunet("Saudi Arabia", 45) # put 53 to get all weeks
# cdcwho('National') # level where data gets scraped
# get_covid_data()
