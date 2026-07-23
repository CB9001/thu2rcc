#include <iostream>
#include <fstream>
#include <vector>
#include <unordered_set>
#include <string>
#include <cuda.h>
#include <cuda_runtime.h>
#include <chrono>
#include <algorithm>
#include <iomanip>

#define THREADS_PER_BLOCK 256

__device__ const uint32_t crc32LookupTable[256] = {
    0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E,
    0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB,
    0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8,
    0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940,
    0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599,
    0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
    0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433, 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB,
    0x086D3D2D, 0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457,
    0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE, 0xA3BC0074,
    0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5,
    0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F, 0x5EDEF90E,
    0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
    0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27,
    0x7D079EB1, 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0,
    0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1,
    0xA6BC5767, 0x3FB506DD, 0x48B2364B, 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79,
    0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92,
    0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
    0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4,
    0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C,
    0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D,
    0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9, 0xBDBDF21C, 0xCABAC28A,
    0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37,
    0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D
};

__device__ const char digitPairs[200] = {
    '0','0','0','1','0','2','0','3','0','4','0','5','0','6','0','7','0','8','0','9',
    '1','0','1','1','1','2','1','3','1','4','1','5','1','6','1','7','1','8','1','9',
    '2','0','2','1','2','2','2','3','2','4','2','5','2','6','2','7','2','8','2','9',
    '3','0','3','1','3','2','3','3','3','4','3','5','3','6','3','7','3','8','3','9',
    '4','0','4','1','4','2','4','3','4','4','4','5','4','6','4','7','4','8','4','9',
    '5','0','5','1','5','2','5','3','5','4','5','5','5','6','5','7','5','8','5','9',
    '6','0','6','1','6','2','6','3','6','4','6','5','6','6','6','7','6','8','6','9',
    '7','0','7','1','7','2','7','3','7','4','7','5','7','6','7','7','7','8','7','9',
    '8','0','8','1','8','2','8','3','8','4','8','5','8','6','8','7','8','8','8','9',
    '9','0','9','1','9','2','9','3','9','4','9','5','9','6','9','7','9','8','9','9'
};

__device__ unsigned int jamcrc32(const char* data, int length, const uint32_t* table = crc32LookupTable) {
    unsigned int crc = ~0u;
    for (int i = 0; i < length; i++) {
        unsigned char byte = data[i];
        int index = (crc ^ byte) & 0xFF;
        crc = (crc >> 8) ^ table[index];
    }
    return crc;
}

__device__ int int_to_string(int value, char* buffer, int buflen, const char* pairs = digitPairs) {
    unsigned int uvalue = (value < 0) ? (unsigned int)(-value) : (unsigned int)value;
    int pos = buflen;

    while (uvalue >= 100) {
        unsigned int rem = uvalue % 100;
        uvalue /= 100;
        pos -= 2;
        buffer[pos]     = pairs[rem * 2];
        buffer[pos + 1] = pairs[rem * 2 + 1];
    }

    if (uvalue < 10) {
        buffer[--pos] = (char)('0' + uvalue);
    } else {
        pos -= 2;
        buffer[pos]     = pairs[uvalue * 2];
        buffer[pos + 1] = pairs[uvalue * 2 + 1];
    }

    if (value < 0) {
        buffer[--pos] = '-';
    }

    return pos;
}

__global__ void calc_hash_kernel(char* cheats, int* offsets, unsigned int* results_c1, unsigned int* results_c2, int num_cheats) {
    __shared__ uint32_t s_crcTable[256];
    __shared__ char s_digitPairs[200];

    if (threadIdx.x < 256) {
        s_crcTable[threadIdx.x] = crc32LookupTable[threadIdx.x];
    }
    if (threadIdx.x < 200) {
        s_digitPairs[threadIdx.x] = digitPairs[threadIdx.x];
    }
    __syncthreads();

    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < num_cheats) {
        char* cheat_string = &cheats[offsets[idx]];
        int cheat_length = offsets[idx + 1] - offsets[idx];

        char obfuscated[20] = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
                               '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
        int cheat_crc = jamcrc32(cheat_string, cheat_length, s_crcTable);
        unsigned int accumulator = 0;

        const int CRC_STR_BUFLEN = 12;
        char new_crc_str[CRC_STR_BUFLEN];

        for (int i = 0; i < 100000; i++) {
            // Re-uppercase obfuscated cheat string
            for (int c = 0; c < 20; c++) {
                if (obfuscated[c] == 'x') {
                    obfuscated[c] = 'X';
                }
            }

            int new_crc = cheat_crc + i;
            int start = int_to_string(new_crc, new_crc_str, CRC_STR_BUFLEN, s_digitPairs);
            int new_crc_len = CRC_STR_BUFLEN - start;

            for (int j = 0; j < new_crc_len; j++) {
                obfuscated[j] = new_crc_str[start + j];
                accumulator += obfuscated[j] * 0x3ff;
            }

            obfuscated[new_crc_len] = 'X';

            for (int j = new_crc_len; j < 20; j++) {
                accumulator += obfuscated[j] * 0x3ff;
            }

            // Lowercase obfuscated cheat string before hash is computed
            for (int c = new_crc_len; c < 20; c++) {
                if (obfuscated[c] == 'X') {
                    obfuscated[c] = 'x';
                }
            }

            cheat_crc = jamcrc32(obfuscated, 20, s_crcTable);
        }

        results_c1[idx] = jamcrc32(&cheat_string[cheat_length / 3], cheat_length - cheat_length / 3, s_crcTable) ^ accumulator;
        results_c2[idx] = jamcrc32(obfuscated, 20, s_crcTable) ^ accumulator;
    }
}

