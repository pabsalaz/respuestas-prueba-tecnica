import pandas as pd

def func_mapeo_de_variables(df: pd.DataFrame) -> pd.DataFrame:
    """
    Genera una tabla que muestra, para cada variable en un DataFrame,
    su número de nulos, tipo, valores únicos, porcentaje de nulos y valores atípicos.
    """
    variables = df.columns.tolist()
    nulos = []
    tipo_variable = []
    valores_unicos = []
    unicos = []
    outliers = []

    for variable in variables:
        serie = df[variable]
        nulos.append(serie.isnull().sum())
        tipo_variable.append(serie.dtype)
        valores_unicos.append(serie.nunique(dropna=True))
        unicos.append(serie.dropna().unique().tolist())

        if pd.api.types.is_numeric_dtype(serie):
            Q1 = serie.quantile(0.25)
            Q3 = serie.quantile(0.75)
            IQR = Q3 - Q1
            limite_inferior = Q1 - 1.5 * IQR
            limite_superior = Q3 + 1.5 * IQR
            valores_atipicos = serie[(serie < limite_inferior) | (serie > limite_superior)].dropna().unique().tolist()
            outliers.append(valores_atipicos)
        else:
            outliers.append([])

    tabla = pd.DataFrame({
        "Variable": variables,
        "Nulos": nulos,
        "Tipo Variable": tipo_variable,
        "Valores Únicos": valores_unicos,
        "Únicos": unicos,
        "Valores Atípicos": outliers
    })

    tabla["Porcentaje Nulos"] = (tabla["Nulos"] / len(df)) * 100
    tabla.sort_values("Porcentaje Nulos", ascending=False, inplace=True)
    tabla.reset_index(drop=True, inplace=True)

    return tabla