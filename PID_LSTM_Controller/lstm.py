import tensorflow as tf
from tensorflow.contrib import rnn


class LSTM:

    def __init__(self,n_input,n_hidden,n_outpot,logs_path,learning_rate):
        
        self.writer = tf.summary.FileWriter(logs_path)
        # tf Graph input
        self.x = tf.placeholder("float", [None, n_input, 1])
        self.y = tf.placeholder("float", [None, n_outpot])
        # reshape to [1, n_input]
        x = tf.reshape(self.x, [-1, n_input])

        # Generate a n_input-element sequence of inputs
        # (eg. [had] [a] [general] -> [20] [6] [33])
        x = tf.split(x,n_input,1)

        # 2-layer LSTM, each layer has n_hidden units.
        # Average Accuracy= 95.20% at 50k iter
        rnn_cell = rnn.MultiRNNCell([rnn.BasicLSTMCell(n_hidden),rnn.BasicLSTMCell(n_hidden)])

        # 1-layer LSTM with n_hidden units but with lower accuracy.
        # Average Accuracy= 90.60% 50k iter
        # Uncomment line below to test but comment out the 2-layer rnn.MultiRNNCell above
        #rnn_cell = rnn.BasicLSTMCell(n_hidden)

        # RNN output node weights and biases
        self.weights = {'out': tf.Variable(tf.random_normal([n_hidden, n_outpot])) }
        self.biases = {'out': tf.Variable(tf.random_normal([n_outpot]))}
        # generate prediction
        outputs, states = rnn.static_rnn(rnn_cell, x, dtype=tf.float32)            
        # there are n_input outputs but
        # we only want the last output
        self.pred= tf.matmul(outputs[-1], self.weights['out']) + self.biases['out']
        
        # Loss and optimizer
        self.cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(logits=self.pred, labels=self.y))
        self.optimizer = tf.train.RMSPropOptimizer(learning_rate=learning_rate).minimize(self.cost)
        # Model evaluation
        correct_pred = tf.equal(tf.argmax(self.pred,1), tf.argmax(self.y,1))
        self.accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))
        # Initializing the variables
        self.init = tf.global_variables_initializer()
    
    
    def run(self):
        self.sess = tf.Session() 
        self.sess.run(self.init)
        self.writer.add_graph(self.sess.graph)
        return self.sess 
        
    def trainstep(self,I,T):       
        _, acc, loss = self.sess.run([self.optimizer, self.accuracy, self.cost], feed_dict={self.x: I, self.y: T})        
        return acc, loss
    
    def teststep(self,Itest):
        onehot_pred=self.sess.run(self.pred, feed_dict={self.x: Itest})
        return int(tf.argmax(onehot_pred, 1).eval())
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
