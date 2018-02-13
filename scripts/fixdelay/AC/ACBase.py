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

import os

# Settings
class ACSettings(object):
	pass


# Paths
class ACPaths(object):
	# Folders
	work_folder = "work/ACRun/"
	script_folder = os.environ["EDGE_ROOT"] + "/scripts/fixdelay/AC/"

	# Files (Check Paths)
	ACCheckPaths_script = work_folder + "ACCheckPaths.tcl"
	available_paths_report = work_folder + "available_paths.rpt"

	# Files (Functions)
	ACSynth_functions = work_folder + "AC_functions.tcl"
	ACSynth_warnings = work_folder + "AC_warnings.tcl"

	# Files
	ACInit = script_folder + "ACInit.py"
	ACInit_script = work_folder + "ACInit.tcl"
	ACStart = script_folder + "ACStart.py"
	ACStart_script = work_folder + "ACStart.tcl"

	# Temporary Files
	ACSynth_temp = work_folder + "ACSynth.data"
	


# Commands
class ACCommand(object):
	# AC Command Names
	reportConstraints = "AC_report_constraints"
	checkConstraints = "AC_check_constraints"
	setConstraints = "AC_set_constraints"

	# DC/ICC Commands
	setMinDelay = "custom_set_min_delay"

	# External Commands
	getDelay = "custom_get_delay"
	maxOfArray = "custom_max"
	report_paths = "custom_report_existent"


# TCL Variables
class ACVar(object):
	prefix = "AC_"

	# Global Vars
	maxIterations = prefix + "maxIterations"
	constraintMet = prefix + "allConstOK"
	
	# Shared Vars
	sharedBase = prefix + "aux_base"
	sharedEnforced = prefix + "aux_enforced"
	sharedDelta = prefix + "aux_delta"
	sharedAux = prefix + "aux"

	# Path and Constraint
	path = prefix + "path"
	constraint = prefix + "cnst"


# Base Object
class ACObject(object):
	def __init__(self):
		super(ACObject, self).__init__()
		self.id = ["ACObject"]

	def getID(self):
		return self.id[-1]

	def isInstance(self, className):
		return (className in self.id)
		

# Exception Classes
class ACException(Exception):
	def __init__(self, origin, cause):
		self.origin = origin
		self.cause = cause


	def description(self):
		return self.origin + " - " + self.cause


class ACConstraintException(ACException):
	def __init__(self, cause):
		origin = "Constraint"
		ACException.__init__(self, origin, cause)


class ACPathException(ACException):
	def __init__(self, cause):
		origin = "Path"
		ACException.__init__(self, origin, cause)


class ACSetException(ACException):
	def __init__(self, cause):
		origin = "Set"
		ACException.__init__(self, origin, cause)


class ACRelativeTimingException(ACException):
	def __init__(self, cause):
		origin = "Constraint"
		ACException.__init__(self, origin, cause)


class ACDesignException(ACException):
	def __init__(self, cause):
		origin = "Design"
		ACException.__init__(self, origin, cause)


class ACParserException(ACException):
	def __init__(self, cause):
		origin = "Parser"
		ACException.__init__(self, origin, cause)

class ACSynthException(ACException):
	def __init__(self, cause):
		origin = "Synthesis"
		ACException.__init__(self, origin, cause)


