#!/usr/bin/env python
# coding: utf-8

# In[152]:


pip install mysql-connector-python


# In[288]:


import mysql.connector
import sqlalchemy
from sqlalchemy import create_engine

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import numpy as np
import plotly.express as px
import pymysql


# In[289]:


import warnings
warnings.filterwarnings('ignore')

db = mysql.connector.connect(
        host='localhost',
        user='root',
        password='1234',
        database='sprint4'
)

cursor = db.cursor()

cursor.execute("show tables")
tablas=[x[0] for x in cursor.fetchall()]



for tabla in tablas_mysql:
    nombre_tabla = tabla[0]  # El fetchall trae tuplas, saco el nombre
    dfs[f'df_{nombre_tabla}'] = pd.read_sql(f"SELECT * FROM {nombre_tabla}", con=conector)

# Ver las claves
print(dfs.keys())
#para llamar a los df tengo que hacer dfs['df_nombre']

cursor.close()
db.close()

# Imprimir los nombres de las tablas que se leyeron correctamente
for x in dataframes:
    print(x)
# In[290]:


db = mysql.connector.connect(
        host='localhost',
        user='root',
        password='1234',
        database='sprint4'
)

cursor = db.cursor()

# Traer todas las tablas de la base
cursor.execute("SHOW TABLES")
tablas_mysql = cursor.fetchall()

# Crear diccionario
dfs = {}

# Recorro las tablas dinámicamente
for tabla in tablas_mysql:
    nombre_tabla = tabla[0]  # El fetchall trae tuplas, saco el nombre
    dfs[f'df_{nombre_tabla}'] = pd.read_sql(f"SELECT * FROM {nombre_tabla}", con=db)

# Ver las claves
print(dfs.keys())
#para llamar a los df tengo que hacer dfs['df_nombre']


# #compruebo que no haya duplicados:
# def data_info(df):
#    
#     """Input: dataframe.
#     Function displays basic information, 
#     checks for duplicates and NaN. 
#     """
#     
#     # get first and last 5 rows
#     display(df)
#     
#     # get information about the data
#     print()
#     print(df.info())
#     
#     # number of unique values for each column
#     print()
#     print('\033[1mNumber of unique values')
#     display(df.nunique())
#     
#     # check for duplicates (without id columns)
#     print()
#     if df.iloc[:,1:].duplicated().sum() > 0:
#         print('Data contain full duplicates\n')
#     else:
#         print('There are no full duplicates in the data\n')
#     
#     # check for NaN
#     if df.isna().sum().sum() > 0:
#         print('Data contain NaN\n')
#     else:
#         print('There are no NaNs in the data\n')

# for tabel in dfs:
#     print(f'\033[1m{tabel.upper()}')
#     print('_____________________')
#     data_info(dfs[tabel])

# In[291]:


dfs['df_products']


# ## LIMPIO

# In[292]:


# Elimino de la tabla products el dolar en la columna 'price' y la transformo en float
# Eliminar el símbolo '$' y convertir a float, manejando posibles valores nulos o errores
dfs['df_products']['price'] = dfs['df_products']['price'].str.replace('$', '', regex=False).astype(float)
dfs['df_products'].head()


# In[293]:


# Convertimos 'birth_day' a tipo datetime, como en powerbi
dfs['df_users']['birth_date'] = pd.to_datetime(dfs['df_users']['birth_date'])

# Función para calcular la edad
from datetime import date

def calculo_edad(birth_date):
    today = date.today()  # Fecha actual
    return today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day)) 
# Creamos la columna 'edad'
dfs['df_users']['edad'] = dfs['df_users']['birth_date'].apply(calculo_edad)

print(dfs['df_users']['edad'].head())

print(dfs['df_users'].head())


# In[294]:


#crear columna año y día de la semana, como power bi:
#creamos columna fecha y la convierto en formato datetime
dfs['df_transactions']['fecha'] = dfs['df_transactions']['timestamp'].dt.date

