function simulink_to_graphml(system, graphml_filename, verbose)
%simulink_to_graphml Converts a simulink system to a GraphML file.
%   Detailed explanation goes here

%% Init
graphml_filehandle = fopen(graphml_filename,'w');

%% Write Preamble
% Write the GraphML XML Preamble
fprintf(graphml_filehandle, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(graphml_filehandle, '<graphml xmlns="http://graphml.graphdrawing.org/xmlns" \n');
fprintf(graphml_filehandle, '\txmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \n');
fprintf(graphml_filehandle, '\txsi:schemaLocation="http://graphml.graphdrawing.org/xmlns \n');
fprintf(graphml_filehandle, '\thttp://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">\n';

%% Write Attribute Definitions
% Write the GraphML Attribute Definitions

%% Traverse Graph and Transcribe to GraphML File
simulink_to_graphml_helper(system, verbose, false, 0);

%% Close GraphML File
fprintf(graphml_filehandle, '</graphml>');

fclose(graphml_filehandle);

end

