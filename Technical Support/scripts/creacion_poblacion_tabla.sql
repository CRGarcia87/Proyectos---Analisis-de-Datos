-- 1. Limpieza total
DROP TABLE IF EXISTS Fact_Tickets CASCADE;
DROP TABLE IF EXISTS Dim_Agente CASCADE;
DROP TABLE IF EXISTS Dim_Prioridad CASCADE;
DROP TABLE IF EXISTS Dim_SLA_Status CASCADE;
DROP TABLE IF EXISTS Dim_Estado CASCADE;
DROP TABLE IF EXISTS Dim_Origen CASCADE;
DROP TABLE IF EXISTS Dim_Tema CASCADE;
DROP TABLE IF EXISTS Dim_Grupo_Producto CASCADE;
DROP TABLE IF EXISTS Dim_Grupo_Agente CASCADE;
DROP TABLE IF EXISTS Dim_Encuesta CASCADE;

-- 2. Creación de TODAS las dimensiones estratégicas
CREATE TABLE Dim_Agente (id_agente SERIAL PRIMARY KEY, nombre_agente VARCHAR(150) UNIQUE NOT NULL);
CREATE TABLE Dim_Prioridad (id_prioridad SERIAL PRIMARY KEY, nivel_prioridad VARCHAR(50) UNIQUE NOT NULL);
CREATE TABLE Dim_SLA_Status (id_sla SERIAL PRIMARY KEY, estado_sla VARCHAR(100) UNIQUE NOT NULL);
CREATE TABLE Dim_Estado (id_estado SERIAL PRIMARY KEY, estado_ticket VARCHAR(100) UNIQUE NOT NULL);
CREATE TABLE Dim_Origen (id_origen SERIAL PRIMARY KEY, origen_ticket VARCHAR(100) UNIQUE NOT NULL);
CREATE TABLE Dim_Tema (id_tema SERIAL PRIMARY KEY, nombre_tema TEXT UNIQUE NOT NULL);
CREATE TABLE Dim_Grupo_Producto (id_producto SERIAL PRIMARY KEY, nombre_producto VARCHAR(150) UNIQUE NOT NULL);
CREATE TABLE Dim_Grupo_Agente (id_grupo_agente SERIAL PRIMARY KEY, nombre_grupo VARCHAR(150) UNIQUE NOT NULL);
CREATE TABLE Dim_Encuesta (id_encuesta SERIAL PRIMARY KEY, resultado_encuesta VARCHAR(100) UNIQUE NOT NULL);

-- 3. La nueva y superpoderosa Tabla de Hechos
CREATE TABLE Fact_Tickets (
    ticket_id VARCHAR(100) PRIMARY KEY,
    id_agente INT REFERENCES Dim_Agente(id_agente),
    id_prioridad INT REFERENCES Dim_Prioridad(id_prioridad),
    id_sla_resolucion INT REFERENCES Dim_SLA_Status(id_sla),
    id_estado INT REFERENCES Dim_Estado(id_estado),
    id_origen INT REFERENCES Dim_Origen(id_origen),
    id_tema INT REFERENCES Dim_Tema(id_tema),
    id_producto INT REFERENCES Dim_Grupo_Producto(id_producto),
    id_grupo_agente INT REFERENCES Dim_Grupo_Agente(id_grupo_agente),
    id_encuesta INT REFERENCES Dim_Encuesta(id_encuesta),
    
    -- Fechas clave
    fecha_creacion TIMESTAMP,
    fecha_primera_respuesta TIMESTAMP,
    fecha_resolucion TIMESTAMP,
    
    -- Métricas cuantitativas puras (para promediar en Power BI)
    tiempo_primera_respuesta_horas NUMERIC(10,2),
    tiempo_resolucion_horas NUMERIC(10,2),
    interacciones_agente INT
);

