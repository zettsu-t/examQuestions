#!/usr/bin/python3
# coding: utf-8

'''
This script tests the comment extractor language_ratings.py
Copyright (C) 2017 Zettsu Tatsuya

usage : python3 -m unittest discover tests
'''

import os
from unittest import TestCase
from unittest.mock import Mock
from bs4 import BeautifulSoup
import ratings.language_ratings as tested

EMPTY_ARGUMENTS = [''] * 4
TEST_CSV_TEXT = tested.CSV_HEADER + '2,C,8.5\n' + '15,R,1.5\n'
TEST_R_SCRIPT_FILENAME = 'ratings/' + tested.RSCRIPT_BASENAME


class TestLanguageRatings(TestCase):
    '''Testing class LanguageRatings'''

    def test_initialize(self):
        '''Testing the constructor'''

        arguments = ['', 'HtmlFilename', 'TableFilename', 'PngFilename']
        ratings = tested.LanguageRatings(arguments)
        self.assertEqual(ratings.html_path, arguments[1])
        self.assertEqual(ratings.table_filename, arguments[2])
        self.assertEqual(ratings.png_filename, arguments[3])

    def test_generate(self):
        '''Testing the constructor'''

        table_filename = '__tmp_table.txt'
        table_text = '1st\n2nd\n3rd\n'

        arguments = ['', 'HtmlFilename', table_filename, 'PngFilename']
        ratings = tested.LanguageRatings(arguments)

        ratings.fetch = Mock()
        ratings.parse_file = Mock()
        ratings.make_table = Mock()
        ratings.make_table.return_value = ('', table_text)
        ratings.make_chart = Mock()
        self.assertEqual(ratings.generate(), tested.EXIT_STATUS_SUCCESS)

        with open(table_filename, 'r') as file:
            actual = ''.join(file.readlines())
            self.assertEqual(actual, table_text)

    def test_get_unique_name(self):
        '''Testing a unique language for similar names'''

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        cases = ['visual basic', 'Visual Basic',
                 'VisualBasic', ' VISUALBASIC ']
        for name in cases:
            actual = ratings.get_unique_name(name)
            self.assertEqual(actual, 'visualbasic')

    def test_parse_file_3elements(self):
        '''Testing to parse a row with three elements'''

        table_text = '<tr><td>1</td><td> A B </td><td>9.5</td></tr>'
        expected = ['ab', 1, 'A B', 9.5]

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        soup = BeautifulSoup(table_text, 'lxml')
        actual = ratings.parse_file(soup)
        self.assertEqual(actual, [expected])

    def test_parse_file_6elements(self):
        '''Testing to parse a row with six elements'''

        table_text = '<tr><td>1</td><td>x</td><td>y</td>' \
                     '<td>A B</td><td>9.5</td><td>z</td></tr>'
        expected = ['ab', 1, 'A B', 9.5]

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        soup = BeautifulSoup(table_text, 'lxml')
        actual = ratings.parse_file(soup)
        self.assertEqual(actual, [expected])

    def test_parse_file_rows(self):
        '''Testing to parse rows in a HTML document'''

        table_text = '<tr><td>1</td><td>A B</td><td>9.5</td></tr>' \
                     '<tr><td>1</td><td>x</td><td>y</td>' \
                     '<td> Cde </td><td>6.25</td><td>z</td></tr>'
        expected = [['ab', 1, 'A B', 9.5], ['cde', 1, 'Cde', 6.25]]

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        soup = BeautifulSoup(table_text, 'lxml')
        actual = ratings.parse_file(soup)
        self.assertEqual(actual, expected)

    def test_parse_file_invalid(self):
        '''Testing to ignore invalid HTML elements'''

        table_text = '<tr><td>x1</td><td>B1</td><td>0.5</td></tr>' \
                     '<tr><td>2</td><td>B2</td><td>x0.5</td></tr>' \
                     '<tr><td>4</td><td>B3</td><td>0.5</td></tr>'
        expected = ['b3', 4, 'B3', 0.5]

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        soup = BeautifulSoup(table_text, 'lxml')
        actual = ratings.parse_file(soup)
        self.assertEqual(actual, [expected])

    def test_make_table_empty(self):
        '''Testing to make a empty language table'''

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        partial_table, full_table = ratings.make_table([])
        self.assertEqual(partial_table, tested.CSV_HEADER)
        self.assertTrue(full_table.startswith(tested.MARKDOWN_HEADER))

        def make_row(name):
            '''Retuns a row string for the table'''

            return '|-|{0}|||\n'.format(name)

        expected = tested.MARKDOWN_HEADER
        expected += ''.join(map(make_row, tested.LANGUAGE_SET))
        self.assertTrue(full_table.startswith(expected))

    def test_make_table(self):
        '''Testing to make a language table'''

        languages = [['c', 2, 'C', 8.5],
                     ['r', 15, 'R', 1.5],
                     ['d', 30, 'D', 0.5]]

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        partial_table, full_table = ratings.make_table(languages)
        self.assertGreater(partial_table.find('2,C,8.5'), 0)
        self.assertGreater(partial_table.find('15,R,1.5'), 0)
        self.assertEqual(partial_table.find('D,'), -1)
        self.assertGreater(full_table.find('|2|C|8.500|8.500'), 0)
        self.assertGreater(full_table.find('|15|R|1.500|10.000'), 0)
        self.assertEqual(full_table.find('|D|'), -1)

    def test_make_chart(self):
        '''Testing to make a chart'''

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        table_filename = '__tmp_table.txt'
        png_filename = '__tmp_chart.png'
        try:
            ratings.make_chart(TEST_CSV_TEXT, table_filename,
                               png_filename, TEST_R_SCRIPT_FILENAME)
            self.assertGreater(os.stat(table_filename).st_size, 0)
            self.assertGreater(os.stat(png_filename).st_size, 0)
        finally:
            os.remove(table_filename)
            os.remove(png_filename)

    def test_make_chart_no_csv(self):
        '''Testing to fail in creating a CSV file'''

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        with self.assertRaises(FileNotFoundError):
            ratings.make_chart(tested.CSV_HEADER,
                               '_invalid_path_/__tmp_table.txt',
                               '__tmp_chart.png', TEST_R_SCRIPT_FILENAME)

    def test_make_chart_no_r_script(self):
        '''Testing to fail in launching a R script'''

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        table_filename = '__tmp_table.txt'
        try:
            with self.assertRaises(tested.ErrorInR):
                rscript_name = '_invalid_path_/' + tested.RSCRIPT_BASENAME
                ratings.make_chart(tested.CSV_HEADER, table_filename,
                                   '__tmp_chart.png', rscript_name)
        finally:
            os.remove(table_filename)

    def test_make_chart_r_failed(self):
        '''Testing to fail in making a chart'''

        ratings = tested.LanguageRatings(EMPTY_ARGUMENTS)
        table_filename = '__tmp_table.txt'
        png_filename = '_invalid_path_/__tmp_chart.png'
        try:
            with self.assertRaises(tested.ErrorInR):
                ratings.make_chart(TEST_CSV_TEXT, table_filename,
                                   png_filename, TEST_R_SCRIPT_FILENAME)
        finally:
            os.remove(table_filename)
