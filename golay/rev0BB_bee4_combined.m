%% Rev0BB

%% Init
clear; close all; clc;

%% Sim Params
disp('Setting Model Parameters ...')
rev0BB_setup;

%% BEE4
bee_ip_addr = '127.0.0.1';
disp(['BEE4: ',  bee_ip_addr, ':48868']);
pause_time = 0.0001;

packed32 = pack32(testMsg);
tx_len = length(testMsg);

b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 0);
pause(pause_time);
b4d_reg_write(bee_ip_addr, 'A', 'tx_reset', 1);
b4d_reg_write(bee_ip_addr, 'A', 'rx_reset', 1);
pause(pause_time);
b4d_reg_write(bee_ip_addr, 'A', 'tx_reset', 0);
b4d_reg_write(bee_ip_addr, 'A', 'rx_reset', 0);
b4d_bram_write(bee_ip_addr, 'A', 'InputBRAM', double(packed32));
b4d_reg_write(bee_ip_addr, 'A', 'tx_len', tx_len);
pause(pause_time);

%Before Sending
disp(['Orig Msg [', num2str(length(testTextTrunk))  ,' char]: ']);
disp(testTextTrunk);

rx_len = b4d_reg_read(bee_ip_addr, 'A', 'rx_len');
rx_count = b4d_reg_read(bee_ip_addr, 'A', 'rx_count');
out8_decoded = '';
if rx_len > 0
    out = transpose(b4d_bram_read(bee_ip_addr, 'A', 'OutputBRAM', ceil(rx_len/2^32)));
    out8 = unpack32_8(Convert2UInt32(out));
    out8_endian = reverse_endian8(out8);
    out8_decoded = arrayfun(@(x) char(x), transpose(out8_endian));
end

disp(['Before Tx: Rx [', num2str(rx_len/8), ' chars, count=', num2str(rx_count) ,'] ']);
disp(out8_decoded);

%After Sending
b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 1);
pause(pause_time);
b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 0);
pause(pause_time);
rx_len = b4d_reg_read(bee_ip_addr, 'A', 'rx_len');
rx_count = b4d_reg_read(bee_ip_addr, 'A', 'rx_count');
out8_decoded = '';
if rx_len > 0
    out = transpose(b4d_bram_read(bee_ip_addr, 'A', 'OutputBRAM', ceil(rx_len/32)));
    out8 = unpack32_8(Convert2UInt32(out));
    out8_endian = reverse_endian8(out8);
    out8_decoded = arrayfun(@(x) char(x), transpose(out8_endian));
end

disp(['After Tx : Rx [', num2str(rx_len/8), ' chars, count=', num2str(rx_count) ,'] ']);
disp(out8_decoded);

% Test another string
% Data length is fixed
b4d_reg_write(bee_ip_addr, 'A', 'tx_reset', 1);
pause(pause_time);
b4d_reg_write(bee_ip_addr, 'A', 'tx_reset', 0);

testText = '"And we must study through reading, listening, discussing, observing and thinking. We must not neglect any one of those ways of study. The trouble with most of us is that we fall down on the latter -- thinking -- because it''s hard work for people to think, And, as Dr. Nicholas Murray Butler said recently, ''all of the problems of the world could be settled easily if men were only willing to think.'' " - Thomas Watson';
[testMsg, testTextTrunk, testTextTrunkBin] =generate_frame(testText, dataLen, xCTRL_PRE_adj, startWord, guard, after);
packed32 = pack32(testMsg);
tx_len = length(testMsg);
b4d_bram_write(bee_ip_addr, 'A', 'InputBRAM', double(packed32));
b4d_reg_write(bee_ip_addr, 'A', 'tx_len', tx_len);
pause(pause_time);
disp(['Tx: [', num2str(length(testTextTrunk))  ,' char]: ']);
disp(testTextTrunk);

b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 1);
pause(pause_time);
b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 0);
pause(pause_time);
rx_len = b4d_reg_read(bee_ip_addr, 'A', 'rx_len');
rx_count = b4d_reg_read(bee_ip_addr, 'A', 'rx_count');
out8_decoded = '';
if rx_len > 0
    out = transpose(b4d_bram_read(bee_ip_addr, 'A', 'OutputBRAM', ceil(rx_len/32)));
    out8 = unpack32_8(Convert2UInt32(out));
    out8_endian = reverse_endian8(out8);
    out8_decoded = arrayfun(@(x) char(x), transpose(out8_endian));
end

disp(['Rx: [', num2str(rx_len/8), ' chars, count=', num2str(rx_count) ,'] ']);
disp(out8_decoded);

%% The Interactive Section
prompt = 'Enter Text to Tx/Rx [nothing to exit]: ';

str = strtrim(input(prompt,'s'));
while ~isempty(str)
    
    
    b4d_reg_write(bee_ip_addr, 'A', 'tx_reset', 1);
    pause(pause_time);
    b4d_reg_write(bee_ip_addr, 'A', 'tx_reset', 0);

    testText = '"And we must study through reading, listening, discussing, observing and thinking. We must not neglect any one of those ways of study. The trouble with most of us is that we fall down on the latter -- thinking -- because it''s hard work for people to think, And, as Dr. Nicholas Murray Butler said recently, ''all of the problems of the world could be settled easily if men were only willing to think.'' " - Thomas Watson';
    [testMsg, testTextTrunk, testTextTrunkBin] =generate_frame(str, dataLen, xCTRL_PRE_adj, startWord, guard, after);
    packed32 = pack32(testMsg);
    tx_len = length(testMsg);
    b4d_bram_write(bee_ip_addr, 'A', 'InputBRAM', double(packed32));
    b4d_reg_write(bee_ip_addr, 'A', 'tx_len', tx_len);
    pause(pause_time);
    disp(['Tx: [', num2str(length(testTextTrunk))  ,' char]: ']);
    disp(testTextTrunk);

    b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 1);
    pause(pause_time);
    b4d_reg_write(bee_ip_addr, 'A', 'tx_en', 0);
    pause(pause_time);
    rx_len = b4d_reg_read(bee_ip_addr, 'A', 'rx_len');
    rx_count = b4d_reg_read(bee_ip_addr, 'A', 'rx_count');
    out8_decoded = '';
    if rx_len > 0
        out = transpose(b4d_bram_read(bee_ip_addr, 'A', 'OutputBRAM', ceil(rx_len/32)));
        out8 = unpack32_8(Convert2UInt32(out));
        out8_endian = reverse_endian8(out8);
        out8_decoded = arrayfun(@(x) char(x), transpose(out8_endian));
    end

    disp(['Rx: [', num2str(rx_len/8), ' chars, count=', num2str(rx_count) ,'] ']);
    disp(out8_decoded);
    
    str = strtrim(input(prompt,'s'));
end