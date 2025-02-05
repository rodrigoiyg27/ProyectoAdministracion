import requests
import pandas as pd
import psycopg2
from sqlalchemy import create_engine

# pip install psycopg2 requests pandas sqlalchemy

# Configuración de la base de datos
DB_NAME = "COVID"
DB_USER = "covid_read"
DB_PASSWORD = "covid19"
DB_HOST = "localhost"
DB_PORT = "5432"

# Conectar a PostgreSQL
engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

def cargar_datos_covid():
    url = "https://opendata.ecdc.europa.eu/covid19/nationalcasedeath/json/"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        df = pd.DataFrame(data)

        # Guardar en PostgreSQL
        df.to_sql("covid_data", engine, if_exists="replace", index=False)
        print("Datos de COVID-19 cargados correctamente.")
    else:
        print("Error al obtener los datos de COVID-19")

def cargar_datos_paises():
    df = pd.read_csv("countries of the world.csv", delimiter=",")
    
    # Guardar en PostgreSQL
    df.to_sql("paises", engine, if_exists="replace", index=False)
    print("Datos de países cargados correctamente.")

cargar_datos_covid()
cargar_datos_paises()
