classdef HCSR04 < arduinoio.LibraryBase & matlab.mixin.CustomDisplay
    % HCSR04 Create an HCSR04 device object.
    %   
    % sensor = addon(a,'JRodrigoTech/HCSR04',triggerPin,echoPin) creates a HCSR04 device object.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Access = private, Constant = true)
        CREATE_HCSR04           = hex2dec('01')
        DELETE_HCSR04           = hex2dec('02')
        HCSR04_READ_DISTANCE    = hex2dec('03')
        HCSR04_READ_TIME        = hex2dec('04')
    end

    properties(Access = protected, Constant = true)
        LibraryName = 'JRodrigoTech/HCSR04'
        DependentLibraries = {}
        ArduinoLibraryHeaderFiles = {'Ultrasonic/Ultrasonic.h'}
        CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'HCSR04.h')
        CppClassName = 'HCSR04'
    end
    
    properties(Access = private)
        ResourceOwner = 'JRodrigoTech/HCSR04';
    end
    
    methods(Hidden, Access = public)
        function obj = HCSR04(parentObj, triggerPin, echoPin)
            %   Connect to a Ultrasonic sensor HC-SR04 sensor
            %
            %   Syntax:
            %   sensor = addon(a,'JRodrigoTech/HCSR04',triggerPin,echoPin)
            %
            %   Description:
            %   sensor = addon(a,'JRodrigoTech/HCSR04',triggerPin,echoPin)	Connects to a HC-SR04 sensor 
            %
            %   Example:
            %       a = arduino('COM3','Uno','libraries','JRodrigoTech/HCSR04');
            %       sensor = addon(a,'JRodrigoTech/HCSR04','D12','D13')
            %
            %   Input Arguments:
            %   parentObj  - Arduino
            %   triggerPin - Arduino pin to send the signal (character vector)
            %   echoPin    - Arduino pin to receive the echoed back signal (character vector)
            %
            %   Output Arguments:
            %   obj - HCSR04 object

            narginchk(3, 3);
            obj.Parent = parentObj;
            
            try
                obj.Pins = {triggerPin, echoPin};
                % Configure pin modes
                configurePinResource(obj.Parent, triggerPin, obj.ResourceOwner, 'DigitalOutput');
                configurePinResource(obj.Parent, echoPin, obj.ResourceOwner, 'DigitalInput');
                
                createUltrasonicSensor(obj);
            catch e
                throwAsCaller(e);
            end
        end
    end
    
    methods(Access = protected)
        function delete(obj)
            try
                parentObj = obj.Parent;
                for iLoop = obj.Pins
                    configurePinResource(parentObj,iLoop{:},obj.ResourceOwner,'Unset');
                end
                
                deleteUltrasonicSensor(obj);
            catch
                % Do not throw errors on destroy.
                % This may result from an incomplete construction.
            end
        end  
    end
        
    methods(Access = private)
        function createUltrasonicSensor(obj)
            cmdID = obj.CREATE_HCSR04;
            data = getTerminalsFromPins(obj.Parent, obj.Pins);
            sendCommand(obj, obj.LibraryName, cmdID, data);
        end
        
        function deleteUltrasonicSensor(obj)
            cmdID = obj.DELETE_HCSR04;
            sendCommand(obj, obj.LibraryName, cmdID, []);
        end
    end
    
    methods(Access = public)
        function val = readTravelTime(obj)
            %   Get the time for echo pin to receive echoed back signal
            %
            %   Syntax:
            %   readTravelTime(sensor)
            %
            %   Description:
            %   Get the time for echo pin to receive echoed back signal after a signal is sent from send pin
            %
            %   Example:
            %       a = arduino('COM3','Uno','libraries','JRodrigoTech/HCSR04');
            %       sensor = addon(a,'JRodrigoTech/HCSR04','D12','D13');
            %       value = readTravelTime(sensor)
            %
            %   Input Arguments:
            %   obj - HCSR04 device
            %
            %   Output Arguments:
            %   val - Sensed duration that echo pin is high (s)
        
            cmdID = obj.HCSR04_READ_TIME;
            
            try
                val = sendCommand(obj, obj.LibraryName, cmdID, []);
                val = double(typecast(uint8(val), 'int32')); % microseconds
                val = val/1000000; % seconds
            catch e
                throwAsCaller(e);
            end
        end
        
        function val = readDistance(obj)
            %   Get the sensed distance to the nearest object
            %
            %   Syntax:
            %   readDistance(sensor)
            %
            %   Description:
            %   Get the sensed distance to the nearest object, assuming speed of sound is 340m/s
            %
            %   Example:
            %       a = arduino('COM3','Uno','libraries','JRodrigoTech/HCSR04');
            %       sensor = addon(a,'JRodrigoTech/HCSR04','D12','D13');
            %       value = readDistance(sensor)
            %
            %   Input Arguments:
            %   obj - HCSR04 device
            %
            %   Output Arguments:
            %   val - Sensed distance (m)
            
            cmdID = obj.HCSR04_READ_DISTANCE;
            
            try
                val = sendCommand(obj, obj.LibraryName, cmdID, []);
                val = typecast(uint8(val), 'int32'); % in cm
                val = double(val)/100; % in meter
            catch e
                throwAsCaller(e);
            end
        end
    end
    
    methods (Access = protected)
        function displayScalarObject(obj)
            header = getHeader(obj);
            disp(header);
                        
            % Display main options
            fprintf('               Pins: ''%s''(Trigger), ''%s''(Echo)\n', obj.Pins{1}, obj.Pins{2});
            fprintf('\n');
                  
            % Allow for the possibility of a footer.
            footer = getFooter(obj);
            if ~isempty(footer)
                disp(footer);
            end
        end
    end
end