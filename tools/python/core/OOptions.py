# !/bin/env python
# -*- coding: utf-8 -*-


import sys,os 
import getopt 
import ConfigParser

class Options :
    def __init__(self, argv, usage = "", app_name = None ) :
	self.options = {}
	self.argv = argv

	if app_name : 
	    self.app_name = app_name 
	else : # si aucun nom n'est précisé, on l'extrait de l'argv, mais sans l'extension
	    self.app_name = os.path.splitext( os.path.basename( argv[0] ) )[0]

	# Message à afficher en cas de mauvaise utilisation des options 
	usage += "\nUsage : %s [OPTIONS] arguments" % self.app_name 
	self.usage = usage


    def __configure_file( self, filename, section='DEFAULT' ) : 
	# prend les valeurs indiquées dans le fichier de configuration 
	config = ConfigParser.ConfigParser()

	try : 
	    config.readfp( open( filename ) )
	except : 
	    return

	# Pour chaque option prévue 
	for o in self.options : 
	    try : 
		# essaye de la lire dans le fichier de conf 
		a = config.get(section,o)

		# si c'est un flag
		if self.options[o]['flag'] == True :
		    # il faut convertir en booléen 
		    self.options[o]['value'] = bool( eval( a ) ) 
		else : 
		    # sinon c'est un string 
		    self.options[o]['value'] = a

		# on ajoute que ce fichier de conf a changé la valeur
		self.options[o]['origin'] = filename

	    except : 
		pass


    def __configure_command( self ) : 
	# construction de la chaine argument pour getopt
	gos_short = ''
	gos_long = []

	for o in self.options : 
	    opt = self.options[o]

	    # getopt demande deux chaines pour les typographies longues et courtes 
	    gos_short += opt['short'] 
	    _gos_long  = opt['long']

	    # si l'option prend un paramètre
	    if not opt['flag'] : 
		gos_short += ':' 
		_gos_long += '='

	    gos_long += [ _gos_long ]


	# parse la ligne de commande 
	try :
	    opts, args = getopt.getopt( self.argv[1 :], gos_short, gos_long ) 
	except getopt.GetoptError : 
	    print 'Unkown option' 
	    self.print_usage() 
	    sys.exit(2)

	s2l = {} # associations court :long

	for o in self.options : 
	    short = self.options[o]['short'] 
	    # lève une erreur si l'option courte a déjà été déclarée 
	    if short in s2l : 
		raise "Short option '%s' already declared for the options '%s', please use another letter for the option '%s'." % (short, s2l[short], o ) 
	    s2l[ self.options[o]['short'] ] = self.options[o]['long']

        # prend les valeurs indiquées sur la ligne de commande
	for o,a in opts : 
	    # court => on enlève un tiret 
	    os = o[1 :] 
	    # long => on enlève deux tirets
	    ol = o[2 :]

	    # si c'est une option courte 
	    if os in s2l : 
		# si c'est un flag 
		if self.options[ s2l[os] ]['flag'] : 
		    # demandé => vrai
		    self.options[ s2l[os] ]['value'] = True 
		else : 
		    # prend la valeur indiquée 
		    self.options[ s2l[os] ]['value'] = a

		self.options[ s2l[os] ]['origin'] = 'command line' 
		
	    # si c'est une option longue
	    elif ol in self.options : 
		if self.options[ol]['flag'] : 
		    self.options[ ol ]['value'] = True 
		else : 
		    self.options[ol]['value'] = a 

		self.options[ol]['origin'] = 'command line'

	# retourne tout ce qui n'a pas été parsé
	return args


    def parse(self, profile = 'DEFAULT') : 
	# on essaye d'abord le fichier de conf général 
	self.__configure_file( './%s.conf' % self.app_name, profile )

	# puis on essaye le fichier de conf utilisateur 
	self.__configure_file( os.path.join( os.path.expanduser(' '), '.%s.conf' % self.app_name ), profile )

	# enfin, la ligne de commande
	args = self.__configure_command()

	return args


    def add( self, short, long, description, default='' ) : 
	flag = False 
	if default==True or default==False : 
	    flag = True
    
	# si l'option est déjà présente
	if long in self.options : 
	    raise "Long option '%s' already declared, please use another one." % long 
	else : 
	    self.options [ long ] = {
		'short' :short, # identifiant court (une lettre)
		'long' :long, # identifiant long 
		'description' :description, # texte de description 
		'origin' :'hard coded', # source de la valeur
		'flag' :flag, # indicateur de flag 
		'value' :default # valeur de l'option
	    }


    def print_usage(self) : 
	print self.usage

	for o in self.options : 
	    fs = "\t-%s, --%s\t\t%s" 
	    
	    # si pas un flag, indique qu'il faut un paramètre
	    if not self.options[o]['flag'] : 
		fs = "\t-%s, --%s\t=VAL\t%s" 
	    
	    print fs % ( self.options[o]['short'], self.options[o]['long'], self.options[o]['description'] )


    def print_state(self) : 
	print "Options settings :","option='value' (origin)"
	for o in self.options :
	    print "\t%s='%s'\t(%s)" % ( self.options[o]['long'], self.options[o]['value'], self.options[o]['origin'] )

    def get( self, long ) : 
	return self.options[long]['value'] 

