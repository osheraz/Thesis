import numpy as np
from lstm import LSTM
import pandas as pd
import collections
import random

import tensorflow as tf
tf.reset_default_graph()

# Parameters
filename="0100-0050_5.000-1.500-1.000-0.050.csv"
posdesir=50
learning_rate = 0.001
training_iters = 5000
display_step = 100
n_input = 3
n_output=1
n_hidden = 512 


# Target log path
logs_path = '/tmp/tensorflow/rnn_words'

def readfile(csv_file):
    #open and read only z and u coloms from the csv file
    df = pd.read_csv(csv_file, usecols = [3, 4],names=["inputs","target"], skiprows=[0])
    
    #return z and u as np.array 
    return np.array(df.inputs),np.array(df.target),len(df.target)

#loding input and target data   
carrpos , target , data_size = readfile(filename)
posdesir=np.ones(len(carrpos))*posdesir
training_data=posdesir-carrpos

#def build_dataset(inputs):
#    count = collections.Counter(inputs).most_common()
#    dictionary = dict()
#    for word, _ in count:
#        dictionary[word] = len(dictionary)
#    reverse_dictionary = dict(zip(dictionary.values(), dictionary.keys()))
#    return dictionary, reverse_dictionary, len(dictionary)
#dictionary, reverse_dictionary ,data_size= build_dataset(training_data)

lstm=LSTM(n_input,n_hidden,data_size,logs_path,learning_rate)

with lstm.run():
    step = 0
    offset = random.randint(0,n_input+1)
    end_offset = n_input + 1
    acc_total = 0
    loss_total = 0


    while step < training_iters:
        # Generate a minibatch. Add some randomness on selection process.
        if offset > (len(training_data)-end_offset):
            offset = random.randint(0, n_input+1)
 #       acc, loss = lstm.trainstep(training_data[0].resa,target)

       
        symbols_in_keys = [[[(training_data[i])]] for i in range(offset, offset+n_input) ]
        symbols_in_keys = np.reshape(np.array(symbols_in_keys), [-1, n_input, 1])

       # symbols_out_onehot=[(target)] for i in range(offset, offset+n_output) ]
        symbols_out_onehot= np.reshape(np.array(target), [ n_output,-1]).shape


  
        acc, loss = lstm.trainstep(symbols_in_keys,symbols_out_onehot)
        

        loss_total += loss
        acc_total += acc
        if (step+1) % display_step == 0:
            print("Iter= " + str(step+1) + ", Average Loss= " + \
                  "{:.6f}".format(loss_total/display_step) + ", Average Accuracy= " + \
                  "{:.2f}%".format(100*acc_total/display_step))
            acc_total = 0
            loss_total = 0
            symbols_in = [training_data[i] for i in range(offset, offset + n_input)]
            symbols_out = training_data[offset + n_input]

            index = lstm.teststep(symbols_in_keys)

            symbols_out_pred = reverse_dictionary[index]

            print("%s - [%s] vs [%s]" % (symbols_in,symbols_out,symbols_out_pred))
            
        step += 1
        offset += (n_input+1)
        
    for words in training_data: 
        symbols_in_keys = [dictionary[(words)]]
        for i in range(1):
            keys = np.reshape(np.array(symbols_in_keys), [-1, n_input, 1])              
            onehot_pred_index = lstm.teststep(keys)
            sentence = "%s %s" % (words,reverse_dictionary[onehot_pred_index])
            symbols_in_keys = symbols_in_keys[1:]
            symbols_in_keys.append(onehot_pred_index)
            print(sentence)