import pandas as pd
import numpy as np
import scipy.io as sio
import plotly.express as px

import plotly.io as pio
pio.templates.default = 'simple_white'

def load_data(file_name):
    '''
    Loads the paper data file and returns it as a raw DF
    '''
    raw_data = sio.loadmat(file_name)
    data = pd.DataFrame(raw_data["ChemisensorData"])
    return data

def clean_data(file_name):
    '''
    Loads the paper data file and returns as a clean DF, containing ALL data,
every class and FET
    '''
    # load data
    data = load_data(file_name)
    rows, columns = data.shape
    row_names = []
    column_names = []

    # get clean rows
    for row in range(rows):
        row_name_ = data.iloc[row,0] 
        while(type(row_name_) !=np.str_):
            row_name_ = row_name_[0]
        row_names.append(row_name_)

    # get clean rows
    for column in range(columns):
        column_name_ = data.iloc[0,column] 
        while(type(column_name_) !=np.str_):
            column_name_ = column_name_[0]
        column_names.append(column_name_)

    # create a new df with clean row and column
    df = data.copy(deep=True)
    df.loc[0] = column_names
    df[0] = row_names

    df.columns = df.loc[0]
    df.drop(0,inplace=True)

    # get dimensions of new df (just to be sure)
    rows,columns = df.shape
    new_df = pd.DataFrame(index=np.arange(rows), columns=np.arange(columns))

    # un nest the curves
    for row in np.arange(0,rows):
        for column in np.arange(1,columns):
            nested_curves = df.iloc[row,column][1:]
            curves = []
            for pair in range(nested_curves.size):
                curves.append(nested_curves[pair][0][:,1])

            new_df.iloc[row,column] = curves
    
    new_df.columns=df.columns
    new_df.iloc[:, :1] = df.iloc[:, :1]
    new_df.set_index(new_df.columns[0],inplace=True)

    return new_df

def concat_data(df, sensor_label="sensor"):
    """Concats the data from clean_data() into a single, easy to use df"""
    rows, columns = df.shape

    # list to store a df of every sample class
    df_list = []

    if (sensor_label=="no_sensor"):
        for row in range(rows): # for each ro
            class_list = [pd.DataFrame(df.iloc[row,column]) # gets a df of each column
                          for column in range(columns)]
            df_list.append(pd.concat(class_list)) # adds a df of the pair

    elif (sensor_label=="sensor"):
        for row in range(rows):
            class_list = []
            for column in  range(columns):
                df_ = pd.DataFrame(df.iloc[row,column])
                df_[202] = column # removes the sensor label
                class_list.append(df_)

            df_list.append(pd.concat(class_list))

    for idx,df in enumerate(df_list):
        df["label"]=idx

    return pd.concat(df_list)

def get_full_df(df_list):
    """Concats all DFs in a list into a single DF"""

    # adiciona a big label
    small_label_list = []
    for idx,df in enumerate(df_list):
        df["label_big"]=idx
        small_label_list.append(np.array(df.label.to_list()))

    full_df = pd.concat(df_list)

    for idx,label_list in enumerate(small_label_list):
        if idx >0:
            small_label_list[idx]= label_list+max(small_label_list[idx-1])+1
    full_df["label"] = np.concatenate(small_label_list).tolist()

    return full_df

def get_vgs_vector(file_name):
    '''
    Gets the vgs vector, ripped frm clean_data()
    '''
    # load data
    data = load_data(file_name)
    rows, columns = data.shape
    row_names = []
    column_names = []

    # get clean rows
    for row in range(rows):
        row_name_ = data.iloc[row,0] 
        while(type(row_name_) !=np.str_):
            row_name_ = row_name_[0]
        row_names.append(row_name_)

    # get clean rows
    for column in range(columns):
        column_name_ = data.iloc[0,column] 
        while(type(column_name_) !=np.str_):
            column_name_ = column_name_[0]
        column_names.append(column_name_)

    # create a new df with clean row and column
    df = data.copy(deep=True)
    df.loc[0] = column_names
    df[0] = row_names
    return df.iloc[1,1][1][0][:,0]

def get_labels(file_name):
    '''
    Gets the vgs vector, ripped from clean_data()
    '''
    # load data
    data = load_data(file_name)
    rows, columns = data.shape
    row_names = []
    column_names = []

    # get clean rows
    for row in range(rows):
        row_name_ = data.iloc[row,0] 
        while(type(row_name_) !=np.str_):
            row_name_ = row_name_[0]
        row_names.append(row_name_)

    # get clean rows
    for column in range(columns):
        column_name_ = data.iloc[0,column] 
        while(type(column_name_) !=np.str_):
            column_name_ = column_name_[0]
        column_names.append(column_name_)

    # create a new df with clean row and column
    df = data.copy(deep=True)
    df.loc[0] = column_names
    df[0] = row_names
    return [s.replace('_', ' ') for s in row_names][1:]


