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


import xml.sax
from ACBase import ACParserException
from ACSet_f import ACPath, ACSet
from ACConstraint_f import ACConstraint
from ACRelativeConstraint_f import ACRelativeConstraint
from ACDesign_f import ACDesign


class ACParserHandler(xml.sax.ContentHandler):
	def startDocument(self):
		# Parameters
		self.encoding = "utf-8"
		self.defaultSetAction = "sum"
		self.defaultDelayTarget = False
		self.defaultForceEndpoint = False
		self.defaultCoefficient = "1" #M
		self.defaultSetExtraDelay = "0" #M
		
		# Error/Warning Info Holder
		self.ignoredConstraints = [] # Tuple: (Constraint name, type, design name)
		
		# Control
		self.ignoringConstraint = False

		# State Buffers
		self.designs = []
		self.sets = []
		self.paths = []
		self.constraints = []
		self.state = []
		self.buffer = ""


	def endDocument(self):
		# Check if state is empty
		if len(self.sets) != 0:
			raise ACParserException("endDocument method: there are remaining sets on the stack")	

		if len(self.paths) != 0:
			raise ACParserException("endDocument method: there are remaining paths on the stack")

		if len(self.constraints) != 0:
			raise ACParserException("endDocument method: there are remaining constraints on the stack")

		if len(self.state) != 0:
			raise ACParserException("endDocument method: there are remaining states on the stack")

	def startElement(self, name, attrs):
		name = name.encode(self.encoding)
		if not self.ignoringConstraint:

			if name == "design":
				if "name" in attrs.keys():
					n = attrs.get("name").encode(self.encoding) 
					for d in self.designs:
						if d.getName() == n:
							raise ACParserException("startElement(design) method: design name '" + name + "' is already in use")	

					d = ACDesign(n)
					self.designs.append(d)
				else:
					raise ACParserException("'design' entry has no 'name' attribute")	

			
			#Create constraint object, If type is not supported, ignore this constraint and report later
			elif name == "constraint":
				if self.state[-1] != "design":
					raise ACParserException("startElement(constraint) method: Previous element is invalid. Expected 'design'. State log: {" + ' ; '.join(self.state) + "}")

				if "name" not in attrs.keys():
					raise ACParserException("'constraint' entry has no 'name' attribute")	

				if "type" not in attrs.keys():
					raise ACParserException("'constraint' entry has no 'type' attribute")	
		
				if attrs.get("type").encode(self.encoding) == "relative":
					n = attrs.get("name").encode(self.encoding) 
					for c in self.designs[-1].getConstraints():
						if c.getName() == n:
							raise ACParserException("startElement(constraint) method: constraint name '" + name + "' is already in use")	

					c = ACRelativeConstraint(n,self.designs[-1])
					self.constraints.append(c)
				else:
					self.ignoredConstraints.append((attrs.get("name").encode(self.encoding), attrs.get("type").encode(self.encoding), self.designs[-1].getName()))
					self.ignoringConstraint = True
			
	
			elif (name == "description") or (name == "startpoint") or (name == "endpoint") or (name == "exclude"):
				self.buffer = ""
	

			elif name == "set":
				action = self.defaultSetAction
				setExtraDelay = self.defaultSetExtraDelay #M
				if "action" in attrs.keys():
					action = attrs.get("action").encode(self.encoding)
				
				if "setExtraDelay" in attrs.keys(): #M
					setExtraDelay = attrs.get("setExtraDelay").encode(self.encoding)

				if (self.state[-1] == "set") or (self.state[-1] == "base") or (self.state[-1] == "enforced"):
					s = ACSet(self.sets[-1], action,setExtraDelay) #M
					self.sets.append(s)
				else:
					raise ACParserException("startElement(set) method: Previous element is invalid. Expected 'set', 'base', or 'enforced'. State log: {" + ' ; '.join(self.state) + "}")


			elif (name == "base") or (name == "enforced"):
				action = self.defaultSetAction
				setExtraDelay = self.defaultSetExtraDelay #M
				if "action" in attrs.keys():
					action = attrs.get("action").encode(self.encoding)

				if "setExtraDelay" in attrs.keys(): #M
					setExtraDelay = attrs.get("setExtraDelay").encode(self.encoding)

				if (self.state[-1] == "constraint"):
					s = ACSet(self.constraints[-1], action,setExtraDelay)
					self.sets.append(s)
				else:
					raise ACParserException("startElement(" + name + ") method: Previous element is invalid. Expected 'constraint'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "path":
				p = ACPath()

				# Process Delay Target
				if "delayTarget" in attrs.keys():
					if attrs.get("delayTarget").encode(self.encoding) == "true":
						p.setDelayTarget(True)

					elif attrs.get("delayTarget").encode(self.encoding) == "false":
						p.setDelayTarget(False)
					else:
						raise ACParserException("startElement(path) method: 'delayTarget' property '" + attrs.get("delayTarget").encode(self.encoding) + "' is invalid. Expected 'true' or 'false'")
				else:
					p.setDelayTarget(self.defaultDelayTarget)


				# Process Coefficient #M
				if "coefficient" in attrs.keys():
					try:
						temp = float(attrs.get("coefficient").encode(self.encoding))					
						p.setCoefficient(attrs.get("coefficient").encode(self.encoding))
					except:
						raise ACParserException("startElement(path) method: 'coefficient' property '" + attrs.get("coefficient").encode(self.encoding) + "' is invalid. Expected a real number")
				else:
					p.setCoefficient(self.defaultCoefficient)


				# Process Force Endpoint
				if "forceEndpoint" in attrs.keys():
					if attrs.get("forceEndpoint").encode(self.encoding) == "true":
						p.setForceEndpoint(True)

					elif attrs.get("forceEndpoint").encode(self.encoding) == "false":
						p.setForceEndpoint(False)
					else:
						raise ACParserException("startElement(path) method: 'forceEndpoint' property '" + attrs.get("forceEndpoint").encode(self.encoding) + "' is invalid. Expected 'true' or 'false'")
				else:
					p.setForceEndpoint(self.defaultForceEndpoint)


				# Process Parent
				if (self.state[-1] == "set") or (self.state[-1] == "base") or (self.state[-1] == "enforced"):
					p.setParent(self.sets[-1])
				else:
					raise ACParserException("startElement(path) method: Previous element is invalid. Expected 'set', 'base', or 'enforced'. State log: {" + ' ; '.join(self.state) + "}" + " Constraint = '" + self.constraints[-1].getName() + "'.")

				self.paths.append(p)

		self.state.append(name)


	def endElement(self, name):
		if self.state[-1] != name:
			raise ACParserException("endElement(" + name + "): Unexpected element ended. Expected '" + self.state[-1] + "'")
		else:
			self.state.pop()

		if self.ignoringConstraint:
			if name == "constraint":
				self.ignoringConstraint = False;
		else:

			if name == "constraint":
				if self.state[-1] == "design":
					self.designs[-1].addConstraint(self.constraints.pop())				
				else:
					raise ACParserException("endElement(constraint) method: Previous element is invalid. Expected 'design'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "description":
				if self.state[-1] == "constraint":
					self.constraints[-1].setDescription(self.buffer)
				else:
					raise ACParserException("endElement(description) method: Previous element is invalid. Expected 'constraint'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "base":
				if self.state[-1] == "constraint":
					if self.constraints[-1].isInstance("ACRelativeConstraint"):
						self.constraints[-1].setBaseSet(self.sets.pop())
					else:
						raise ACParserException("endElement(base) method: Constraint class is '" + self.constraints[-1].getID() + "'. Expected 'ACRelativeConstraint'")
				else:
					raise ACParserException("endElement(base) method: Previous element is invalid. Expected 'constraint'. State log: {" + ' ; '.join(self.state) + "}")

			
			elif name == "enforced":
				if self.state[-1] == "constraint":
					if self.constraints[-1].isInstance("ACRelativeConstraint"):
						self.constraints[-1].setEnforcedSet(self.sets.pop())
					else:
						raise ACParserException("endElement(base) method: Constraint class is '" + self.constraints[-1].getID() + "'. Expected 'ACRelativeConstraint'")
				else:
					raise ACParserException("endElement(base) method: Previous element is invalid. Expected 'constraint'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "startpoint":
				if self.state[-1] == "path":
					self.paths[-1].setStartpoint(self.buffer)
				else:
					raise ACParserException("endElement(startpoint) method: Previous element is invalid. Expected 'path'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "endpoint":
				if self.state[-1] == "path":
					self.paths[-1].setEndpoint(self.buffer)
				else:
					raise ACParserException("endElement(endpoint) method: Previous element is invalid. Expected 'path'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "exclude":
				if self.state[-1] == "path":
					self.paths[-1].setExclude(self.buffer)
				else:
					raise ACParserException("endElement(exclude) method: Previous element is invalid. Expected 'path'. State log: {" + ' ; '.join(self.state) + "}")

			elif name == "set":
				if (self.state[-1] == "set") or (self.state[-1] == "base") or (self.state[-1] == "enforced"):
					s = self.sets.pop()
					self.sets[-1].addSet(s)
				else:
					raise ACParserException("endElement(set) method: Previous element is invalid. Expected 'set', 'base', or 'enforced'. State log: {" + ' ; '.join(self.state) + "}")


			elif name == "path":
				if (self.state[-1] == "set") or (self.state[-1] == "base") or (self.state[-1] == "enforced"):
					if not self.paths[-1].isValid():
						raise ACParserException("endElement(path) method: path is not valid")
					self.sets[-1].addPath(self.paths.pop())				
				else:
					raise ACParserException("endElement(path) method: Previous element is invalid. Expected 'set', 'base', or 'enforced'. State log: {" + ' ; '.join(self.state) + "}")


	def characters(self, content):
		self.buffer += content.encode(self.encoding)


	def getDesings(self):
		return self.designs


	def didIgnoreConstraints(self):
		if len(self.ignoredConstraints) != 0:
			return True
		return False


	def getIgnoredConstraintsString(self):
		s = ""

		for i in self.ignoredConstraints:
			s += "\t Design: " + i[2] + " - Constraint: " + i[0] + " - Type: " + i[1] + "\n"

		return s