dfs['df_transactions']['fecha'] = pd.to_datetime(dfs['df_transactions']['fecha'])

dfs['df_transactions']['fecha'].info()


#columna year
dfs['df_transactions']['Year'] = dfs['df_transactions']['fecha'].dt.strftime('%Y')

dfs['df_transactions']['Year']

#columna día de la semana
dfs['df_transactions']['Day'] =  dfs['df_transactions']['fecha'].dt.strftime('%A')

dfs['df_transactions']['Day'] 


# In[295]:


dfs['df_companies']['phone'] = dfs['df_companies']['phone'].astype(str)
dfs['df_companies']


# In[296]:


dfs['df_companies']['country'] = dfs['df_companies']['country'].astype('str')
dfs['df_companies']['website'] = dfs['df_companies']['website'].astype('str')
dfs['df_companies']['email'] = dfs ['df_companies']['email'].astype('str')
dfs['df_companies']['company_name'] = dfs['df_companies']['company_name'].astype('str')
dfs['df_companies']['company_id'] = dfs['df_companies']['company_id'].str.replace('b-', '').astype('str')
dfs['df_transactions']['business_id'] = dfs['df_transactions']['business_id'].str.replace('b-', '')


# In[297]:


dfs['df_companies'].info()
dfs['df_actives_cards'].info()
dfs['df_credit_cards'].info()
dfs['df_productos_vendidos'].info() 
dfs['df_products'].info() 
dfs['df_transactions'].info() 
dfs['df_users'].info()


# In[298]:


dfs['df_transactions']['declined'] = dfs['df_transactions']['declined'].astype(int).astype(bool)


# In[299]:


dfs['df_transactions'].info()


# ### EXERCICI 1
# Una variable numérica:
# 

# In[300]:


dfs['df_transactions']['amount'].head(10).plot(kind='bar', title='Top 10 Amounts in Transaction', color='green')
plt.show()


# ### EXERCICI 2
# dos variables numericas

# In[301]:


precio = dfs['df_products']['price']
peso = dfs['df_products']['weight']

plt.scatter(x=precio, y=peso, color='blue')
plt.xlabel('Precio Producto')
plt.ylabel('Peso')
plt.title("Peso VS Precio")
plt.show()


# ### EXERCICI 3
# Una variable categòrica

# In[302]:


order = dfs['df_users']['country'].value_counts().index

plt.figure(figsize = (8,6))
ax = sns.countplot(data=dfs['df_users'], x="country", order=order)
ax.set_xlabel('')
ax.set_ylabel('Conteo')
ax.set_title('Cantidad de Usuarios por País ')

for p in ax.patches:
    ax.annotate(f'{int(p.get_height())}',
                (p.get_x() + p.get_width() / 2., p.get_height()), 
                ha='center', va='baseline', 
                fontsize=10, color='black', xytext=(0, 5), 
                textcoords='offset points')

plt.show()


# ### EXERCICI 4
# Una variable categòrica i una numèrica:

# In[303]:


#Ingresos por país:

#merge
transactions_companies = dfs['df_transactions'].merge(dfs['df_companies'], left_on='business_id', right_on='company_id')

print(transactions_companies[['business_id', 'company_id', 'company_name', 'country']].head())


# In[304]:


print(dfs['df_transactions']['business_id'].unique()[:5])
print(dfs['df_companies']['company_id'].unique()[:5])


# In[305]:


transactions_companies = dfs['df_transactions'].merge(dfs['df_companies'], left_on='business_id', right_on='company_id', 
                                                      how='left')

print(transactions_companies[['business_id', 'company_id', 'company_name', 'country']].head())


# In[306]:


transactions_companies = dfs['df_transactions'].merge(
    dfs['df_companies'][['company_id', 'country']], 
    left_on='business_id', 
    right_on='company_id',
    how='left'
)
transactions_companies


# In[307]:


