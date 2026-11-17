import math

class ViterbiDecoder:
    def __init__(self, k, n, constraint_length, generators, soft_decision=False):
        """
        初始化 Viterbi 译码器
        :param k: 输入比特数（通常为 1）
        :param n: 输出比特数
        :param constraint_length: 约束长度 K（寄存器个数为 K-1）
        :param generators: 生成多项式列表（十进制整数），例如 (2,1,3) 码对应 [7, 5] (即 111 和 101)
        :param soft_decision: 是否使用软判决（True: 输入为浮点数/对数似然比; False: 输入为 0/1 硬判决）
        """
        if k != 1:
            raise ValueError("本简化实现仅支持 k=1 的卷积码（每次输入 1 bit）")
        
        self.k = k
        self.n = n
        self.K = constraint_length
        self.num_states = 1 << (self.K - 1)  # 状态数 = 2^(K-1)
        self.soft_decision = soft_decision
        
        # 将生成多项式转换为二进制列表格式，例如 7 -> [1, 1, 1]
        self.generators = []
        for g in generators:
            bin_str = bin(g)[2:].zfill(self.K)
            self.generators.append([int(b) for b in bin_str])
            
        # 预计算状态转移表
        # next_state[state][input] -> next_state
        # output_bits[state][input] -> (out1, out2, ...)
        self.next_state = [[0] * 2 for _ in range(self.num_states)]
        self.output_bits = [[()] * 2 for _ in range(self.num_states)]
        self._build_trellis()

    def _build_trellis(self):
        """构建网格图（状态转移表和输出表）"""
        for state in range(self.num_states):
            for bit in [0, 1]:
                # 寄存器内容：当前输入 bit + 历史状态 (K-1 bits)
                # 注意：不同教材对寄存器位置的约定可能不同，这里假设最高位为最新输入
                register = [bit] + [(state >> i) & 1 for i in range(self.K - 2, -1, -1)]
                
                # 计算输出
                out = []
                for g in self.generators:
                    # 异或操作
                    o = sum(r * gg for r, gg in zip(register, g)) % 2
                    out.append(o)
                self.output_bits[state][bit] = tuple(out)
                
                # 计算下一个状态：输入 bit 进入最高位，丢弃最低位
                next_s = ((bit << (self.K - 2)) | (state >> 1)) if self.K > 1 else 0
                self.next_state[state][bit] = next_s

    def decode(self, received):
        """
        Viterbi 译码主函数
        :param received: 接收到的码字序列（一维 list）
        :return: 译码后的比特序列，以及最优路径的度量值
        """
        if len(received) % self.n != 0:
            raise ValueError("接收序列长度必须是 n 的整数倍")
        
        num_steps = len(received) // self.n
        
        # 初始化路径度量（PM）和幸存路径
        # 从全零状态开始，初始度量设无穷大，除了状态 0
        pm = [float('inf')] * self.num_states
        pm[0] = 0.0
        
        # 记录每个时刻、每个状态的幸存路径
        # path_history[t][state] = (prev_state, input_bit)
        path_history = []

        for t in range(num_steps):
            # 取出当前时刻接收到的 n 个符号
            rx_block = received[t * self.n : (t + 1) * self.n]
            
            new_pm = [float('inf')] * self.num_states
            current_history = [(-1, -1)] * self.num_states
            
            for state in range(self.num_states):
                if pm[state] == float('inf'):
                    continue
                
                for bit in [0, 1]:
                    next_s = self.next_state[state][bit]
                    expected_out = self.output_bits[state][bit]
                    
                    # 计算分支度量
                    if self.soft_decision:
                        # 软判决：接收值为实数，计算欧氏距离平方或相关度量
                        # 这里采用简化的欧氏距离平方
                        branch_metric = sum((r - (-1 if e == 0 else 1)) ** 2 for r, e in zip(rx_block, expected_out))
                    else:
                        # 硬判决：接收值为 0 或 1，计算汉明距离
                        branch_metric = sum(r ^ e for r, e in zip(rx_block, expected_out))
                    
                    # 更新路径度量
                    new_metric = pm[state] + branch_metric
                    
                    # 选择最佳路径（ACS：Add-Compare-Select）
                    if new_metric < new_pm[next_s]:
                        new_pm[next_s] = new_metric
                        current_history[next_s] = (state, bit)
                        
            pm = new_pm
            path_history.append(current_history)

        # 回溯（Traceback）
        # 选择最终度量最小的状态作为终点（通常编码器会以全零状态结尾）
        best_state = min(range(self.num_states), key=lambda s: pm[s])
        best_metric = pm[best_state]
        
        decoded_bits = []
        current_state = best_state
        
        for t in range(num_steps - 1, -1, -1):
            prev_state, bit = path_history[t][current_state]
            decoded_bits.append(bit)
            current_state = prev_state
            
        decoded_bits.reverse()
        return decoded_bits, best_metric


