// Listen to /arm/motor_cmd and publish the msg to the motors

#include <ros.h>
#include <std_msgs/Int32MultiArray.h>
#include <std_msgs/Int32.h>
#include <SPI.h>

// define parametes
#define motor_con 4

// L9958 slave select pins for SPI
#define SS_M4 14
#define SS_M3 13
#define SS_M2 12
#define SS_M1 11
// L9958 DIRection pins
#define DIR_M1 2
#define DIR_M2 3
#define DIR_M3 4
#define DIR_M4 7
// L9958 PWM pins
#define PWM_M1 9
#define PWM_M2 10    // Timer1
#define PWM_M3 5
#define PWM_M4 6     // Timer0

// L9958 Enable for all 4 motors
#define ENABLE_MOTORS 8

//-------------------- Methods
void set_motor_pwm(const std_msgs::Int32MultiArray& msg);

//-------------------- Global variables
ros::NodeHandle nh;
std_msgs::Int32MultiArray pot_fb;
std_msgs::Int32 pwm_fb;

ros::Subscriber<std_msgs::Int32MultiArray> sub("/arm/motor_cmd", &set_motor_pwm);
ros::Publisher pub_fb("/arm/pot_fb", &pot_fb);
ros::Publisher pub_pwm("/arm/true_pwm1", &pwm_fb);
byte motors_PWM_pin[4] = {9,10,5,6};
byte motors_DIR_pin[4] = {2,3,4,7};
long int arr[motor_con]={0};
int currentPosition = 0;
byte feedback[4] = {A9, A10, A11, A12}; //potentiometer from actuator

void setup() {
  
  unsigned int configWord;
  nh.getHardware()->setBaud(115200);
  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(pub_fb);
  nh.advertise(pub_pwm);
  pot_fb.data_length =motor_con;
  
  Serial.begin(115200);
  // put your setup code here, to run once:
  pinMode(SS_M1, OUTPUT); digitalWrite(SS_M1, LOW);  // HIGH = not selected
  pinMode(SS_M2, OUTPUT); digitalWrite(SS_M2, LOW);
  pinMode(SS_M3, OUTPUT); digitalWrite(SS_M3, LOW);
  pinMode(SS_M4, OUTPUT); digitalWrite(SS_M4, LOW);

  // L9958 DIRection pins
  pinMode(DIR_M1, OUTPUT);
  pinMode(DIR_M2, OUTPUT);
  pinMode(DIR_M3, OUTPUT);
  pinMode(DIR_M4, OUTPUT);

  // L9958 PWM pins
  pinMode(PWM_M1, OUTPUT);  digitalWrite(PWM_M1, LOW);
  pinMode(PWM_M2, OUTPUT);  digitalWrite(PWM_M2, LOW);    // Timer1
  pinMode(PWM_M3, OUTPUT);  digitalWrite(PWM_M3, LOW);
  pinMode(PWM_M4, OUTPUT);  digitalWrite(PWM_M4, LOW);    // Timer0

  // L9958 Enable for all 4 motors
  pinMode(ENABLE_MOTORS, OUTPUT); 
 digitalWrite(ENABLE_MOTORS, HIGH);  // HIGH = disabled

/******* Set up L9958 chips *********
  ' L9958 Config Register
  ' Bit
  '0 - RES
  '1 - DR - reset
  '2 - CL_1 - curr limit
  '3 - CL_2 - curr_limit
  '4 - RES
  '5 - RES
  '6 - RES
  '7 - RES
  '8 - VSR - voltage slew rate (1 enables slew limit, 0 disables)
  '9 - ISR - current slew rate (1 enables slew limit, 0 disables)
  '10 - ISR_DIS - current slew disable
  '11 - OL_ON - open load enable
  '12 - RES
  '13 - RES
  '14 - 0 - always zero
  '15 - 0 - always zero
  */  // set to max current limit and disable ISR slew limiting
  configWord = 0b0000010000001100;

  SPI.begin();
  SPI.setBitOrder(LSBFIRST);
  SPI.setDataMode(SPI_MODE1);  // clock pol = low, phase = high

  // Motor 1
  digitalWrite(SS_M1, LOW);
  SPI.transfer(lowByte(configWord));
  SPI.transfer(highByte(configWord));
  digitalWrite(SS_M1, HIGH);
  // Motor 2
  digitalWrite(SS_M2, LOW);
  SPI.transfer(lowByte(configWord));
  SPI.transfer(highByte(configWord));
  digitalWrite(SS_M2, HIGH);
  // Motor 3
  digitalWrite(SS_M3, LOW);
  SPI.transfer(lowByte(configWord));
  SPI.transfer(highByte(configWord));
  digitalWrite(SS_M3, HIGH);
  // Motor 4
  digitalWrite(SS_M4, LOW);
  SPI.transfer(lowByte(configWord));
  SPI.transfer(highByte(configWord));
  digitalWrite(SS_M4, HIGH);


digitalWrite(ENABLE_MOTORS, LOW);// LOW = enabled
} // End setup

void loop() {
    nh.spinOnce();
    delay(5);
      for (int i = 0; i < motor_con; i++)
  {
    currentPosition = analogRead(feedback[i]);
    Serial.print("Position    ");
    Serial.println(currentPosition);
    arr[i] = currentPosition;
  }
  pot_fb.data = arr;
  pub_fb.publish(&pot_fb);
  delay(5);
}//end void loop

void set_motor_pwm(const std_msgs::Int32MultiArray& msg) {
  int motor_pwm = 0;
  bool motor_dir = 0;
  for (int i = 0; i < motor_con; i++) {
    motor_pwm = msg.data[i];
    if (motor_pwm > 0)
      motor_dir = 1;
    else
      motor_dir = 0;
    Serial.print("PWM    ");
    Serial.print(motor_pwm);
    if (i==3){
    pwm_fb.data = motor_pwm;
    pub_pwm.publish(&pwm_fb);
    }
    digitalWrite(motors_DIR_pin[i], motor_dir);
    analogWrite(motors_PWM_pin[i],  abs(motor_pwm));
  }

}
