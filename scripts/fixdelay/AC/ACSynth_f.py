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




import sys
import xml.sax
import traceback
from ACBase import ACObject, ACPaths, ACSettings, ACVar, ACCommand
from ACBase import ACException, ACSynthException
from ACParser_f import ACParserHandler


# Add support for multiple designs
class ACSynth(ACObject):
	def __init__(self):
		super(ACSynth, self).__init__()
		self.id.append("ACSynth")
		self.designs = None
		self.warnings = ""

	def loadConstraints(self,fileName):
		handler = ACParserHandler()
		parser = xml.sax.make_parser()
		parser.setContentHandler(handler)

		try:
			parser.parse(fileName)
		except ACException, e:
			print "ERROR: " + e.description()
			traceback.print_exc()
			raise e;

		self.designs = handler.getDesings()

		if handler.didIgnoreConstraints():
			self.warning("ACParser Warnings:", handler.getIgnoredConstraintsString())


	def warning(self, title, content):
		self.warnings += title + " " + content + "\n"

	
	def createWarningReport(self):
		report = "#\n# ACSynth Warinings (Generated Automatically) \n#\n\n"
		for w in self.warnings.split('\n'):
			report += "echo \""  + w + "\" \n"

		warning_file = open(ACPaths.ACSynth_warnings, "w")
		try:
			warning_file.write(report)
		finally:
			warning_file.close()

	
	def getDesigns(self):
		return self.designs


	# TODO: Implement Chain Check, Report Disabled Paths, Multitargeted Paths, generate TCL with report,<<<<<<<
	# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	def checkDesigns(self, paths):
		for d in self.designs:
			d.updateEnabled(paths)
			for dc in d.getDisabledConstraints():
				self.warning("Disabled Constraint:", dc.getName() + " is disabled. (Design: " + d.getName() + ")")

	
	def reportConstraintsFunction(self):
		d = self.designs[0]

		# Get Delay Script
		getDelayScript = "# Get Delays \n"
		getDelayScript += d.createGetDelayScript() + "\n"

		# Report Constraints
		checkConstraintScript = "# Report Constraints \n"
		checkConstraintScript += "echo \"\\n**************************************************** \"" + "\n"
		checkConstraintScript += "echo \" Report of Asynchronous Constraints: \"" + "\n\n"
		checkConstraintScript += d.createReportConstraintScript()

		# Assemble Function
		script = "# AC_report_constraints Function (Generated Automatically) \n"
		script += "proc " + ACCommand.reportConstraints + " {} { \n"
		script += getDelayScript.replace("\n","\n\t")
		script += checkConstraintScript.replace("\n","\n\t") + "\n"
		script += "} \n"

		return script

	
	def checkConstraintsFunction(self):
		d = self.designs[0]

		# Get Delay Script
		getDelayScript = "# Get Delays \n"
		getDelayScript += d.createGetDelayScript() + "\n"

		# Initialize Shared Var
		initVarScript = "# Initialize Shared Var \n"
		initVarScript += "set " + ACVar.constraintMet + " 1 \n "

		# Check Constraints
		checkConstraintScript = "# Check Constraints \n"
		checkConstraintScript += d.createCheckConstraintScript()

		# Assemble Function
		script = "# AC_check_constraints Function (Generated Automatically) \n"
		script += "proc " + ACCommand.checkConstraints + " {} { \n"
		script += getDelayScript.replace("\n","\n\t")
		script += initVarScript.replace("\n","\n\t")
		script += checkConstraintScript.replace("\n","\n\t") + "\n"
		script += "\treturn $" + ACVar.constraintMet + " \n"
		script += "} \n"

		return script



	# Multiple constraints to the same wire; Multiplier stuff
	def setConstraintsFunction(self):
		d = self.designs[0]

		# Get Delay Script
		getDelayScript = "# Get Delays \n"
		getDelayScript += d.createGetDelayScript() + "\n"
    
		# Set Constraints
		setConstraintScript = "# Set Constraints \n"
		setConstraintScript += "echo \"\\n**************************************************** \"" + "\n"
		setConstraintScript += "echo \" Setting min_delay Constraints: \"" + "\n\n"
		setConstraintScript += d.createSetConstraintScript()

		# Assemble Function
		script = "# AC_set_constraints Function (Generated Automatically) \n"
		script += "proc " + ACCommand.setConstraints + " {} { \n"
		script += getDelayScript.replace("\n","\n\t")
		script += setConstraintScript.replace("\n","\n\t") + "\n"
		script += "} \n"


		return script



	# TODO: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	def fixDelayFunction(self):
		return ""

	
	def createFunctions(self):
		d = self.designs[0]

		
		# Assemble script
		# Header and variable setup
		script = "#\n# ACSynth Functions (Generated Automatically) \n#\n\n"
		script += self.reportConstraintsFunction() + "\n"
		script += self.checkConstraintsFunction() + "\n"
		script += self.setConstraintsFunction() + "\n"
		script += self.fixDelayFunction() + "\n"


		script_file = open(ACPaths.ACSynth_functions, "w")
		try:
			script_file.write(script)
		finally:
			script_file.close()

		self.createWarningReport()