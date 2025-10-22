import streamlit as st
import pandas as pd
from dotenv import load_dotenv
load_dotenv()
import kaggle

"""
# My first app
Here's our first attempt at using data to create a table:
"""

kaggle.api.authenticate()
dataset_identifier = 'olistbr/brazilian-ecommerce' # Replace with the actual dataset identifier
download_path = './data' # Specify your desired download path
kaggle.api.dataset_download_files(dataset_identifier, path=download_path, unzip=True)
print(f"Dataset '{dataset_identifier}' downloaded and unzipped to '{download_path}'")

df = pd.read_csv('./data/olist_orders_dataset.csv')
st.write(df)