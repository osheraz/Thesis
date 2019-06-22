import numpy as np
import pandas as pd
import sklearn.preprocessing
import tensorflow as tf
import os
from matplotlib import pyplot as plt
import shutil

tf.logging.set_verbosity(tf.logging.INFO)

TRAIN_START  = 50
TRAIN_TARGET = 60

TEST_START   = 110
TEST_TARGET  = 95

train_filename = '%04d-%04d_5.000-1.500-1.000-0.050.csv' % (TRAIN_START, TRAIN_TARGET)
test_filename = '%04d-%04d_5.000-1.500-1.000-0.050.csv' % (TEST_START, TEST_TARGET)

n_input = 1
SEQLEN = 5
BATCHSIZE = 50
SHUFFLE_SIZE = 50

RNN_CELLSIZE = 80
N_LAYERS = 2
DROPOUT_PKEEP = 0.7

dir_name="./output"
def deldir(dir_name):
    if(os.path.exists(dir_name)):
        shutil.rmtree(dir_name, ignore_errors=True)

        
deldir(dir_name)

def readfile(csv_file,posdesir):
    # open and read only z and u coloms from the csv file
    df = pd.read_csv(csv_file, usecols=[3, 4], names=["inputs", "target"], skiprows=[0])
    posdesir = np.ones(len(df['inputs'])) * posdesir
    min_max_scaler = sklearn.preprocessing.MinMaxScaler()
    df['inputs'] = df['inputs'] - posdesir  
    df['inputs'] = min_max_scaler.fit_transform(df.inputs.values.reshape(-1, 1))
    original_target = np.array(df.target)
    df['target'] = min_max_scaler.fit_transform(df.target.values.reshape(-1, 1))
    
    datasize=(len(df.target)-len(df.target)%SEQLEN)
    
    # return z and u as np.array
    return np.array(df.inputs), np.array(df.target), datasize,original_target


def train_input():
    dataset = tf.data.Dataset.from_tensor_slices((x_train, y_train))
    dataset = dataset.repeat()
    dataset = dataset.shuffle(SHUFFLE_SIZE)
    dataset = dataset.batch(BATCHSIZE)
    samples, labels = dataset.make_one_shot_iterator().get_next()

    return samples, labels


def test_input():
    dataset = tf.data.Dataset.from_tensor_slices((x_test, y_test))
    dataset = dataset.repeat(1)
    dataset = dataset.batch(BATCHSIZE)
    samples, labels = dataset.make_one_shot_iterator().get_next()

    return samples, labels



def model_rnn_fn(features, labels, mode):
    batchsize = tf.shape(features)[0]

    seqlen = tf.shape(features)[1]

    cells = [tf.nn.rnn_cell.GRUCell(RNN_CELLSIZE) for _ in range(N_LAYERS)]

    cells[:-1] = [tf.nn.rnn_cell.DropoutWrapper(cell, output_keep_prob=DROPOUT_PKEEP) for cell in cells[:-1]]
    cell = tf.nn.rnn_cell.MultiRNNCell(cells, state_is_tuple=False)

    Yn, H = tf.nn.dynamic_rnn(cell, features, dtype=tf.float64)
    Yn = tf.reshape(Yn, [batchsize * seqlen, RNN_CELLSIZE])

    Yr = tf.layers.dense(Yn, 1)  # Yr l[BATCHSIZE*SEQLEN, 1]
    Yr = tf.reshape(Yr, [batchsize, seqlen, n_input])  # Yr [BATCHSIZE, SEQLEN, 1]

    Yout = Yr[:, -1, :]  # Last output Yout [BATCHSIZE, 1]

    loss = train_op = None

    if mode != tf.estimator.ModeKeys.PREDICT:
        loss = tf.losses.mean_squared_error(Yr, labels)  # la  bels[BATCHSIZE, SEQLEN, 1]
        lr = 0.001
        optimizer = tf.train.AdamOptimizer(learning_rate=lr)

        train_op = tf.contrib.training.create_train_op(loss, optimizer)

    return tf.estimator.EstimatorSpec(
        mode=mode,
        predictions={"Yout": Yout},
        loss=loss,
        train_op=train_op
    )




# loading input and target data
inputs, targets, data_size , _ = readfile(train_filename,TRAIN_TARGET)


x_train = np.reshape(inputs[:data_size], (-1, SEQLEN, n_input))
y_train = np.reshape(targets[:data_size], (-1, SEQLEN, n_input))


test_inputs, test_target , data_size ,original_target = readfile(test_filename,TEST_TARGET)

x_test = np.reshape(test_inputs[:data_size], (-1, SEQLEN, n_input))
y_test = np.reshape(test_target[:data_size], (-1, SEQLEN, n_input))


#TF
training_config = tf.estimator.RunConfig(model_dir="./output")

estimator = tf.estimator.Estimator(model_fn=model_rnn_fn, config=training_config)

estimator.train(input_fn=train_input, steps=1000)

results = estimator.predict(test_input)

Yout_ = [result["Yout"] for result in results]

predict = np.array(Yout_)

actual = y_test[:, -1]

propotion = max(original_target)-min(original_target)

shift = min(original_target)


colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
plt.plot(propotion*np.array(actual) + shift, label="Actual Force ", color='red')
plt.plot(propotion*predict + shift, label="Predicted Force", color='green', )

plt.title('LSTM-Position+Velocity Controller')
plt.xlabel('time [ms]')
plt.ylabel('Force')
plt.legend(loc='best')

plt.show()