tr_pais = transactions_companies[transactions_companies['declined'] == 0]
tr_pais = tr_pais.groupby('country')['amount'].sum().reset_index()
tr_pais = tr_pais.sort_values('amount', ascending=False)
print(tr_pais)


# In[308]:


print(transactions_companies[['id', 'amount', 'declined', 'country']].head(10))


# In[309]:


plt.figure(figsize=(14,7))
sns.barplot(data=tr_pais, x='country', y='amount', palette='viridis')
plt.title('Total de Transacciones Aceptadas por País', fontsize=18)
plt.xlabel('País', fontsize=16)
plt.ylabel('Total (€)')
plt.xticks(rotation=60)
plt.tight_layout()
plt.show()


# In[310]:


tr_pais = tr_pais.groupby('country')['amount'].mean().plot.bar()
#més senzill


# In[311]:


#Limpiamos columnas de IDs
dfs['df_transactions']['business_id'] = dfs['df_transactions']['business_id'].str.replace('b-', '').str.strip()
dfs['df_companies']['company_id'] = dfs['df_companies']['company_id'].str.strip()


# In[312]:


#Comprobamos la agrupación
tr_país = transactions_companies.groupby('country')['amount'].sum().reset_index()
print(tr_país.head())  # Muestra las primeras filas del DataFrame agrupado


# In[313]:


# Verificamos si hay valores NaN en la columna 'country'
print(tr_país['country'].isna().sum()) 


# In[314]:


#Eliminamos filas con valores nulos en la columna 'country'
tr_país = tr_país.dropna(subset=['country'])


# In[316]:


tr_pais = transactions_companies[transactions_companies['declined'] == 0]
tr_pais = tr_pais.groupby('country')['amount'].sum().reset_index()
tr_pais = tr_pais.sort_values('amount', ascending=False)

print(type(tr_pais)) 
print(tr_pais.head())  

plt.figure(figsize=(8, 6))
sns.barplot(data=tr_pais, x='country', y='amount')
plt.title('Total de Transacciones Aceptadas por País')
plt.xlabel('País')
plt.ylabel('Cantidad')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()


# In[317]:


print(tr_país.dtypes)

tr_país['amount'] = pd.to_numeric(tr_país['amount'], errors='coerce')

tr_país['country'] = tr_país['country'].astype(str)


# In[318]:


print(tr_país['amount'].isna().sum())
tr_país = tr_país.dropna(subset=['amount'])
#para comprobar valores duplicados


# In[319]:


# Eliminamos el dolar en 'price' y cambiamos a float
dfs['df_products']['price'] = dfs['df_products']['price'].replace('$','').astype(float)
dfs['df_products']


# ### EXERCICI 5
# Dues variables categòriques:

# In[320]:


transactions_users = dfs['df_transactions'].merge(dfs['df_users'][['id', 'country']], left_on='user_id', right_on='id', suffixes=('', '_user'))
trans_country = transactions_users.groupby('country').size().reset_index(name='total_transactions')

sns.barplot(data=trans_country, x='country', y='total_transactions')
plt.title('Total de Transacciones por País de Usuario')
plt.xlabel('País')
plt.ylabel('Total de Transacciones')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()


# ### EXERCICI 6
# Tres variables
# 

# In[321]:


#está mal este
#Scatter plot (Cuantas transacciones y gasto total) 
#no me sale bien, mirar bien el merge o las variables.

bubble_chart= dfs['df_transactions']
bubble_chart = pd.merge(bubble_chart[['id','user_id','amount']], dfs['df_users'][['id','country']], left_on= 'user_id', right_on= 'id')

bubble_chart = bubble_chart.drop('id_y', axis = 1)

bubble_chart = bubble_chart.rename(columns={'id_x':'id'})

bubble_chart_grouped = bubble_chart.groupby('id').agg(
    total_amount=('amount', 'sum'),
    total_trans= ('id', 'count'),
    country = ('country','first')
).reset_index()
bubble_chart_grouped = bubble_chart_grouped.dropna(subset=['country'])
sns.set_theme(style="darkgrid")

