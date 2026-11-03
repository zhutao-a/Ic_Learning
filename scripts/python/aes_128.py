import os

# =========================================================================
# 1. 核心常量：S盒 (S-Box) 与逆S盒 (Inverse S-Box)
# 作用：提供非线性变换，是 AES 安全性的核心
# =========================================================================
SBOX = [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
]

INV_SBOX = [
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
]

# 轮常量 (Round Constants)，用于密钥扩展
RCON = [0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36]

# =========================================================================
# 2. 伽罗华域 GF(2^8) 乘法运算
# 作用：MixColumns (列混淆) 操作必需的底层数学运算
# =========================================================================
def xtime(a):
    """GF(2^8) 域中乘以 x (也就是乘以 2)"""
    return (((a << 1) ^ 0x1b) & 0xff) if (a & 0x80) else (a << 1)

def gf_mult(a, b):
    """GF(2^8) 域中的乘法"""
    p = 0
    for _ in range(8):
        if b & 1: p ^= a
        a = xtime(a)
        b >>= 1
    return p

# =========================================================================
# 3. AES 核心变换操作 (针对 4x4 状态矩阵)
# =========================================================================
def sub_bytes(state):
    """字节代换 (非线性替换)"""
    for r in range(4):
        for c in range(4):
            state[r][c] = SBOX[state[r][c]]

def inv_sub_bytes(state):
    """逆字节代换"""
    for r in range(4):
        for c in range(4):
            state[r][c] = INV_SBOX[state[r][c]]

def shift_rows(state):
    """行移位 (打乱结构，提供扩散作用)"""
    state[1][0], state[1][1], state[1][2], state[1][3] = state[1][1], state[1][2], state[1][3], state[1][0]
    state[2][0], state[2][1], state[2][2], state[2][3] = state[2][2], state[2][3], state[2][0], state[2][1]
    state[3][0], state[3][1], state[3][2], state[3][3] = state[3][3], state[3][0], state[3][1], state[3][2]

def inv_shift_rows(state):
    """逆行移位"""
    state[1][0], state[1][1], state[1][2], state[1][3] = state[1][3], state[1][0], state[1][1], state[1][2]
    state[2][0], state[2][1], state[2][2], state[2][3] = state[2][2], state[2][3], state[2][0], state[2][1]
    state[3][0], state[3][1], state[3][2], state[3][3] = state[3][1], state[3][2], state[3][3], state[3][0]

def mix_columns(state):
    """列混淆 (GF域矩阵相乘，进一步提供扩散作用)"""
    for c in range(4):
        s0, s1, s2, s3 = state[0][c], state[1][c], state[2][c], state[3][c]
        state[0][c] = gf_mult(0x02, s0) ^ gf_mult(0x03, s1) ^ s2 ^ s3
        state[1][c] = s0 ^ gf_mult(0x02, s1) ^ gf_mult(0x03, s2) ^ s3
        state[2][c] = s0 ^ s1 ^ gf_mult(0x02, s2) ^ gf_mult(0x03, s3)
        state[3][c] = gf_mult(0x03, s0) ^ s1 ^ s2 ^ gf_mult(0x02, s3)

def inv_mix_columns(state):
    """逆列混淆"""
    for c in range(4):
        s0, s1, s2, s3 = state[0][c], state[1][c], state[2][c], state[3][c]
        state[0][c] = gf_mult(0x0e, s0) ^ gf_mult(0x0b, s1) ^ gf_mult(0x0d, s2) ^ gf_mult(0x09, s3)
        state[1][c] = gf_mult(0x09, s0) ^ gf_mult(0x0e, s1) ^ gf_mult(0x0b, s2) ^ gf_mult(0x0d, s3)
        state[2][c] = gf_mult(0x0d, s0) ^ gf_mult(0x09, s1) ^ gf_mult(0x0e, s2) ^ gf_mult(0x0b, s3)
        state[3][c] = gf_mult(0x0b, s0) ^ gf_mult(0x0d, s1) ^ gf_mult(0x09, s2) ^ gf_mult(0x0e, s3)

def add_round_key(state, w, round_num):
    """轮密钥加 (状态矩阵与当前轮密钥进行异或)"""
    for c in range(4):
        for r in range(4):
            state[r][c] ^= w[round_num * 4 + c][r]

