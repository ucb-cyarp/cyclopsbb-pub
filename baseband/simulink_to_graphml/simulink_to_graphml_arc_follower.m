%Parent and parent port are important to create the GraphML arc entry.

% The Given Node and Port are important as this routien will trace each
% outgoing arc from the given port.  Each time a subsystem is encountered 
% (and the signal is not driving the enable line, this function recursively 
% calls itself on the input port of the subsystem.  If an subsystem is
% encountered and the port is driving the enable line, an arc is made and
% the enable driver in the IR node corresponding to the subsystem is 
% populated and the function returns. If a standard (not a subsystem) node
% is encountered, an arc entry is made and the graphml helper is called on 
% the node.

% Cases:
    % Encounters general block
    %    Calls simulink to graphml helper
    % Encounters normal port of susbsystem
    %    Check if subsystem already has an IR node created for it and
    %    create one if it does not.  Add entries to the approproate node
    %    maps.  Add the node to the hierarchy stack.
    %    *If susbsystem is enabled
    %        Create Special Input Port IR node, set the parent to the node 
    %        representing the enabled subsystem, add it to the appropriate maps
    %        and create an arc connecting the signal driver to it.  Assign
    %        the handle of the simulink port node it is representing to
    %        this IR node.  Add the subsystem to the stack and recursivly 
    %        call the arc follower on the output of the simulink port but 
    %        give the new Special Input port IR node as the driver.
    %    *If subsystem is not enabled
    %        Add the subsystem to the stack and recursivly 
    %        call the arc follower on the output of the simulink port.  Do
    %        not change the driver node or port
    % Encounteres enable input to subsystem
    %    Check if subsystem already has an IR node created for it and
    %    create one if it does not.  Add entries to the approproate node
    %    maps.  Populate the "enable driver" entries of the subsystem's
    %    corresonding IR node to the node and port driving this line
    % Encounters output port
    %    If not top level subsystem:
    %        If output port of enabled susbsystem:
    %            If output port reached, subsystem IR node must already
    %            exist.  Create Special Output Port IR node, add it to the
    %            appropriate maps, and creat an arc connecting the signal
    %            driver to it.  Assign the handle of the simulink port node
    %            it is representing to this IR node.  Pop the subsystem off
    %            of the stack and recursively call the arc follower on the
    %            output of the associated subsystem port but give the new
    %            Special Output port IR node as the driver
    %        If ouput port of an non-enabled subsystem:
    %            Pop the subsystem off of the stack and recursively call 
    %            the arc follower on the output of the associated subsystem
    %            port but do not change the driver    
    %    If top level, connect to appropriate output node and return
    
% Note, Special Input/Output ports have a reference to the enabled
% subsystem which controls their behavior.  Once the graph traversal is
% complete and the drivers of the enable ports are discovered, a pass 
% creates arcs from the enabled subsystem drivers to each Special
% Input/Output node.
    
% Pass in GraphNode as the driver node and port number as the driver port.  
% The simulink names can be fetched using the simulink handle saved in the 
% IR if needed.  Special nodes are assigned handles to the port nodes in 
% simulink that they represent.  Simulink ports that are not at the 
% boundary of an enabled subsystem do not have associated IR nodes.

%The node and port from which we are tracing are given as simulink handles
%since we may recurse on input/output ports in non-enabled subsystems which
%will not have assiated IR nodes.

%When initially calling the arc follower, the simulink_node,
%simulink_port_number, driver_ir_noder, and driver_port_number will likely
%all refur to the same logical port in the design.  The simulink_node and
%simulink_port_number may change as subsystems are traversed.  The
%driver_ir_node and driver_port_number may change if an enabled subsystem
%is encountered ands a Special Input node is created

%Instead of an explicit stack, a IR node is passed to the function
%representing the current subsystem.  The hierarchy can be traversed by
%following the "parent" reference in the IR node.  Nodes incountered are
%added to this node as "children".
        
function [new_nodes, new_arcs] = simulink_to_graphml_arc_follower(simulink_node, simulink_port_number, driver_ir_node, driver_port_number, system_ir_node, unconnected_node)
%====Init Outputs=====
new_arcs = [];
new_nodes = [];

%====Get the simulink handle to the output port====
block_port_handles = get_param(simulink_node, 'PortHandles');
block_output_port_handles = block_port_handles.Outport;
%Get the specified output port based on the number
%TODO: Appears that the array index is the same as the port number.
%However, this was not specified in the help page.  Do a search just to be
%safe.
port_handle = [];
for i = 1:length(block_output_port_handles)
    %Check the port number
    port_num = get_param(block_output_port_handles(i), 'PortNumber');
    if port_num == simulink_port_number
        port_handle = block_output_port_handles(i);
        break;
    end
end

%Check for the case the port was not found
if isempty(port_handle)
    error(['Could not find specified simulink port']);
end

%=====Find the destinations of the given port====
%There are a couple of ways to do this.  One is to use the PortConnectivity
%property of the block.  The downside is that it gives a full table of port
%connections including input and output ports.  The table has to be
%filtered and parsed since different colums having specific values convey
%special meanings.

%The alternative (which I used in the c-slow code) is to get the "Line"
%connected to the port.  In simulink, lines connect output ports to input
%ports (or special ports such as enables).  This is not a hidden feature
%since the Simulink function list (API)
%https://www.mathworks.com/help/simulink/functionlist.html lists the
%function add_line.  The "LineHandles" property returns the lines connected
%to the block.  Alternativly, there is a "Line" property in the Port.  We
%can use this to get the line connected to the port.  A bonus of using the
%Line is that it contains entries for the src and dst block and port
%handles.  This makes it easier to traverse the graph.  Ports also have the
%property "PortType" which can be used to distinguish between input ports
%and special ports.  An alternative would be to use the port handle and to
%seach the "PortHandles" property of the block to find what catagory it
%falls it.  This technique for traversig the graph via lines was described in
%https://www.mathworks.com/matlabcentral/answers/102262-how-can-i-obtain-the-port-types-of-destination-ports-connected-an-output-port-of-any-simulink-block
%and was used as a reference for the c-slow code.

%Also, you can get the node name of an associated port using the "Parent"
%parameter.  You will need to use get_param to get the associated Handle.

%The Parent paramter of a Node gives the simulink system is directly
%contained within (ie, the next level up in the simulink system hierarchy).

out_line = get_param(port_handle, 'Line');

dst_block_handles = get_param(out_line, 'DstBlockHandle');
dst_port_handles = get_param(out_line, 'DstPortHandle');

%====Iterate on each destination=====

%Note: The size of the node handles array should match the size of the port
%handles array.  I ran a quick experiment where a single output was
%connected to 2 inputs of another node.  The node handle was repeated.

%Check if the node is unconnected
if isempty(dst_port_handles)
    %Create an arc to the "Unconnected" special node
    unconnected_arc = GraphArc.createBasicArc(driver_ir_node, driver_port_number, unconnected_node, 1, 'Standard'); %dst port does not matter since this is to the special node
    new_arcs = [new_arcs, unconnected_arc];
    
    return;
end

for i = 1:length(dst_port_handles)
    
    %It looks like the dst_port_handles and dst_node_handles are linked by
    %index but this does not seem to be guarenteed by the documentation.
    %Will do the safe thing for now and use the Parent parameter and then
    %fetch the node handle seperatly.
    %TODO: Check this because it seems to make sense that the 2 would be
    %linked by index.  If this is guarenteed, we can directly use the node
    %handle
    dst_port_handle = dst_port_handles(i);
    
    %This is how we would like to do it
    dst_block_handle = dst_block_handles(i);
    
    %TODO: Remove this check if the above method does in fact hold (other
    %scripts on mathworkscentral seem to make this assumption as well)
    dst_port_parent = get_param(dst_port_handle, 'Parent');
    dst_block_handle_check = get_param(dst_port_parent, 'Handle');
    
    if dst_block_handle ~= dst_block_handle_check
        error('Block Handels for Port Do Not Match (Check Assumption)');
    end
    %TODO: End Remove Check
    
    %Get the signal properties
    
    
    %=====Check for what case this is=====
    %Get block type
    dst_type = get_param(dst_block_handle, 'Type');
    %    Check that this is in fact a block
    if ~strcmp(dst_type, 'block')
        error('Destination block is not a Simulink Block');
    end
    
    dst_block_type = get_param(dst_block_handle, 'BlockType');
    dst_reference_block = get_param(dst_block_handle, 'ReferenceBlock');
    
    if strcmp(dst_block_type, 'SubSystem') && strcmp(dst_reference_block, 'hdlsllib/HDL RAMs/HDL FIFO')
        %This is a special FIFO block and is treated seperatly (as a
        %primitive rather than a subsystem.
        
        %TODO: IMPLEMENT
        errror('HDL FIFO Not Yet Implemented');
    
    elseif strcmp(dst_block_type, 'SubSystem')
        %The dst block is a SubSystem
        
        %Check if the subsystem is enabled
        system_enabled = is_system_enabled(dst_block_handle);
        
        if system_enabled
            %This is an enabled subsystem
            
            %Check if the port is the enable port
            port_type = get_param(dst_port_handle, 'PortType');
            if strcmp(port_type, 'enable')
                %The dst port is the enable port of the subsystem
                
                %TODO: IMPLEMENT
                
            else
                %The dst port is an input port to the enabled subsystem
                
                %TODO: IMPLEMENT
            end
            
        else
            %This is not an enabled subsystem
            %TODO: IMPLEMENT
            
            
        end
        
    elseif strcmp(dst_block_type, 'Outport')
        %The dst block is an output port node (within a subsystem)
        
        %TODO: IMPLEMENT
        
    elseif strcmp(dst_block_type, 'ConstellationDiagram') || strcmp(dst_block_type, 'Scope') || strcmp(dst_block_type, 'Display') || strcmp(dst_block_type, 'SpectrumAnalyzer')
        %The dst block is a visualization block
        %In this case, the vis_type property of the node should be set to
        %the type of visualizer
        
        %TODO: IMPLEMENT
        
    elseif strcmp(dst_block_type, 'Terminator')
        %The dst block is a terminator
        
        %TODO:IMPLEMENT
        
    else
        %This is a basic block.  These blocks can have different BlockType
        %names based on their functions
        
        %TODO: IMPLEMENT
        
    end

end