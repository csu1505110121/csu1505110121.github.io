#!/bin/python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

filename = 'example_ir.txt'

peak = []
broad = []

with open(filename,'r') as f:
	while True:
		line = f.readline()
		if not line:
			break
		else:
			if '# Peak information' in line:
				line = f.readline()
				for x in range(100000):
					line = f.readline()
					if '#' not in line:
						break
					else:
						peak.append([float(line.split()[1]),float(line.split()[2])])

with open(filename,'r')	as f:
	while True:
		line = f.readline()
		if not line:
			break
		else:		
			if '# Spectra' in line:
				line = f.readline()
				for x in range(1000000):
					line = f.readline()
					if len(line.strip()) == 0:
						break
					else:
						broad.append([float(line.split()[0]),float(line.split()[1]),float(line.split()[2])])

#print(np.array(peak))
#print(np.array(broad))
fig, ax = plt.subplots(figsize=(12,8))

peak = np.array(peak)
broad = np.array(broad)

#print(peak.shape[0])

ax.plot(broad[:,0],broad[:,1],color='black',linestyle='-')

ax2 = ax.twinx()
for x in np.arange(peak.shape[0]):
	ax2.vlines(peak[x][0],0,peak[x][1],color='blue',linestyle='-')

ax2.set_ylim(-30,1600)
ax2.yaxis.set_ticks(np.arange(0,1500.1,500))
ax2.yaxis.set_tick_params(labelsize=14, color='blue')
ax2.spines['right'].set_color('blue')
ax2.xaxis.label.set_color('blue')
ax2.tick_params(axis='y',colors='blue')
ax2.set_ylabel(r'$Intensity~(10^{-40} esu^2 cm^2)$',fontsize=18,fontfamily='sans-serif',fontstyle='italic',color='blue',rotation=-90,labelpad=20)

ax.set_xlabel(r'Frequency $(cm^{-1})$',fontsize=18,fontfamily='sans-serif',fontstyle='italic')
ax.set_ylabel(r'$\epsilon~(M^{-1}cm^{-1})$',fontsize=18,fontfamily='sans-serif',fontstyle='italic')

ax.set_xlim(0,1800)
ax.set_ylim(-30,1600)

ax.xaxis.set_tick_params(labelsize=14)
ax.yaxis.set_tick_params(labelsize=14)

ax.xaxis.set_ticks(np.arange(0,1800.1,300))
ax.yaxis.set_ticks(np.arange(0,1500.1,500))

plt.tight_layout()

#plt.savefig('examplt_ir_broaden.png',dpi=1000,bbox_inches='tight')

plt.show()
			
