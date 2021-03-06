#include <boost/crc.hpp>      // for boost::crc_basic, boost::crc_optimal
#include <vector>
#include <algorithm>
#include <cstdio>


int main(int argc, char** argv)
{
    //std::vector<unsigned char> testMsgByte {0x1D, 0x93, 0x05, 0x1D, 0x98, 0x56};
    //uint32_t expected = 0x2D2BEFCE;
    
    //std::vector<unsigned char> testMsgByte {0x48, 0xCB, 0x70, 0xEE, 0xA9, 0x9E, 0x6E, 0x86, 0xF7, 0xF6, 0x66, 0x42};
    //uint32_t expected = 0xA43E164E;

    //std::vector<unsigned char> testMsgByte {0xAE, 0x06, 0xEA, 0x76, 0xC4, 0x49, 0xAF, 0xBA, 0x02, 0x00, 0x3B, 0x26, 0x0B, 0x3A, 0x30, 0xAD, 0x34, 0x41, 0xE6, 0x33, 0x95, 0xF7, 0xDF, 0xEE};
    //uint32_t expected = 0x3890254B;

    //std::vector<unsigned char> testMsgByte {0x1E, 0xB9, 0x3A, 0x76, 0x0E, 0xD2, 0xCC, 0x02, 0x39, 0x9B, 0x7F, 0xED, 0xEE, 0x0B, 0x13, 0x71, 0xC5, 0x3D, 0xE8, 0x03, 0xD7, 0x9B, 0xA4, 0xDB, 0xF5, 0x44, 0x5C, 0x76, 0xEC, 0x86, 0x75, 0x00, 0x1E, 0x44, 0x98, 0x0C, 0xB0, 0xCC, 0xDB, 0x14, 0xBD, 0x11, 0x73, 0x55, 0xA1, 0x27, 0x00, 0x2C, 0x9D, 0xB9, 0x7F, 0x31, 0x55, 0x2E, 0xD8, 0x46, 0x46, 0xF4, 0xE9, 0x99, 0x36, 0xAD, 0xD2, 0xB2, 0x6F, 0x03, 0xA9, 0xDD, 0xF8, 0xEA, 0x18, 0x96, 0x14, 0x05, 0x7D, 0xE6, 0x46, 0xDF, 0x5C, 0x16, 0x9F, 0xCB, 0xFB, 0x1F, 0x27, 0xD7, 0x19, 0x9A, 0xAD, 0x10, 0x0B, 0x29, 0x4C, 0xA4, 0x20, 0xA0, 0xDA, 0x57, 0x74, 0xB0, 0x92, 0x6B, 0x5D, 0xF3, 0xF7, 0x30, 0x65, 0x8C, 0x93, 0x86, 0xF0, 0x22, 0xF9, 0x06, 0x51, 0xAB, 0xE7, 0x14, 0xB2, 0xB8, 0x00, 0x74, 0x53, 0x75, 0xAA, 0x47, 0x86, 0x8C};
    //uint32_t expected = 0x3CBBF150;

    //std::vector<unsigned char> testMsgByte {0xEA, 0xD6, 0x90, 0x18, 0xC9, 0x96, 0x22, 0x6D, 0x40, 0x66, 0xDE, 0x08, 0x10, 0x05, 0x83, 0xFB, 0xFA, 0x9C, 0x27, 0x18, 0x67, 0x3A, 0x28, 0xF0, 0x65, 0x53, 0x98, 0x90, 0x56, 0x61, 0x73, 0xA6, 0x8C, 0x6E, 0xE7, 0xF7, 0x2B, 0x0E, 0x87, 0x77, 0x69, 0x28, 0x5B, 0xE6, 0xD2, 0xCD, 0xEF, 0x80, 0x1A, 0x3E, 0x6A, 0x9C, 0x3B, 0x44, 0xE3, 0x9F, 0x57, 0xC7, 0xD4, 0xC5, 0x52, 0xF6, 0xBB, 0xCF, 0x5F, 0xEE, 0x95, 0xEE, 0xD1, 0xDE, 0x65, 0x63, 0x1C, 0xD1, 0x95, 0x60, 0x37, 0x09, 0x9B, 0x59, 0x24, 0xA9, 0x44, 0x63, 0x81, 0x54, 0xBD, 0x2B, 0x19, 0x5B, 0xD3, 0x7E, 0x7F, 0xBF, 0x20, 0x0B, 0x7F, 0x6B, 0xC8, 0x05, 0x1E, 0xC3, 0xE5, 0xF7, 0xF3, 0x57, 0xEC, 0x39, 0x9B, 0xDE, 0x8B, 0xD2, 0x2A, 0xD7, 0xC9, 0x73, 0xB2, 0x2F, 0x95, 0xAB, 0xF6, 0xEB, 0x8F, 0x4A, 0x67, 0x34, 0x11, 0x33, 0x7B, 0x97, 0x2B, 0x99, 0x8F, 0x71, 0x00, 0x64, 0x1C, 0x8F, 0x62, 0x26, 0x4D, 0xBC, 0x3C, 0x77, 0x0F, 0x13, 0xA2, 0xE4, 0x12, 0x0D, 0xD0, 0xB6, 0xE2, 0x57, 0x06, 0x98, 0x48, 0xDD, 0x57, 0xE5, 0x2B, 0xBE, 0x65, 0x2C, 0x42, 0xCE, 0xD5, 0x30, 0x01, 0xCC, 0x5E, 0xEF, 0xD7, 0xB9, 0x77, 0x9B, 0xB9, 0x77, 0xBE, 0x52, 0x9A, 0xC8, 0x1A, 0x54, 0xF6, 0xA1, 0x1A, 0xC0, 0xD6, 0xF7, 0x1E, 0xC7, 0x4A, 0x63, 0xBE, 0xA9, 0xD6, 0x83, 0xC0, 0xAD, 0xE8, 0x35, 0x09, 0xC1, 0xF6, 0xF7, 0xAF, 0x1B, 0x9C, 0xF8, 0xDF, 0x41, 0x65, 0x5F, 0x8E, 0x07, 0x9B, 0x14, 0xE0, 0x2D, 0x3A, 0x08, 0xCE, 0xA1, 0x94, 0xF7, 0xBE, 0x56, 0xBB, 0x76, 0x29, 0xDF, 0x44, 0x1C, 0x0B, 0xAD, 0xBF, 0xEE, 0x7B, 0xE8, 0xB5, 0x2B, 0x07, 0xA5, 0xB3, 0xDD, 0xEA, 0x26, 0x7A, 0xA2, 0x8C, 0x51, 0x48, 0xAB, 0x20};
    //uint32_t expected = 0x6252BE80;

    //std::vector<unsigned char> testMsgByte {0x7B};
    //uint32_t expected = 0xFE0AA056;

    std::vector<unsigned char> testMsgByte {0xBB, 0x7A, 0xA5, 0x71, 0xE4, 0x67, 0x95, 0x87, 0x92, 0x67, 0x21};
    uint32_t expected = 0x68105C87;

    uint32_t remainder[2] = {0, 0};

    //Get initial remainder for non augmented_crc
    
    uint32_t aug_crc_gen = boost::augmented_crc<32, 0x04C11DB7>(remainder, 4, 0xFFFFFFFF);
    printf("Augmented Remainder: 0x%x, Non-Augmented Remainder: 0x%x\n", 0xFFFFFFFF,  aug_crc_gen);

    boost::crc_optimal<32, 0x04C11DB7, 0xc704dd7b, 0x00000000, true, true>  crc_gen;
    
    for(int i = 0; i<testMsgByte.size(); i++)
    {
        crc_gen.process_byte(testMsgByte[i]);
    }
    
    uint32_t checksum = crc_gen();

    printf("Checksum [Fast]: 0x%x, Expected: 0x%x\n", checksum, expected);

    if(checksum==expected)
    {
         printf("PASSED\n");
    } else {
         printf("FAILED\n");
    } 

    return 0;
}
