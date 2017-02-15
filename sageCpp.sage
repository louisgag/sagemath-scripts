# this file is licensed under a Creative Commons Attribution 4.0 International License, unlike the statement given in the LICENSE file
# see http://louisgagnon.com/scBlog/sageCpp.html for more info
# print in c++ format for Dakota optimizer
from sympy.utilities.codegen import codegen
import numpy
CGvarName = numpy.array(['eta','alpha_m_c','Reynolds_c','sigma_rod_c','sigma_b_c','sigma_s_c','tau_b_m_c','Omega_t_m_c']) # obj funct must be first
CGvar = numpy.array([eta_c,alpha_m_c,Reynolds_c,sigma_rod_c,sigma_b_c,sigma_s_c,tau_b_m_c,Omega_t_m_c]) # names of equation objects in Sage
allVars = CGvar[0].variables() # accessing all optim vars as being the ones of the objective function
CG_tl = [] # initializing codegen tuple list: [(name, Eqn), (name, Eqn),...]
for iVAR in (0..len(CGvar)-1):
CG_tl.append((CGvarName[iVAR], CGvar[iVAR]._sympy_())); # appending codegen tuple list
for iCG in (0..len(allVars)-1):
    CGName = 'd'+CGvarName[iVAR]+'_%s' % allVars[iCG] # derivative variable name
    CGDeriv = derivative(CGvar[iVAR],allVars[iCG]) # derivative itself
    CG_tl.append((CGName,CGDeriv._sympy_())) # appending codegen tuple list
    [(c_name, EqnsCpp), (h_name, EqnsH)] = codegen(CG_tl, "C", "test", 'project', to_files=False, header=False, empty=False, argument_sequence=None, global_vars=None)
fCG=open('cppEquations.txt','w')
fCG.write('//Codegen header, equations, and derivatives for objective and constraint functions = \n')
fCG.write(EqnsH)
fCG.write(EqnsCpp)
fCG.close()