sns.scatterplot(
    data= bubble_chart_grouped,
    x="total_amount",
    y="total_trans",
    hue= "country")
plt.title('Gasto Total y Núm transacciones por Cliente y País')
plt.xlabel('Gasto Total (€)')
plt.ylabel('Número de transacciones')
plt.show()


# In[322]:


bubble_chart = dfs['df_transactions'][['id', 'user_id', 'amount']].copy()
bubble_chart = bubble_chart.merge(
    dfs['df_users'][['id', 'country']],
    left_on='user_id',
    right_on='id',
    suffixes=('_transaction', '_user')
)
# eliminamos el id duplicado
bubble_chart = bubble_chart.drop(columns='id_user')
bubble_chart = bubble_chart.rename(columns={'id_transaction': 'transaction_id'})

bubble_chart_grouped = bubble_chart.groupby('user_id').agg(
    total_amount=('amount', 'sum'),
    total_trans=('transaction_id', 'count'),
    country=('country', 'first')
).reset_index()

bubble_chart_grouped = bubble_chart_grouped.dropna(subset=['country'])

sns.set_theme(style="darkgrid")

sns.scatterplot(
    data=bubble_chart_grouped,
    x="total_amount",
    y="total_trans",
    hue="country"
)

plt.title('Gasto Total y Nº Transacciones por Cliente y País')
plt.xlabel('Gasto Total (€)')
plt.ylabel('Número de transacciones')
plt.tight_layout()
plt.show()


# In[330]:


bubble_chart = dfs['df_transactions'][['id', 'user_id', 'amount']].copy()

#país del usuario
bubble_chart = bubble_chart.merge(
    dfs['df_users'][['id', 'country']],
    left_on='user_id',
    right_on='id',
    suffixes=('_transaction', '_user')
)

#columna duplicada
bubble_chart = bubble_chart.drop(columns='id_user')
bubble_chart = bubble_chart.rename(columns={'id_transaction': 'transaction_id'})

#agrupamos
bubble_chart_grouped = bubble_chart.groupby('user_id').agg(
    total_amount=('amount', 'sum'),
    total_trans=('transaction_id', 'count'),
    country=('country', 'first')
).reset_index()

#los países sin usuario los eliminamos
bubble_chart_grouped = bubble_chart_grouped.dropna(subset=['country'])

bubble_size = bubble_chart_grouped['total_amount'] / bubble_chart_grouped['total_amount'].max() * 1000

plt.figure(figsize=(12, 8))
plt.scatter(
    bubble_chart_grouped['total_amount'],
    bubble_chart_grouped['total_trans'],
    s=bubble_size,
    alpha=0.6
)

plt.title('Gasto Total y Nº Transacciones por Cliente y País')
plt.xlabel('Gasto Total (€)')
plt.ylabel('Número de Transacciones')
plt.tight_layout()
plt.show()


# In[331]:


get_ipython().run_line_magic('config', 'Completer.use_jedi = False')


# ### EXERCICI 7
# Graficar un pairplot

# In[332]:


print(bubble_chart_grouped.isnull().sum())


# In[333]:


bubble_chart_grouped = bubble_chart_grouped.dropna(subset=['total_amount', 'total_trans'])


# In[343]:


bubble_chart_grouped = bubble_chart_grouped.dropna(subset=['total_amount', 'total_trans'])

plt.figure(figsize=(80, 40))
sns.pairplot(
    data=bubble_chart_grouped,
    vars=['total_amount', 'total_trans'],
    hue='country',
    palette='Set2',
    plot_kws={'alpha': 0.9}
)

plt.suptitle('Pairplot: Gasto Total y Número de Transacciones por País', y=1.02, fontsize=20)
plt.show()
#vemos el gasto total de cada usuario en comparación con el número de transacciones totales de cada usuario por país


# In[ ]:




