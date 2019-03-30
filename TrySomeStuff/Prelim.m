%% THis should work

%% Create the sensor
%a = arduino('COM5', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04');

% Create ultrasonic sensor object with trigger pin D12 and echo pin D13.
%sensor = addon(a, 'JRodrigoTech/HCSR04', 'D12', 'D13');




%% Measure Sensed Distance in Meters

for i = 1:50
    val = readTravelTime(sensor);
    v1 = readVoltage(a,'A0');
    degC = (((v1*1000)-500))/10;
    sound = sqrt(1.4*287*(degC+273));
    dist(i) = val*sound/2*100/2.54;
    fprintf('Current time is %.9f ms\n', val);
    fprintf('Temp is %.4f Deg C\n', degC);
    fprintf('Distance is %.3f in\n', dist(i));
    %fprintf('Delay\n');
    %writePWMDutyCycle(a, 'D9',(51.46-val)/51.46);
    pause(.1);
end
in4H= chauvenet(dist);
csvwrite('4Hin_Clean', in4H);
mean(in4H)
%clear sensor
%clear a