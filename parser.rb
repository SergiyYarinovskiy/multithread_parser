$LOAD_PATH << Dir.pwd

require 'nokogiri'
require 'open-uri'
require 'hotline_parser'

URL = 'http://hotline.ua/dacha_sad/cepnye-pily/'
HOST = 'http://hotline.ua'

parser = HotlineParser::PageParser.new(URL, HOST)
parser.parse
