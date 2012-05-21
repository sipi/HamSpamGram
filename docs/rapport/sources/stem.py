
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
# END ARGUMENT PROCESSING

# si le stemmer n'est pas défini on affiche 
# la liste des tokens
if(len(stemmer) == 0):
  tokens = util.tokenizeFile(conf_path)
  
  for i in range(0,  len(tokens)):
    if tokens[i] == "\n":
      print 
    else:
      print tokens[i],
else:
# lémmatisation
  stemFile(conf_path, st)