def separate_full_df_into_small_label(DF):
    """Separates full DF from get_full_df into DFs separated by file
    (milk, coffee, etc)
    """
    df_list = []
    max_label = max(DF.label_big)
    for label in range(max_label+1):
        df_ = DF[DF.label_big==label].copy(deep=True)
        df_.label = df_.label-min(df_.label)
        df_list.append(df_.reset_index(drop=True).drop("label_big", axis=1))
    return df_list

    
def plot_df_by_sensor(df, df_name, save = False,slegend =True):
    """Plots the curves of a DF by the sensor"""
    # Melt the DataFrame
    plot_df = df.drop("label", axis=1).melt(id_vars=202, var_name='point', value_name='value')
    plot_df['point'] = plot_df['point'].astype(int)  # Ensure points are numeric

    # Convert the color column to string to make it categorical/discrete
    plot_df[202] = (plot_df[202]+1).astype(str) # +1 so the 1st sensor isnt 0

    # Create a plot using Plotly Express with discrete colors
    fig = px.scatter(plot_df, 
                    x="point", 
                    y="value", 
                    color=202,
                    color_discrete_sequence=px.colors.qualitative.Plotly)  # Use a discrete color scale

    # Update layout to adjust appearance and size
    fig.update_layout(
        width=800,
        height=400,
        title=df_name + " Dataset destacados pelo sensor utilizado",
        xaxis_title="Index",
        yaxis_title="Currente (A)",
        legend_title="Sensor",  # Add a title for your legend
        showlegend=slegend,
 
    
    )

    # Show the plot
    fig.show()
    if save == True:
        fig.write_image("df_by_sensor.png", scale=3)  # 3x the default resolution




def plot_df_by_label(df, df_name,save = False,slegend=True):
    """Plots the curves of a DF by the label"""
    df_copy = df.copy(deep=True)
    # get the real labels
    labels_list = get_labels(df_name+"_data.mat")

    # replace by the real label
    df_copy["label"]= df_copy.label.map(lambda x: labels_list[x])
    # Melt the DataFrame
    plot_df = df_copy.drop(202, axis=1).melt(id_vars="label", var_name='point', value_name='value')
    plot_df['point'] = plot_df['point'].astype(int)  # Ensure points are numeric

    # Create a plot using Plotly Express with discrete colors
    fig = px.scatter(plot_df, 
                    x="point", 
                    y="value", 
                    color="label",
                    color_discrete_sequence=px.colors.qualitative.Plotly)  # Use a discrete color scale

    # Update layout to adjust appearance and size
    fig.update_layout(
        width=800,
        height=400,
        title=df_name + " Dataset destacados pela label",
        xaxis_title="Index",
        yaxis_title="Currente (A)",
        legend_title="Label",  # Add a title for your legend
        showlegend=slegend
    )

    # Show the plot
    fig.show()
    if save == True:
        fig.write_image("df_by_label.png", scale=3)

def plot_full_df_by_small_label(df, df_list):
    """Plots the curves of a fullDF by the small label"""
    df_copy = df.copy(deep=True)
    # get the real labels
    labels_list = []
    for name in df_list:
        lst = get_labels(name+"_data.mat")
        labels_list = labels_list+lst

    # replace by the real label
    df_copy["label"]= df_copy.label.map(lambda x: labels_list[x])
    # Melt the DataFrame
    plot_df = df_copy.drop([202,"label_big"], axis=1).melt(id_vars="label", var_name='point', value_name='value')
    plot_df['point'] = plot_df['point'].astype(int)  # Ensure points are numeric

    # Create a plot using Plotly Express with discrete colors
    fig = px.scatter(plot_df, 
                    x="point", 
                    y="value", 
                    color="label",
                    color_discrete_sequence=px.colors.qualitative.Plotly)  # Use a discrete color scale

    # Update layout to adjust appearance and size
    fig.update_layout(
        width=600,
        height=400,
        title=" Datasets destacados pela pequena label",
        xaxis_title="Index",
        yaxis_title="Currente (A)",
        legend_title="Label"  # Add a title for your legend
        
    )

    # Show the plot
    fig.show()

def plot_full_df_by_big_label(df, df_list):
    """Plots the curves of a fullDF by the big label"""
    df_copy = df.copy(deep=True)
    # get the real labels


    # replace by the real label
    df_copy["label_big"]= df_copy.label_big.map(lambda x: df_list[x])
    # Melt the DataFrame
    plot_df = df_copy.drop([202,"label"], axis=1).melt(id_vars="label_big", var_name='point', value_name='value')
    plot_df['point'] = plot_df['point'].astype(int)  # Ensure points are numeric

    # Create a plot using Plotly Express with discrete colors
    fig = px.scatter(plot_df, 
                    x="point", 
                    y="value", 
                    color="label_big",
                    color_discrete_sequence=px.colors.qualitative.Plotly)  # Use a discrete color scale

    # Update layout to adjust appearance and size
    fig.update_layout(
        width=600,
        height=400,
        title=" Datasets destacados pela grande label",
        xaxis_title="Index",
        yaxis_title="Currente (A)",
        legend_title="Label"  # Add a title for your legend
    )

    # Show the plot
    fig.show()

