#!/usr/bin/python3
# coding: utf-8

'''
This script
- reads the TIOBE index from a local file or via Internet
- writes a table for languages and,
- draws a parete chart by R

usage (to parse a local HTML file)
$ python3 language_ratings.py html-filename csv-filename png-filename
- html-filename (input) : a local HTML file
- csv-filename (output) : a CSV file that contains the TIOBE index rating
  for selected languages
- png-filename (output) : a parete chart for the table

usage (to read TIOBE official website)
$ python3 language_ratings.py web csv-filename png-filename

Copyright (C) 2017 Zettsu Tatsuya
'''

import subprocess
import sys
from collections import OrderedDict
import requests
from bs4 import BeautifulSoup

# Programming languages to extract TIOBE index ratings
LANGUAGE_SET = ['Ruby', 'JavaScript', 'Java', 'C#', 'Visual Basic .NET',
                'Perl', 'Python', 'Groovy', 'Scala', 'Bash',
                'C++', 'C', 'Assembly language', 'Haskell',
                'Elixir', 'Erlang',
                'PHP', 'Clojure', 'Scheme', 'OCaml', 'F#', 'Rust',
                'Makefile', 'Kuin']

# If a HTML filename is same as the special keyword,
# this script downloads from the URL instead of reading a local file.
REMOTE_KEYWORD = 'web'
REMOTE_URL = 'https://www.tiobe.com/tiobe-index/'

# Usage
USAGE_TEXT = 'usage : python3 language_ratings.py (html-filename|web) csv-filename png-filename'

# Exit status for make
EXIT_STATUS_SUCCESS = 0
EXIT_STATUS_ERROR = 1

class ErrorInR(Exception):
    '''Tells a runtime error which occurred in R'''
    pass

class LanguageRatings():
    '''Makes a table for a subset of languages from the TIOBE index'''

    def __init__(self, command_line_arguments):
        self.html_path = command_line_arguments[1]
        self.csv_filename = command_line_arguments[2]
        self.png_filename = command_line_arguments[3]

    def generate(self):
        '''Generates a chart and csv file from a HTML document'''

        soup = self.fetch(self.html_path)
        partial_table, full_table = self.make_table(self.parse_file(soup))
        self.make_chart(partial_table, self.csv_filename, self.png_filename)
        with open(self.csv_filename, 'w') as file:
            file.write(full_table)

        return EXIT_STATUS_SUCCESS

    @staticmethod
    def fetch(html_path):
        '''Downloads or loads a HTML document'''

        if html_path == REMOTE_KEYWORD:
            html_response = requests.get(REMOTE_URL)
            html_text = html_response.text
        else:
            html_text = open(html_path)

        return BeautifulSoup(html_text, 'html.parser')

    @staticmethod
    def get_unique_name(name):
        '''Returns a unique name for a language'''

        return name.replace(' ', '').lower()

    def parse_file(self, soup):
        '''Parses a HTML document that contains a TIOBE index table'''

        languages = []

        # Parses HTML table tags
        for tr_tag in soup.find_all('tr'):
            td_tags = tr_tag.find_all('td')
            columns = []

            # Popular languages
            if len(td_tags) == 6:
                columns = [0, 3, 4]
            elif len(td_tags) == 3:
                columns = [0, 1, 2]
            else:
                continue

            try:
                rank = int(td_tags[columns[0]].string)
                language = td_tags[columns[1]].string
                ratings = float(td_tags[columns[2]].string.replace('%', ''))
                name = self.get_unique_name(language)
                languages.append([name, rank, language, ratings])
            except ValueError:
                pass

        return languages

    def make_table(self, languages):
        '''Makes a markdown table'''

        partial_table = 'TIOBE index rank,Programming Language,Ratings[%]\n'
        full_table = '|TIOBE index rank|Programming Language'
        full_table += '|Ratings[%]|Cumulative Ratings[%]|\n'
        full_table += '|:--|:------|:------|:------|\n'
        cumulative_ratings = 0.000

        # Keep an order for languages not ranked
        language_map = OrderedDict()
        for language in LANGUAGE_SET:
            name = self.get_unique_name(language)
            language_map[name] = language

        for name, rank, language, ratings in languages:
            if name in language_map:
                cumulative_ratings += ratings
                partial_table += '{0},{1},{2:f}\n'. \
                                 format(rank, language, ratings)
                full_table += '|{0}|{1}|{2:5.3f}|{3:5.3f}|\n'. \
                              format(rank, language, ratings, cumulative_ratings)
                language_map[name] = ''

        for _, language in language_map.items():
            if language:
                full_table += '|-|{0:s}|||\n'.format(language)

        return partial_table, full_table

    @staticmethod
    def make_chart(partial_table, csv_filename, png_filename):
        '''Makes a parete chat by R'''

        # If it succeeded, overwrite the CSV file later.
        with open(csv_filename, 'w') as file:
            file.write(partial_table)

        arguments = ['Rscript', 'language_ratings.R', '--args',
                     csv_filename, png_filename]
        result = subprocess.run(arguments)

        if result.returncode:
            raise ErrorInR

        return None

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(USAGE_TEXT)
        sys.exit(EXIT_STATUS_ERROR)

    sys.exit(LanguageRatings(sys.argv).generate())
