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
import pickle
from ACBase import ACPaths, ACSettings, ACCommand, ACVar
from ACSynth_f import ACSynth

# Script Header
script = "# ACStart Script (Generated Automatically) \n\n"

# Read available_paths_report
paths = []
for line in open(ACPaths.available_paths_report).readlines():
	paths.append(line.strip("\n"))

# Load ACSynth
synth_temp = open(ACPaths.ACSynth_temp, "r")
try:
	s = pickle.load(open(ACPaths.ACSynth_temp, "r"))
finally:
	synth_temp.close()

# Generate Runloop scripts
s.checkDesigns(paths)
s.createFunctions()

# Load Functions
script += "source " + ACPaths.ACSynth_functions + "\n"

# Report Constraints
script += "source " + ACPaths.ACSynth_warnings

# Write script
script_file = open(ACPaths.ACStart_script, "w")
try:
	script_file.write(script)
finally:
	script_file.close()
