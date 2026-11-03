import os
# 导入刚才写的 AES 底层函数（请确保你的文件名为 aes_128.py，使用下划线）
from aes_128 import key_expansion, encrypt_block, xor_bytes

# =========================================================================
# CCM 参数说明（本脚本固定为 AES-128-CCM）
#   - 密钥长度: 16 字节
#   - nonce 长度: 13 字节  => L = 15 - 13 = 2（长度字段 2 字节）
#   - tag 长度: 16 字节    => M' = (16-2)//2 = 7
# =========================================================================

TAG_LEN = 16
NONCE_LEN = 13
L = 15 - NONCE_LEN          # 2
M_PRIME = (TAG_LEN - 2) // 2  # 7


def pad16(data: bytes) -> bytes:
    """补零到 16 字节的整数倍（注意：CCM 的 CBC-MAC 用的是零填充，不是 PKCS7）"""
    r = len(data) % 16
    return data if r == 0 else data + b'\x00' * (16 - r)


def format_b0(nonce: bytes, msg_len: int, aad_len: int) -> bytes:
    """
    构造 B0 块（RFC 3610 第 2.2 节）
    Flags = 64*Adata + 8*M' + L'
    """
    L_prime = L - 1              # 1
    adata = 1 if aad_len > 0 else 0
    flags = (adata << 6) | (M_PRIME << 3) | L_prime
    return bytes([flags]) + nonce + msg_len.to_bytes(L, 'big')


def format_aad(aad: bytes) -> bytes:
    """
    AAD 格式化：长度编码 + AAD 本体 + 补零。
    简化实现：仅支持 aad 长度 < 0xFF00（两字节长度编码）。
    """
    if not aad:
        return b''
    la = len(aad)
    if la < 0xFF00:
        len_enc = la.to_bytes(2, 'big')
    else:
        raise ValueError("AAD 过长，本简化实现仅支持 < 0xFF00 字节")
    return pad16(len_enc + aad)


def cbc_mac(key_schedule, b0: bytes, aad: bytes, plaintext: bytes) -> bytes:
    """
    计算 CBC-MAC 值（X_{n+1}）。
    输入 = B0 || 格式化AAD || 补零明文，逐块 AES 加密后异或。
    """
    mac_input = b0 + format_aad(aad) + pad16(plaintext)

    x = bytes(16)  # CBC-MAC 初始向量全零
    for i in range(0, len(mac_input), 16):
        block = mac_input[i:i+16]
        x = encrypt_block(xor_bytes(x, block), key_schedule)
    return x


def ctr_crypt(key_schedule, nonce: bytes, data: bytes, start_counter: int = 1) -> bytes:
    """
    CTR 模式加/解密（对称操作）。
    A_i = Flags || nonce || counter，其中 Flags = L-1。
    """
    out = b''
    for i in range(0, len(data), 16):
        ctr = start_counter + i // 16
        ai = bytes([L - 1]) + nonce + ctr.to_bytes(L, 'big')
        si = encrypt_block(ai, key_schedule)
        chunk = data[i:i+16]
        out += xor_bytes(chunk, si[:len(chunk)])
    return out


def aes_ccm_encrypt(key: bytes, nonce: bytes, plaintext: bytes, aad: bytes = b'') -> bytes:
    """
    AES-128-CCM 加密。
    返回：密文 || 16字节 tag
    """
    if len(key) != 16:
        raise ValueError("密钥必须为 16 字节（AES-128）")
    if len(nonce) != NONCE_LEN:
        raise ValueError(f"nonce 必须为 {NONCE_LEN} 字节")

    key_schedule = key_expansion(key)
    msg_len = len(plaintext)

    # 1) CBC-MAC 计算认证值
    b0 = format_b0(nonce, msg_len, len(aad))
    mac = cbc_mac(key_schedule, b0, aad, plaintext)

    # 2) 用 counter=0 的密钥流 S0 加密 MAC，得到 tag
    a0 = bytes([L - 1]) + nonce + (0).to_bytes(L, 'big')
    s0 = encrypt_block(a0, key_schedule)
    tag = xor_bytes(mac, s0)

    # 3) 用 counter=1,2,... 的密钥流加密明文
    ciphertext = ctr_crypt(key_schedule, nonce, plaintext, start_counter=1)

    return ciphertext + tag


def aes_ccm_decrypt(key: bytes, nonce: bytes, ciphertext_with_tag: bytes, aad: bytes = b'') -> bytes:
    """
    AES-128-CCM 解密并校验 tag。
    输入格式：密文 || 16字节 tag
    校验失败抛 ValueError。
    """
    if len(key) != 16:
        raise ValueError("密钥必须为 16 字节（AES-128）")
    if len(nonce) != NONCE_LEN:
        raise ValueError(f"nonce 必须为 {NONCE_LEN} 字节")
    if len(ciphertext_with_tag) < TAG_LEN:
        raise ValueError("输入数据过短，缺少 tag")

    ciphertext = ciphertext_with_tag[:-TAG_LEN]
    received_tag = ciphertext_with_tag[-TAG_LEN:]
    msg_len = len(ciphertext)

    key_schedule = key_expansion(key)

    # 1) CTR 解密得到明文
    plaintext = ctr_crypt(key_schedule, nonce, ciphertext, start_counter=1)

    # 2) 重新计算 MAC 与 tag
    b0 = format_b0(nonce, msg_len, len(aad))
    mac = cbc_mac(key_schedule, b0, aad, plaintext)

    a0 = bytes([L - 1]) + nonce + (0).to_bytes(L, 'big')
    s0 = encrypt_block(a0, key_schedule)
    expected_tag = xor_bytes(mac, s0)

    # 3) 恒定时间比较 tag
    diff = 0
    for a, b in zip(received_tag, expected_tag):
        diff |= a ^ b
    if diff != 0:
        raise ValueError("tag 校验失败，数据可能被篡改")

    return plaintext


# =========================================================================
# 测试与运行
# =========================================================================
if __name__ == "__main__":
    KEY = b"MySuperSecretKey"   # 16 字节
    NONCE = os.urandom(13)      # 13 字节
    AAD = b"header-info"

    message = "AES-CCM 基于已有 aes-128 实现"
    print(f"【原始明文】: {message}")

    pt = message.encode('utf-8')
    enc = aes_ccm_encrypt(KEY, NONCE, pt, AAD)
    print(f"【nonce】   : {NONCE.hex()}")
    print(f"【密文+tag】: {enc.hex()}")

    dec = aes_ccm_decrypt(KEY, NONCE, enc, AAD)
    print(f"【解密结果】: {dec.decode('utf-8')}")

    assert dec == pt
    print("✅ AES-CCM 加解密成功且内容一致！")