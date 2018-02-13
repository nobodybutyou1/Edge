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

from ACBase import ACConstraintException
from ACBase import ACObject


class ACConstraint(ACObject):
	def __init__(self, aName, aDesign):
		super(ACConstraint, self).__init__()
		self.id.append("ACConstraint")
		
		if aName == "":
			raise ACConstraintException("init method: 'aName' has zero length")
		
		if not aDesign.isInstance("ACDesign"):
			raise ACConstraintException("init method: 'aDesign' is instance of '" + aDesign.getID() + "'' (expected class: ACDesign)")
		
		self.name = aName
		self.design = aDesign	
		self.description = ""

	def getName(self):
		return self.name

	def getDesign(self):
		return self.design

	def setDescription(self, description):
		self.description = description

	def getDescription(self):
		return self.description

	def getPathStrings(self):
		raise ACConstraintException("getPathNames not implemented")

	def getPathStringSplit(self):
		raise ACConstraintException("getPathStringSplit not implemented")

	def getPaths(self):
		raise ACConstraintException("getPaths not implemented")

	def createSetConstraintScript(self):
		raise ACConstraintException("createSetConstraintCommands not implemented")

	def createCheckConstraintScript(self):
		raise ACConstraintException("createCheckConstraintScript not implemented")

	def isValid(self):
		raise ACConstraintException("isValid not implemented")

	def updataEnabled(self, paths):
		raise ACConstraintException("updataEnabled not implemented")		

	def isEnabled(self):
		raise ACConstraintException("isEnabled not implemented")		

	def getPathDict(self):
		return self.getDesign().getPathDict()
	
	def getConstraintDict(self):
		return self.getDesign().getConstraintDict()