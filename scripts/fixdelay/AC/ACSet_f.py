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

from ACBase import ACPathException, ACSetException
from ACBase import ACObject, ACCommand


class ACPath(ACObject):
	def __init__(self):
		super(ACPath, self).__init__()
		self.id.append("ACPath")
		
		self.startpoint = None
		self.endpoint = None
		self.exclude = None
		self.delayTarget = None
		self.forceEndpoint = True
		self.parent = None
		self.enabled = False
		self.coefficient = None #M

	def isValid(self):
		if self.startpoint is None or self.endpoint is None:
			return False

		if self.isDelayTarget() is None:
			return False

		return True


	def updateEnabled(self, points):
		found_start = False
		found_end = False
		self.enabled = False

		for p in points:
			if not found_start:
				if self.getStartpoint() == p:
					found_start = True

			if not found_end:
				if self.getEndpoint() == p:
					found_end = True

			if found_start and found_end:
				self.enabled = True
				break

		return self.isEnabled()


	def isEnabled(self):
		return self.enabled


	def setStartpoint(self, startpoint):
		if (startpoint == ""):
			raise ACPathException("setStartpoint method:'starpoint' has zero length")

		self.startpoint = startpoint

	
	def getStartpoint(self):
		return self.startpoint


	def setEndpoint(self, endpoint):
		if (endpoint == ""):
			raise ACPathException("setEndpoint method: 'endpoint' has zero length")

		self.endpoint = endpoint


	def getEndpoint(self):
		return self.endpoint


	def setExclude(self, exclude):
		if (exclude == ""):
			self.exclude = "EdgeExcludeNone"

		self.exclude = exclude

	
	def getExclude(self):
		return self.exclude


	def setParent(self, parent):
		if not parent.isInstance("ACSet"):
			raise ACPathException("setParent method: 'parent' is instance of '" + parent.getID() + "' (expected class: ACSet)")

		if self.parent is not None:
			raise ACPathException("setParent method: parent has already been set")			

		self.parent = parent

	
	def getParent(self):
		return self.parent


	def getPath(self):
		return (self.startpoint, self.endpoint, self.exclude)


	def getPathString(self):
		return self.getStartpoint() + " " + self.getEndpoint() + " " + self.getExclude()

	
	def getPathStringSplit(self):
		return [self.getStartpoint(), self.getEndpoint(), self.getExclude()]

		
	def setDelayTarget(self, target):
		self.delayTarget = target


	def isDelayTarget(self):
		return self.delayTarget


	def setCoefficient(self,coefficient): #M
		self.coefficient = coefficient #M


	def getCoefficient(self): #M
		return self.coefficient #M


	def setForceEndpoint(self, should):
		self.forceEndpoint = should


	def shouldForceEndpoint(self):
		return self.forceEndpoint


	def isEqual(self, otherPath):
		if not otherPath.isInstance("ACPath"):
			raise ACPathException("isEqual method: 'otherPath' is instance of '" + otherPath.getID() + "' (expected class: ACPath)")

		#if ((self.getStartpoint() == otherPath.getStartpoint()) and (self.getEndpoint() == otherPath.getEndpoint())):
		if ((self.getStartpoint() == otherPath.getStartpoint()) and (self.getEndpoint() == otherPath.getEndpoint()) and (self.getExclude() == otherPath.getExclude())):
			return True

		return False