-- 4. Poblamiento de datos en las tablas de dimensiones
INSERT INTO Dim_Agente (nombre_agente) SELECT DISTINCT agent_name FROM staging_tickets WHERE agent_name IS NOT NULL;
INSERT INTO Dim_Prioridad (nivel_prioridad) SELECT DISTINCT priority FROM staging_tickets WHERE priority IS NOT NULL;
INSERT INTO Dim_SLA_Status (estado_sla) SELECT DISTINCT sla_for_resolution FROM staging_tickets WHERE sla_for_resolution IS NOT NULL;
INSERT INTO Dim_Estado (estado_ticket) SELECT DISTINCT status FROM staging_tickets WHERE status IS NOT NULL;
INSERT INTO Dim_Origen (origen_ticket) SELECT DISTINCT source FROM staging_tickets WHERE source IS NOT NULL;
INSERT INTO Dim_Tema (nombre_tema) SELECT DISTINCT topic FROM staging_tickets WHERE topic IS NOT NULL;
INSERT INTO Dim_Grupo_Producto (nombre_producto) SELECT DISTINCT product_group FROM staging_tickets WHERE product_group IS NOT NULL;
INSERT INTO Dim_Grupo_Agente (nombre_grupo) SELECT DISTINCT agent_group FROM staging_tickets WHERE agent_group IS NOT NULL;
INSERT INTO Dim_Encuesta (resultado_encuesta) SELECT DISTINCT survey_results FROM staging_tickets WHERE survey_results IS NOT NULL;

-- 5. Poblamiento de la Tabla de Hechos
INSERT INTO Fact_Tickets 
SELECT DISTINCT ON (st.ticket_id)
    st.ticket_id,
    da.id_agente, dp.id_prioridad, ds.id_sla, de.id_estado, dor.id_origen, 
    dt.id_tema, dprod.id_producto, dga.id_grupo_agente, denc.id_encuesta,
    
    NULLIF(st.created_time, '')::TIMESTAMP,
    NULLIF(st.first_response_time, '')::TIMESTAMP,
    NULLIF(st.resolution_time, '')::TIMESTAMP,
    
    -- Calcula horas hasta la primera respuesta
    CASE WHEN NULLIF(st.first_response_time, '') IS NOT NULL AND NULLIF(st.created_time, '') IS NOT NULL 
         THEN EXTRACT(EPOCH FROM (st.first_response_time::TIMESTAMP - st.created_time::TIMESTAMP)) / 3600.0 ELSE NULL END,
         
    -- Calcula horas hasta la resolución total
    CASE WHEN NULLIF(st.resolution_time, '') IS NOT NULL AND NULLIF(st.created_time, '') IS NOT NULL 
         THEN EXTRACT(EPOCH FROM (st.resolution_time::TIMESTAMP - st.created_time::TIMESTAMP)) / 3600.0 ELSE NULL END,
         
    -- Convierte el texto "1.0" a Decimal primero, y luego a Entero
    CAST(NULLIF(st.agent_interactions, '') AS NUMERIC)::INT

FROM staging_tickets st
LEFT JOIN Dim_Agente da ON st.agent_name = da.nombre_agente
LEFT JOIN Dim_Prioridad dp ON st.priority = dp.nivel_prioridad
LEFT JOIN Dim_SLA_Status ds ON st.sla_for_resolution = ds.estado_sla
LEFT JOIN Dim_Estado de ON st.status = de.estado_ticket
LEFT JOIN Dim_Origen dor ON st.source = dor.origen_ticket
LEFT JOIN Dim_Tema dt ON st.topic = dt.nombre_tema
LEFT JOIN Dim_Grupo_Producto dprod ON st.product_group = dprod.nombre_producto
LEFT JOIN Dim_Grupo_Agente dga ON st.agent_group = dga.nombre_grupo
LEFT JOIN Dim_Encuesta denc ON st.survey_results = denc.resultado_encuesta
ORDER BY st.ticket_id;