#    WESB - Wmfs extensible status bar
#
#    Copyright (C) 2011  Clement Sipieter <c.sipieter@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys    
import core.util as util
from core.OOptions import Options
from nltk.stem.lancaster import LancasterStemmer
from nltk.stem.porter import PorterStemmer
from nltk.stem.snowball import SnowballStemmer
from nltk.stem.wordnet import WordNetLemmatizer

###########################
#  FUNCTIONS              #
###########################

def stemFile(path, st):
  
  tokens = util.tokenizeFile(path)
  
  for i in range(0,  len(tokens)):
    if tokens[i] == "\n":
      print 
    else:
      print st.stem(tokens[i].lower()),

  


##############################
#  MAIN                      #
##############################




##############################
# ARGUMENT PROCESSING
conf_path = ""

usage= "hum, I do an help. Sorry..."
oo = Options( sys.argv, usage )

oo.add( 's', 'stemmer','stemming method', '' ) 
args = oo.parse()

stemmer = oo.get('stemmer')
if stemmer == 'lancaster' : 
  print >> sys.stderr , "lancaster"
  st = LancasterStemmer()
elif stemmer == 'porter':
  print >> sys.stderr , "porter"
  st = PorterStemmer()
elif stemmer == 'snowball':
  print >> sys.stderr , "snowball"
  st = SnowballStemmer("english")
elif stemmer == 'wordnet':
  print >> sys.stderr , "wordnet"
  st = WordNetLemmatizer()


while args :
  conf_path = args.pop()
 

if(len(conf_path) == 0):
  print "not file specified"

if(len(stemmer) == 0):
  tokens = util.tokenizeFile(conf_path)
  
  for i in range(0,  len(tokens)):
    if tokens[i] == "\n":
      print 
    else:
      print tokens[i],
else:
  stemFile(conf_path, st)





