%% Control HC-SR04 Ultrasonic Sensor
%
% This example shows how to use the MATLAB(R) Support Package for
% Arduino(R) Hardware to control a HC-SR04 ultrasonic ranging module
% capable of measuring distances in the 2cm to 400cm range.
 
% Copyright 2016-2017 The MathWorks, Inc. 

%% Hardware Requirements
% * Arduino board
% * HC-SR04 ultrasonic sensor
 
%% Hardware Setup
% 
% * Connect Trig pin to pin D12 on Arduino board.
% * Connect Echo pin to pin D13 on Arduino board.
% * Connect VCC pin to 5V pin on Arduino board.
% * Connect GND pin to GND pin on Arduino board.
%
% <<HCSR04Example_01.png>>
%

%% Create HCSR04 Object
% Create arduino object with JRodrigoTech/HCSR04 add-on.
a = arduino('COM4', 'Uno', 'Libraries', 'JRodrigoTech/HCSR04')

%%
% Create ultrasonic sensor object with trigger pin D12 and echo pin D13.
sensor = addon(a, 'JRodrigoTech/HCSR04', 'D12', 'D13')

%% Measure Sensed Distance in Meters
val = readDistance(sensor);
sprintf('Current distance is %.4f meters\n', val)

%% Measure Distance from Sensed Time
% The distance can be computed from the sensed time using this equation,
% distance = (time x speedOfSound)/2. Assume speed of sound is 340m/s here.
t = readTravelTime(sensor);
sprintf('Current distance is %.4f meters\n', 340*t/2)

%% Clean Up
clear sensor
clear a