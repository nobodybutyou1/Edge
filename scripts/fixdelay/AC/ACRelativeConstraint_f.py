# Copyright (c) 2017, Matheus Gibiluka, and Matheus Trevisan Moreira
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# * Neither the name of the Pontifical Catholic University of Rio Grande do Sul nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Matheus Gibiluka, and Matheus Trevisan Moreira BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from ACBase import ACRelativeTimingException
from ACBase import ACCommand, ACVar
from ACConstraint_f import ACConstraint
from ACSet_f import ACPath, ACSet

class ACRelativeConstraint(ACConstraint):
	def __init__(self, aName, aDesign):
		super(ACRelativeConstraint, self).__init__(aName,aDesign)
		self.id.append("ACRelativeConstraint")

		# Base set is where the delay is measured
		self.base = None
		# Enforced set's min delay is made larger than base set's max delay
		self.enforced = None


	def isValid(self):
		if (self.base is None):
			return False
		
		if (self.enforced is None) or (self.enforced.getDelayTarget() is None):
			return False

		return True


	def updateEnabled(self, paths):
		self.base.updateEnabled(paths)
		self.enforced.updateEnabled(paths)

		return self.isEnabled()


	def isEnabled(self):
		return (self.base.isEnabled() and self.enforced.isEnabled())


	def setBaseSet(self, aSet):
		if not aSet.isInstance("ACSet"):
			raise ACRelativeTimingException("setBaseSet method: 'aSet' is instance of '" + aSet.getID() + "' (expected class: ACSet)")

		if self.base is not None:
			raise ACRelativeTimingException("setBaseSet method: set has already been set")

		if aSet.getParent() != self:
			raise ACRelativeTimingException("setBaseSet method: the parent of 'aSet' is not the current ACRelativeConstraint")
		
		self.base = aSet


	def setEnforcedSet(self, aSet):
		if not aSet.isInstance("ACSet"):
			raise ACRelativeTimingException("setEnforcedSet method: 'aSet' is instance of '" + aSet.getID() + "' (expected class: ACSet)")

		if self.enforced is not None:
			raise ACRelativeTimingException("setEnforcedSet method: set has already been set")

		if aSet.getParent() != self:
			raise ACRelativeTimingException("setEnforcedSet method: the parent of 'aSet' is not the current ACRelativeConstraint")
		
		self.enforced = aSet
	

	def getPathStrings(self):
		paths = []

		if self.base is not None:
			paths += self.base.getPathStrings()

		if self.enforced is not None:
			paths += self.enforced.getPathStrings()

		return list(set(paths))

		
	def getPathStringSplit(self):
		paths = []

		if self.base is not None:
			paths += self.base.getPathStringSplit()

		if self.enforced is not None:
			paths += self.enforced.getPathStringSplit()

		return list(set(paths))


	def getPaths(self):
		paths = []

		if self.base is not None:
			paths += self.base.getPaths()

		if self.enforced is not None:
			paths += self.enforced.getPaths()

		return paths

	
	def createReportConstraintScript(self):
		script = "# Constraint '" + self.getName() + "' : \n"
		
		# Get Base path delay
		script += "set " + ACVar.sharedBase + " " + self.base.getDelayExpression("max") + "\n"

		# Get Enforced path delay
		script += "set " + ACVar.sharedEnforced + " " + self.enforced.getDelayExpression("min") + "\n"

		# Calculate Delay delta 
		delayExpr = " [expr $" + ACVar.sharedEnforced + " - $" + ACVar.sharedBase + " ] "
		script += "set " + ACVar.sharedDelta + delayExpr + " \n"

		# Report 
		script += "echo \"\\tConstraint \'" + self.getName() + "\': \" " + "\n"
		script += "echo [format \"\\t\\tEnforced Path delay:    %g \" $" + ACVar.sharedEnforced + " ]" + "\n"
		script += "echo [format \"\\t\\t    Base Path delay:  - %g \" $" + ACVar.sharedBase + " ]" + "\n"
		script += "echo \"\\t\\t                     ----------------\"" + "\n"
		script += "if { $" + ACVar.sharedDelta + " < 0 } { " + "\n"
		script += "\techo [format \"\\t\\t                        %g  (VIOLATED) \" $" + ACVar.sharedDelta + " ]" + "\n"
		script += "} else { " + "\n"
		script += "\techo [format \"\\t\\t                        %g  (MET) \" $" + ACVar.sharedDelta + " ]" + "\n"
		script += "}" + "\n"
		script += "echo \"\\n\"" + "\n"
		
		return script
	

	def createCheckConstraintScript(self):
		script = "# Constraint '" + self.getName() + "' : \n"
		
		# Get Base path delay
		script += "set " + ACVar.sharedBase + " " + self.base.getDelayExpression("max") + "\n"

		# Get Enforced path delay
		script += "set " + ACVar.sharedEnforced + " " + self.enforced.getDelayExpression("min") + "\n"

		# Calculate Delay delta 
		delayExpr = " [expr $" + ACVar.sharedEnforced + " - $" + ACVar.sharedBase + " ] "
		script += "set " + ACVar.sharedDelta + delayExpr + " \n"

		# Set Var if constraint not met 
		script += "if { $" + ACVar.sharedDelta + " < 0 } { " + "\n"
		script += "\tset " + ACVar.constraintMet + " 0 " + "\n"
		script += "}" + "\n"
		
		return script


	def createSetConstraintScript(self):
		script = "# Constraint '" + self.getName() + "' : \n"
		
		# Get Base path delay
		script += "set " + ACVar.sharedBase + " " + self.base.getDelayExpression("max") + "\n"

		# Get Enforced path delay
		script += "set " + ACVar.sharedEnforced + " " + self.enforced.getDelayExpression("min") + "\n"

		# Calculate min delay, and append it to the constraint minDelay 
		delayTarget = self.enforced.getDelayTarget()
		temp = "$" + self.getPathDict()[delayTarget.getPathString()] + "_min"
		if float(delayTarget.getCoefficient()) != 1:
			temp = "[expr " + temp + " * " + delayTarget.getCoefficient() + "]"
		delayExpr = " [expr $" + ACVar.sharedBase + " - $" + ACVar.sharedEnforced + " + " + temp + " ] "

		# Multiply by Multiplier
		script += "set " + ACVar.sharedDelta + delayExpr + " \n"

		# Set min delay to Constraint var
		temp = " $" + ACVar.sharedDelta
		if float(delayTarget.getCoefficient()) != 1:
			temp = " [expr" + temp + " \ " + delayTarget.getCoefficient() + "]"
		script += "set " + self.getDesign().getConstraintDict()[self.getName()] + temp + " \n"

		# Register constraint
		self.getDesign().registerConstraint(self, delayTarget)
		
		# Report Setting
		script += "echo \"\\tConstraint '" + self.getName() + "' set. \"" + "\n"
 
		return script
