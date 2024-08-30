-- Numero di clienti nel database della banca 
SELECT COUNT(DISTINCT id_cliente) AS num_clienti

-- Visualizzazione di tutti i dettagli sui clienti
SELECT *
FROM banca.cliente;

-- Visualizzazione di tutti i dettagli sui conti bancari
SELECT *
FROM banca.conto;

-- Visualizzazione di tutti i dettagli sui tipi di conto
SELECT *
FROM banca.tipo_conto;

-- Visualizzazione di tutti i dettagli sui tipi di transazione
SELECT *
FROM banca.tipo_transazione;

-- Visualizzazione di tutti i dettagli delle transazioni
SELECT *
FROM banca.transazioni;

-- Indicatore ETÀ + tabella temporanea

-- Drop the temporary table if it exists
DROP TABLE IF EXISTS tabella_eta;

-- Create the temporary table
CREATE TABLE tabella_eta (
    id_cliente INT,
    data_nascita DATE,
    eta INT
);

INSERT INTO tabella_eta (id_cliente, data_nascita, eta)
SELECT
    id_cliente,
    data_nascita,
    YEAR(CURDATE()) - YEAR(data_nascita) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(data_nascita, '%m%d')) AS eta
FROM banca.cliente;

SELECT * FROM #tabella_eta;

-- Indicatore TRANSAZIONI IN USCITA

SELECT
    c.id_cliente,
    COUNT(t.id_tipo_trans) AS numero_transazioni_uscita
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'
GROUP BY c.id_cliente;

-- Indicatore TRANSASZIONI IN ENTRATA

SELECT
    c.id_cliente,
    COUNT(t.id_tipo_trans) AS numero_transazioni_entrata
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'
GROUP BY c.id_cliente;

-- Indicatore IMPORTO TRANSATO IN USCITA SU TUTTI I CONTI

SELECT
    c.id_cliente,
    SUM(t.importo) AS importo_transato_uscita
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'
GROUP BY c.id_cliente;

-- Indicatore IMPORTO TRANSATO IN ENTRATA SU TUTTI I CONTI

SELECT
    c.id_cliente,
    SUM(t.importo) AS importo_transato_entrata
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'
GROUP BY c.id_cliente;

-- Indicatore TOTALE CONTI POSSEDUTI

SELECT
    c.id_cliente,
    COUNT(co.id_conto) AS numero_totale_conti
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
GROUP BY c.id_cliente;

-- Indicatore CONTI PER TIPOLOGIA

SELECT
    c.id_cliente,
    tc.desc_tipo_conto,
    COUNT(co.id_conto) AS numero_conti_per_tipologia
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY c.id_cliente, tc.desc_tipo_conto;

-- Indicatore TRANSAZIONI IN USCITA PER TIPOLOGIA

SELECT
    c.id_cliente,
    tc.desc_tipo_conto,
    COUNT(t.id_tipo_trans) AS numero_transazioni_uscita_per_tipologia
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'
GROUP BY c.id_cliente, tc.desc_tipo_conto;

-- indicatore TRANSAZIONI IN ENTRATA PER TIPOLOGIA

SELECT
    c.id_cliente,
    tc.desc_tipo_conto,
    COUNT(t.id_tipo_trans) AS numero_transazioni_entrata_per_tipologia
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'
GROUP BY c.id_cliente, tc.desc_tipo_conto;

-- Indicatore IMPORTO TRANSATO IN USCITA PER TIPOLOGIA

SELECT
    c.id_cliente,
    tc.desc_tipo_conto,
    SUM(t.importo) AS importo_transato_uscita_per_tipologia
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'
GROUP BY c.id_cliente, tc.desc_tipo_conto;

-- Indicatore IMPORTO TRANSATO IN ENTRATA PER TIPOLOGIA

SELECT
    c.id_cliente,
    tc.desc_tipo_conto,
    SUM(t.importo) AS importo_transato_entrata_per_tipologia
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'
GROUP BY c.id_cliente, tc.desc_tipo_conto;

-- Tabella FEATURE per modello ML

DROP TABLE IF EXISTS tabella_feature;

