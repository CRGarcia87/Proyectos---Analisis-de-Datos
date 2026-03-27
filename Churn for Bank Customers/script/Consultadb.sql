-- Eliminamos la tabla si ya existe para evitar errores en pruebas
DROP TABLE IF EXISTS customer_churn;

-- Creamos la tabla con los tipos de datos optimizados
CREATE TABLE customer_churn (
    credit_score INTEGER,
    geography VARCHAR(50),
    gender VARCHAR(20),
    age INTEGER,
    tenure INTEGER,
    balance NUMERIC(15, 2),
    num_of_products INTEGER,
    has_cr_card INTEGER,       -- 1 = Sí, 0 = No
    is_active_member INTEGER,  -- 1 = Sí, 0 = No
    estimated_salary NUMERIC(15, 2),
    exited INTEGER             -- 1 = Se va, 0 = Se queda
);


CREATE OR REPLACE VIEW vw_segmentacion_clientes AS
SELECT 
    credit_score,
    geography,
    gender,
    age,
    -- Creamos un rango de edades
    CASE 
        WHEN age < 30 THEN 'Joven'
        WHEN age BETWEEN 30 AND 50 THEN 'Adulto'
        ELSE 'Senior'
    END AS grupo_edad,
    tenure,
    balance,
    -- Creamos un segmento financiero
    CASE 
        WHEN balance = 0 THEN 'Sin Saldo'
        WHEN balance BETWEEN 1 AND 100000 THEN 'Saldo Medio'
        ELSE 'Saldo alto'
    END AS segmento_financiero,
    num_of_products,
    has_cr_card,
    is_active_member,
    estimated_salary,
    exited
FROM customer_churn;
