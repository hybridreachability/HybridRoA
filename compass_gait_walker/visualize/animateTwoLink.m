function animateTwoLink(tData, qData, video, play_speed, title_str, t_final, dt_frame)
if nargin < 3
    video = false;
end
if nargin < 4
    play_speed = 1.0;
end
if nargin < 5
    title_str = " ";
end
if nargin < 6
    t_final = tData(end);
end
if nargin < 7
    dt_frame = 0.04; % 25 fps
end
% Ayush Agrawal
% ayush.agrawal@berkeley.edu

    figure(1000)
    dt = tData(2) - tData(1);
    if dt < dt_frame
        down_sample_ratio = floor(dt_frame / dt);
    end
    frame_rate = dt * down_sample_ratio / play_speed;

    if video
        extraArgs.videoFilename = ...
            [datestr(now,'YYYYMMDD_hhmmss') '.mp4'];
        vout = VideoWriter(extraArgs.videoFilename,'MPEG-4');
        vout.Quality = 100;
        vout.FrameRate = 1/frame_rate;
        vout.open;
    end
    title_str = strcat(title_str, " (play speed: x", num2str(play_speed, '%.2f'), ")");
%     palette = get_palette_colors();
    for i =1:down_sample_ratio:length(tData) 
        if tData(i) > t_final 
            break
        end
        clf ;
        pSt = pSt_gen([qData(i, :)';zeros(5,1)]);        
        line([-1; pSt(1)],[0;0],'Color', 'k', 'LineWidth', 1.5);
        line([pSt(1) + 2 * sin(0.03); 4], [0;0],'Color', 'k', 'LineWidth', 1.5);

        drawTwoLink(qData(i, :)');
        axis([-1 2.5 -0.5 1.5]) ; 
        axis equal
        title(title_str);
        grid on ;
        drawnow ;
        pause(0.001) ;
        if video
            current_frame = getframe(gcf); %gca does just the plot
            writeVideo(vout,current_frame);
        end
    end

     if video
          vout.close
     end

end