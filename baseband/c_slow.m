function c_slow( system, share_fact, verbose)
%c_slow Applies c-slow based resource sharing to system.
%   Detailed explanation goes here

load_system('c_slow_lib');

%Check if system is an enabled subsystem system
enable_block_list = find_system(system,  'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'EnablePort');
enabled_subsystem = ~isempty(enable_block_list);

if(length(enable_block_list) > 1)
    error(['[C-Slow] Error: ', system], ' has more than one enable block');
end

if(enabled_subsystem)
    if(verbose)
        disp(['[C-Slow] Processing Enabled Subsystem: ', system]);
    end
    
    %% Replace Enable Port/Line
    %subsystem_ports = get_param(system, 'PortConnectivity');
    %enable_port_ind = find(strcmp({subsystem_ports.Type}, 'enable')==1);
    %enable_port = subsystem_port(enable_port_ind);
    %enable_src_block = enable_port.SrcBlock;
    %enable_src_port = enable_port.SrcPort+1; % for some reason, port numbers start from 0
    
    %Rewriting to get source port handle using advice from https://www.mathworks.com/matlabcentral/answers/102262-how-can-i-obtain-the-port-types-of-destination-ports-connected-an-output-port-of-any-simulink-block
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
    new_enb_port_internal_outut_handle = new_enb_port_internal_handles.Outport;
    new_enb_port_num = get_param(new_enb_port, 'Port');
    system_port_handles = get_param(system,'PortHandles');
    system_new_enb_port = system_port_handles.Inport(new_enb_port_num);
    
    system_parent = get_param(system, 'Parent');
    
    %re-connect enable line in parent system
    add_line(system_parent,enable_src_port,system_new_enb_port);
    
    %% Break up delays and insert c-slow enabled shift reg
    delay_block_list = find_system(system, 'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Delay');
    
    for delay_block = delay_block_list
        %check if delay length is set by the dialog (ie. is constant)
        if(get_param(delay_block, 'DelayLength') ~= 'Dialog')
            error(['[C-Slow] Variable length delays are not currently supported: Block ', delay_block])
        end
        
        if(verbose)
            disp(['[C-Slow] Replacing delay with enabled shift registers: ', delay_block])
        end
        
        %Get position
        delay_pos = get_param(delay_bloc, 'Position');
        
        %Get delay value
        delay_val = eval(get_param(delay_block, 'DelayLength'));
        
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
            delay_block_port_handles = get_param(delay_block, 'PortHandles');
            %Get delay value
            delay_val = eval(get_param(delay_block, 'DelayLength'));

            shift_reg_blk = zeros(1, delay_val); % Preallocate
            
            %First replacement is a special case
            %Add Shift Reg Block
            new_blk_position = delay_pos;
            shift_reg_blk(1) = add_block('c_slow_lib/c-slow-enabled-shift', [system, '/cSlowSR'], 'MakeNameUnique', 'on', 'Position', new_blk_position, 'ShareFactor', share_fact);
            shift_reg_ports = get_param(shift_reg_blk(1), 'PortHandles');
            %Wire to orig src
            add_wire(system, delay_block_source_port, shift_reg_ports.Inport(1)); %Port 1 is the data port
            add_wire(system, new_enb_port_internal_outut_handle, shift_reg_ports.Inport(2)); %Port 2 is the enable port
            
            %Now, repeat for rest of delay
            for i = 2:1:delay_val
                new_blk_position(1) = delay_pos(2)*i*2;
                new_blk_position(3) = delay_pos(4)*i*2;
                shift_reg_blk(i) = add_block('c_slow_lib/c-slow-enabled-shift', [system, '/cSlowSR'], 'MakeNameUnique', 'on', 'Position', new_blk_position, 'ShareFactor', share_fact);
                shift_reg_ports_current = get_param(shift_reg_blk(i), 'PortHandles');
                shift_reg_ports_prev = get_param(shift_reg_blk(i-1), 'PortHandles');
                %Wire to previous block
                add_wire(system, shift_reg_ports_prev.Outport, shift_reg_ports_current.Inport(1)); %Port 1 is the data port
                %Wire enable port
                add_wire(system, new_enb_port_internal_outut_handle, shift_reg_ports_current.Inport(2)); %Port 2 is the enable port
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
        for dest_port = delay_block_dest_ports
            add_line(system, source_port, dest_port);
        end
    end
else
    % Not an enabled subsystem
    if(verbose)
        disp(['[C-Slow] Processing Standard Subsystem: ', system]);
    end
    
    %% Change delay parameter
    delay_block_list = find_system(system, 'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Delay');
    
    for delay_block = delay_block_list
        if(verbose)
            disp(['[C-Slow] Changing Delay length: ', delay_block])
        end
        
        %Get delay value
        current_delay_val = eval(get_param(delay_block, 'DelayLength'));
        new_delay_val = current_delay_val*share_fact;
        set_param(delay_block, 'DelayLength', new_delay_val);
    end
    
end

%% Recursivly run on subsystems
subsystem_list = find_system(system, 'FollowLinks', 'on', 'LoadFullyIfNeeded', 'on', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'SubSystem');

%Remove current system from list (should only occur once)
current_system_ind = find(strcmp(subsystem_list, system)==1);
if(~isempty(current_system_ind))
    subsystem_list(current_system_ind) = [];
end

for subsystem = subsystem_list
   c_slow(subsystem, share_fact, verbose); 
end

end

