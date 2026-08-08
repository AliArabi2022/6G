%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showPlaneWaveOnly(arrivalAngle)

figure('Color','w');

hold on
axis equal
grid on

title('Plane Wave')

for y=-1:0.2:1

    plot([-1 1],[y y],...
        'b',...
        'LineWidth',2);

end

text(-0.9,1.15,'Plane Wave');

xlim([-1 1])
ylim([-1.2 1.3])

end