class ACSet(ACObject):
	def __init__(self, parent, action,setExtraDelay): #M
		super(ACSet, self).__init__()
		self.id.append("ACSet")

		if not ((action == "max") or (action == "sum")):
			raise ACSetException("init method: 'action' value is '" + action +"'. (expected: 'max' or 'sum')")

		if not (parent.isInstance("ACSet") or parent.isInstance("ACConstraint")):
			raise ACSetException("init method: 'parent' is instance of '" + parent.getID() + "' (expected class: ACSet or ACConstraint)")
		
		try: #M
			temp = float(setExtraDelay)
		except:
			raise ACSetException("init method: 'setExtraDelay' value is '" + setExtraDelay +"'. (expected: a real number)")

		self.paths = []
		self.sets = []
		self.action = action
		self.parent = parent
		self.setExtraDelay = setExtraDelay #M


	def isValid(self):
		if (len(self.sets) == 0) and (len(self.paths) == 0):
			return False

		for s in self.sets:
			if not s.isValid():
				return False
		
		for p in self.paths:
			if not p.isValid():
				return False

		return True


	def getParent(self):
		return self.parent


	def getAction(self):
		return self.action


	def getSetExtraDelay(self): #M
		return self.setExtraDelay


	def updateEnabled(self, paths):
		is_enabled = False
		has_disabled_path = False
		has_enabled_path = False
		has_disabled_set = False
		has_enabled_set = False

		# Update everybody's status 
		for p in self.paths:
			if p.updateEnabled(paths):
				has_enabled_path = True
			else:
				has_disabled_path = True

		for s in self.sets:
			if s.updateEnabled(paths):
				has_enabled_set = True
			else:
				has_disabled_set = True


		# Check if its enabled
		if has_enabled_set or has_enabled_path:
			if self.action == "max":
				# If action is MAX, at least one set or one path must be active
				is_enabled = True
			elif self.action == "sum":
				# If action is SUM, all sets and paths must be active
				if (not has_disabled_path) and (not has_disabled_set):
					is_enabled = True

		
		if not self.parent.isInstance("ACSet"):
			# Its the root set, so check for delay target
			if self.getDelayTarget() is not None:
				if not self.getDelayTarget().isEnabled():
					is_enabled = False

			self.enabled = is_enabled
			return self.isEnabled()

		return is_enabled	


	def isEnabled(self):
		if self.parent.isInstance("ACSet"):
			return self.parent.isEnabled()

		if not hasattr(self, 'enabled'):
			self.enabled = None

		return self.enabled


	def setDelayTarget(self, aPath):
		if self.getDelayTarget() is None:
			if self.parent.isInstance("ACSet"):
				return self.parent.setDelayTarget(aPath)
		else:
			raise ACSetException("setDelayTarget method: a delay target has been already set")	

		if not aPath.isInstance("ACPath"):
			raise ACSetException("setDelayTarget method: 'aPath' is instance of '" + aPath.getID() + "' (expected class: ACPath)")
			
		self.delayTarget = aPath


	def getDelayTarget(self):
		if self.parent.isInstance("ACSet"):
			return self.parent.getDelayTarget()

		if not hasattr(self, 'delayTarget'):
			self.delayTarget = None

		return self.delayTarget


	def hasPath(self, aPath):
		if not aPath.isInstance("ACPath"):
			raise ACSetException("hasPath method: 'aPath' is instance of '" + aPath.getID() + "' (expected class: ACPath)")

		# Test if path is already in the set
		found = False
		for p in self.paths:
			if p.isEqual(aPath):
				found = True
				break

		if not found:
			for s in self.sets:
				if s.hasPath(aPath):
					found = True
					break

		return found


	def addPath(self, newPath):
		if not newPath.isInstance("ACPath"):
			raise ACSetException("addPath method: 'newPath' is instance of '" + newPath.getID() + "' (expected class: ACPath)")

		if (newPath.getParent() != self):
			raise ACSetException("addPath method: the parent of 'newPath' is not the current ACSet")			

		# Check if there is a conflict of delay targets
		if (self.getDelayTarget() is not None) and newPath.isDelayTarget():
			raise ACSetException("addPath method: tried to add a delay-targeted path to a set that already has a delay target")

		# Check if path is already inside set
		if not self.hasPath(newPath):
			self.paths.append(newPath)
			if newPath.isDelayTarget():
				self.setDelayTarget(newPath)


	def addSet(self,newSet):
		if not newSet.isInstance("ACSet"):
			raise ACSetException("addSet method: 'newSet' is instance of '" + newSet.getID() + "' (expected class: ACSet)")

		if (newSet.getParent() != self):
			raise ACSetException("addSet method: the parent of 'newSet' is not the current ACSet")

		self.sets.append(newSet)


	def getPaths(self):
		paths = list(self.paths)

		for s in self.sets:
			paths += s.getPaths()

		return paths


	def getPathStrings(self):
		paths = []

		for p in self.paths:
			paths.append(p.getPathString())

		for s in self.sets:
			paths += s.getPathStrings()

		# Eliminate redundancies
		return list(set(paths))

		
	def getPathStringSplit(self):
		paths = []

		for p in self.paths:
			paths += p.getPathStringSplit()

		for s in self.sets:
			paths += s.getPathStringSplit()

		# Eliminate redundancies
		return list(set(paths))


	def getPathDict(self):
		return self.parent.getPathDict()
	

	def getConstraintDict(self):
		return self.parent.getConstraintDict()


	def getDelayExpression(self, delayType):
		expr = ""

		if self.action == "max":
			# Expression to calculate max delay
			# Path delay
			for p in self.paths:
				if p.isEnabled():
					temp = "$" + self.getPathDict()[p.getPathString()] #M
					if delayType == "min":
						temp += "_min"
					temp += " "
					if float(p.getCoefficient()) != 1:
						temp = "[expr " + temp + "* " + p.getCoefficient() + "] "	
					expr += temp
					#expr += "$" + self.getPathDict()[p.getPathString()]
					#if delayType == "min":
					#	expr += "_min"
					#expr += " "

			# Other sets delays
			for s in self.sets:
				if s.isEnabled():
					expr += s.getDelayExpression(delayType) + " "		

			if expr != "":
				expr = "[" + ACCommand.maxOfArray + " " + expr + "] "
				
			# add Set Extra Delay #M
			if float(self.setExtraDelay) != 0:
				expr += "+ " + self.setExtraDelay 	


		elif self.action == "sum":
			# Expression to calculate sum of delays (All paths need to be enabled for sum)
			# Sum PATH delay
			for p in self.paths:
				if expr != "":
					expr += "+ "

				#expr += "$" + self.getPathDict()[p.getPathString()]
				#if delayType == "min":
				#	expr += "_min"
				#expr += " "
				
				temp = "$" + self.getPathDict()[p.getPathString()] #M
				if delayType == "min":
					temp += "_min"
				temp += " "
				if float(p.getCoefficient()) != 1:
					temp = "[expr " + temp + "* " + p.getCoefficient() + "] "	
				expr += temp

			# Sum delay of other sets
			for s in self.sets:
				if expr != "":
					expr += "+ "

				expr += s.getDelayExpression(delayType) + " "	
		
			# add Set Extra Delay #M
			if float(self.setExtraDelay) != 0:
				expr += "+ " + self.setExtraDelay + " "	

		else:
			raise ACSetException("getDelayExpression method: expression for action '" + self.action + "' not implemented")

		# Check if not empty
		if expr != "":
			expr = "[expr " + expr + "] "
		else:
			raise ACSetException("getDelayExpression method: resulting expression is empty")

		return expr

