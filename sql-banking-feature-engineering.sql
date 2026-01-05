/*
Lo scopo del presente progetto è creare, partendo da un database bancario, una tabella di feature per il training di modelli 
di machine learning contenente i dati dei clienti della banca e una serie di indicatori calcolati a partire dalle transazioni 
effettuate dai conti posseduti, riferita all'identificativo del cliente.

Al fine di agevolare la comprensione degli indicatori calcolati, riporto una legenda esplicativa dei titoli degl indicatori:

    INDICATORI DI BASE:
    id_cliente = identificativo univoco del cliente
    nome = nome del cliente
    cognome = cognome del cliente
    eta = età del cliente
    
    INDICATORI SULLE TRANSAZIONI: 
    numero_tot_transazioni_entrata = numero totale delle transazioni in entrata su tutti i conti
    numero_tot_transazioni_uscita = numero totale delle transazioni in uscita su tutti i conti
    importo_transazioni_entrata = importo totale (somma) delle transazioni in entrata su tutti i conti
    importo_transazioni_uscita = importo totale (somma) delle transazioni in uscita su tutti i conti
    
    INDICATORI SUI CONTI:
    numero_conti_posseduti = numero di conti posseduti da ciascun cliente
    numero_conti_tipo_0 = numero di conti di tipo "0" (= conto Base) posseduti da ciascun cliente
    numero_conti_tipo_1 = numero di conti di tipo "1" (= conto Business) posseduti da ciascun cliente
    numero_conti_tipo_2 = numero di conti di tipo "2" (= conto Privati) posseduti da ciascun cliente
    numero_conti_tipo_3 = numero di conti di tipo "3" (= conto Famiglie) posseduti da ciascun cliente
    
    INDICATORI SULLE TRANSAZIONI PER TIPOLOGIA DI CONTO:
    numero_transazioni_uscita_conto_tipo_0 = numero di transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "0" (= conto base)
    numero_transazioni_uscita_conto_tipo_1 = numero di transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "1" (= conto Business)
    numero_transazioni_uscita_conto_tipo_2 = numero di transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "2" (= conto Privati)
    numero_transazioni_uscita_conto_tipo_3 = numero di transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "3" (= conto Famiglie)
    numero_transazioni_entrata_conto_tipo_0 I= numero di transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "0" (= conto base)
    numero_transazioni_entrata_conto_tipo_1 = numero di transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "1" (= conto Business)
    numero_transazioni_entrata_conto_tipo_2 = numero di transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "2" (= conto Privati)
    numero_transazioni_entrata_conto_tipo_3 = numero di transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "3" (= conto Famiglie)
    importo_uscita_conto_tipo_0 = importo totale (somma) delle transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "0" (= conto base)
    importo_uscita_conto_tipo_1 = importo totale (somma) delle transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "1" (= conto Business)
    importo_uscita_conto_tipo_2 = importo totale (somma) delle transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "2" (= conto Privati)
    importo_uscita_conto_tipo_3 = importo totale (somma) delle transazioni in uscita effettuate da ciascun cliente sui propri conti di tipo "3" (= conto Famiglie)
    importo_entrata_conto_tipo_0 = importo totale (somma) delle transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "0" (= conto base)
    importo_entrata_conto_tipo_1 = importo totale (somma) delle transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "1" (= conto Business)
    importo_entrata_conto_tipo_2 = importo totale (somma) delle transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "2" (= conto Privati)
    importo_entrata_conto_tipo_3 = importo totale (somma) delle transazioni in entrata effettuate da ciascun cliente sui propri conti di tipo "3" (= conto Famiglie)
 */
 

-- Creo delle tabelle temporanee, suddivise per tipologia di indicatore, che poi andrò ad unire in una tabella finale denormalizzata



-- Tabella temporanea degli indicatori di base

CREATE TEMPORARY TABLE IF NOT EXISTS indicatori_di_base AS
SELECT id_cliente, nome, cognome, TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta -- calcolo età cliente
FROM cliente;


-- Tabella temporanea degli indicatori sulle transazioni

CREATE TEMPORARY TABLE IF NOT EXISTS indicatori_sulle_transazioni AS
SELECT 
    c.id_cliente,
    /* calcolo del numero totale di transazioni, in entrata e in uscita, per cliente*/
    SUM(CASE WHEN tt.segno = '+' THEN 1 ELSE 0 END) AS numero_tot_transazioni_entrata,
    SUM(CASE WHEN tt.segno = '-' THEN 1 ELSE 0 END) AS numero_tot_transazioni_uscita,
    /* calcolo dell'importo totale delle transazioni, in entrata e in uscita, per cliente*/
    ROUND(SUM(CASE WHEN tt.segno = '+' THEN t.importo ELSE 0 END), 2) AS importo_transazioni_entrata,
    ROUND(SUM(CASE WHEN tt.segno = '-' THEN t.importo ELSE 0 END), 2) AS importo_transazioni_uscita
FROM cliente c
LEFT JOIN conto co ON c.id_cliente = co.id_cliente
LEFT JOIN transazioni t ON co.id_conto = t.id_conto
LEFT JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
GROUP BY c.id_cliente;


-- Tabella temporanea degli indicatori sui conti

