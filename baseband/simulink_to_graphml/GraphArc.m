classdef GraphArc < handle
    %GraphArc Represents a Graph Arc extracted from Simulink
    %   Is part of the intermediate representation for the data flow graph
    
    properties
        srcNode %GraphNode handle
        srcPortNumber %output port number of the src
        
        dstNode
        dstPortNumber
        dstPortType %One of the following
                     % 0 = Standard
                     % 1 = Enable (the enable signal)
                     % 2 = Reset (the reset signal) -- TODO:
                     % Implement this.  Only handle enable for now
                     
        %This is used when an arc passes through a flattened node.  This is
        %used to preserve the origional semantics in case a pass needs to
        %throw out the flattened implementation.
        intermediateNode
        intermediatePortNumber
        intermediatePortType
        intermediatePortDirection
        
        simulinkSrcPortHandle
        simulinkDestPortHandle
        
        %Simulink signal properties
        datatype
        complex
        dimension
        width
        
        %Properties for connection to visualizer
        vis_type
        
        %Properties used to bundle arcs in busses
        bus_expanded
        bus_neighbors
        
        %ArcId
        arcId
        
    end
    
    methods
        function obj = GraphArc(srcNode, srcPortNumber, dstNode, dstPortNumber, dstPortType)
            %GraphArc Construct an instance of this class
            %   dstPortType can be one of the following: 'Standard',
            %   'Enable'
            
            %Copy Parameters
            obj.srcNode = srcNode;
            obj.srcPortNumber = srcPortNumber;
            obj.dstNode = dstNode;
            obj.dstPortNumber = dstPortNumber;
            
            obj.intermediateNode = [];
            obj.intermediatePortNumber = [];
            obj.intermediatePortType = [];
            obj.intermediatePortDirection = [];
            
            %Set Type
            if strcmp(dstPortType, 'Standard')
                obj.dstPortType = 0;
            elseif strcmp(dstPortType, 'Enable')
                obj.dstPortType = 1;
            else
                obj.dstPortType = 6;
                error(['''', dstPortType, ''' is not a recognized port type']);
            end
            
            %Set Defaults
            obj.simulinkSrcPortHandle = 0;
            obj.simulinkDestPortHandle = 0;
        
            obj.datatype = [];
            obj.complex = [];
            obj.dimension = [];
            obj.width = [];
            obj.vis_type = [];
            
            obj.bus_expanded = false;
            obj.bus_neighbors = [];
        end
        
        function emitGraphml(obj, file, numTabs)
           %emitGraphml Writes GraphML entries for this arc.
           %numTabs specifies the initial indent (in hardtabs)
           
           sourceIdPath = obj.srcNode.getFullIDPath('::', 'n%d', false);
           dstIdPath = obj.dstNode.getFullIDPath('::', 'n%d', false);
           
           %Emit Arc entry
           writeNTabs(file, numTabs);
           fprintf(file, '<edge id="e%d" source="%s" target="%s">\n', obj.arcId, sourceIdPath, dstIdPath);
           
           %Emit attributes
           writeNTabs(file, numTabs+1);
           fprintf(file, '<data key="arc_src_port">%d</data>\n', obj.srcPortNumber);
           writeNTabs(file, numTabs+1);
           fprintf(file, '<data key="arc_dst_port">%d</data>\n', obj.dstPortNumber);
           
           %Emit Intermediates
           if ~isempty(obj.intermediateNode)
               fprintf(file, '<data key="arc_intermediate_node">%s</data>\n', obj.intermediateNode.getFullIDPath('::', 'n%d', false));
           end
           if ~isempty(obj.intermediatePortNumber)
               fprintf(file, '<data key="arc_intermediate_port">%d</data>\n', obj.intermediatePortNumber);
           end
           if ~isempty(obj.intermediatePortType)
               fprintf(file, '<data key="arc_intermediate_port_type">%s</data>\n', obj.intermediatePortType);
           end
           if ~isempty(obj.intermediatePortDirection)
               fprintf(file, '<data key="arc_intermediate_direction">%s</data>\n', obj.intermediatePortDirection);
           end
           
           %Create lable with relevant information
           disp_label = sprintf('Src Port Num: %d\nDst Port Num: %d\nDst Port Type: %s', obj.srcPortNumber, obj.dstPortNumber, obj.dstPortTypeStr());
           writeNTabs(file, numTabs+1);
           %Include static entries if applicable
           if ~isempty(obj.intermediateNode)
               disp_label = [disp_label, sprintf('\nIntermediate Node: %s', anyToString(obj.intermediateNode.getFullIDPath('::', 'n%d', false)))];
           end
           if ~isempty(obj.intermediatePortNumber)
               disp_label = [disp_label, sprintf('\nIntermediate Port Number: %s', anyToString(obj.intermediatePortNumber))];
           end
           if ~isempty(obj.intermediatePortType)
               disp_label = [disp_label, sprintf('\nIntermediate Port Type: %s', anyToString(obj.intermediatePortType))];
           end
           if ~isempty(obj.intermediatePortDirection)
               disp_label = [disp_label, sprintf('\nIntermediate Port Direction: %s', anyToString(obj.intermediatePortDirection))];
           end
           if ~isempty(obj.datatype)
                disp_label = [disp_label, sprintf('\nDatatype: %s', anyToString(obj.datatype))];
           end
           if ~isempty(obj.complex)
                disp_label = [disp_label, sprintf('\nComplex: %s', anyToString(obj.complex))];
           end
           if ~isempty(obj.dimension)
                disp_label = [disp_label, sprintf('\nDimension: %s', anyToString(obj.dimension))];
           end
           if ~isempty(obj.width)
                disp_label = [disp_label, sprintf('\nWidth: %s', anyToString(obj.width))];
           end
           if ~isempty(obj.vis_type)
                disp_label = [disp_label, sprintf('\nVis Type: %s', anyToString(obj.vis_type))];
           end
           fprintf(file, '<data key="arc_disp_label">%s</data>\n', disp_label);
           
           %Emit Static Attributes
           if ~isempty(obj.datatype)
                writeNTabs(file, numTabs+1);
                fprintf(file, '<data key="arc_datatype">%s</data>\n', anyToString(obj.datatype));
           end
           
           if ~isempty(obj.complex)
                writeNTabs(file, numTabs+1);
                fprintf(file, '<data key="arc_complex">%s</data>\n', anyToString(obj.complex));
           end
           
           if ~isempty(obj.dimension)
                writeNTabs(file, numTabs+1);
                fprintf(file, '<data key="arc_dimension">%s</data>\n', anyToString(obj.dimension));
           end
           
           if ~isempty(obj.width)
                writeNTabs(file, numTabs+1);
                fprintf(file, '<data key="arc_width">%s</data>\n', anyToString(obj.width));
           end
           
           if ~isempty(obj.vis_type)
                writeNTabs(file, numTabs+1);
                fprintf(file, '<data key="arc_vis_type">%s</data>\n', anyToString(obj.vis_type));
           end
           
           %Close arc entry
           writeNTabs(file, numTabs);
           fprintf(file, '</edge>\n');
            
        end
        
        function str = dstPortTypeStr(obj)
            %dstPortTypeStr Returns the string description of the dst port
            %type
            str = 'Unknown';
            
            if obj.dstPortType == 0
                str = 'Standard';
            elseif obj.dstPortType == 1
                str = 'Enable';
            elseif obj.dstPortType == 2
                str = 'Reset';
            end
                
        end
            
    end
    
    methods (Static)
        function newArc = createBasicArc(src_ir_node, src_ir_port_number, dst_ir_node, dst_ir_port_number, dstPortType)
        %createBasicArc Create a GraphArc object between the src and dst node.  Adds
        %this arc to the src node's out_arcs and to the dst node's in_arcs lists.
        %The ir_node arguments need to be handles.

        newArc = GraphArc(src_ir_node, src_ir_port_number, dst_ir_node, dst_ir_port_number, dstPortType);

        src_ir_node.addOut_arc(newArc);
        dst_ir_node.addIn_arc(newArc);

        %returns newArc
        end
        
        function newArc = createArc(src_ir_node, src_ir_port_number, dst_ir_node, dst_ir_port_number, dstPortType)
        %createArc Create a GraphArc object between the src and dst node.  Adds
        %this arc to the src node's out_arcs and to the dst node's in_arcs
        %lists. Checks the datatype properties of both ports (unless one of
        %the nodes is a master in which case only one port is checked).
        %The datatype properites of the arc are set.
        %The ir_node arguments need to be handles.

        newArc = GraphArc(src_ir_node, src_ir_port_number, dst_ir_node, dst_ir_port_number, dstPortType);
        
        %Add to nodes
        src_ir_node.addOut_arc(newArc);
        dst_ir_node.addIn_arc(newArc);
        
        %Check Datatype
        
        %Note, special nodes have the handle to the port and therefore can
        %get the appopriate datatypes
        if ~src_ir_node.isMaster() && ~dst_ir_node.isMaster()
            %Check both port data types
            
            if ~src_ir_node.isSpecial()
                src_port_handle = getSimulinkOutputPortHandle(src_ir_node.simulinkHandle, src_ir_port_number);
            else
                src_port_handle = src_ir_node.getSpecialNodeSimulinkPortHandle();
            end
                
            if ~dst_ir_node.isSpecial()
                dst_port_handle =  getSimulinkInputPortHandle(dst_ir_node.simulinkHandle, dst_ir_port_number);
            else
                %This is a special node, get the datatype from the output
                %node
                dst_port_handle = dst_ir_node.getSpecialNodeSimulinkPortHandle();
            end
            
            src_datatype = get_param(src_port_handle, 'CompiledPortDatatype');
            dst_datatype = get_param(dst_port_handle, 'CompiledPortDatatype');
            
            if ~strcmp(src_datatype, dst_datatype)
                error(['Datatypes for ' src_ir_node.name ' port '  src_ir_port_number ' (' src_datatype ') and ' dst_ir_node.name ' port ' dst_ir_port_number ' (' dst_datatype ') do not match']); 
            end
            
            src_complex = get_param(src_port_handle, 'CompiledPortComplexSignal');
            dst_complex = get_param(dst_port_handle, 'CompiledPortComplexSignal');
            
            %TODO: Investigate when this may be a cell array 
            if iscell(src_complex)
                src_complex = src_complex{1};
            end
            if iscell(src_complex)
                dst_complex = dst_complex{1};
            end
            
            if src_complex ~= dst_complex
                error(['Complexity of ' src_ir_node.name ' port '  src_ir_port_number ' (' num2str(src_complex) ') and ' dst_ir_node.name ' port ' dst_ir_port_number ' (' num2str(dst_complex) ') do not match']); 
            end
            
            src_dimensions = get_param(src_port_handle, 'CompiledPortDimensions');
            dst_dimensions = get_param(dst_port_handle, 'CompiledPortDimensions');
            
            if src_dimensions ~= dst_dimensions
                error(['Dimensions of ' src_ir_node.name ' port '  src_ir_port_number ' (' num2str(src_dimensions) ') and ' dst_ir_node.name ' port ' dst_ir_port_number ' (' num2str(dst_dimensions) ') do not match']); 
            end
            
            src_width = get_param(src_port_handle, 'CompiledPortWidth');
            dst_width = get_param(dst_port_handle, 'CompiledPortWidth');
            
            if src_width ~= dst_width
                error(['Width of ' src_ir_node.name ' port '  src_ir_port_number ' (' num2str(src_width) ') and ' dst_ir_node.name ' port ' dst_ir_port_number ' (' num2str(dst_width) ') do not match']); 
            end
            
            %Set properties in arc
            newArc.datatype = src_datatype;
            newArc.complex = src_complex;
            newArc.dimension = src_dimensions;
            newArc.width = src_width;
            
        elseif ~src_ir_node.isMaster() && dst_ir_node.isMaster()
            %Pull directly from src port.  Do not check
            
            if ~src_ir_node.isSpecial()
                src_port_handle = getSimulinkOutputPortHandle(src_ir_node.simulinkHandle, src_ir_port_number);
            else
                src_port_handle = src_ir_node.getSpecialNodeSimulinkPortHandle();
            end
            
            src_datatype = get_param(src_port_handle, 'CompiledPortDatatype');
            src_complex = get_param(src_port_handle, 'CompiledPortComplexSignal');
            src_dimensions = get_param(src_port_handle, 'CompiledPortDimensions');
            src_width = get_param(src_port_handle, 'CompiledPortWidth');
            
            %Set properties in arc
            newArc.datatype = src_datatype;
            newArc.complex = src_complex;
            newArc.dimension = src_dimensions;
            newArc.width = src_width;
            
        elseif src_ir_node.isMaster() && ~dst_ir_node.isMaster()
            %Pull directly from dst port.  Do not check

            if ~dst_ir_node.isSpecial()
                dst_port_handle =  getSimulinkInputPortHandle(dst_ir_node.simulinkHandle, dst_ir_port_number);
            else
                %This is a special node, get the datatype from the output
                %node
                dst_port_handle = dst_ir_node.getSpecialNodeSimulinkPortHandle();
            end
            
            dst_datatype = get_param(dst_port_handle, 'CompiledPortDatatype');
            dst_complex = get_param(dst_port_handle, 'CompiledPortComplexSignal');
            dst_dimensions = get_param(dst_port_handle, 'CompiledPortDimensions');
            dst_width = get_param(dst_port_handle, 'CompiledPortWidth');
            
            %Set properties in arc
            newArc.datatype = dst_datatype;
            newArc.complex = dst_complex;
            newArc.dimension = dst_dimensions;
            newArc.width = dst_width;
            
        else
            %Both nodes are masters
            %Issue a warning and set datatypes to []
            
            warning(['Both ' src_ir_node.name ' and ' dst_ir_node.name ' are master nodes ... datatype information unavailable for arc'])
            
            newArc.datatype = [];
            newArc.complex = [];
            newArc.dimension = [];
            newArc.width = [];

        end

        %returns newArc
        end
        
        function newArc = createEnableArc(src_ir_node, src_ir_port_number, dst_ir_node, dst_ir_port_number)
        %createBasicArc Create a GraphArc object between the driver of a
        %special Input/Output ports enable port to that special node.  In
        %this case, the datatype is taken from the src (driver) alone.
        %this arc to the src node's out_arcs and to the dst node's in_arcs lists.
        %The ir_node arguments need to be handles.

        newArc = GraphArc(src_ir_node, src_ir_port_number, dst_ir_node, dst_ir_port_number, 'Enable');

        src_ir_node.addOut_arc(newArc);
        dst_ir_node.addIn_arc(newArc);
        
        %Pull directly from src port.  Do not check

        if ~src_ir_node.isSpecial()
            src_port_handle = getSimulinkOutputPortHandle(src_ir_node.simulinkHandle, src_ir_port_number);
        else
            src_port_handle = src_ir_node.getSpecialNodeSimulinkPortHandle();
        end

        src_datatype = get_param(src_port_handle, 'CompiledPortDatatype');
        src_complex = get_param(src_port_handle, 'CompiledPortComplexSignal');
        src_dimensions = get_param(src_port_handle, 'CompiledPortDimensions');
        src_width = get_param(src_port_handle, 'CompiledPortWidth');

        %Set properties in arc
        newArc.datatype = src_datatype;
        newArc.complex = src_complex;
        newArc.dimension = src_dimensions;
            newArc.width = src_width;

        %returns newArc
        end
    end
end

