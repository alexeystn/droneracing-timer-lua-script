#from matplotlib import pyplot as plt
import numpy as np
import wave

beeps =[  # name, frequency, length
    ['ready',   3200, 0.1],
    ['start',   1600, 0.8],
    ['warning', 1200, 0.8],
    ['finish',  2400, 0.8] ]

path = './'

for b in beeps:

    name = b[0]
    frequency = b[1] # sound, Hz
    tFull = b[2] # seconds
    amplitude = 0.5 # must be less than 1.0
    Fs = 32000 # sample rate, Hz
    tFade = 0.01 # seconds

    timeline = np.arange(0, tFull, 1/Fs)
    envelope = np.array([t/tFade if t < tFade
                         else (tFull - t)/tFade if (tFull - t) < tFade
                         else 1 for t in timeline])
    
    # square wave with 3rd and 5th harmonics
    waveform = np.sin(frequency * np.pi * timeline)
    waveform = waveform + np.sin(frequency * 3 * np.pi * timeline) / 3
    waveform = waveform + np.sin(frequency * 5 * np.pi * timeline) / 5 

    sound = (waveform * envelope * amplitude * (2**15-1)).astype('int16')

    wavFile = wave.open(path + name + '.wav', 'w')
    wavFile.setparams((1, 2, Fs, 0, 'NONE', 'not compressed'))
    wavFile.writeframes(sound.tobytes())
    wavFile.close()
    
    print(name)

    # plt.plot(sound)
    # plt.title(name)
    # plt.show()
