%% Plot the constallation
function M = plotConst(data_i, data_q, number_pts, step, const_pts, window_x, window_y, graph_y_lim, fig_size, title_txt)
    %clear M mid_pt_hist slope_hist dist_hist;

    %number_pts = 50;
    %step = 50;
    %const_pts = complex([-1, 1]);
    %window_x = [-2, 2];
    %window_y = [-2, 2];

    %graph_y_lim = [-2, 2];

    data = complex(data_i + data_q.*j);

    data_2d = transpose(cat(1, data_i, data_q));

    frame = 1;
    
    %Positioning from https://www.mathworks.com/matlabcentral/newsreader/view_thread/136464
    screensize = get(0,'ScreenSize');
    xpos = ceil((screensize(3)-fig_size(2))/2);
    ypos = ceil((screensize(4)-fig_size(1))/2);

    f = figure('Position', [xpos, ypos, fig_size(1), fig_size(2)]);

    for i = step:step:length(data)

        %this will never occure if starting from "step"
        if (i-number_pts) <= 0
            lb = 1;
        else
            lb = i-number_pts;
        end

        [idx, C] = kmeans(data_2d((lb:i),:), length(const_pts));

        %find left and right clusters
        if(C(1,1) < C(2,1))
            leftC_i = C(1,1);
            leftC_q = C(1,2);
            rightC_i = C(2,1);
            rightC_q = C(2,2);
        else
            leftC_i = C(2,1);
            leftC_q = C(2,2);
            rightC_i = C(1,1);
            rightC_q = C(1,2);
        end

        mid_pt_i = (leftC_i + rightC_i)/2;
        mid_pt_q = (leftC_q + rightC_q)/2;

        mid_pt_hist(frame) = complex(mid_pt_i+mid_pt_q*j);
        slope_hist(frame) = (rightC_q - leftC_q)/(rightC_i - leftC_i);
        dist_hist(frame) = sqrt((rightC_q - leftC_q)^2 + (rightC_i - leftC_i)^2);

        %plot axes
        subplot(3, 1 ,[1,2]);
        plot(complex([0+window_y(1)*j, 0+window_y(2)*j]), 'k--');
        hold on;
        plot(complex([window_x(1)+0*j, window_x(2)+0*j]), 'k--');
        %plot history of midpoint
        plot(mid_pt_hist, 'm-');
        %plot ref const pts
        plot(const_pts, 'r+');
        %plot rx pts
        plot(data(lb:i), 'b.');
        %plot kmeans cluster centers
        plot(complex([leftC_i+leftC_q*j, rightC_i+rightC_q*j]), 'go-');
        plot(complex(mid_pt_i+mid_pt_q*j), 'm*');
        axis square;
        xlabel('I');
        ylabel('Q');
        grid minor;
        xlim(window_x);
        ylim(window_y);
        title(title_txt);

        hold off;
        subplot(3, 1 ,3);
        plot(real(mid_pt_hist), 'k-');
        hold on;
        plot(imag(mid_pt_hist), 'b-');
        plot(slope_hist, 'm-');
        plot(dist_hist, 'g-');
        grid minor;
        xlim([1, length(data)/step]);
        ylim([graph_y_lim]);
        leg=legend('Midpoint X', 'Midpoint Y', 'Slope', 'Distance');
        set(leg.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.8;.8;.8;.6]));
        hold off;

        M(frame) = getframe(f);
        frame = frame+1;
    end

    close(f);
    %f = figure;
    %movie(f, M)
end