CREATE TABLE tabella_feature (
    id_cliente INT,
    eta INT,
    numero_transazioni_uscita INT,
    numero_transazioni_entrata INT,
    importo_transato_uscita REAL,
    importo_transato_entrata REAL,
    numero_totale_conti INT,
    numero_conti_per_tipologia_Conto_Base INT,
    numero_conti_per_tipologia_Conto_Business INT,
    numero_conti_per_tipologia_Conto_Privati INT,
    numero_conti_per_tipologia_Conto_Famiglie INT,
    numero_transazioni_uscita_per_tipologia_Conto_Base INT,
    numero_transazioni_uscita_per_tipologia_Conto_Business INT,
    numero_transazioni_uscita_per_tipologia_Conto_Privati INT,
    numero_transazioni_uscita_per_tipologia_Conto_Famiglie INT,
    numero_transazioni_entrata_per_tipologia_Conto_Base INT,
    numero_transazioni_entrata_per_tipologia_Conto_Business INT,
    numero_transazioni_entrata_per_tipologia_Conto_Privati INT,
    numero_transazioni_entrata_per_tipologia_Conto_Famiglie INT,
    importo_transato_uscita_per_tipologia_Conto_Base REAL,
    importo_transato_uscita_per_tipologia_Conto_Business REAL,
    importo_transato_uscita_per_tipologia_Conto_Privati REAL,
    importo_transato_uscita_per_tipologia_Conto_Famiglie REAL,
    importo_transato_entrata_per_tipologia_Conto_Base REAL,
    importo_transato_entrata_per_tipologia_Conto_Business REAL,
    importo_transato_entrata_per_tipologia_Conto_Privati REAL,
    importo_transato_entrata_per_tipologia_Conto_Famiglie REAL
);

-- Inserimento dei dati aggregati nella tabella_feature
INSERT INTO tabella_feature
SELECT
    c.id_cliente,
    
    -- Calcolo dell'età del cliente
    TIMESTAMPDIFF(YEAR, c.data_nascita, CURDATE()) AS eta,
    
    -- Numero di transazioni in uscita su tutti i conti
    IFNULL(SUM(CASE WHEN tt.segno = '-' THEN 1 ELSE 0 END), 0) AS numero_transazioni_uscita,
    
    -- Numero di transazioni in entrata su tutti i conti
    IFNULL(SUM(CASE WHEN tt.segno = '+' THEN 1 ELSE 0 END), 0) AS numero_transazioni_entrata,
    
    -- Importo transato in uscita su tutti i conti
    IFNULL(SUM(CASE WHEN tt.segno = '-' THEN t.importo ELSE 0 END), 0) AS importo_transato_uscita,
    
    -- Importo transato in entrata su tutti i conti
    IFNULL(SUM(CASE WHEN tt.segno = '+' THEN t.importo ELSE 0 END), 0) AS importo_transato_entrata,
    
    -- Numero totale di conti posseduti
    COUNT(DISTINCT co.id_conto) AS numero_totale_conti,
    
    -- Numero di conti per tipologia
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' THEN 1 ELSE 0 END) AS numero_conti_per_tipologia_Conto_Base,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' THEN 1 ELSE 0 END) AS numero_conti_per_tipologia_Conto_Business,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' THEN 1 ELSE 0 END) AS numero_conti_per_tipologia_Conto_Privati,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' THEN 1 ELSE 0 END) AS numero_conti_per_tipologia_Conto_Famiglie,
    
    -- Numero di transazioni in uscita per tipologia
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_per_tipologia_Conto_Base,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_per_tipologia_Conto_Business,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_per_tipologia_Conto_Privati,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_per_tipologia_Conto_Famiglie,
    
    -- Numero di transazioni in entrata per tipologia
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_per_tipologia_Conto_Base,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_per_tipologia_Conto_Business,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_per_tipologia_Conto_Privati,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_per_tipologia_Conto_Famiglie,
    
    -- Importo transato in uscita per tipologia
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS importo_transato_uscita_per_tipologia_Conto_Base,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS importo_transato_uscita_per_tipologia_Conto_Business,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS importo_transato_uscita_per_tipologia_Conto_Privati,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '-' THEN t.importo ELSE 0 END) AS importo_transato_uscita_per_tipologia_Conto_Famiglie,
    
    -- Importo transato in entrata per tipologia
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Base' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS importo_transato_entrata_per_tipologia_Conto_Base,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Business' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS importo_transato_entrata_per_tipologia_Conto_Business,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Privati' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS importo_transato_entrata_per_tipologia_Conto_Privati,
    SUM(CASE WHEN tc.desc_tipo_conto = 'Conto Famiglie' AND tt.segno = '+' THEN t.importo ELSE 0 END) AS importo_transato_entrata_per_tipologia_Conto_Famiglie

FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione

GROUP BY c.id_cliente;


