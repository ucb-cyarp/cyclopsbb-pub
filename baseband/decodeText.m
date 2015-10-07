function [ ] = decodeText(symbolIn, valid)
%DECODE_TEXT Decodes text as it is recieved
persistent count;
persistent symbolBuffer;
persistent decodedText;
persistent prevValid;

if isempty(prevValid)
    prevValid = false;
end
    
if isempty(count)
    count = 0;
end

if isempty(symbolBuffer)
    symbolBuffer = 0;
end

if isempty(decodedText)
    decodedText = '';
end

if(valid)
    %Buffer the newest symbol (binary)
    newBit = 0;
    if(symbolIn ~= 0 )
        newBit = 1;
    end

    symbolBuffer = symbolBuffer * 2;
    symbolBuffer = symbolBuffer + newBit;
    count = count+1;

    %%have full char, now decode and reset
    if(count >= 8)
        newChar = char(symbolBuffer);
        decodedText = [decodedText newChar];
        disp(decodedText);
        count = 0;
        symbolBuffer = 0;
    end
else
    count = 0;
    symbolBuffer = 0;
    decodedText = '';
end

