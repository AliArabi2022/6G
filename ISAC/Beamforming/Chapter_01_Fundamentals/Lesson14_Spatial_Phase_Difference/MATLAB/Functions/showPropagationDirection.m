%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showPropagationDirection(arrivalAngle)

figure('Color','w');

hold on
grid on
axis equal

for y=-1:0.2:1

    plot([-1 1],[y y],...
        'b',...
        'LineWidth',2);

end

theta = deg2rad(arrivalAngle);

quiver(...
    -0.4,...
     0.8,...
     cos(theta),...
    -sin(theta),...
     0,...
     'r',...
     'LineWidth',3);

text(0.2,0.65,...
    sprintf('\\theta = %.0f^o',arrivalAngle));

title('Propagation Direction')

xlim([-1 1])
ylim([-1.2 1.3])

end