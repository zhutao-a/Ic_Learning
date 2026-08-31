import numpy as np
import matplotlib.pyplot as plt

# =========================
# 1. Parameter settings
# =========================
bits = np.array([1, 0, 1, 1, 0, 0, 1, 0])   # Input binary sequence
f1 = 200                                     # Frequency for bit 1 (Hz)
f0 = 100                                     # Frequency for bit 0 (Hz)
Tb = 0.1                                     # Bit duration (s)
fs = 2000                                    # Sampling frequency (Hz)
A = 1.0                                      # Signal amplitude
phi0 = 0.0                                   # Initial phase (rad)

# Number of samples per bit
N = int(Tb * fs)

# Total number of samples
total_samples = len(bits) * N

# Time axis
t = np.arange(total_samples) / fs

# =========================
# 2. Generate baseband binary waveform
# =========================
# Repeat each bit N times for visualization
baseband = np.repeat(bits, N)
t_baseband = np.arange(len(baseband)) / fs

# =========================
# 3. Generate CPFSK signal
# =========================
# In CPFSK, phase must be continuous across symbol boundaries.
# Therefore, we update the phase sample by sample.

cp_fsk_signal = np.zeros(total_samples)
phase = phi0

for i in range(total_samples):
    # Determine which bit the current sample belongs to
    bit_index = i // N
    current_bit = bits[bit_index]

    # Select frequency according to the current bit
    if current_bit == 1:
        f = f1
    else:
        f = f0

    # Generate the current sample using the accumulated phase
    cp_fsk_signal[i] = A * np.cos(phase)

    # Update phase continuously
    phase += 2 * np.pi * f / fs

# =========================
# 4. Compute spectrum using FFT
# =========================
L = len(cp_fsk_signal)
S = np.fft.fft(cp_fsk_signal)
freq = np.fft.fftfreq(L, d=1/fs)

# Keep only positive frequencies
mask = freq >= 0
freq_pos = freq[mask]
S_mag_pos = np.abs(S[mask]) / L

# Convert to dB scale
S_db = 20 * np.log10(S_mag_pos + 1e-12)

# =========================
# 5. Plot the results
# =========================
fig, axs = plt.subplots(3, 1, figsize=(12, 9))

# ---- Plot 1: Binary sequence ----
axs[0].step(t_baseband, baseband, where='post', color='blue', linewidth=2)
axs[0].set_title('Binary Sequence')
axs[0].set_xlabel('Time (s)')
axs[0].set_ylabel('Bit Value')
axs[0].set_ylim(-0.2, 1.2)
axs[0].set_xlim(0, len(bits) * Tb)
axs[0].grid(True)

# Draw bit boundaries
for k in range(len(bits) + 1):
    axs[0].axvline(k * Tb, color='red', linestyle='--', alpha=0.4)

# ---- Plot 2: CPFSK waveform ----
axs[1].plot(t, cp_fsk_signal, color='green', linewidth=1)
axs[1].set_title('Continuous-Phase FSK Signal (Time Domain)')
axs[1].set_xlabel('Time (s)')
axs[1].set_ylabel('Amplitude')
axs[1].set_xlim(0, len(bits) * Tb)
axs[1].grid(True)

# Draw bit boundaries
for k in range(len(bits) + 1):
    axs[1].axvline(k * Tb, color='red', linestyle='--', alpha=0.4)

# ---- Plot 3: Spectrum ----
axs[2].plot(freq_pos, S_db, color='purple', linewidth=1.2)
axs[2].set_title('Continuous-Phase FSK Spectrum')
axs[2].set_xlabel('Frequency (Hz)')
axs[2].set_ylabel('Magnitude (dB)')
axs[2].set_xlim(0, 400)
axs[2].grid(True)

plt.tight_layout()
plt.show()

# =========================
# 6. Print basic information
# =========================
print("Input binary sequence:", bits)
print("Frequency for bit 1:", f1, "Hz")
print("Frequency for bit 0:", f0, "Hz")
print("Bit duration:", Tb, "s")
print("Sampling frequency:", fs, "Hz")
print("Samples per bit:", N)
print("Total samples:", total_samples)