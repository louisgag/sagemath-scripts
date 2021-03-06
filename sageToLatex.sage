# copyright Louis Gagnon 2017 under GNU GPL 3.0
# this file is an extended version of the one provided by Thorsten here: https://ask.sagemath.org/question/25820/how-can-i-print-equations-just-like-latex/?answer=25855#post-id-25855
# **********************************************************************
# THIS SCRIPT ALLOWS TO COPY AND PASTE SAGEMATH SYMBOLIC EXPRESSION NOTATION
# AND HAVE IT DIRECTLY CONVERTED TO LATEX NOTATION
# **********************************************************************
# this way, one can more easily keep a Latex document updated from a SageMath worksheet
#
# LATEX PACKAGES REQUIRED:
# *) add the following two lines, uncommented, to the header of you main Latex file if theses packages are not already declared:
# \usepackage{esdiff} % for non-italic derivatives
# \usepackage{breqn} % automatic linebreaks for eqns
#
# INSTRUCTIONS:
#
# 1) paste this whole file somewhere near the beginning of your worksheet and uncomment the following line to set the boolean printArticle as such:
#printArticle = bool(1) # enable if want to print the text and equations for the article
#
# 2) in your document, include, where desired, the following string additions:
#if (printArticle):
#   latexPrint += 'YOUR TEXT,' + get_expression('derivative(x/b + 5 + sqrt(3/b),x)', isEqn=bool(1))
#
# 3) at the end of your document create the Latex file that you can then include (ex: \input{myEqns.tex}) in your master Latex document:
#if (printArticle):
#    fLATEX=open('myEqns.tex','w')
#    fLATEX.write(latexPrint)
#    fLATEX.close()
#
#
if (printArticle):
   import re # for re.sub commands (which works with regexp)
   def parenthesis_match(prefix,preNum,theStr): # preNum is the number of already open parenthesis (ie: go beyond normal closure by preNum)
      matches = []
      while (theStr.find(prefix) != -1):
          p = -1-preNum
          for li in [theStr.find(prefix)+len(prefix)..len(theStr)-1]:
              if theStr[li] == '(':
                p -=1
              if theStr[li] == ')':
                p += 1
              if p==0:
                 matches.append(theStr[theStr.find(prefix)+len(prefix):li])
                 break
          theStr = theStr[li:]
      return matches
   def get_expression(theStr,isEqn): # customized for my own purpose, isEqn can beel bool or eqn label
      theStr = re.sub('([0-9.]+)\*([0-9.]+)',r'\1 \cdot \2',theStr)
      theStr = re.sub('([a-zA-Z0-9\._\^]+)/([a-zA-Z0-9_\.\^]+)',r'subBackslashfrac{\1}{\2}',theStr)
      theStr = theStr.replace('*',' ')
      for i in range(1,3):
          theStr = theStr.replace('  ',' ')
      theStr = re.sub('([^a-zA-Z0-9_]|^)pi([^a-zA-Z0-9_]|$)',r'\1subBackslashpi\2',theStr) ## NOTE: this prevents replacement of pi in subscripts (_) because in my code _pi means the percent infill subscript
      rrr = r'([^a-zA-Z0-9]|^)([aA]lpha|[bB]eta|[gG]amma|[dD]elta|[eE]psilon|[zZ]eta|[eE]ta|[tT]heta|[iI]ota|[kK]appa|Lambda|[mM]u|[nN]u|[xX]i|[oO]micron|[rR]ho|[sS]igma|[tT]au|[uU]psilon|[Pp]hi|[cC]hi|[pP]si|[oO]mega|sin|cos|tan)([^a-zA-Z0-9]|$)' # scanning for greek letter names and trig functions not part of a longer word but possibly at beginning or end of string
      while (re.search(rrr,theStr)): # looping until there are no longer such greek letter names
          theStr = re.sub(rrr,r'\1subBackslash\2\3',theStr)
      theStr = theStr.replace('Lambda','lambda')
      rrr = r'([^a-zA-Z0-9]|^)a(cos|sin|tan|sec)([^a-zA-Z0-9]|$)' # scanning for arc trig functions not part of a longer word but possibly at beginning or end of string
      while (re.search(rrr,theStr)): # looping until there are no longer such greek letter names
          theStr = re.sub(rrr,r'\1subBackslash\2^{-1}\3',theStr)
      for iz in range(1,3): # set upper range to maximum+1 expect embeded integrals
          skipOut = bool(0)
          for sr in parenthesis_match('integrate(',0,theStr):
              for it2 in parenthesis_match('integrate(',0,sr):
                  sr2 = re.sub('([^,]+),([^,]+),([^,]+),([^,]+)',r'^{\4}_{\3}\1 d\2',it2)
                  theStr = theStr.replace('integrate('+it2+")",'\int'+sr2)
                  skipOut = bool(1)
              if (not skipOut):
                  sr2 = re.sub('([^,]+),([^,]+),([^,]+),([^,]+)',r'^{\4}_{\3}\1 d\2',sr)
                  theStr = theStr.replace('integrate('+sr+")",'\int'+sr2)
      for sr in parenthesis_match('derivative(derivative(',1,theStr): # identifies double derivs with identical inner derivs
          srsr = sr.split(',') # divide comma separated string
          srpr = srsr[len(srsr)-2] # second to last comma separated string
          if (srpr[0:-1]) == (srsr[len(srsr)-1]): # ensures we have first and second derivatives equal
              theStr2 = '\diff[2]{' + srsr[len(srsr)-3] + '}{' + srpr[0:-1] + '}'
              theStr = theStr.replace('derivative(derivative('+sr+")",theStr2)
      for iz in range(1,3): # set upper range to maximum+1 expect embeded derivatives
          skipOut = bool(0)
          for sr in parenthesis_match('derivative(',0,theStr):
              for it2 in parenthesis_match('derivative(',0,sr):
                  sr2 = re.sub('([^,]+),([^,]+)',r'{\1}{\2}',it2)
                  theStr = theStr.replace('derivative('+it2+")",'\diff'+sr2)
                  skipOut = bool(1)
              if (not skipOut):
                  sr2 = re.sub('([^,]+),([^,]+)',r'{\1}{\2}',sr)
                  theStr = theStr.replace('derivative('+sr+")",'\diff'+sr2)
      for sr in parenthesis_match('sqrt(',0,theStr):
          theStr = theStr.replace('sqrt('+sr+")",'\sqrt{'+sr+'}')      
      for sr in parenthesis_match('abs(',0,theStr):
          theStr = theStr.replace('abs('+sr+")",'\\lvert'+sr+'\\rvert') # requires \usepackage{mathtools} and \DeclarePairedDelimiter\abs{\lvert}{\rvert}% in the Latex header
      for sr in parenthesis_match('^(',0,theStr):
          theStr = theStr.replace('^('+sr+")",'^{'+sr+'}')
      for sr in parenthesis_match('exp(',0,theStr):
          theStr = theStr.replace('exp('+sr+")",'e^{'+sr+'}')
      theStr = theStr.replace('subBackslash','\\')
      for i in range(1,5): # set upper range to maximum+1 expect embeded subscripts
          theStr = re.sub('_([a-zA-Z0-9_]+)',r'_{\1}',theStr)
      for i in range(1,2): # set upper range to maximum+1 expect embeded supercripts
          theStr = re.sub('\^([a-zA-Z0-9\.\^]+)',r'^{\1}',theStr)
      if (isEqn != 1):
          itsLabel = '\\label{eq:' + isEqn + '}'
      else:
          itsLabel = ''
      if (isEqn):
          return "\\begin{dmath}"+itsLabel+theStr+"\end{dmath}\n"
      else:
          return "$"+theStr+"$\n"
   latexPrint = ''
