%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lesson 14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showArrayWithWave(...
    arrivalAngle,...
    antennaPosition)

figure('Color','w');

hold on
grid on
axis equal

theta = deg2rad(arrivalAngle);

for k=-4:4

    shift = k*0.15;

    x = [-1 1];

    y = [shift shift];

    R = [cos(theta) -sin(theta)
         sin(theta)  cos(theta)];

    p1 = R*[x(1);y(1)];
    p2 = R*[x(2);y(2)];

    plot([p1(1) p2(1)],...
         [p1(2) p2(2)],...
         'b');
end

plot(antennaPosition,...
     [0 0],...
     'ko',...
     'MarkerFaceColor','r',...
     'MarkerSize',10);

quiver(-0.6,...
        0.7,...
        cos(theta)*0.4,...
       -sin(theta)*0.4,...
        0,...
       'r',...
       'LineWidth',3);

title('Wave Arrival')

xlim([-1 1])
ylim([-1 1])

end