void crack_hashes(const std::vector<std::string>& cheats, const std::unordered_set<std::string>& hash_set) {
    int num_cheats = cheats.size();

    if (num_cheats == 0) {
        std::cout << "No candidate cheats to process.\n";
        return;
    }

    // Host memory
    std::vector<int> offsets(num_cheats + 1);
    std::string concatenated_cheats;
    for (int i = 0; i < num_cheats; ++i) {
        offsets[i] = concatenated_cheats.size();
        concatenated_cheats += cheats[i];
    }
    offsets[num_cheats] = concatenated_cheats.size();

    // Device memory
    char* d_cheats;
    int* d_offsets;
    unsigned int *d_results_c1, *d_results_c2;

    cudaMalloc(&d_cheats, concatenated_cheats.size() * sizeof(char));
    cudaMalloc(&d_offsets, offsets.size() * sizeof(int));
    cudaMalloc(&d_results_c1, num_cheats * sizeof(unsigned int));
    cudaMalloc(&d_results_c2, num_cheats * sizeof(unsigned int));

    cudaMemcpy(d_cheats, concatenated_cheats.c_str(), concatenated_cheats.size() * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_offsets, offsets.data(), offsets.size() * sizeof(int), cudaMemcpyHostToDevice);

    std::cout << "Starting to crack using CUDA GPU acceleration...\n";

    // Start timing
    auto start_time = std::chrono::high_resolution_clock::now();

    int blocks = (num_cheats + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    calc_hash_kernel<<<blocks, THREADS_PER_BLOCK>>>(d_cheats, d_offsets, d_results_c1, d_results_c2, num_cheats);

    // Wait for GPU to finish
    cudaDeviceSynchronize();

    // End timing
    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> elapsed_time = end_time - start_time;

    // Retrieve results
    std::vector<unsigned int> results_c1(num_cheats), results_c2(num_cheats);
    cudaMemcpy(results_c1.data(), d_results_c1, num_cheats * sizeof(unsigned int), cudaMemcpyDeviceToHost);
    cudaMemcpy(results_c2.data(), d_results_c2, num_cheats * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    // Check results
    for (int i = 0; i < num_cheats; ++i) {
        char buffer[23];
        snprintf(buffer, sizeof(buffer), "0x%08x,0x%08x", results_c1[i], results_c2[i]);
        if (hash_set.find(buffer) != hash_set.end()) {
            std::cout << "Found a cheat! " << cheats[i] << " (" << buffer << ")\n";
        }
    }

    // Print timing information
    double total_time_seconds = elapsed_time.count() / 1000.0;
    double time_per_1000 = (elapsed_time.count() / num_cheats);

    std::cout << std::fixed << std::setprecision(4);
    std::cout << "Took " << total_time_seconds << " seconds (That's " << time_per_1000 << " seconds per 1,000 hashes)\n";

    // Free device memory
    cudaFree(d_cheats);
    cudaFree(d_offsets);
    cudaFree(d_results_c1);
    cudaFree(d_results_c2);
}

std::vector<std::string> read_lines_from_file(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file '" << filename << "'\n";
        return {};
    }
    std::vector<std::string> lines;
    std::string line;
    while (std::getline(file, line)) {
        if (!line.empty() && line.back() == '\r') {
            line.pop_back();
        }
        if (line.empty()) continue;
        std::transform(line.begin(), line.end(), line.begin(), [](unsigned char c) { return std::tolower(c); });
        lines.push_back(line);
    }
    return lines;
}

void print_help() {
    std::cout << "Usage: thu2rcc <hash_list> <wordlist>\n";
    std::cout << "\thash_list: Each line in the hash list should represent a c1, c2 hash pair in '0x00c16f4b,0xaa6fae66' format\n";
    std::cout << "\twordlist:  Each line in the wordlist should be a candidate cheat code to check\n";
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        print_help();
        return 1;
    }

    const std::string hash_list_path = argv[1];
    const std::string cheat_list_path = argv[2];

    std::cout << "Hash List: " << hash_list_path << "\n";
    std::cout << "Cheat List: " << cheat_list_path << "\n";

    std::vector<std::string> hash_list = read_lines_from_file(hash_list_path);
    std::vector<std::string> cheats = read_lines_from_file(cheat_list_path);

    if (hash_list.empty()) {
        std::cerr << "Error: Hash list file is empty or could not be loaded.\n";
        return 1;
    }

    std::unordered_set<std::string> hash_set(hash_list.begin(), hash_list.end());

    crack_hashes(cheats, hash_set);

    return 0;
}
