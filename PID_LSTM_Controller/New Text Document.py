import numpy as np
import pandas as pd
import sklearn
import sklearn.preprocessing
import tensorflow as tf
from matplotlib import pyplot as plt

tf.logging.set_verbosity(tf.logging.INFO)

####################################
filename = '0050-0060_5.000-1.500-1.000-0.050.csv'


def readfile(csv_file):
    # open and read only z and u coloms from the csv file
    posdesir = 60
    df = pd.read_csv(csv_file, usecols=[3, 4], names=["inputs", "target"], skiprows=[0])
    posdesir = np.ones(len(df['inputs'])) * posdesir
    min_max_scaler = sklearn.preprocessing.MinMaxScaler()
    df['inputs'] = df['inputs'] - posdesir
    df['inputs'] = min_max_scaler.fit_transform(df.inputs.values.reshape(-1, 1))
    df['target'] = min_max_scaler.fit_transform(df.target.values.reshape(-1, 1))

    # return z and u as np.array
    return np.array(df.inputs), np.array(df.target), len(df.target)


# loding input and target data
inputs, targets, data_size = readfile(filename)

####################################

n_input = 1

SEQLEN = 20

BATCHSIZE = 32
SHUFFLE_SIZE = 50

df_input = inputs[:2*1760]
df_target = targets[:2*1760]

# df_input = df_input[:-2].values
# df_target = df_target[:-2].values


X = np.reshape(df_input, (-1, SEQLEN, n_input))
Y = np.reshape(df_target, (-1, SEQLEN, n_input))
train_split = 0.8

num_data = X.shape[0]

num_train = int(train_split * num_data)

x_train = X[0:num_train]
y_train = Y[0:num_train]

y_test = Y[num_train:]
x_test = X[num_train:]

#x_test = X[0:num_train]
#y_test = Y[0:num_train]

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


RNN_CELLSIZE = 80
N_LAYERS = 2
DROPOUT_PKEEP = 0.7


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


training_config = tf.estimator.RunConfig(model_dir="./output")

estimator = tf.estimator.Estimator(model_fn=model_rnn_fn, config=training_config)

estimator.train(input_fn=train_input, steps=700)

results = estimator.predict(test_input)

Yout_ = [result["Yout"] for result in results]

predict = np.array(Yout_)

actual = y_test[:, -1]

propotion = 75.115-21.35
shift = 21.35


colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
plt.plot(propotion*np.array(actual) + shift, label="Actual Values", color='red')
plt.plot(propotion*predict + shift, label="Predicted Values", color='green', )

plt.title('stock')
plt.xlabel('time [days]')
plt.ylabel('normalized price')
plt.legend(loc='best')

plt.show()
