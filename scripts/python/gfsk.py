import numpy as np
import matplotlib.pyplot as plt

# ==========================
# 1. Bluetooth BR GFSK parameters
# ==========================
bits = np.array([1, 0, 1, 1, 0, 0, 1, 0])  # Input bit sequence
Rb = 1e6
Rs = Rb
Tb = 1 / Rb
BT = 0.5
h = 0.32
A = 1.0
phi0 = 0.0
fc = 2e6
sps = 40
fs = Rs * sps
fdev = h / (2 * Tb)
N = int(Tb * fs)
total_samples = len(bits) * N
t = np.arange(total_samples) / fs

# ==========================
# 2. NRZ bit mapping
# ==========================
symbols = 2 * bits - 1
baseband = np.repeat(symbols, N)
t_baseband = np.arange(len(baseband)) / fs

# ==========================
# 3. Gaussian filter design
# ==========================
span = 4
t_g = np.arange(-span * N, span * N + 1) / fs
B = BT / Tb
g = np.exp(-2 * (np.pi ** 2) * (B ** 2) * (t_g ** 2) / np.log(2))
g = g / np.sum(g)

# ==========================
# 4. Gaussian filtering
# ==========================
conv_full = np.convolve(baseband, g, mode='full')
start = (len(g) - 1) // 2
filtered_baseband = conv_full[start:start + len(baseband)]

# ==========================
# 5. Generate Bluetooth GFSK signal
# ==========================
inst_freq = fc + fdev * filtered_baseband
phase = np.zeros(total_samples)
phase[0] = phi0
for i in range(1, total_samples):
    phase[i] = phase[i - 1] + 2 * np.pi * inst_freq[i - 1] / fs
gfsk_signal = A * np.cos(phase)
gfsk_complex = A * np.exp(1j * (phase - 2 * np.pi * fc * t))

# ==========================
# 6. FFT spectrum
# ==========================
L = len(gfsk_signal)
window = np.hanning(L)
signal_win = gfsk_signal * window
S = np.fft.fft(signal_win)
freq = np.fft.fftfreq(L, d=1 / fs)
cg = np.sum(window) / L
S_mag = np.abs(S) / (L * cg)
mask = freq >= 0
freq_pos = freq[mask]
S_mag_pos = S_mag[mask]
S_db = 20 * np.log10(S_mag_pos + 1e-15)

# ==========================
# 7. Plot results in 3x2 layout
# ==========================
fig, axs = plt.subplots(3, 2, figsize=(12, 12))
axs = axs.flatten()

# Plot 1: Input bits
axs[0].step(t_baseband * 1e6, (baseband + 1) / 2, where='post', color='blue', linewidth=2)
axs[0].set_title('Bluetooth BR Input Bit Sequence')
axs[0].set_xlabel('Time (us)')
axs[0].set_ylabel('Bit Value')
axs[0].set_ylim(-0.2, 1.2)
axs[0].set_xlim(0, len(bits) * Tb * 1e6)
axs[0].grid(True)
for k in range(len(bits) + 1):
    axs[0].axvline(k * Tb * 1e6, color='red', linestyle='--', alpha=0.4)

# Plot 2: Gaussian filtered NRZ
axs[1].plot(t * 1e6, filtered_baseband, color='orange', linewidth=1.5)
axs[1].set_title('Gaussian Filtered Baseband (BT = 0.5)')
axs[1].set_xlabel('Time (us)')
axs[1].set_ylabel('Amplitude')
axs[1].set_xlim(0, len(bits) * Tb * 1e6)
axs[1].grid(True)
for k in range(len(bits) + 1):
    axs[1].axvline(k * Tb * 1e6, color='red', linestyle='--', alpha=0.4)

# Plot 3: Instantaneous frequency
axs[2].plot(t * 1e6, inst_freq / 1e6, color='brown', linewidth=1.2)
axs[2].set_title('Instantaneous Frequency')
axs[2].set_xlabel('Time (us)')
axs[2].set_ylabel('Frequency (MHz)')
axs[2].set_xlim(0, len(bits) * Tb * 1e6)
axs[2].grid(True)
for k in range(len(bits) + 1):
    axs[2].axvline(k * Tb * 1e6, color='red', linestyle='--', alpha=0.4)

# Plot 4: GFSK waveform
axs[3].plot(t * 1e6, gfsk_signal, color='green', linewidth=1)
axs[3].set_title('Bluetooth BR GFSK Signal (Time Domain)')
axs[3].set_xlabel('Time (us)')
axs[3].set_ylabel('Amplitude')
axs[3].set_xlim(0, len(bits) * Tb * 1e6)
axs[3].grid(True)
for k in range(len(bits) + 1):
    axs[3].axvline(k * Tb * 1e6, color='red', linestyle='--', alpha=0.4)

# Plot 5: Spectrum
axs[4].plot(freq_pos / 1e6, S_db, color='purple', linewidth=1.2)
axs[4].set_title('Bluetooth BR GFSK Spectrum')
axs[4].set_xlabel('Frequency (MHz)')
axs[4].set_ylabel('Magnitude (dB)')
axs[4].set_xlim(max(0, (fc - 1.5e6) / 1e6), (fc + 1.5e6) / 1e6)
axs[4].grid(True)

# Hide the unused subplot
axs[5].axis('off')

plt.tight_layout()

plt.show()

# ==========================
# 8. Print basic information
# ==========================
print("Input binary sequence:", bits)
print("Mapped symbols:", symbols)
print("Bluetooth BR bit rate: %.3f Mbps" % (Rb / 1e6))
print("Bit duration: %.3f us" % (Tb * 1e6))
print("BT product:", BT)
print("Modulation index h:", h)
print("Frequency deviation: %.1f kHz" % (fdev / 1e3))
print("Samples per symbol:", sps)
print("Sampling frequency: %.1f MHz" % (fs / 1e6))
print("Carrier frequency for simulation: %.1f MHz" % (fc / 1e6))
print("Total samples:", total_samples)
print("Lengths -> t:", len(t), " baseband:", len(baseband), " filter:", len(g), " filtered_baseband:", len(filtered_baseband))