# =========================================================================
# 4. 密钥扩展算法 (Key Expansion)
# 作用：把 16 字节(128位) 的初始密钥扩展成 11 组子密钥 (44 个字)
# =========================================================================
def key_expansion(key: bytes):
    w = [[0, 0, 0, 0] for _ in range(44)]
    # 前四个字直接来自原始密钥
    for i in range(4):
        w[i] = [key[4*i], key[4*i+1], key[4*i+2], key[4*i+3]]

    for i in range(4, 44):
        temp = w[i-1][:]
        if i % 4 == 0:
            # 字循环 (RotWord) + 字节代换 (SubWord) + 轮常量异或 (Rcon)
            temp = [temp[1], temp[2], temp[3], temp[0]]
            temp = [SBOX[b] for b in temp]
            temp[0] ^= RCON[i // 4]
        # w[i] = w[i-4] XOR temp
        w[i] = [w[i-4][k] ^ temp[k] for k in range(4)]
    return w

# =========================================================================
# 5. 单个 Block (16字节) 的加解密
# =========================================================================
def encrypt_block(block: bytes, key_schedule) -> bytes:
    """加密一个 16 字节的区块"""
    state = [[0]*4 for _ in range(4)]
    # 按列主序装载进 4x4 状态矩阵
    for r in range(4):
        for c in range(4):
            state[r][c] = block[r + 4*c]

    # 第 0 轮：初始轮密钥加
    add_round_key(state, key_schedule, 0)

    # 第 1 到 9 轮
    for i in range(1, 10):
        sub_bytes(state)
        shift_rows(state)
        mix_columns(state)
        add_round_key(state, key_schedule, i)

    # 第 10 轮 (不包含列混淆)
    sub_bytes(state)
    shift_rows(state)
    add_round_key(state, key_schedule, 10)

    # 状态矩阵转回 1D 字节流
    out = [0]*16
    for r in range(4):
        for c in range(4):
            out[r + 4*c] = state[r][c]
    return bytes(out)

def decrypt_block(block: bytes, key_schedule) -> bytes:
    """解密一个 16 字节的区块"""
    state = [[0]*4 for _ in range(4)]
    for r in range(4):
        for c in range(4):
            state[r][c] = block[r + 4*c]

    # 逆向的第 10 轮
    add_round_key(state, key_schedule, 10)

    # 逆向的第 9 到 1 轮
    for i in range(9, 0, -1):
        inv_shift_rows(state)
        inv_sub_bytes(state)
        add_round_key(state, key_schedule, i)
        inv_mix_columns(state)

    # 逆向的第 0 轮
    inv_shift_rows(state)
    inv_sub_bytes(state)
    add_round_key(state, key_schedule, 0)

    out = [0]*16
    for r in range(4):
        for c in range(4):
            out[r + 4*c] = state[r][c]
    return bytes(out)

# =========================================================================
# 6. 高层封装：PKCS7 填充机制 + CBC 工作模式
# 作用：让算法可以加密任意长度的字符串，而不仅限于16字节的整倍数
# =========================================================================
def pad(data: bytes) -> bytes:
    """PKCS7 填充算法"""
    padding_len = 16 - (len(data) % 16)
    return data + bytes([padding_len] * padding_len)

def unpad(data: bytes) -> bytes:
    """去除 PKCS7 填充"""
    padding_len = data[-1]
    return data[:-padding_len]

def xor_bytes(a: bytes, b: bytes) -> bytes:
    """按位异或两个字节数组"""
    return bytes(x ^ y for x, y in zip(a, b))

def aes128_cbc_encrypt(plaintext: bytes, key: bytes, iv: bytes) -> bytes:
    """AES-128 CBC 模式加密"""
    assert len(key) == 16, "AES-128 需要 16 字节密钥"
    assert len(iv) == 16, "IV 必须是 16 字节"

    padded_data = pad(plaintext)
    key_schedule = key_expansion(key)
    ciphertext = b''
    prev_block = iv

    for i in range(0, len(padded_data), 16):
        block = padded_data[i:i+16]
        # CBC 特性：明文块先与上一个密文块(或IV)异或，再加密
        block = xor_bytes(block, prev_block)
        enc_block = encrypt_block(block, key_schedule)
        ciphertext += enc_block
        prev_block = enc_block

    return ciphertext

def aes128_cbc_decrypt(ciphertext: bytes, key: bytes, iv: bytes) -> bytes:
    """AES-128 CBC 模式解密"""
    assert len(key) == 16, "AES-128 需要 16 字节密钥"
    assert len(ciphertext) % 16 == 0, "密文长度必须是16的倍数"

    key_schedule = key_expansion(key)
    plaintext = b''
    prev_block = iv

    for i in range(0, len(ciphertext), 16):
        block = ciphertext[i:i+16]
        dec_block = decrypt_block(block, key_schedule)
        # 解密后的块再与上一个密文块(或IV)异或，还原真实明文
        plaintext += xor_bytes(dec_block, prev_block)
        prev_block = block

    return unpad(plaintext)

# =========================================================================
# 7. 测试与运行
# =========================================================================
if __name__ == "__main__":
    # AES-128 需要精确的 16 字节密钥 (128 bits)
    KEY = b"MySuperSecretKey"

    # 随机生成一个 16 字节的 IV (初始化向量)
    IV = os.urandom(16)

    message = "底层 AES 原理：从零手写加解密 (No Plugins!)"
    print(f"【原始明文】: {message}\n")

    # 将字符串转为字节序列
    msg_bytes = message.encode('utf-8')

    # 执行加密
    encrypted_bytes = aes128_cbc_encrypt(msg_bytes, KEY, IV)
    print(f"【加密结果】 (Hex格式): {encrypted_bytes.hex()}\n")

    # 执行解密
    decrypted_bytes = aes128_cbc_decrypt(encrypted_bytes, KEY, IV)
    print(f"【解密结果】: {decrypted_bytes.decode('utf-8')}\n")

    # 断言确认
    assert msg_bytes == decrypted_bytes
    print("✅ 加解密成功且内容一致！")