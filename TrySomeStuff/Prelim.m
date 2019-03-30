%% THis should work

%% Create the sensor
a = arduino('COM4', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04');

% Create ultrasonic sensor object with trigger pin D12 and echo pin D13.
sensor = addon(a, 'JRodrigoTech/HCSR04', 'D12', 'D13');




%% Measure Sensed Distance in Meters
for i = 1:10000
    val = readTravelTime(sensor)*343/2*100;
    fprintf('Current distance is %.4f centemeters\n', val);
    fprintf('Delay\n');
    writePWMDutyCycle(a, 'D9',(51.46-val)/51.46);
    pause(.5);
end


clear sensor
clear a