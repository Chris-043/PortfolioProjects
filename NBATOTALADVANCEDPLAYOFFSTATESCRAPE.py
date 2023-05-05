# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:57:48 2023

@author: mccar
"""

from selenium import webdriver
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup
import pandas as pd

##Set up a list for all nba seasons -- there's probably a better way to do this. Nba.com only has 97 for the first year
nba_Seasons = ['2021-22', '2020-21', '2019-20', '2018-19', '2017-18', '2016-17', '2015-16', '2014-15', '2013-14', '2012-13', '2011-12', '2010-11', '2009-10', '2008-09', '2007-08', '2006-07', '2005-06', '2004-05', '2003-04', '2002-03', '2001-02', '2000-01','2000-01', '1999-00', '1998-99', '1997-98', '1996-97']

###timeout gives 25 seconds to find element present in nba.com
timeout = 25
##Establish use of Firefox web driver -- need to install Geckodriver onto PC
driver = webdriver.Firefox()

##Need to manually close out ad and cookie question when driver loads nba.com page -- could be a way around
for season in nba_Seasons:
    url = f"https://www.nba.com/stats/players/advanced?Season={season}&SeasonType=Playoffs&PerMode=Totals"
    driver.get(url)
    element_present = EC.presence_of_element_located((By.XPATH, r"/html/body/div[1]/div[2]/div[2]/div[3]/section[2]/div/div[2]/div[2]/div[1]/div[3]/div/label/div/select"))
    WebDriverWait(driver, timeout).until(element_present)
    select = Select(driver.find_element(By.XPATH,"/html/body/div[1]/div[2]/div[2]/div[3]/section[2]/div/div[2]/div[2]/div[1]/div[3]/div/label/div/select"))
    select.select_by_index(0)
    src = driver.page_source
    parser = BeautifulSoup(src, "lxml")
    table = parser.find("div", attrs = {"class":"Crom_container__C45Ti crom-container"})
    headers = table.findAll('th')
    headerlist = [h.text.strip() for h in headers [1:24]]
    headerlist1 = [a for a in headerlist if not 'RANK' in a]
    rows = table.findAll('tr')[1:]
    player_stats = [[td.getText().strip() for td in rows[i].findAll('td')[1:]] for i in range(len(rows))]
    stats = pd.DataFrame(player_stats, columns=headerlist1)
    pd.DataFrame.to_excel(stats, f"C:\\Users\\mccar\\OneDrive\\Documents\\NBA PLAYOFF ADVANCED STATS\\NBAPLAYOFFSTATS{season}.xlsx")
    print(f"{season} is downloaded to an excel workbook")
    