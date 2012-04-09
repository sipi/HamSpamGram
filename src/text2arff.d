import std.stdio;
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

void main()
{
  
}


