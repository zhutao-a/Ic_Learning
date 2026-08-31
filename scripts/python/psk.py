# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt
import math

# ==========================
# 1. Parameter settings
# ==========================
mod_type = 'QPSK'   # 'BPSK', 'QPSK', '8PSK'
rolloff = 0.4       # SRRC roll-off factor
A = 1.0             # Carrier amplitude
fc = 10e6           # Carrier frequency (Hz)
Rs = 1e6            # Symbol rate (symbols/s)
T = 1.0 / Rs        # Symbol period (s)
sps = 16            # Samples per symbol
fs = Rs * sps       # Sampling frequency (Hz)
num_symbols = 100

# Generate random input bits
np.random.seed(0)
if mod_type == 'BPSK':
    bits_per_symbol = 1
elif mod_type == 'QPSK':
    bits_per_symbol = 2
elif mod_type == '8PSK':
    bits_per_symbol = 3
else:
    raise ValueError("Unsupported modulation type")

num_bits = num_symbols * bits_per_symbol
bits = np.random.randint(0, 2, num_bits)

# ==========================
# 2. SRRC filter design
# ==========================
def srrc_filter(beta, T, sps, span):
    # Generate Square-Root Raised Cosine (SRRC) filter coefficients
    N = span * sps
    t = np.arange(-N / 2, N / 2 + 1) / sps * T
    h = np.zeros_like(t)

    for i in range(len(t)):
        ti = t[i]
        if abs(ti) < 1e-12:
            h[i] = (1.0 / np.sqrt(T)) * (1 - beta + 4 * beta / np.pi)
        elif beta > 0 and abs(abs(ti) - T / (4 * beta)) < 1e-12:
            h[i] = (beta / np.sqrt(2 * T)) * (
                (1 + 2 / np.pi) * np.sin(np.pi / (4 * beta)) +
                (1 - 2 / np.pi) * np.cos(np.pi / (4 * beta))
            )
        else:
            numerator = (
                np.sin(np.pi * ti * (1 - beta) / T) +
                4 * beta * ti / T * np.cos(np.pi * ti * (1 + beta) / T)
            )
            denominator = np.pi * ti / T * (1 - (4 * beta * ti / T) ** 2)
            h[i] = (1.0 / np.sqrt(T)) * numerator / denominator

    h = h / np.sqrt(np.sum(h ** 2))
    return t, h

span = 8
t_h, h_srrc = srrc_filter(rolloff, T, sps, span)

# ==========================
# 3. Symbol mapping
# ==========================
def bits_to_symbols(bits, mod_type):
    # Map input bits to complex modulation symbols
    if mod_type == 'BPSK':
        symbols = 2 * bits - 1
        return symbols.astype(complex)
    elif mod_type == 'QPSK':
        bits_reshaped = bits.reshape(-1, 2)
        symbols = []
        for b0, b1 in bits_reshaped:
            if (b0, b1) == (0, 0):
                s = 1 + 1j
            elif (b0, b1) == (0, 1):
                s = -1 + 1j
            elif (b0, b1) == (1, 1):
                s = -1 - 1j
            else:
                s = 1 - 1j
            symbols.append(s / np.sqrt(2))
        return np.array(symbols)
    elif mod_type == '8PSK':
        bits_reshaped = bits.reshape(-1, 3)
        mapping = {
            (0, 0, 0): 0,
            (0, 0, 1): 1,
            (0, 1, 1): 2,
            (0, 1, 0): 3,
            (1, 1, 0): 4,
            (1, 1, 1): 5,
            (1, 0, 1): 6,
            (1, 0, 0): 7,
        }
        symbols = []
        for b in bits_reshaped:
            k = mapping[tuple(b)]
            phase = 2 * np.pi * k / 8.0
            s = np.exp(1j * phase)
            symbols.append(s)
        return np.array(symbols)

symbols = bits_to_symbols(bits, mod_type)

# ==========================
# 4. Upsampling
# ==========================
I_symbols = np.real(symbols)
Q_symbols = np.imag(symbols)

I_up = np.zeros(len(I_symbols) * sps)
Q_up = np.zeros(len(Q_symbols) * sps)

I_up[::sps] = I_symbols
Q_up[::sps] = Q_symbols

baseband_before_srrc = I_up + 1j * Q_up

# ==========================
# 5. SRRC pulse shaping
# ==========================
I_shaped = np.convolve(I_up, h_srrc, mode='same')
Q_shaped = np.convolve(Q_up, h_srrc, mode='same')
baseband_signal = I_shaped + 1j * Q_shaped
N_total = len(baseband_signal)
t = np.arange(N_total) / fs

# ==========================
# 6. Passband PSK modulation
# ==========================
carrier_I = np.cos(2 * np.pi * fc * t)
carrier_Q = np.sin(2 * np.pi * fc * t)
psk_signal = A * (I_shaped * carrier_I - Q_shaped * carrier_Q)

