%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% togglePause.m
%
% Toggle animation pause using SPACE key.
%
% Version : 1.0.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function togglePause(src,event)

arguments
    src
    event
end

if strcmp(event.Key,'space')

    paused = getappdata(src,'Paused');

    setappdata(src,'Paused',~paused);

end

end