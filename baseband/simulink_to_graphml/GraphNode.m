classdef GraphNode < handle
    %GraphNode Represents a Graph Node extracted from Simulink
    %   Is part of the intermediate representation for the data flow graph
    
    properties
        name %The name of the block (from simulink)
        
        nodeType %Type of block.  Can be 1 of the following
                 % 0 = Standard
                 % 1 = Subsystem
                 % 2 = Enabled Subsystem
                 % 3 = Special Input Port
                 % 4 = Special Output Port
                 % 5 = Top Level
        
        simulinkType %Simulink type
        simulinkHandle %Simulink node handle
        dialogProperties %A map of dialog Properties extracted from simulink
        
        parent %A reference to the parent node object (in the hierarchy)
               %Ie, a reference to the subsystem the node is directly
               %within
               % = [] if top level
        
        children %A cell array of children of this node (only valid for subsystems)
        
        out_arcs %A cell array of outward arcs (handles to GraphArc objects)
        in_arcs %A cell array of input arcs
        
        en_in_src_node %A reference to the node driving the enable line of the susbsytem if the node type is "Enabled Subsystem" or the gating line if the node is a "Special Port"
        en_in_src_port %A reference to the port of the node driving the enable line of the susbsytem if the node type is "Enabled Subsystem" or the gating line if the node is a "Special Port"
                       %Will not be populated for "Special Ports" until the
                       %graph has been completely traversed.  Populated in a
                       %later stage
        
        inputPorts %A map of input port numbers to names ("" if name not given)
                   %For special Input/Output ports the enable signal line
                   %is the 2nd input port.  The data goes to port 1
        outputPorts %A map of output port numbers to names ("" if name not given)
                    %For special Input/Output there is only 1 port for the
                    %output
        
        sampleTime %The sample time for the block (from simulink)
        
        nodeId %A generic node ID.  Will be an integer rather than the simulink handle doubles
    end
    
    methods
        function obj = GraphNode(name, type, parent)
            %GraphNode Construct an instance of this class
            %   Type is 'Standard', 'Subsystem', 'Enabled Subsystem', 'Special
            %   Input Port', 'Special Output Port', 'Top Level'
            
            %Copy arguments
            obj.name = name;
            obj.parent = parent;
            
            %Set Type
            if strcmp(type, 'Standard')
                obj.nodeType = 0;
            elseif strcmp(type, 'Subsystem')
                obj.nodeType = 1;
            elseif strcmp(type, 'Enabled Subsystem')
                obj.nodeType = 2;
            elseif strcmp(type, 'Special Input Port')
                obj.nodeType = 3;
            elseif strcmp(type, 'Special Output Port')
                obj.nodeType = 4;
            elseif strcmp(type, 'Top Level')
                obj.nodeType = 5;
            else
                obj.nodeType = 6;
                error(['''', type, ''' is not a recognized node type']);
            end
            
            %Set Defaults
            obj.simulinkType = "";
            obj.simulinkHandle = 0;
            obj.dialogProperties = containers.Map();
            obj.children = [];
            obj.out_arcs = [];
            obj.in_arcs = [];
            obj.en_in_src_node = [];
            obj.en_in_src_port = [];
            
            obj.inputPorts = containers.Map();
            obj.outputPorts = containers.Map();
        
            obj.nodeId  = 0; 
        end
        
        function addChild(obj, child)
            %addChild Add a child node to the list of children
            obj.children = [obj.children, child];
        end
        
        function outputArg = getAncestorHierarchy(obj)
            %getAncestorHierarchy Returns the hierarchy containing the
            %given node
            %   The first element is the top level node and the last is the
            %   given node
            outputArg = [];
            
            done = false;
            cursor = obj;
            while ~done
                outputArg = [cursor, outputArg];
                
                if ~isempty(cursor.parent)
                    cursor = cursor.parent;
                else
                    done = true;
                end
            end
        end
        
        function outputArg = getFullSimulinkPath(obj)
            %getFullSimulinkPath Get the full simulink path string of the
            %node
            hierarchy = obj.getAncestorHierarchy();
            
            %Assume there is at least 1 node in the hierarchy
            outputArg = hierarchy(1).name;
            for i = 2:length(hierarchy)
                outputArg = [outputArg, '/', hierarchy(i).name];
            end
        end
        
        function outputArg = getFullIDPath(obj, delim, formatSpec, includeTop)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            hierarchy = obj.getAncestorHierarchy();
            
            if includeTop
                %Assume there is at least 1 node in the hierarchy
                outputArg = sprintf(formatSpec, hierarchy(1).nodeId);
                start = 2;
            else
                %Check if there is at least 2 nodes
                if length(hierarchy) > 1
                    outputArg = sprintf(formatSpec, hierarchy(2).nodeId);
                    start = 3;
                else
                    outputArg = '';
                    start = length(hierarchy) + 1; %Prevent the loop from running
                end
            end
            
            for i = start:length(hierarchy)
                outputArg = [outputArg, delim, sprintf(formatSpec, hierarchy(i).nodeId)];
            end
            
        end
        
        function addOut_arc(obj, newArc)
            %addOut_arc Add an arc to the out_arcs list;
            obj.out_arcs = [obj.out_arcs, newArc];
        end
            
        function addIn_arc(obj, newArc)
            %addIn_arc Add an arc to the in_arcs list;
            obj.in_arcs = [obj.in_arcs, newArc];
        end
    end
end
