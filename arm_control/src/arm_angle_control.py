#!/usr/bin/env python

import numpy as np
import pprint
import rospy
from rospy.numpy_msg import numpy_msg

from std_msgs.msg import Int32MultiArray

# Global Variables
pp = pprint.PrettyPrinter(indent=4)
model_name = 'komodo2'
node_name = 'arm_controller'
pwm_to_pub = Int32MultiArray()
motor_con = 4
limit = 1000
crit = 0
dx = 20
dy = dx
# Motor specs: [mm]
x = np.linspace(260, 340, dx)  # HDA50 Stroke
y = np.linspace(197, 270, dy)  # P16 Stroke
y_ = 197  # P16 Extracted length
x_ = 246  # HDA50 Extracted length
h = 140
L = 550
l4 = 80
l1 = 285
r = 237
l3 = 46
l2 = 293
lp = 206
l33 = 398





def main():
    ArmController()
    rospy.spin()

def clamp(x, minimum, maximum):
    return max(minimum, min(x, maximum))


class ArmController:

    rospy.init_node(node_name)
    Hz = 50
    rate = rospy.Rate(Hz)
    kp_ac=10
    ki_ac=.1
    kd_ac =0
    kp_sc=20
    ki_sc=.2
    kd_sc = 0
    des_cmd = 300*np.ones((motor_con,),dtype=np.int32)
    pwm_temp = np.zeros((motor_con,),dtype=np.int32)
    fb = np.zeros((motor_con,),dtype=np.int32)
    error =np.zeros((motor_con,),dtype=np.int32)
    error_sum = np.zeros((motor_con,),dtype=np.int32)
    Xp = np.zeros((20,20))
    Yp = np.zeros((20,20))
    delta = np.zeros((20,20))


    def __init__(self):

        rospy.Subscriber('/arm/angle_height', Int32MultiArray, self.update_cmd_angle_height)
        rospy.Subscriber('/arm/des_cmd',Int32MultiArray, self.update_cmd)
        rospy.Subscriber('/arm/pot_fb',Int32MultiArray, self.update_fb)
        self.motor_pub = rospy.Publisher('/arm/motor_cmd', Int32MultiArray, queue_size=10)
        self.Xp, self.Yp, self.delta = self.calc_working_area()

        while not rospy.is_shutdown():


            #rospy.loginfo("des_cmd " + str(self.des_cmd) + "      fb " + str(self.fb))
            self.des_cmd=np.asarray(self.des_cmd)
            self.error = self.des_cmd-self.fb

            ##self.error = np.where(abs(self.error_sum) < crit, 0, self.error)
            self.error = np.where(abs(self.error) < crit, 0, self.error)

            self.error_sum += self.error
            self.error_sum = np.where(abs(self.error_sum) < limit, self.error_sum, np.sign(self.error_sum)*limit)
            #rospy.loginfo("error: " + str(self.error) + "      sum: " + str(self.error_sum))

            self.pwm_temp[:2] = self.kp_ac*self.error[:2] + self.ki_ac*self.error_sum[:2] # first 2 is P16
            self.pwm_temp[2:] = self.kp_sc*self.error[2:] + self.ki_sc*self.error_sum[2:] # next  2 is HD50


            self.pwm_temp = np.clip(self.pwm_temp, -250, 250)
            self.pwm_temp =self.pwm_temp.tolist()

            #rospy.loginfo("value: " + str(self.pwm_temp))
            #rospy.loginfo("type: " + str(type(self.pwm_temp)))
            np.set_printoptions(precision=1)
            rospy.loginfo("feedback : " + str(self.fb) + "    pwm applied : " + str(self.pwm_temp))

            pwm_to_pub.data=self.pwm_temp
            #rospy.loginfo("type: " + str(type(pwm_to_pub)))
            #rospy.loginfo("pwm_to_pub : " + str(pwm_to_pub))

            self.motor_pub.publish(pwm_to_pub)

            self.rate.sleep()



    def update_fb(self, data):
        """

        :param data:
        :type data:
        :return:       range      0 - 1023
        :rtype:
        """
        self.fb = data.data


    def update_cmd(self, data):
        """

        :param data:
        :type data:
        :return:       range      0 - 1023
        :rtype:
        """
        #self.des_cmd = data.data
        
        if (data.data[0] == data.data[1] and data.data[2] == data.data[3]):
            self.des_cmd = data.data
        else:
            rospy.loginfo("DONT BREAK MY ARM!")

    def update_cmd_angle_height(self, data):
        """

        :param data:
        :type data:
        :return:       range      0 - 1023
        :rtype: self.des_cmd = data.data
        """
        angle = data.data[0]
        height = data.data[1]
        eps_d = 5*np.pi/180
        eps_h = 10
        delta_ = self.delta + 20 * np.pi / 180
        [idx, idy] = np.where(abs(delta_ - angle) < eps_d)
        [ihx, ihy] = np.where(abs(self.Yp - height) < eps_h)
        ind_x = idx[np.isin(self.Yp[idx, idy], self.Yp[ihx, ihy])]
        ind_y = idy[np.isin(self.Yp[idx, idy], self.Yp[ihx, ihy])]
        x_cmd = (x[ind_x] - x_)  * 1023 / 101
        y_cmd = (y[ind_y] - y_)  * 1023 / 150
        self.des_cmd = np.array([x_cmd[0] , x_cmd[0] , y_cmd[0] , y_cmd[0]]).astype(int)
        rospy.loginfo("x : " + str(x_cmd[0]) + "    y : " + str(y_cmd[0]))

    def calc_working_area(self):
        """

        :param data:
        :type data: BobcatControl
        :return:
        :rtype:
        """
        # Arm mech

        q = np.arcsin((x**2 + h**2 - l1**2) / (2*x*h))
        # a = np.arcsin(-h + x*np.sin(q)) /(l1)
        b_ = np.arcsin((h* np.sin(np.pi/2 - q)) /(l1)) - 12.6*np.pi/180
        b = b_ + 36.35*np.pi/180

        # Bucket mech

        phi = np.arccos((y**2 - r**2 - l3**2) / (-2 * r * l3))
        gama = 87.21*np.pi/180 - phi
        [QB, G] = np.meshgrid(q - b, gama)
        delta = QB + G

        # Bucket tip location

        p1 = x*np.cos(q) + l33 * np.cos(q - b)
        p2 = lp * np.cos(delta)
        p3 = x*np.sin(q) + l33 * np.sin(q - b)
        p4 = lp *np.sin(delta)
        Xp = np.add(p1, p2)
        Yp = np.add(p3, p4)
        return Xp, Yp , delta






if __name__ == '__main__':
    try:
        main()
    except rospy.ROSInterruptException:
        pass
