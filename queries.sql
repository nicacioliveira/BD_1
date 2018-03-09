/*Grupo 6: Antunes Dantas da Silva, Nicácio Oliveira de Sousa, Ivyna Rayany Santino, José Glauber Braz, Thalyta Fabrine e Valter Vinicius de Lucena.*/

/*Grupo 6*/
/*01. Liste o nome dos rios, ordenados pelo indicativo e pelo nome de forma decrescente.*/
/*OK*/
SELECT nome, indicativo FROM rio ORDER BY indicativo DESC, nome DESC;

/*02. Crie uma visão que liste o nome dos açudes e seus os valores de oxigênio para todos os açudes do Rio Grande do Norte.*/
/*OK*/
CREATE OR REPLACE VIEW oxi_acudes_rn
AS
SELECT DISTINCT A.nome as NomeAcude, E.oxigenio
        FROM acude A, estacao_de_qualidade E, posto_pluviometrico P, rio R
        WHERE E.idAcude = A.idAcude and E.idRio = A.idRio and P.idBacia = R.idBacia and R.idRio = A.idRio and P.estado = 'Rio Grande do Norte';

/*03. Faça um trigger que, ao tentar inserir uma medição de qualidade de açude com uma data posterior ao dia atual, seja feita a inserção usando a data atual.*/
/*OK*/
CREATE OR REPLACE TRIGGER data_medcotadiaria_limit
BEFORE INSERT ON medicao_cota_diaria
FOR EACH ROW
DECLARE
BEGIN
   IF (:NEW.data > sysdate)
   THEN
       SELECT sysdate INTO :NEW.data FROM DUAL;
   END IF;
END data_medcotadiaria_limit;

/

INSERT INTO medicao_cota_diaria(COTAATUAL, DATA, IDACUDE, MATRICULA)
VALUES (0.8045, TO_DATE('2018/03/10 06:06:06', 'yyyy/mm/dd hh24:mi:ss'), (SELECT idacude FROM ACUDE WHERE nome='Epitácio Pessoa'), (SELECT matricula FROM usuario WHERE nome='Antunes' ));

/*04. Liste o nome dos 5 usuários que cadastraram mais medições, seja ela pluviométrica ou de cota diária.*/
/*OK*/
SELECT nome FROM
 (SELECT nome, matricula FROM
   (SELECT u.matricula, u.nome FROM usuario u                                              
     LEFT OUTER JOIN medicao_cota_diaria cota
     ON (cota.matricula = u.matricula)
     LEFT OUTER JOIN medicao_pluviometrica p on(p.matricula = u.matricula))
GROUP BY matricula, nome ORDER BY COUNT(1) DESC) WHERE ROWNUM <= 5;

/*05. Liste os nomes dos postos pluviométricos e o nome da bacia pertencente, agrupados pela bacia.*/
/*OK*/
SELECT p.nome as Posto_Pluviométrico, b.nome as Bacia
FROM posto_pluviometrico p, bacia b
WHERE p.idbacia = b.idbacia
GROUP BY p.nome, b.nome
ORDER BY b.nome;

/*06. Liste os valores dos volumes para cada Cota Área Volume do açude de Bodocongó, ordenados de forma crescente.*/
/*OK*/
SELECT cota.volume
FROM cota_area_volume cota, acude a
WHERE cota.idAcude = a.idAcude AND a.nome = 'Bodocongó'
ORDER BY cota.volume;

/*07. Liste os nomes das estações de qualidade e o nome do rio em que é feita a medição, agrupado por nome do rio.*/
/*OK*/
SELECT E.nome as estacao, R.nome as rio
FROM estacao_de_qualidade E, rio R
WHERE E.idRio = R.idRio
GROUP BY R.nome, E.nome
ORDER BY R.nome;

/*08. Liste a quantidade de medições pluviométricas feitas por posto pluviométrico.*/
/*OK*/
SELECT nome as Posto_luviometrico, COUNT(*) as QTD_Medicoes FROM posto_pluviometrico p
INNER JOIN medicao_pluviometrica m ON p.idpostopluviometrico=m.idpostopluviometrico
GROUP BY nome;

/*09. Qual foi o valor total de chuvas para cada açude no mês de Janeiro/2018?*/
/*OK*/
SELECT (VALOR_CHUVA_DIA_1 + VALOR_CHUVA_DIA_2 + VALOR_CHUVA_DIA_3 + VALOR_CHUVA_DIA_4 + VALOR_CHUVA_DIA_5 +
        VALOR_CHUVA_DIA_6 + VALOR_CHUVA_DIA_7 + VALOR_CHUVA_DIA_8 + VALOR_CHUVA_DIA_9 + VALOR_CHUVA_DIA_10 +
        VALOR_CHUVA_DIA_11 + VALOR_CHUVA_DIA_12 + VALOR_CHUVA_DIA_13 + VALOR_CHUVA_DIA_14 + VALOR_CHUVA_DIA_15 +
        VALOR_CHUVA_DIA_16 + VALOR_CHUVA_DIA_17 + VALOR_CHUVA_DIA_18 + VALOR_CHUVA_DIA_19 + VALOR_CHUVA_DIA_20 +
        VALOR_CHUVA_DIA_21 + VALOR_CHUVA_DIA_22 + VALOR_CHUVA_DIA_23 + VALOR_CHUVA_DIA_24 + VALOR_CHUVA_DIA_25 +
        VALOR_CHUVA_DIA_26 + VALOR_CHUVA_DIA_27 + VALOR_CHUVA_DIA_28 + VALOR_CHUVA_DIA_29 + VALOR_CHUVA_DIA_30 +
        VALOR_CHUVA_DIA_31) AS total_chuvas, mp.DATA AS data_medicao, a.nome as acude