# ==========================
# 7. FFT spectrum calculation
# ==========================
L = len(psk_signal)
S = np.fft.fft(psk_signal)
freq = np.fft.fftfreq(L, d=1.0 / fs)
mask = freq >= 0
freq_pos = freq[mask]
S_mag_pos = np.abs(S[mask]) / L
S_db = 20 * np.log10(S_mag_pos + 1e-12)
S_bb = np.fft.fft(baseband_signal)
S_bb_mag = np.abs(S_bb[mask]) / L
S_bb_db = 20 * np.log10(S_bb_mag + 1e-12)

# ==========================
# 8. Prepare plot items
# ==========================
plot_items = []
bit_wave = np.repeat(bits, sps)
t_bit = np.arange(len(bit_wave)) / fs

plot_items.append(("bits", (t_bit, bit_wave)))
plot_items.append(("constellation", symbols))
plot_items.append(("baseband_before_srrc", (t, I_up, Q_up)))
plot_items.append(("baseband_after_srrc", (t, I_shaped, Q_shaped)))
plot_items.append(("passband", (t, psk_signal)))
plot_items.append(("spectrum", (freq_pos, S_db, S_bb_db)))

# ==========================
# 9. Plot figures with at most 6 subplots per figure (3x2)
# ==========================
plots_per_fig = 6
num_figs = math.ceil(len(plot_items) / plots_per_fig)

for fig_idx in range(num_figs):
    start = fig_idx * plots_per_fig
    end = min(start + plots_per_fig, len(plot_items))
    current_items = plot_items[start:end]
    fig, axs = plt.subplots(3, 2, figsize=(14, 10))
    axs = np.array(axs).reshape(-1)
    for ax_idx, item in enumerate(current_items):
        ax = axs[ax_idx]
        kind = item[0]
        data = item[1]
        if kind == "bits":
            t_bit, bit_wave = data
            ax.step(t_bit, bit_wave, where='post', color='blue', linewidth=1.5)
            ax.set_title(mod_type + ' Input Binary Sequence')
            ax.set_xlabel('Time (s)')
            ax.set_ylabel('Bit Value')
            ax.set_ylim(-0.2, 1.2)
            ax.grid(True)
        elif kind == "constellation":
            symbols_plot = data
            ax.scatter(np.real(symbols_plot), np.imag(symbols_plot), color='red', s=30)
            ax.set_title(mod_type + ' Constellation')
            ax.set_xlabel('In-Phase')
            ax.set_ylabel('Quadrature')
            ax.axis('equal')
            ax.grid(True)
        elif kind == "baseband_before_srrc":
            t0, I0, Q0 = data
            ax.plot(t0, I0, label='I_before(t)', linewidth=1.2)
            ax.plot(t0, Q0, label='Q_before(t)', linewidth=1.2)
            ax.set_title(mod_type + ' Baseband Before SRRC')
            ax.set_xlabel('Time (s)')
            ax.set_ylabel('Amplitude')
            ax.legend()
            ax.grid(True)
        elif kind == "baseband_after_srrc":
            t1, I1, Q1 = data
            ax.plot(t1, I1, label='I_after(t)', linewidth=1.2)
            ax.plot(t1, Q1, label='Q_after(t)', linewidth=1.2)
            ax.set_title(mod_type + ' Baseband After SRRC')
            ax.set_xlabel('Time (s)')
            ax.set_ylabel('Amplitude')
            ax.legend()
            ax.grid(True)
        elif kind == "passband":
            t2, sig = data
            ax.plot(t2, sig, color='green', linewidth=1.0)
            ax.set_title(mod_type + ' Passband Signal')
            ax.set_xlabel('Time (s)')
            ax.set_ylabel('Amplitude')
            ax.grid(True)
        elif kind == "spectrum":
            f, S1_db, S2_db = data
            ax.plot(f / 1e6, S1_db, color='purple', linewidth=1.2, label='Passband Spectrum')
            ax.plot(f / 1e6, S2_db, color='orange', linewidth=1.0, alpha=0.8, label='Baseband Spectrum')
            ax.set_title(mod_type + ' Spectrum')
            ax.set_xlabel('Frequency (MHz)')
            ax.set_ylabel('Magnitude (dB)')
            ax.set_xlim(0, min(fs / 2, 20e6) / 1e6)
            ax.legend()
            ax.grid(True)
    for k in range(len(current_items), 6):
        axs[k].axis('off')
    fig.suptitle(f'Figure {fig_idx + 1}', fontsize=14)
    plt.tight_layout(rect=[0, 0, 1, 0.96])

plt.show()

# ==========================
# 10. Print basic information
# ==========================
print("Modulation type:", mod_type)
print("Input binary sequence:", bits)
print("Roll-off factor:", rolloff)
print("Symbol rate:", Rs, "symbols/s")
print("Symbol period:", T, "s")
print("Sampling frequency:", fs, "Hz")
print("Samples per symbol:", sps)
print("Carrier frequency:", fc, "Hz")
print("Number of symbols:", num_symbols)
print("Total samples:", N_total)