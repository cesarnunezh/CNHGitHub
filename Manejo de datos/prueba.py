import pandas as pd
import requests
from bs4 import BeautifulSoup as bs

url = 'https://www.soccerbase.com/teams/home.sd'
r = requests.get(url)
soup = bs(r.content, 'html.parser')
teams = soup.find('div', {'class': 'headlineBlock'}, text='Team').next_sibling.find_all('li')

teams_dict = {}
for team in teams:
    link = 'https://www.soccerbase.com' + team.find('a')['href']
    team = team.text

    teams_dict[team] = link


team = []
comps = []
dates = []
h_teams = []
a_teams = []
h_scores = []
a_scores = []

consolidated = []
for k, v in teams_dict.items():
    print('Acquiring %s data...' % k)

    headers = ['Team', 'Competition', 'Home Team', 'Home Score', 'Away Team', 'Away Score', 'Date Keep']
    r = requests.get('%s&teamTabs=results' % v)
    soup = bs(r.content, 'html.parser')

    h_scores.extend([int(i.text) for i in soup.select('.score a em:first-child')])
    limit_scores = [int(i.text) for i in soup.select('.score a em + em')]
    a_scores.extend([int(i.text) for i in soup.select('.score a em + em')])

    limit = len(limit_scores)
    team.extend([k for i in soup.select('.tournament', limit=limit)])
    comps.extend([i.text for i in soup.select('.tournament a', limit=limit)])
    dates.extend([i.text for i in soup.select('.dateTime .hide', limit=limit)])
    h_teams.extend([i.text for i in soup.select('.homeTeam a', limit=limit)])
    a_teams.extend([i.text for i in soup.select('.awayTeam a', limit=limit)])



df = pd.DataFrame(list(zip(team, comps, h_teams, h_scores, a_teams, a_scores, dates)),
                  columns=headers)