# =========================================================================
# 测试与验证
# =========================================================================
if __name__ == "__main__":
    # 经典 (2,1,3) 卷积码，生成多项式为 (7, 5)_8 => 二进制 111 和 101
    # 约束长度 K=3，码率 1/2
    g_polys = [0b111, 0b101] 
    
    print("="*50)
    print("测试 1：硬判决 Viterbi 译码")
    print("="*50)
    
    # 初始化译码器（硬判决模式）
    decoder_hard = ViterbiDecoder(k=1, n=2, constraint_length=3, generators=g_polys, soft_decision=False)
    
    # 模拟原始发送序列
    original_bits = [1, 0, 1, 1, 0, 0, 1, 0]
    
    # 模拟编码（为了测试，这里直接调用内部状态机生成编码结果）
    encoded_bits = []
    state = 0
    for bit in original_bits:
        encoded_bits.extend(decoder_hard.output_bits[state][bit])
        state = decoder_hard.next_state[state][bit]
    # 尾部补零（Flush），让状态回到 0（可选，但不是必须的）
    # for _ in range(2):
    #     encoded_bits.extend(decoder_hard.output_bits[state][0])
    #     state = decoder_hard.next_state[state][0]
    
    print(f"原始比特: {original_bits}")
    print(f"编码输出: {encoded_bits}")
    
    # 模拟信道噪声：翻转两个比特
    received_hard = encoded_bits.copy()
    received_hard[2] ^= 1  # 翻转第 3 个比特
    received_hard[5] ^= 1  # 翻转第 6 个比特
    print(f"接收序列: {received_hard} (注：有 2 个比特错误)")
    
    decoded, metric = decoder_hard.decode(received_hard)
    print(f"译码结果: {decoded}")
    print(f"路径度量: {metric}")
    
    # 验证是否纠错成功
    if decoded == original_bits:
        print("✅ 硬判决译码成功，成功纠正了错误！")
    else:
        print("❌ 硬判决译码失败。")
        
    print("\n" + "="*50)
    print("测试 2：软判决 Viterbi 译码")
    print("="*50)
    
    # 初始化译码器（软判决模式）
    decoder_soft = ViterbiDecoder(k=1, n=2, constraint_length=3, generators=g_polys, soft_decision=True)
    
    # 模拟软判决接收值：0 映射为 -1.0，1 映射为 1.0，加入高斯噪声
    # 此处的数值模拟 LLR 或带噪信号
    received_soft = [1.2, -0.8, 0.1, 1.1, -1.3, -0.9, 1.5, 0.2, -1.1, -0.8, 1.2, 0.9, -1.4, -0.9, 0.7, -1.2]
    print(f"软判决接收值: {received_soft}")
    
    decoded_soft, metric_soft = decoder_soft.decode(received_soft)
    print(f"译码结果: {decoded_soft}")
    print(f"路径度量: {metric_soft:.2f}")
    
    if decoded_soft == original_bits:
        print("✅ 软判决译码成功，成功解出了原始序列！")
    else:
        print("❌ 软判决译码失败。")