function c_slow_helper( system, share_fact, verbose, parent_enabled, parent_enable_src)
%c_slow_helper Applies c-slow based resource sharing to system.
%   Detailed explanation goes here

load_system('c_slow_lib');

%Check if this is one of the builtin Simulink subsystems that have no state
%and should be ignored
system_mask_type = get_param(system, 'MaskType');
if(strcmp(system_mask_type, 'Compare To Zero')==1)
    if(verbose)
        disp(['[C-Slow] Skipping Built-in Simulink Stateless Subsystem: ', system]);
    end
    %This is a built in simulink subsystem with no state.  No need to go
    %further.
    return;
end

%Check if system is an enabled subsystem system
enable_block_list = find_system(system,  'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'EnablePort');
enabled_subsystem = ~isempty(enable_block_list);

if(length(enable_block_list) > 1)
    error(['[C-Slow] Error: ', system], ' has more than one enable block');
end

%Check if this block is masked.  If it is, get the workspace vars and
%assemble a script to set them in the eval calls (used later)
masked_system = (strcmp(get_param(system, 'Mask'), 'on')==1);
if(masked_system)
    mask = Simulink.Mask.get(system);
    mask_workspace = mask.getWorkspaceVariables;
else
    mask_workspace = [];
end

%Check if this block uses a library link.  If so, disable it.
lib_linked_system = ~(strcmp(get_param(system, 'StaticLinkStatus'), 'none')==1);
if(lib_linked_system)
    set_param(system, 'LinkStatus', 'inactive');
end

%Get list of subsystems before c-slow shift register subststems are placed
subsystem_list = find_system(system, 'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'SubSystem');
system_parent = get_param(system, 'Parent');

new_enb_port_internal_output_handle = 0;% Will be set below

if(enabled_subsystem || parent_enabled)
    if(enabled_subsystem)
        if(verbose)
            disp(['[C-Slow] Processing Enabled Subsystem: ', system]);
        end
    
        %% Replace Enable Port/Line
        %Advice from from https://www.mathworks.com/matlabcentral/answers/102262-how-can-i-obtain-the-port-types-of-destination-ports-connected-an-output-port-of-any-simulink-block
        system_port_handles = get_param(system, 'PortHandles');
        enable_port = system_port_handles.Enable;
        enable_line = get_param(enable_port, 'Line');
        enable_src_port = get_param(enable_line, 'SrcPortHandle');
        enable_block = enable_block_list(1);

        %remove enable line and block (will remove enable port)
        delete_line(enable_line);
        delete_block(enable_block);
        new_enb_port = add_block('simulink/Sources/In1', [system, '/en'], 'MakeNameUnique', 'on');
        new_enb_port_internal_handles = get_param(new_enb_port, 'PortHandles');
        new_enb_port_internal_output_handle = new_enb_port_internal_handles.Outport;
        new_enb_port_num = str2double(get_param(new_enb_port, 'Port'));
        system_port_handles = get_param(system,'PortHandles');
        system_new_enb_port = system_port_handles.Inport(new_enb_port_num);
        
        %Add Terminator block in case no state exists within the system or
        %subsystems.  Will stop complaints of unconnected ports.
        term_width = 30;
        term_height = 30;
        enable_port_pos = get_param(new_enb_port, 'Position');
        term_pos(1) = enable_port_pos(3)+term_width;
        term_pos(2) = enable_port_pos(2);
        term_pos(3) = term_pos(1)+term_width;
        term_pos(4) = term_pos(2)+term_height;
        terminator = add_block('simulink/Commonly Used Blocks/Terminator', [system, '/en_terminate'], 'MakeNameUnique', 'on', 'Position', term_pos);
        terminator_port_handles = get_param(terminator, 'PortHandles');
        add_line(system, new_enb_port_internal_output_handle, terminator_port_handles.Inport(1), 'autorouting', 'on');
        
        if(parent_enabled)
            %need to and the parent enable signal with the local enable
            %signal
            system_pos = get_param(system, 'Position');
            width = 30;
            height = 30;
            and_pos(1) = system_pos(1)-width*2;
            and_pos(2) = system_pos(2)-height*2;
            and_pos(3) = system_pos(1)-width;
            and_pos(4) = system_pos(2)-height;
            
            and_block = add_block('simulink/Logic and Bit Operations/Logical Operator', [system_parent, '/en_and'], 'MakeNameUnique', 'on', 'Operator', 'AND', 'Position', and_pos);
            and_block_port_handles = get_param(and_block, 'PortHandles');
            %Connect internal enable line
            add_line(system_parent, enable_src_port, and_block_port_handles.Inport(1), 'autorouting', 'on');
            %Connect external enable line
            add_line(system_parent, parent_enable_src, and_block_port_handles.Inport(2), 'autorouting', 'on');
            %Connect and-ed logic to enable port
            add_line(system_parent, and_block_port_handles.Outport, system_new_enb_port, 'autorouting', 'on');
        else
            %simply re-connect enable line in parent system
            add_line(system_parent, enable_src_port, system_new_enb_port, 'autorouting', 'on');
        end
    else
        %Not an enabled subsystem but is within an enabled sybsystem.
        %% Convert to pseudo-enabled subsystem
        if(verbose)
            disp(['[C-Slow] Processing Standard Subsystem Within Enabled System: ', system]);
        end
        
        %Create new enable port
        new_enb_port = add_block('simulink/Sources/In1', [system, '/en'], 'MakeNameUnique', 'on');
        new_enb_port_internal_handles = get_param(new_enb_port, 'PortHandles');
        new_enb_port_internal_output_handle = new_enb_port_internal_handles.Outport;
        new_enb_port_num = str2double(get_param(new_enb_port, 'Port'));
        system_port_handles = get_param(system,'PortHandles');
        system_new_enb_port = system_port_handles.Inport(new_enb_port_num);
        
        %Connect new port to enable line in parent system
        add_line(system_parent, parent_enable_src, system_new_enb_port, 'autorouting', 'on');
        
        %Add Terminator block in case no state exists within the system or
        %subsystems.  Will stop complaints of unconnected ports.
        term_width = 30;
        term_height = 30;
        enable_port_pos = get_param(new_enb_port, 'Position');
        term_pos(1) = enable_port_pos(3)+term_width;
        term_pos(2) = enable_port_pos(2);
        term_pos(3) = term_pos(1)+term_width;
        term_pos(4) = term_pos(2)+term_height;
        terminator = add_block('simulink/Commonly Used Blocks/Terminator', [system, '/en_terminate'], 'MakeNameUnique', 'on', 'Position', term_pos);
        terminator_port_handles = get_param(terminator, 'PortHandles');
        add_line(system, new_enb_port_internal_output_handle, terminator_port_handles.Inport(1), 'autorouting', 'on');
        
    end
    
    %% Break up delays and insert c-slow enabled shift reg
    delay_block_list = find_system(system, 'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Delay');
    
    for ind = 1:1:length(delay_block_list)
        delay_block=delay_block_list{ind};
        %check if delay length is set by the dialog (ie. is constant)
        if(get_param(delay_block, 'DelayLengthSource') ~= 'Dialog')
            error(['[C-Slow] Variable length delays are not currently supported: Block ', delay_block])
        end
        
        if(verbose)
            disp(['[C-Slow] Replacing delay with enabled shift registers: ', delay_block])
        end
        
        %Get position
        delay_pos = get_param(delay_block, 'Position');
        
        %Get delay value
        delay_val = eval_and_destroy(get_param(delay_block, 'DelayLength'), mask_workspace);
        
        delay_block_port_handles = get_param(delay_block, 'PortHandles');
        
        %Get source port (should have 1 input port) & delete line
        delay_block_source_line = get_param(delay_block_port_handles.Inport, 'Line');
        delay_block_source_port = get_param(delay_block_source_line, 'SrcPortHandle');
        delete_line(delay_block_source_line);

        %Get destination ports (should only have 1 output port but possibly
        %many destinations) & delete line
        delay_block_dest_line = get_param(delay_block_port_handles.Outport, 'Line');
        delay_block_dest_ports = get_param(delay_block_dest_line, 'DstPortHandle');
        delete_line(delay_block_dest_line);
        
        %Remove delay block
        delete_block(delay_block)

        source_port = 0; % set later
        if(delay_val > 0) 
            %Delay value is non-zero, replace it
            shift_reg_blk = zeros(1, delay_val); % Preallocate
            
            %First replacement is a special case
            %Add Shift Reg Block
            block_width = delay_pos(3) - delay_pos(1);
            new_blk_position = delay_pos;
            shift_reg_blk(1) = add_block('c_slow_lib/c-slow-enabled-shift', [system, '/cSlowSR'], 'MakeNameUnique', 'on', 'Position', new_blk_position, 'ShareFactor', num2str(share_fact));
            shift_reg_ports = get_param(shift_reg_blk(1), 'PortHandles');
            %Wire to orig src
            add_line(system, delay_block_source_port, shift_reg_ports.Inport(1), 'autorouting', 'on'); %Port 1 is the data port
            add_line(system, new_enb_port_internal_output_handle, shift_reg_ports.Inport(2), 'autorouting', 'on'); %Port 2 is the enable port
            
            %Now, repeat for rest of delay
            for i = 2:1:delay_val
                new_blk_position(1) = delay_pos(1)+block_width*2*(i-1);
                new_blk_position(3) = delay_pos(3)+block_width*2*(i-1);
                shift_reg_blk(i) = add_block('c_slow_lib/c-slow-enabled-shift', [system, '/cSlowSR'], 'MakeNameUnique', 'on', 'Position', new_blk_position, 'ShareFactor', num2str(share_fact));
                shift_reg_ports_current = get_param(shift_reg_blk(i), 'PortHandles');
                shift_reg_ports_prev = get_param(shift_reg_blk(i-1), 'PortHandles');
                %Wire to previous block
                add_line(system, shift_reg_ports_prev.Outport, shift_reg_ports_current.Inport(1), 'autorouting', 'on'); %Port 1 is the data port
                %Wire enable port
                add_line(system, new_enb_port_internal_output_handle, shift_reg_ports_current.Inport(2), 'autorouting', 'on'); %Port 2 is the enable port
            end
            
            %Set the source port (to be connected to the destinations) to
            %be the output of the last shift register instance
            shift_reg_ports = get_param(shift_reg_blk(delay_val), 'PortHandles');
            source_port = shift_reg_ports.Outport;
        else
            %Delay is 0, remove it by passing original source port
            source_port = delay_block_source_port;
        end

        %wire the source port to the destination ports
        for j = 1:1:length(delay_block_dest_ports)
            dest_port=delay_block_dest_ports(j);
            add_line(system, source_port, dest_port, 'autorouting', 'on');
        end
    end
else
    % Not an enabled subsystem
    if(verbose)
        disp(['[C-Slow] Processing Standard Subsystem: ', system]);
    end
    
    %% Change delay parameter
    delay_block_list = find_system(system, 'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Delay');
    
    for ind = 1:1:length(delay_block_list)
        delay_block=delay_block_list{ind};
        
        if(verbose)
            disp(['[C-Slow] Changing Delay length: ', delay_block])
        end
        
        %Get delay value
        current_delay_val = eval_and_destroy(get_param(delay_block, 'DelayLength'), mask_workspace);
        new_delay_val = current_delay_val*share_fact;
        set_param(delay_block, 'DelayLength', num2str(new_delay_val));
    end
    
end

%% Recursivly run on subsystems
%Use list we got before c-slow shift register subsystems were created
%Remove current system from list (should only occur once)
current_system_ind = find(strcmp(subsystem_list, system)==1);
if(~isempty(current_system_ind))
    subsystem_list(current_system_ind) = [];
end

for ind = 1:1:length(subsystem_list)
   subsystem=subsystem_list{ind};
   c_slow_helper(subsystem, share_fact, verbose, (enabled_subsystem || parent_enabled), new_enb_port_internal_output_handle); 
end

end