CREATE TEMPORARY TABLE IF NOT EXISTS indicatori_sui_conti AS
SELECT 
    c.id_cliente,
    /* calcolo del numero di conti posseduti da ciascun cliente, per tipologia di conto*/
    COUNT(co.id_conto) AS numero_conti_posseduti,
    SUM(CASE WHEN co.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS numero_conti_tipo_0,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS numero_conti_tipo_1,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS numero_conti_tipo_2,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS numero_conti_tipo_3
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
GROUP BY c.id_cliente;


-- Tabella temporanea degli indicatori sulle transazioni per tipologia di conto

CREATE TEMPORARY TABLE IF NOT EXISTS indicatori_sulle_transazioni_per_tipologia_di_conto AS
SELECT
    c.id_cliente,
    /* calcolo del numero di transazioni in uscita per tipologia di conto*/
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS numero_transazioni_uscita_conto_tipo_0,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS numero_transazioni_uscita_conto_tipo_1,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS numero_transazioni_uscita_conto_tipo_2,
    SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS numero_transazioni_uscita_conto_tipo_3,
    /* calcolo del numero di transazioni in entrata per tipologia di conto*/
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS numero_transazioni_entrata_conto_tipo_0,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS numero_transazioni_entrata_conto_tipo_1,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS numero_transazioni_entrata_conto_tipo_2,
    SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS numero_transazioni_entrata_conto_tipo_3,
    /* calcolo importo totale in uscita, per tipologia di conto, arrotondato alla seconda cifra decimale  */
    ROUND(SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 0 THEN t.importo ELSE 0 END), 2) AS importo_uscita_conto_tipo_0,
    ROUND(SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 1 THEN t.importo ELSE 0 END), 2) AS importo_uscita_conto_tipo_1,
    ROUND(SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 2 THEN t.importo ELSE 0 END), 2) AS importo_uscita_conto_tipo_2,
    ROUND(SUM(CASE WHEN tt.segno = '-' AND co.id_tipo_conto = 3 THEN t.importo ELSE 0 END), 2) AS importo_uscita_conto_tipo_3,
    /* calcolo importo totale in entrata, per tipologia di conto, arrotondato alla seconda cifra decimale */
    ROUND(SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 0 THEN t.importo ELSE 0 END), 2) AS importo_entrata_conto_tipo_0,
    ROUND(SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 1 THEN t.importo ELSE 0 END), 2) AS importo_entrata_conto_tipo_1,
    ROUND(SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 2 THEN t.importo ELSE 0 END), 2) AS importo_entrata_conto_tipo_2,
    ROUND(SUM(CASE WHEN tt.segno = '+' AND co.id_tipo_conto = 3 THEN t.importo ELSE 0 END), 2) AS importo_entrata_conto_tipo_3
FROM cliente c
LEFT JOIN conto co 
       ON co.id_cliente = c.id_cliente
LEFT JOIN transazioni t 
       ON t.id_conto = co.id_conto
LEFT JOIN tipo_transazione tt 
       ON tt.id_tipo_transazione = t.id_tipo_trans
GROUP BY c.id_cliente;


-- Creo una tabella denominata analisi che contiene tutti gli indicatori creati con le tabelle temporanee precedentemente realizzate

CREATE TABLE IF NOT EXISTS analisi AS
SELECT 
    c.id_cliente,
    ib.nome,
    ib.cognome,
    ib.eta,
    ist.numero_tot_transazioni_entrata,
    ist.numero_tot_transazioni_uscita,
    ist.importo_transazioni_entrata,
    ist.importo_transazioni_uscita,
    isc.numero_conti_posseduti,
    isc.numero_conti_tipo_0,
    isc.numero_conti_tipo_1,
    isc.numero_conti_tipo_2,
    isc.numero_conti_tipo_3,
    istc.numero_transazioni_uscita_conto_tipo_0,
    istc.numero_transazioni_uscita_conto_tipo_1,
    istc.numero_transazioni_uscita_conto_tipo_2,
    istc.numero_transazioni_uscita_conto_tipo_3,
    istc.numero_transazioni_entrata_conto_tipo_0,
    istc.numero_transazioni_entrata_conto_tipo_1,
    istc.numero_transazioni_entrata_conto_tipo_2,
    istc.numero_transazioni_entrata_conto_tipo_3,
    istc.importo_uscita_conto_tipo_0,
    istc.importo_uscita_conto_tipo_1,
    istc.importo_uscita_conto_tipo_2,
    istc.importo_uscita_conto_tipo_3,
    istc.importo_entrata_conto_tipo_0,
    istc.importo_entrata_conto_tipo_1,
    istc.importo_entrata_conto_tipo_2,
    istc.importo_entrata_conto_tipo_3
FROM cliente c
LEFT JOIN indicatori_di_base ib
       ON c.id_cliente = ib.id_cliente
LEFT JOIN indicatori_sulle_transazioni ist
       ON c.id_cliente = ist.id_cliente
LEFT JOIN indicatori_sui_conti isc
       ON c.id_cliente = isc.id_cliente
LEFT JOIN indicatori_sulle_transazioni_per_tipologia_di_conto istc
       ON c.id_cliente = istc.id_cliente;


