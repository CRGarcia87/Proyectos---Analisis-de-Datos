# 🏦 Bank Customer Churn Analysis: End-to-End Data Pipeline

## 📖 Resumen del Proyecto
Este proyecto es una solución analítica de extremo a extremo (End-to-End) diseñada para identificar, medir y mitigar la fuga de clientes (Customer Churn) en una institución financiera. 

A partir de un dataset transaccional de 10,000 registros, desarrollé un pipeline de datos que extrae la información, la limpia, procesa reglas de negocio en un motor relacional y culmina en un dashboard gerencial interactivo. El objetivo principal es proporcionar insights accionables al área Comercial para diseñar campañas de retención precisas y proteger el capital del banco.

## 🛠️ Stack Tecnológico
* **Python (pandas):** Extracción, Análisis Exploratorio de Datos (EDA) y limpieza de nulos/duplicados para generar un "Golden Record".
* **PostgreSQL:** Almacenamiento, estructuración y creación de Vistas (`VIEWS`) con lógica de negocio (Segmentación demográfica y financiera).
* **Power BI & DAX:** Conexión directa a la base de datos, modelado, cálculos de impacto financiero y visualización de datos (UI/UX corporativo).

## 🧠 Metodología y Desarrollo
1. **Data Engineering (Python & SQL):**
   * Se optimizó el uso de memoria del dataset convirtiendo variables de texto a categóricas.
   * Se eliminaron campos sensibles (ej. apellidos) cumpliendo con prácticas básicas de Data Governance.
   * Se diseñaron Vistas en PostgreSQL usando `CASE WHEN` para pre-procesar la segmentación de edades y niveles de saldo, aligerando la carga de procesamiento en la herramienta de BI.
2. **Business Intelligence (Power BI):**
   * Creación de medidas DAX dinámicas para calcular el *Churn Rate* y el *Impacto Económico*.
   * Implementación de la función nativa de "Depósitos" (Bins) para crear histogramas de riesgo exactos sin saturar el motor SQL.

## 📊 Insights Comerciales Clave
Tras analizar el modelo, se extrajeron las siguientes conclusiones de alto valor para el negocio:

* **Hemorragia Financiera:** La tasa de fuga actual del 20.37% representa una pérdida de capital de **$185.59 Millones**.
* **Zona Crítica de Riesgo (Edad):** El abandono de clientes no es un patrón general. Existe una zona de riesgo focalizada donde la probabilidad de fuga supera el 50%, concentrada específicamente en la cohorte de **45 a 55 años** (etapa de pre-jubilación).
* **Foco Operativo:** Aunque la tasa de abandono de los clientes "Senior" es proporcionalmente más alta, el mayor **volumen** de pérdida (la mayor cantidad de personas) recae en el grupo de "Adultos" (30-50 años).

**💡 Recomendación Estratégica:** Diseñar una campaña de retención agresiva ofreciendo productos de inversión de pre-jubilación y mejora de tasas, dirigida exclusivamente a clientes que están por cumplir 50 años, priorizando a aquellos que pertenecen al segmento de "Saldo VIP".