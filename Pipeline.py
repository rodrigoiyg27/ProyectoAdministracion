import requests
import pandas as pd
import psycopg2
from sqlalchemy import create_engine

# Configuración de la base de datos
DB_NAME = "COVID"
DB_USER = "covid_read"
DB_PASSWORD = "covid19"
DB_HOST = "localhost"
DB_PORT = "5432"

# Conectar a PostgreSQL
engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

def actualizar_datos_covid():
    url = "https://opendata.ecdc.europa.eu/covid19/nationalcasedeath/json/"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        print("Ejemplo de estructura del JSON:", data[0])  # Verifica la estructura del JSON

        # Convertir a DataFrame
        df = pd.DataFrame(data)

        # Verificar que las columnas correctas existan
        if {"year_week", "country", "indicator", "population"}.issubset(df.columns):
            # Filtrar solo los datos de casos y muertes
            df = df[df["indicator"].isin(["cases", "deaths"])]

            # Cargar datos actuales desde PostgreSQL
            existing_data = pd.read_sql("SELECT year_week, country, indicator FROM covid_data", engine)

            # Filtrar solo los nuevos registros
            new_records = df.merge(existing_data, on=["year_week", "country", "indicator"], how="left", indicator=True)
            new_records = new_records[new_records["_merge"] == "left_only"].drop(columns=["_merge"])

            if not new_records.empty:
                new_records.to_sql("covid_data", engine, if_exists="append", index=False)
                print(f"✅ {len(new_records)} nuevos registros agregados.")
            else:
                print("🔄 No hay nuevos registros para agregar.")
        else:
            print("⚠️ No se encontraron las columnas esperadas. Revisa la estructura del JSON.")

    else:
        print(f"❌ Error al descargar los datos: {response.status_code}")

# Ejecutar la función
actualizar_datos_covid()
