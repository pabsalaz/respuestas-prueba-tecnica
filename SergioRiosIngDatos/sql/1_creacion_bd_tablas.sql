-- Creacion BD
CREATE DATABASE informacion_cartera;

-- CREACIÓN DE TABLAS:

-- Crear la tabla de segmentos
CREATE TABLE segmento (
    cod_segmento INT PRIMARY KEY,
    segmento VARCHAR(50)
);

-- Crear la tabla de información de clientes
CREATE TABLE info_clientes (
    num_documento BIGINT PRIMARY KEY,
    nombre VARCHAR(50),
    primer_apellido VARCHAR(50),
    segundo_apellido VARCHAR(50),
    cod_segmento INT,
    cod_subsegmento INT,
    calificacion_riesgo VARCHAR(20),
    municipio_ubicacion VARCHAR(100),
    numero_celular VARCHAR(20),
    FOREIGN KEY (cod_segmento) REFERENCES segmento(cod_segmento)
);

-- Crear la tabla de productos
CREATE TABLE productos (
    id_nombre_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100)
);

-- Crear la tabla de periodicidad
CREATE TABLE periodicidad (
    cod_periodicidad INT PRIMARY KEY,
    periodicidad VARCHAR(20)
);

-- Crear la tabla de tasas
CREATE TABLE tasas (
    id_tasa INT IDENTITY(1,1) PRIMARY KEY,
    calificacion_riesgo VARCHAR(20),
    cod_segmento INT,
    cod_subsegmento INT,
    id_nombre_producto INT,
    valor_tasa DECIMAL(18,7),
    FOREIGN KEY (cod_segmento) REFERENCES segmento(cod_segmento),
    FOREIGN KEY (id_nombre_producto) REFERENCES productos(id_nombre_producto)
);

-- Crear la tabla de obligaciones de clientes
CREATE TABLE obligaciones_clientes (
    id_obligacion INT IDENTITY(1,1) PRIMARY KEY,
    radicado BIGINT,
    num_documento BIGINT,
    id_producto VARCHAR(60),
    id_nombre_producto INT,
    tipo_id_producto VARCHAR(30),
    valor_inicial DECIMAL(10,2),
    fecha_desembolso DATE,
    plazo INT,
    cod_periodicidad INT,
    saldo_deuda DECIMAL(10,2),
    modalidad VARCHAR(50),
    tipo_plazo VARCHAR(50),
    FOREIGN KEY (num_documento) REFERENCES info_clientes(num_documento),
    FOREIGN KEY (id_nombre_producto) REFERENCES productos(id_nombre_producto),
    FOREIGN KEY (cod_periodicidad) REFERENCES periodicidad(cod_periodicidad)
);