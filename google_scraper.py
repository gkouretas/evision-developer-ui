import pandas as pd
import datetime as dt
import goslate
from pytrends.request import TrendReq
from googletrans import Translator

def scrape(codes, terms, lang, time):
    # print(codes)
    # print(terms)
    # print(lang)
    # print(time)
    terms.sort()
    pytrends = TrendReq(hl='en-US', tz=360)
    # time = 'today 5-y'
    # print(time)

    # time = '2015-02-15 2020-02-15'

    # enter desired time in this section, will usually be 'today 5-y'
    # for the app
    if lang != 'en': terms = trans(lang, terms)
    ggl_complete = pd.DataFrame(columns = [] * len(terms) * 2)
    insufficient_data = 0
    for area in codes:
        search_count = 0
        while(len(terms) > search_count):
            try:
                pytrends.build_payload(kw_list= [terms[search_count]], timeframe = time, geo = area)
                ggl = pytrends.interest_over_time()
                ggl = ggl.drop(columns = 'isPartial')
                ggl_complete = pd.concat([ggl_complete, ggl], axis = 1)
                search_count += 1
            except Exception:
                search_count += 1
                insufficient_data += 1
                pass
    ggl_complete = ggl_complete.to_numpy()
    print(ggl_complete)
    return [ggl_complete, insufficient_data]

def get_date(time):
    # time = '2015-02-15 2020-02-15'
    dates = []
    pytrends = TrendReq(hl='en-US', tz=360)
    pytrends.build_payload(kw_list= ['google'], timeframe = time, geo = 'US')
    data = pytrends.interest_over_time()
    indexes = data.index
    times = list(indexes.to_pydatetime())
    for i in range(0, len(times)):
        dates.append(times[i].strftime('%Y-%m-%d'))
    return dates


def trans(lang, terms):
    # google trans code. Can use if the API gets fixed

    # -----------------


    # translator = Translator() # translate method
    # # try:
    # print(terms)
    # print(lang)
    # terms = translator.translate(terms, dest=lang) # tries to translates terms to desired language, will be an object
    # # except Exception:
    # print('translation not working')
    # # return # returns NoneType if primary language of area is not supported by google translate (there are a few like this)
    # count = 0 # count for list indexing
    # for trans in terms:
    #     terms[count] = trans.text # changes object to text
    #     count += 1

    gs = goslate.Goslate()
    translations = []
    for term in terms:
        translations.append(gs.translate(term, lang))
        time.sleep(1)
    print(translations)

    return translations # returns translated terms


# def get_range():
#     curr_week = dt.date.today().isocalendar()[1]
#     start_date = dt.datetime.strptime(f'2017-W{curr_week}-1', "%Y-W%W-%w")
#     start_date = str(start_date).split(" ")[0]
#     end_date = str(dt.date.today())
#     return start_date + ' ' + end_date

# file = scrape(['US-AL', 'US-AK', 'US-AZ', 'US-AR', 'US-CA', 'US-CO', 'US-CT', 'US-DE', 'US-DC', 'US-FL', 'US-GA', 'US-HI', 'US-ID', 'US-IL', 'US-IN', 'US-IA', 'US-KS', 'US-KY', 'US-LA', 'US-ME', 'US-MD', 'US-MA', 'US-MI', 'US-MN', 'US-MS', 'US-MO', 'US-MT', 'US-NE', 'US-NV', 'US-NH', 'US-NJ', 'US-NM', 'US-NY', 'US-NC', 'US-ND', 'US-OH', 'US-OK', 'US-OR', 'US-PA', 'US-RI', 'US-SC', 'US-SD', 'US-TN', 'US-TX', 'US-UT', 'US-VT', 'US-VA', 'US-WA', 'US-WV', 'US-WI', 'US-WY'], ['flu', 'cough', 'sore throat', 'tamiflu'], 'en');
# file = scrape(['US-CA', 'US-TX', 'US-NY'], ['flu', 'cough', 'sore throat', 'tamiflu'], 'en');
# file = scrape(['GR-A', 'GR-I', 'GR-G', 'GR-C', 'GR-F', 'GR-D', 'GR-B', 'GR-M', 'GR-L', 'GR-J', 'GR-H', 'GR-E', 'GR-K'], ['flu', 'cough', 'sore throat', 'tamiflu'], 'el');
# file = scrape(['GR'], ['flu', 'cough', 'sore throat', 'tamiflu'], 'el');
# print(file)
# print(get_date())
# print(dates)
# file.to_csv('test.csv');

scrape(['US-CA'], ['loss of smell', 'loss of taste'], 'en', '2020-01-26 2021-02-12')
