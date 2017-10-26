#!/usr/bin/python3
# coding: utf-8

'''
This script
- reads the TIOBE index from a local file or via Internet
- writes a markdown table for languages and,
- draws a parete chart by R

usage (to parse a local HTML file)
$ python3 language_ratings.py html-filename table-filename png-filename
- html-filename (input) : a local HTML file
- table-filename (output) : a markdown table file that contains the TIOBE
  index rating for selected languages
- png-filename (output) : a parete chart for the table

usage (to read TIOBE official website)
$ python3 language_ratings.py web table-filename png-filename

Copyright (C) 2017 Zettsu Tatsuya
'''

import subprocess
import sys
from collections import OrderedDict
import requests
from bs4 import BeautifulSoup

# Programming languages to extract TIOBE index ratings
LANGUAGE_SET = ['Ruby', 'JavaScript', 'Java', 'C#', 'Visual Basic .NET',
                'Perl', 'Python', 'Groovy', 'Scala', "R", 'Bash',
                'C++', 'C', 'Assembly language', 'Haskell',
                'Elixir', 'Erlang',
                'PHP', 'Clojure', 'Scheme', 'OCaml', 'F#', 'Rust',
                'Makefile', 'Kuin']

# If a HTML filename is same as the special keyword,
# this script downloads from the URL instead of reading a local file.
REMOTE_KEYWORD = 'web'
REMOTE_URL = 'https://www.tiobe.com/tiobe-index/'

# Usage
USAGE_TEXT = 'usage : python3 language_ratings.py (html-filename|web) table-filename png-filename'

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
        self.table_filename = command_line_arguments[2]
        self.png_filename = command_line_arguments[3]

    def generate(self):
        '''Generates a chart and a markdown table file from a HTML document'''

        soup = self.fetch(self.html_path)
        partial_table, full_table = self.make_table(self.parse_file(soup))
        self.make_chart(partial_table, self.table_filename, self.png_filename)
        with open(self.table_filename, 'w') as file:
            file.write(full_table)

        return EXIT_STATUS_SUCCESS

    @staticmethod
    def fetch(html_path):
        '''Downloads or loads a HTML document'''

        if html_path == REMOTE_KEYWORD:
            # Set environment variables HTTP_PROXY and HTTPS_PROXY
            # to use HTTP proxies.
            # To avoid 'certificate verify failed', set verify=False
            html_response = requests.get(REMOTE_URL, verify=False)
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
    def make_chart(partial_table, table_filename, png_filename):
        '''Makes a parete chat by R'''

        # Creates a CSV file of which name is table_filename
        # If it succeeded, overwrite the file later.
        # If it failed, the CSV file remains and can be checekd in debugging.
        with open(table_filename, 'w') as file:
            file.write(partial_table)

        arguments = ['Rscript', 'language_ratings.R', '--args',
                     table_filename, png_filename]
        result = subprocess.run(arguments)

        if result.returncode:
            raise ErrorInR

        return None

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print(USAGE_TEXT)
        sys.exit(EXIT_STATUS_ERROR)

    sys.exit(LanguageRatings(sys.argv).generate())
