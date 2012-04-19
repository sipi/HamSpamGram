import std.stdio;
import std.file;
import std.ascii;
import std.utf;
import std.cstream;
import std.conv;
import std.string;

unittest 
{ 
  string[] words = getWords("Juste un test, pour voir si ça à l'air de fonctioner.");
  assert(words.length == 12);
}

string[] getWords(string text)
{
  
  enum { SEARCH_WORD, IN_WORD, ON_UTF_CHAR }
  
  string[] words;
  int nb_words = 0;
  int deb = 0, fin = 0;
  int state=0;
  char c;

  for(int i=0; i < text.length; ++i)
  {
    c = text[i];
    switch(state)
    {
      case SEARCH_WORD:
        if(isPunctuation(c))
        {
        }
        else if(isAlpha(c))
        { 
          deb=i;
          state=IN_WORD;
        }
        else if(c>128)
        {
          deb=i;
          state=ON_UTF_CHAR;     
        }
        break;
      case IN_WORD:
        if(c<128 && !isAlpha(c) && c != '-')
        {
          fin = i;
          words.length = words.length + 1;
          words[nb_words++] = text[deb..fin];
          state=SEARCH_WORD;
          --i;
        }
        else
        {
          if(c>=128)
            state=ON_UTF_CHAR;
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
    fin = cast(int)(text.length) - 1;
    words.length = words.length + 1;

    words[nb_words++] = text[deb..fin];
  }
    
  return words;

}

void word_count(string[] word_list, ref uint[string] dictionnary)
{
  for(uint i = 0; i < word_list.length; ++i)
  {
    ++dictionnary[word_list[i].toLower().idup];
  }

}

void main(string[] files)
{
  uint num_file = 0;
  uint[string][] dictionnaries;
  dictionnaries.length = files.length;
  
  foreach(string file; files)
  {
    //saute le nom du program
    if(num_file == 0)
    {
      ++num_file;
      continue;
    }          
    
    string[] words = getWords(cast(string)read(file));

    word_count(words, dictionnaries[num_file]);

    writeln(dictionnaries[num_file].length);
    foreach(word; dictionnaries[num_file].keys)
      writeln(word," - ",dictionnaries[num_file][word]);
    
    ++num_file;

  }
  
 
  
}


