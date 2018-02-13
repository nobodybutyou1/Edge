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


from ACBase import ACDesignException
from ACBase import ACObject, ACCommand, ACVar
from ACConstraint_f import ACConstraint


class ACDesign(ACObject):
	def __init__(self, aName):
		super(ACDesign, self).__init__()
		self.id.append("ACDesign")

		if aName == "":
			raise ACDesignException("init method: 'aName' has zero length")

		self.name = aName
		self.constraints = []
		self.pathDict = None
		self.constraintDict = None
		self.constraintRegistryDict = None


	def getName(self):
		return self.name


	def updateEnabled(self, paths):
		for c in self.constraints:
			c.updateEnabled(paths)
		self.createDictionaries()


	def getDisabledConstraints(self):
		dc = []
		for c in self.constraints:
			if not c.isEnabled():
				dc.append(c)
		return dc


	def getEnabledConstraints(self):
		dc = []
		for c in self.constraints:
			if c.isEnabled():
				dc.append(c)
		return dc

				
	def addConstraint(self, aConstraint):
		if not aConstraint.isInstance("ACConstraint"):
			raise ACDesignException("addConstraint method: 'aConstraint' is instance of '" + aConstraint.getID() + "' (expected class: ACConstraint)")

		if aConstraint.getDesign() != self:
			raise ACDesignException("addConstraint method: the design of 'aConstraint' is not the current ACDesign")

		for c in self.constraints:
			if c.getName() == aConstraint.getName():
				raise ACDesignException("addConstraint method: the name of 'aConstraint' is already being used in this design")
		
		if not aConstraint.isValid():
			raise ACDesignException("addConstraint method: 'aConstraint' is not valid")

		self.constraints.append(aConstraint)

	
	def getConstraints(self):
		return self.constraints	


	def getPathStrings(self):
		paths = []

		for c in self.constraints:
			paths += c.getPathStrings()

		return list(set(paths))


	def getPathStringSplit(self):
		paths = []

		for c in self.constraints:
			paths += c.getPathStringSplit()


		return list(set(paths))


	def getPaths(self):
		paths = []

		for c in self.constraints:
			paths += c.getPaths()

		return paths


	def createDictionaries(self):
		paths = []
	
		# Constraint Dictionary
		i = 0
		self.constraintDict = {}
		for c in self.constraints:
			if c.isEnabled():
				self.constraintDict[c.getName()] = ACVar.constraint + str(i)
				paths += c.getPathStrings()
				i += 1

		# Uniquify Paths
		paths = list(set(paths))

		# Path Dictionary
		i = 0
		self.pathDict = {}	
		for p in paths:
			self.pathDict[p] = ACVar.path + str(i)
			i += 1

		
	def getPathDict(self):
		if self.pathDict is None:
			self.createDictionaries()
		return self.pathDict
	

	def getConstraintDict(self):
		if self.constraintDict is None:
			self.createDictionaries()
		return self.constraintDict


	def createGetDelayScript(self):
		script = "# Get Delays \n"
		script += "global edge_clk_m_pin\n"
		script += "global edge_clk_s_pin\n"
		script += "global edge_clk_m_latch_in\n"
		script += "global edge_clk_s_latch_in\n"
		script += "global edge_clk_m_latch_out\n"
		script += "global edge_clk_s_latch_out\n"
		for p in self.getPathDict().keys():
			script += "set " + self.getPathDict()[p] + " [" + ACCommand.getDelay + " " + p + " max] \n"
			script += "set " + self.getPathDict()[p] + "_min [" + ACCommand.getDelay + " " + p + " min] \n"

		return script


	def createReportConstraintScript(self):
		script = "###### Report Constraints \n"

		for c in self.constraints:
			if c.isEnabled():
				script += c.createReportConstraintScript()
				script += "\n"

		return script


	def createCheckConstraintScript(self):
		script = "###### Check Constraints \n"

		for c in self.constraints:
			if c.isEnabled():
				script += c.createCheckConstraintScript()
				script += "\n"

		return script


	def createSetConstraintScript(self):
		script = "###### Set Constraints \n"

		# Reset Multiple Constraint Dict
		self.constraintRegistryDict = None

		for c in self.constraints:
			if c.isEnabled():
				script += c.createSetConstraintScript()
				script += "\n"

		# Set delays for each path. If multiple constraints target the same wire, MAX is taken
		if self.constraintRegistryDict.keys() is not None:
			for p in self.constraintRegistryDict.keys():

				script += "set " + ACVar.sharedAux + " "

				if len(self.constraintRegistryDict[p]) == 0:
					raise ACDesignException("createSetConstraintScript method: constraintRegistryDict for path '" + p.getPathStrings + "' is empty.")

				elif len(self.constraintRegistryDict[p]) == 1:
					# Only one delay for this path, so just add it
					script += "$" + self.getConstraintDict()[self.constraintRegistryDict[p][0].getName()]

				else:
					# Several delays for this path, so get MAX of all constraints
					script += "[ " + ACCommand.maxOfArray + " "

					for c in self.constraintRegistryDict[p]:
						# Loop through all constraints
						script += "$" + c.getConstraintDict()[c.getName()] + " "

					script += "]"

				script += " \n"

				# Check if constraint was met
				#script += "if { $" + ACVar.sharedAux + " > 0 } { " 
				script += ACCommand.setMinDelay + " " + p.getStartpoint() + " " + p.getEndpoint() + " " + p.getExclude() + " $" + ACVar.sharedAux

				if p.shouldForceEndpoint():
					script += " 1"
				script += " \n"
				#script += " } \n\n"

		return script


	def registerConstraint(self, constraint, path):
		# Instanciate new Dictionary, if needed
		if self.constraintRegistryDict == None:
			self.constraintRegistryDict = {}

		# Check if path is already registered
		for p in self.constraintRegistryDict.keys():
			if p.getPathString() == path.getPathString():
				self.constraintRegistryDict[p].append(constraint)
				return

		# If reached here, its a new path. Create a new dic entry
		self.constraintRegistryDict[path] = [constraint]
