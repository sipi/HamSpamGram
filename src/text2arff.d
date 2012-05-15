import std.stdio;
import std.ascii;
import std.utf;
import std.conv;
import std.string;

unittest
{
  string[] words = getWords(
      "Juste un test, pour voir si ça à l'air de fonctioner.");
  assert(words.length == 12);
}

const int STDIN_END = 0;
const int INDEX_TOTAL = 0;
const bool SPAM = true;
const bool HAM = false;

string[] getWords(string doc, bool with_ponctuation = false)
{

  enum
  {
    SEARCH_WORD,
    IN_WORD,
    ON_UTF_CHAR
  }

  string[] words;
  int nb_words = 0;
  int deb = 0, fin = 0;
  int state = 0;
  char c;

  for(int i = 0; i < doc.length; ++i)
    {
      c = doc[i];
      switch(state)
        {
          case SEARCH_WORD:
            if(isPunctuation(c))
              {
                if(with_ponctuation)
                {
                  words.length = words.length + 1;
                  words[nb_words++] = text("c_",cast(short)doc[i]);
                }
              }
            else if(isAlpha(c))
              {
                deb = i;
                state = IN_WORD;
              }
            else if(c > 128)
              {
                deb = i;
                state = ON_UTF_CHAR;
              }
          break;
          case IN_WORD:
            if(c < 128 && !isAlpha(c) && c != '-')
              {
                fin = i;
                words.length = words.length + 1;
                words[nb_words++] = text("w_", doc[deb .. fin]);
                state = SEARCH_WORD;
                --i;
              }
            else
              {
                if(c >= 128)
                  state = ON_UTF_CHAR;
              }
          break;
          case ON_UTF_CHAR:
            state = IN_WORD;
          break;
          default:
          break;

        }

    }

  if(state == 1)
    {
      fin = cast(int) (doc.length) - 1;
      words.length = words.length + 1;

      words[nb_words++] = text("w_", doc[deb .. fin]);
    }

  return words;

}

void word_count(string[] word_list, ref uint[string] general_dictionnary,
    ref uint[string] dictionnary)
{
  string word;
  for(uint i = 0; i < word_list.length; ++i)
    {
      word = word_list[i].toLower();
      ++dictionnary[word.idup];
      
      if(dictionnary[word] == 1)
        ++general_dictionnary[word.idup];
    }

}

void print_arff_relation(ref uint[string] dictionnary)
{
  writeln("@relation corpus"); 
  foreach(word; dictionnary.keys)
    writeln("@attribute ",word," numeric");
  
  writeln("@attribute CLASS {SPAM,HAM}");
}

void print_arff_term_frequency(ref uint[string][] dictionnaries, bool[] doc_class)
{
  print_arff_relation(dictionnaries[INDEX_TOTAL]);
  
  writeln("@data");
  for(int index_doc = 1; index_doc < dictionnaries.length; ++index_doc)
  {
    foreach(string word; dictionnaries[INDEX_TOTAL].keys)
      write(dictionnaries[index_doc].get(word,0),",");
    
    if(doc_class[index_doc] == SPAM)
      write("SPAM");
    else
      write("HAM");
    
    write("\n");
  }
}

void print_arff_boolean(ref uint[string][] dictionnaries, bool[] doc_class)
{
  writeln("@relation corpus"); 
  foreach(word; dictionnaries[INDEX_TOTAL].keys)
    writeln("@attribute ",word," {0, 1}");
  
  writeln("@attribute CLASS {SPAM,HAM}");  
  writeln("@data");
  for(int index_doc = 1; index_doc < dictionnaries.length; ++index_doc)
  {
    foreach(string word; dictionnaries[INDEX_TOTAL].keys){
      if(dictionnaries[index_doc].get(word,0) > 0)
        write("1,");
      else
        write("0,");
    }
    
    if(doc_class[index_doc] == SPAM)
      write("SPAM");
    else
      write("HAM");
    
    write("\n");
  }
}

void print_arff_tf_idf(ref uint[string][] dictionnaries, bool[] doc_class, 
    int nbr_doc)
{
  print_arff_relation(dictionnaries[INDEX_TOTAL]);
  
  writeln("@data");
  for(int index_doc = 1; index_doc < dictionnaries.length; ++index_doc)
  {
    foreach(string word; dictionnaries[INDEX_TOTAL].keys)
    {
      float tfidf = cast(float)(dictionnaries[index_doc].get(word,0)) * 
        (cast(float)(nbr_doc) / cast(float)(dictionnaries[INDEX_TOTAL][word]));
      
      write(tfidf,",");
    }
    
    if(doc_class[index_doc] == SPAM)
      write("SPAM");
    else
      write("HAM");
    
    write("\n");
  }
}



void print(ref uint[string][] dictionnaries, bool[] doc_class)
{
  //affichage
  for(int index_doc = 0; index_doc < dictionnaries.length; ++index_doc)
  {
    foreach(string word; dictionnaries[index_doc].keys)
      write(word," ");
    
    if(doc_class[index_doc] == SPAM)
      write("SPAM");
    else
      write("HAM");
    
    writeln();
  }
}

void main(string[] options)
{

  uint[string][] dictionnaries;
  bool[] doc_class;
  dictionnaries.length = 1;
  doc_class.length = 1;
  uint num_doc = 0;
  string doc;

  
  while(stdin.readln(doc) != STDIN_END)
    {
      ++(dictionnaries.length);
      ++(doc_class.length);
      ++num_doc;
      
      string[] words = getWords(doc, true);
      
      //classification of spam or ham base on last word
      if(words[words.length-1] == "spam")
        doc_class[num_doc] = SPAM;
      else
        doc_class[num_doc] = HAM;
            
      --(words.length); 
      
      word_count(words, dictionnaries[INDEX_TOTAL],
          dictionnaries[dictionnaries.length-1]);   
    }
  
  
  if(options.length > 1)
  {
    switch(options[1][1])
    {
      case 'b':
        print_arff_boolean(dictionnaries, doc_class);
        break;
      case 't':
        print_arff_term_frequency(dictionnaries, doc_class);
        break;
      default:
        print_arff_tf_idf(dictionnaries, doc_class, num_doc);
    }
    
  }
  else
  {
    print_arff_tf_idf(dictionnaries, doc_class, num_doc);
  }

}