FROM ACUDE a, POSTO_PLUVIOMETRICO pp, RIO r, MEDICAO_PLUVIOMETRICA mp
WHERE mp.idpostopluviometrico = pp.idpostopluviometrico and pp.idbacia = r.idbacia and r.idrio = a.idrio and (EXTRACT(MONTH FROM DATA)) = 01;

/*10. Liste os valores de oxigênio medidos para o açude de Bodocongó entre os dias 15/12/2017 e 17/01/2018./*
/*OK*/
SELECT estacao.oxigenio
FROM estacao_de_qualidade estacao, acude a
WHERE estacao.idAcude = a.idAcude AND a.nome = 'Bodocongó' AND estacao.data BETWEEN TO_DATE('2017/12/15', 'YYYY/MM/DD') AND  TO_DATE('2018/01/17', 'YYYY/MM/DD');

/*11. Qual o nome do usuário realizou menos medições de cotas diárias, e quantas foram?*/
/*OK*/
SELECT nome, (SELECT *
               FROM (
               SELECT MIN(COUNT(matricula))
               FROM medicao_cota_diaria
               GROUP BY matricula)) as frequencia
               FROM Usuario u
               WHERE u.matricula = (SELECT matricula
                                    FROM (
                                    SELECT matricula,COUNT(matricula)
                                    FROM medicao_cota_diaria
                                    GROUP BY matricula ORDER BY COUNT(matricula))
WHERE rownum = 1);

/*12. Qual o pH médio medido no ano de 2017 pro rio Beberibe?*/
/*OK*/
SELECT CAST(avg(eq.ph) AS NUMBER(6,2)) AS PH_BEBERIBE
FROM estacao_de_qualidade eq
WHERE eq.nome = 'Beberibe' AND TO_CHAR(data, 'YYYY')='2017';


/*13. Crie uma visão que liste os valores de chuva diários para a bacia do Alto Paraíba e o nome da bacia.*/
/*OK*/
CREATE OR REPLACE VIEW VALORES_CHUVA_ALTO_PARAIBA
AS SELECT b.nome as Bacia, VALOR_CHUVA_DIA_1, VALOR_CHUVA_DIA_2, VALOR_CHUVA_DIA_3, VALOR_CHUVA_DIA_4, VALOR_CHUVA_DIA_5,
        VALOR_CHUVA_DIA_6,VALOR_CHUVA_DIA_7, VALOR_CHUVA_DIA_8, VALOR_CHUVA_DIA_9, VALOR_CHUVA_DIA_10, VALOR_CHUVA_DIA_11,
        VALOR_CHUVA_DIA_12, VALOR_CHUVA_DIA_13, VALOR_CHUVA_DIA_14, VALOR_CHUVA_DIA_15, VALOR_CHUVA_DIA_16, VALOR_CHUVA_DIA_17,
      VALOR_CHUVA_DIA_18, VALOR_CHUVA_DIA_19, VALOR_CHUVA_DIA_20, VALOR_CHUVA_DIA_21, VALOR_CHUVA_DIA_22, VALOR_CHUVA_DIA_23,
        VALOR_CHUVA_DIA_24, VALOR_CHUVA_DIA_25, VALOR_CHUVA_DIA_26, VALOR_CHUVA_DIA_27, VALOR_CHUVA_DIA_28, VALOR_CHUVA_DIA_29,
        VALOR_CHUVA_DIA_30, VALOR_CHUVA_DIA_31
FROM BACIA b, MEDICAO_PLUVIOMETRICA mp, POSTO_PLUVIOMETRICO pp
WHERE mp.idpostopluviometrico = pp.idpostopluviometrico and pp.idbacia = b.idbacia and b.nome = 'Alto Paraíba';

/*14. Qual o açude com a menor área? */
/*OK*/
SELECT nome, area
FROM acude
WHERE area = (SELECT MIN(area) FROM acude);

/*15. Faça um trigger que não permita a inserção de um açude com volume máximo menor que 100.*/
/*OK*/
CREATE OR REPLACE TRIGGER trVolumeMax
BEFORE INSERT OR UPDATE 
ON acude
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
BEGIN
IF :NEW.volumeMaximo < 100 THEN
raise_application_error(-20001,'Valor invalido.');
END IF;
END trVolumeMax;

/

INSERT INTO ACUDE (NOME, VOLUMEMAXIMO, COMPRIMENTO, AREA, IDRIO) VALUES ('Laguinho UFCG', 99, 250.0, 481.5, (SELECT idrio FROM RIO WHERE nome='Paraíba'));

