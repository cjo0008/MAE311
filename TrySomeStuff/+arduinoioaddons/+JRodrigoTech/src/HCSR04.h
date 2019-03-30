/*
 * @file HCSR04.h
 *
 * Class definition for HCSR04 class that wraps APIs of Ultrasonic library
 * https://github.com/hemalchevli/ultrasonic-library
 * https://forum.arduino.cc/index.php?topic=37712.0
 *
 * @copyright Copyright 2016-2017 The MathWorks, Inc.
 */

#include "LibraryBase.h"
#include "Ultrasonic.h"

#define CREATE_HCSR04               0x01
#define DELETE_HCSR04               0x02
#define HCSR04_READ_DISTANCE        0x03
#define HCSR04_READ_TIME            0x04
        
const char MSG_CREATE_HCSR04[]           PROGMEM = "HCSR04::mySensor = new Ultrasonic(%d,%d);\n";
const char MSG_DELETE_HCSR04[]           PROGMEM = "HCSR04::delete mySensor;mySensor = NULL;\n";
const char MSG_HCSR04_TIMING[]           PROGMEM = "HCSR04::Timing() --> %ld;\n";
const char MSG_HCSR04_RANGING[]          PROGMEM = "HCSR04::Ranging(%s) --> %ld;\n";

class HCSR04 : public LibraryBase
{
	public:
		HCSR04(MWArduinoClass& a)
		{
            libName = "JRodrigoTech/HCSR04";
 			a.registerLibrary(this);
		}
    private:
        Ultrasonic* mySensor;
		
	public:
		void commandHandler(byte cmdID, byte* dataIn, unsigned int payloadSize)
		{
            switch (cmdID){
                case CREATE_HCSR04:{ 
                    byte trigger = dataIn[0];
                    byte echo    = dataIn[1];
                    
                    debugPrint(MSG_CREATE_HCSR04, trigger, echo);
                    mySensor = new Ultrasonic(trigger, echo);
                            
                    sendResponseMsg(cmdID, 0, 0);
                    break;
                }
                case DELETE_HCSR04:{
                    debugPrint(MSG_DELETE_HCSR04);
                    delete mySensor;
                    mySensor = NULL;
                    
                    sendResponseMsg(cmdID, 0, 0);
                    break;
                }
                case HCSR04_READ_TIME:{                
                    long value = mySensor->Timing();
                    debugPrint(MSG_HCSR04_TIMING, value);
                    
                    byte result [4];
                    result[0] = (value & 0x000000ff);
                    result[1] = (value & 0x0000ff00) >> 8;
                    result[2] = (value & 0x00ff0000) >> 16;
                    result[3] = (value & 0xff000000) >> 24;
                    sendResponseMsg(cmdID, result, 4);
                    break;
                }
                case HCSR04_READ_DISTANCE:{
                    
                    long value = mySensor->Ranging(1);
                    debugPrint(MSG_HCSR04_RANGING, "CM\0", value);
                    
                    byte result [4];
                    result[0] = (value & 0x000000ff);
                    result[1] = (value & 0x0000ff00) >> 8;
                    result[2] = (value & 0x00ff0000) >> 16;
                    result[3] = (value & 0xff000000) >> 24;
                    sendResponseMsg(cmdID, result, 4);
                    break;
                }
                default:{
                    // Do nothing
                }
            }
        }
};