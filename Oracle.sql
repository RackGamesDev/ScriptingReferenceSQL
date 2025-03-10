ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
-- CREATE DATABASE MBASE --Crear base de datos (ejecutar las consultas en dicha base)

--OPERACIONES CON TABLAS

--Borrar tabla, si no existe no da error, de normal seria DROP TABLE X
DROP TABLE USUARIO CASCADE CONSTRAINTS;
DROP TABLE TELEFONO CASCADE CONSTRAINTS;
DROP TABLE USUARIO_TELEFONO CASCADE CONSTRAINTS;
DROP TABLE CASA CASCADE CONSTRAINTS;
DROP TABLE VEHICULO CASCADE CONSTRAINTS;

--Crear tabla con esas propiedades
CREATE TABLE USUARIO(uuid VARCHAR(63), nombre VARCHAR(127) NOT NULL, apellido VARCHAR(255), fecha DATE DEFAULT TO_DATE('10/03/2020', 'DD/MM/YYYY'), numero NUMBER(5, 2), calificacion NUMBER(5, 2) DEFAULT '1');
CREATE TABLE TELEFONO(id NUMBER, prefijo VARCHAR(5), numero VARCHAR(9), fecha DATE, activo NUMBER(1) DEFAULT 0 CHECK (activo IN (0, 1)));
CREATE TABLE USUARIO_TELEFONO(uuid_USUARIO VARCHAR(63), id_TELEFONO NUMBER); --Esta tabla sale de una relacion n:m
CREATE TABLE CASA(id NUMBER(8), uuid_USUARIO VARCHAR(63)); --Esta tabla tendra una clave ajena a la pk de otra tabla
--Para hacer atributos autoincrementales hay que ver como se hace en cada gestor de base de datos ya que no hay un estandar

--Agregar la restriccion de clave primaria a esa tabla (puede estar compuesta de varias propiedades)
--Tipos de constraint: UNIQUE uk_, PRIMARY KEY pk_, FOREIGN KEY fk_, CHECK ck_
ALTER TABLE USUARIO ADD CONSTRAINT pk_USUARIO PRIMARY KEY (uuid);
ALTER TABLE TELEFONO ADD CONSTRAINT pk_TELEFONO PRIMARY KEY (id);
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT pk_USUARIO_TELEFONO PRIMARY KEY (uuid_USUARIO, id_TELEFONO);
CREATE TABLE VEHICULO(id NUMBER(8), nombre VARCHAR(9), uuid_USUARIO VARCHAR(63), CONSTRAINT pk_VEHICULO PRIMARY KEY (id), CONSTRAINT fk_VEHICULO_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid)); --Se pueden hacer las restricciones directamente en la tabla, pero no se recomienda


--Agregar la restriccion de clave unica a esa tabla a una propiedad (puede estar compuesta de varias propiedades)
ALTER TABLE USUARIO ADD CONSTRAINT uk_USUARIO_numero UNIQUE (numero);

--Agregar la restriccion de clave ajena a esa tabla con una clave primaria de otra (puede estar compuesta de varias propiedades)
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT fk_USUARIO_TELEFONO_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid);
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT fk_USUARIO_TELEFONO_id_TELEFONO FOREIGN KEY (id_TELEFONO) REFERENCES TELEFONO(id);
ALTER TABLE CASA ADD CONSTRAINT fk_CASA_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid);

--Manejar otro tipo de restricciones sobre ciertas propiedades
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_calificacion CHECK ((calificacion<=100) AND (calificacion > 0)); --Todas estas condiciones tambien pueden ser usadas en consultas con registros
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_apellido CHECK ((apellido) IN ('una opcion', 'otra opcion'));
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_numero CHECK ((numero) BETWEEN 1 AND 100);

ALTER TABLE USUARIO DISABLE CONSTRAINT ck_USUARIO_calificacion;
ALTER TABLE USUARIO ENABLE CONSTRAINT ck_USUARIO_calificacion;
ALTER TABLE USUARIO DROP CONSTRAINT ck_USUARIO_calificacion;

--Agnadir o eliminar propiedades en tablas
ALTER TABLE USUARIO ADD correo VARCHAR(255);
ALTER TABLE USUARIO DROP COLUMN correo;


COMMIT; --Guarda los resultados de haber modificado una base de datos
ROLLBACK; --Devuelve la base de datos al estado del ultimo commit

INSERT INTO TELEFONO (id , numero, fecha) VALUES (0, '123456789', TO_DATE('21/03/2022', 'DD/MM/YYYY')); --Aagnadir un entry a la tabla, TO_DATE se puede reemplazar por SYSDATE para poner la fecha actual
INSERT INTO TELEFONO VALUES (1, '+52', NULL, TO_DATE('21/03/2022', 'DD/MM/YYYY'), 1); --Si se agnaden todos los campos no hace falta ponerlos
UPDATE TELEFONO SET numero = '398458643', prefijo = '+20' WHERE id = 1 AND (prefijo = '+33' OR prefijo = '+34'); --Actualizar el contenido de una tabla donde se cumpla cierta condicion
DELETE FROM TELEFONO WHERE id = 1; --Elminar un entry especifico segun una condicion (IMPORTANTE PONER EL FROM PARA NO BORRAR LA TABLA)
TRUNCATE TABLE TELEFONO; --Borra todos los entrys de una tabla pero no la tabla
INSERT ALL INTO  USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('E001', 'Juan', 'una opcion', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 1.50, 75.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('E002', 'María', 'otra opcion', TO_DATE('2024-01-02', 'YYYY-MM-DD'), 2.25, 80.0)
   SELECT * FROM USUARIO; --Agregar en OracleDB varios registros con un solo comando

--Orden de ejecucion de los calculos: FROM > WHERE > GROUP BY > HAVING  SELECT > ORDER BY
SELECT * FROM TELEFONO; --Devuelve todos los entrys de la tabla con todas las columnas
SELECT * FROM TELEFONO WHERE prefijo = '+52'; --Devuelve todos los entrys de la tabla en base a ciertas condiciones (similar a update, AND y OR tambien funcionarian) (< > >= <= != <>)
SELECT numero * 10 FROM USUARIO WHERE numero = 2 * (numero - 1); --Se pueden hacer operaciones en cualquier parte del select con los datos (+ - / * POWER(a, b) MOD(a, b) SQRT(x)...)
SELECT nombre || ' asdf' FROM USUARIO; --Se usa || para concatenar varchars
SELECT * FROM TELEFONO WHERE prefijo IN ('+52', '+34'); --Devuelve los entrys donde x valor sea igual a alguno de esos valores 
SELECT * FROM TELEFONO WHERE numero BETWEEN 0 AND 5; --Devuelve los entrys donde ese valor numerico este entre esos dos numeros
SELECT * FROM TELEFONO WHERE prefijo IS NOT NULL; --Filtra para ver solo los que no son nulos, tambien se puede hacer solo con los nulos
SELECT * FROM TELEFONO WHERE id LIKE '5_5%'; --Expresiones regulares, % es cualquier cantidad de caracteres y _ es cualquier caracter
SELECT * FROM USUARIO WHERE UPPER(nombre) = 'a'; --Lower convierte cualquier cosa en mayusculas, tambien esta upper. Tambien se podria hacer = LOWER('ASDF')
SELECT nombre, apellido AS ape FROM USUARIO; --Muestra solo las columnas especificadas, tambien se le pueden cambiar el nombre a las columnas
SELECT * FROM USUARIO ORDER BY nombre DESC, apellido; --Ordenar de menor a mayor o alfabeticamente los registros, si ese valor es igual se evaluara el siguiente, DESC hace que sea descendente en este caso o ASC ascendente, se puede reemplazar el nombre de la propiedad por su numero
SELECT * FROM USUARIO ORDER BY nombre FETCH FIRST 3 ROWS ONLY; --Muestra los x primeros registros solo, depende de la version esto se podria reemplazar por LIMIT x , o por SELECT TOP x * FROM...
SELECT DISTINCT nombre FROM USUARIO; --Evita mostar resultadtos repetidos en esa propiedad
SELECT ROWNUM FROM USUARIO; --Devuelve el numero de registro (autoincremental)
SELECT * FROM USUARIO WHERE EXTRACT(MONTH FROM fecha)=1; --Filtrar campos de una fecha

SELECT COUNT(*) AS cantidad FROM USUARIO; --Devuelve la cantidad de registros
SELECT COUNT(CASE WHEN nombre = 'hola' THEN 1 ELSE NULL END) FROM USUARIO; --Contar solo si se cumple la condicion
SELECT COUNT(*) AS "la cantidad" FROM USUARIO; --Para poner mas de una palabra en el nombre
SELECT COUNT(DISTINCT nombre) AS "nombres distintos" FROM USUARIO; --Usando el DISTINCT en una funcion
SELECT MAX(numero) FROM USUARIO; --Devuelve el que tenga el mayor valor, para el menor esta MIN
SELECT AVG(numero) FROM USUARIO; --Devuelve la media de ese valor en todos los registros seleccionados
SELECT SUM(numero) FROM USUARIO; --Devuelve el total de sumar todos esos valores
SELECT REGEXP_SUBSTR(numero, '^\d{3}') FROM TELEFONO; --Recorta el varchar para crear uno nuevo con solo los caracteres que cumplan ese regex, en este caso coge solo los 3 primeros numeros
SELECT * FROM TELEFONO WHERE REGEXP_SUBSTR(numero, '^\d{3}') = '123'; --Tambien se puede usar para filtrar
SELECT * FROM TELEFONO WHERE REGEXP_SUBSTR(numero, '\d{3}', 3, 2, 'i') = '789'; --El tercer parametro representa a partir de que caracter se va a evaluar, el cuarto que ocurrencia cogera (en este caso la segunda), el quinto dependiendo de la letra evalua de maneras distintas (i=case insensitive)
SELECT numero * 10 AS "numero por diez" FROM USUARIO; --Se puede operar con los valores a mostrar
SELECT ABS(numero) FROM USUARIO; --Siempre devuelve numeros positivos
SELECT ROUND(numero, 2) FROM USUARIO; --Redondea un numero para arriba o para abajo, el 2 es la cantidad de decimales que se salvan
SELECT TRUNC(numero, 2) FROM USUARIO; --Trunca un numero (eliminar decimales), dependiendo del sistema gestor esto puede ser TRUNCATE
SELECT LENGTH(nombre) FROM USUARIO; --Devuelve la longitud de un varchar, dependiendo del sistema gestor esto puede ser LEN

SELECT COUNT(*) AS cantidad, nombre FROM USUARIO GROUP BY nombre; --Altera funciones como COUNT, AVG, SUM, etc... para agruparlas segun el valor de un campo, en este caso muestra la cantidad de usuarios con cada nombre
SELECT COUNT(*) AS cantidad, nombre, apellido FROM USUARIO GROUP BY nombre, apellido; --Si hay varias propiedades para agrupar, se haran grupos por todas las combinaciones posibles
SELECT COUNT(*) AS cantidad, nombre FROM USUARIO GROUP BY nombre HAVING COUNT(*) > 3; --Lo mismo que antes pero poniendo un filtro, en este caso devolveria solo las que cumplan esa condicion
SELECT COUNT(*) AS distintos FROM (SELECT COUNT(DISTINCT uuid) FROM USUARIO GROUP BY nombre); --Devolveria la cantidad de propiedades distintas metiendo una consulta en otra
SELECT * FROM USUARIO WHERE nombre IN (SELECT nombre FROM USUARIO); --Poniendo una subconsulta en un IN
SELECT * FROM USUARIO WHERE nombre IN (SELECT DISTINCT apellido FROM USUARIO); --Otro ejemplo de subconsulta
SELECT * FROM USUARIO WHERE EXISTS (SELECT * FROM USUARIO WHERE nombre = 'Jua'); --Comprueba que esa subconsulta no este vacia
SELECT * FROM USUARIO WHERE numero > ANY (SELECT numero FROM USUARIO); --Compara si la condicion se cumple por cualquiera de los valores de un conjunto de valores o subconsulta
SELECT * FROM USUARIO WHERE numero > ALL (SELECT numero FROM USUARIO); --Compara si la condicion se cumple con todos los valores de un conjunto de valores o subconsulta

--Cuando los campos de las tablas sean iguales se usan las uniones, que agregan registros de otras tablas/consultas (unir vertical)
SELECT uuid FROM USUARIO UNION SELECT uuid_USUARIO FROM CASA; --Une los registros de dos selects no repetidos (or) (ABC + BCD = ABCD)
SELECT uuid FROM USUARIO UNION ALL SELECT uuid_USUARIO FROM CASA; --Une los registros de dos selects (or) (ABC + BCD = ABCBCD)
SELECT uuid FROM USUARIO INTERSECT SELECT uuid_USUARIO FROM CASA; --Muestra los registros en comun entre dos selects (and) (ABC + BCD = BC)
SELECT uuid FROM USUARIO MINUS SELECT uuid_USUARIO FROM CASA; --Muestra los registros de una consulta que no se encuentran en la otra (and not) (ABC + BCD = AD)
SELECT uuid FROM USUARIO MINUS SELECT uuid_USUARIO FROM CASA UNION (SELECT uuid_USUARIO FROM CASA MINUS SELECT uuid FROM USUARIO); --Muestra los registros que no tienen en comun ambas consultas (opuesto a intersect)

--Cuando los campos de las tablas no sean iguales se usa el JOIN, que agrega columnas nuevas de otras tablas/consultas (unir horizontal)
--SELECT * FROM USUARIO,TELEFONO; --Devuelve todas las combinaciones posibles con los registros de ambas tablas, NO RECOMENDADO
SELECT USUARIO.nombre, CASA.id FROM USUARIO, CASA WHERE CASA.uuid_USUARIO = USUARIO.uuid; --Seleccionando datos de dos tablas ya que estas tienen una relacion
--Lo anterior era sacar datos de dos tablas, con los JOIN se pueden unir dos tablas para conseguir una nueva (INNER JOIN = JOIN)
SELECT * FROM USUARIO JOIN CASA ON CASA.uuid_USUARIO = USUARIO.uuid WHERE USUARIO.nombre = 'hola'; --El join genera una tabla a partir de las otras 2, esta nueva tabla se puede volver a ampliar con otro join
--Esquema de JOIN, donde A = USUARIO y B = CASA (imagen)
SELECT * FROM USUARIO INNER JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; --Los registros enlazados entre A y B (excluyendo los no enlazados) (tambien llamado JOIN asecas)
SELECT * FROM USUARIO LEFT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; --Todos los registros de A y los enlazados de B
SELECT * FROM USUARIO LEFT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO WHERE CASA.uuid_USUARIO IS NULL; --Todos los registros de A que no esten enlazados a registros de B
SELECT * FROM USUARIO FULL OUTER JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; --Todos los registros de A y B
SELECT * FROM USUARIO FULL OUTER JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO WHERE USUARIO.uuid IS NULL OR CASA.uuid_USUARIO IS NULL; --Todos los registros de A y B que no esten enlazados (contrario de INNER JOIN)
SELECT * FROM USUARIO RIGHT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO WHERE CASA.uuid_USUARIO IS NULL; --Todos los registros de B que no esten enlazados a registros de A
SELECT * FROM USUARIO RIGHT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; --Todos los registros de B y los enlazados de A



--VISTAS
--Las vistas son consultas select guardadas en un nombre (solo si la consulta no es el resultado de varias tablas)
DROP VIEW VISTA; DROP VIEW VISTA2; DROP VIEW VISTA3; --Eliminar una vista
CREATE OR REPLACE VIEW VISTA AS (SELECT nombre, uuid, LENGTH(nombre) AS longitud FROM USUARIO); --Crear una vista, los nombres de las columnas de la tabla de la consulta deben tener nombre
SELECT * FROM VISTA; --Usando la vista (que seria como re-ejecutar la consulta)
INSERT INTO VISTA (uuid, nombre) VALUES ('uuid191', 'Leo'); --Si la vista NO se compone de dos tablas (resultado de join) se pueden agregar datos a la tabla a la que hace referencia (a las columnas nuevas no)
CREATE OR REPLACE VIEW VISTA2 AS (SELECT uuid, nombre, LENGTH(nombre) AS longitud FROM USUARIO WHERE nombre = 'ASDF') WITH CHECK OPTION; --Solo se podran introducir datos a esta vista si se cumple las condiciones de la subconsulta
CREATE OR REPLACE VIEW VISTA3 AS (SELECT uuid, nombre, LENGTH(nombre) AS longitud FROM USUARIO) WITH READ ONLY; --Vista de solo lectura, no se podran modificar los datos





--Insertar muchos registros a la vez
INSERT ALL
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u001', 'Juan', 'una opcion', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 1.50, 75.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u002', 'María', 'otra opcion', TO_DATE('2024-01-02', 'YYYY-MM-DD'), 2.25, 80.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u003', 'Pedro', 'una opcion', TO_DATE('2024-01-03', 'YYYY-MM-DD'), 3.75, 90.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u004', 'Ana', 'otra opcion', TO_DATE('2024-01-04', 'YYYY-MM-DD'), 4.20, 85.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u005', 'Luis', 'una opcion', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 5.80, 95.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u006', 'Carmen', 'otra opcion', TO_DATE('2024-01-06', 'YYYY-MM-DD'), 6.30, 70.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u007', 'Miguel', 'una opcion', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 7.90, 88.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u008', 'Sofia', 'otra opcion', TO_DATE('2024-01-08', 'YYYY-MM-DD'), 8.45, 92.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u009', 'David', 'una opcion', TO_DATE('2024-01-09', 'YYYY-MM-DD'), 9.10, 77.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u010', 'Laura', 'otra opcion', TO_DATE('2024-01-10', 'YYYY-MM-DD'), 10.75, 83.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u011', 'José', 'una opcion', TO_DATE('2024-01-11', 'YYYY-MM-DD'), 11.20, 79.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u012', 'Isabel', 'otra opcion', TO_DATE('2024-01-12', 'YYYY-MM-DD'), 12.65, 86.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u013', 'Roberto', 'una opcion', TO_DATE('2024-01-13', 'YYYY-MM-DD'), 13.90, 91.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u014', 'Elena', 'otra opcion', TO_DATE('2024-01-14', 'YYYY-MM-DD'), 14.35, 74.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u015', 'Carlos', 'una opcion', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 15.80, 88.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u016', 'Teresa', 'otra opcion', NULL, 16.25, 93.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u017', 'Fernando', 'una opcion', NULL, 17.70, 76.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u018', 'Patricia', 'otra opcion', NULL, 18.95, 84.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u019', 'Andrés', 'una opcion', NULL, 19.40, 89.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u020', 'Marina', 'otra opcion', NULL, 20.85, 95.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u021', 'Javier', 'una opcion', NULL, 21.30, 78.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u022', 'Claudia', 'otra opcion', NULL, 22.75, 87.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u023', 'Alberto', 'una opcion', NULL, 23.20, 92.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u024', 'Lucía', 'otra opcion', NULL, 24.65, 75.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u025', 'Ricardo', 'una opcion', NULL, 25.10, 81.0)
SELECT * FROM dual;

INSERT ALL
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (1, '+34', '123456789', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (2, '+44', '987654321', TO_DATE('2024-01-02', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (3, '+1', '555123456', NULL, 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (4, '+49', '147258369', TO_DATE('2024-01-04', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (5, '+33', '369258147', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (6, '+39', '258147369', NULL, 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (7, '+81', '741852963', TO_DATE('2024-01-07', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (8, '+86', '963852741', TO_DATE('2024-01-08', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (9, '+7', '159753456', NULL, 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (10, '+52', '357951852', TO_DATE('2024-01-10', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (11, '+55', '951753842', TO_DATE('2024-01-11', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (12, '+61', '753159852', NULL, 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (13, '+31', '159357852', TO_DATE('2024-01-13', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (14, '+48', '357159852', TO_DATE('2024-01-14', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (15, '+46', '951357852', NULL, 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (16, '+45', '753951852', TO_DATE('2024-01-16', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (17, '+47', '159753852', TO_DATE('2024-01-17', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (18, '+43', '357951852', NULL, 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (19, '+32', '951753852', TO_DATE('2024-01-19', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (20, '+41', '753159852', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (21, '+351', '159357852', NULL, 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (22, '+380', '357159852', TO_DATE('2024-01-22', 'YYYY-MM-DD'), 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (23, '+972', '951357852', TO_DATE('2024-01-23', 'YYYY-MM-DD'), 1)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (24, '+91', '753951852', NULL, 0)
    INTO TELEFONO (id, prefijo, numero, fecha, activo) VALUES (25, '+65', '159753852', TO_DATE('2024-01-25', 'YYYY-MM-DD'), 1)
SELECT * FROM dual;

INSERT ALL
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u001', 1)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u002', 2)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u003', 3)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u004', 4)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u005', 5)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u006', 6)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u007', 7)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u008', 8)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u009', 9)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u010', 10)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u011', 11)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u012', 12)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u013', 13)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u014', 14)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u015', 15)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u016', 16)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u017', 17)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u018', 18)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u019', 19)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u020', 20)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u021', 21)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u022', 22)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u023', 23)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u024', 24)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u025', 25)
SELECT * FROM dual;

INSERT ALL
    INTO CASA (id, uuid_USUARIO) VALUES (1, 'u001')
    INTO CASA (id, uuid_USUARIO) VALUES (2, 'u002')
    INTO CASA (id, uuid_USUARIO) VALUES (3, 'u003')
    INTO CASA (id, uuid_USUARIO) VALUES (4, 'u004')
    INTO CASA (id, uuid_USUARIO) VALUES (5, 'u005')
    INTO CASA (id, uuid_USUARIO) VALUES (6, 'u006')
    INTO CASA (id, uuid_USUARIO) VALUES (7, 'u007')
    INTO CASA (id, uuid_USUARIO) VALUES (8, 'u008')
    INTO CASA (id, uuid_USUARIO) VALUES (9, 'u009')
    INTO CASA (id, uuid_USUARIO) VALUES (10, 'u010')
    INTO CASA (id, uuid_USUARIO) VALUES (11, 'u011')
    INTO CASA (id, uuid_USUARIO) VALUES (12, 'u012')
    INTO CASA (id, uuid_USUARIO) VALUES (13, 'u013')
    INTO CASA (id, uuid_USUARIO) VALUES (14, 'u014')
    INTO CASA (id, uuid_USUARIO) VALUES (15, 'u015')
    INTO CASA (id, uuid_USUARIO) VALUES (16, 'u016')
    INTO CASA (id, uuid_USUARIO) VALUES (17, 'u017')
    INTO CASA (id, uuid_USUARIO) VALUES (18, 'u018')
    INTO CASA (id, uuid_USUARIO) VALUES (19, 'u019')
    INTO CASA (id, uuid_USUARIO) VALUES (20, 'u020')
    INTO CASA (id, uuid_USUARIO) VALUES (21, 'u021')
    INTO CASA (id, uuid_USUARIO) VALUES (22, 'u022')
    INTO CASA (id, uuid_USUARIO) VALUES (23, 'u023')
    INTO CASA (id, uuid_USUARIO) VALUES (24, 'u024')
    INTO CASA (id, uuid_USUARIO) VALUES (25, 'u025')
SELECT * FROM dual;

INSERT ALL
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (1, 'ABC123', 'u001')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (2, 'XYZ789', 'u002')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (3, 'DEF456', 'u003')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (4, 'GHI789', 'u004')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (5, 'JKL123', 'u005')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (6, 'MNO456', 'u006')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (7, 'PQR789', 'u007')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (8, 'STU123', 'u008')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (9, 'VWX456', 'u009')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (10, 'YZA789', 'u010')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (11, 'BCD123', 'u011')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (12, 'EFG456', 'u012')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (13, 'HIJ789', 'u013')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (14, 'KLM123', 'u014')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (15, 'NOP456', 'u015')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (16, 'QRS789', 'u016')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (17, 'TUV123', 'u017')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (18, 'WXY456', 'u018')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (19, 'ZAB789', 'u019')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (20, 'CDE123', 'u020')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (21, 'FGH456', 'u021')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (22, 'IJK789', 'u022')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (23, 'LMN123', 'u023')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (24, 'OPQ456', 'u024')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (25, 'RST789', 'u025')
SELECT * FROM dual;

INSERT ALL
    INTO TELEFONO (id, prefijo, numero, fecha) VALUES (26, '+44', '111222333', NULL)
    INTO TELEFONO (id, prefijo, numero, fecha) VALUES (27, '+33', '444555666', TO_DATE('2024-02-01', 'YYYY-MM-DD'))
    INTO TELEFONO (id, prefijo, numero, fecha) VALUES (28, '+1', '777888999', NULL)
    INTO TELEFONO (id, prefijo, numero, fecha) VALUES (29, '+81', '000111222', TO_DATE('2024-02-03', 'YYYY-MM-DD'))
    INTO TELEFONO (id, prefijo, numero, fecha) VALUES (30, '+49', '333444555', NULL)
SELECT * FROM dual;

INSERT ALL
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u026', 'Testing1', 'una opcion', NULL, 26.50, 85.5)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u027', 'Testing2', 'otra opcion', NULL, 27.75, 92.0)
    INTO USUARIO (uuid, nombre, apellido, fecha, numero, calificacion) VALUES ('u028', 'Testing3', 'una opcion', NULL, 28.90, 78.5)
SELECT * FROM dual;

INSERT ALL
    INTO CASA (id, uuid_USUARIO) VALUES (26, 'u026')
    INTO CASA (id, uuid_USUARIO) VALUES (27, 'u027')
    INTO CASA (id, uuid_USUARIO) VALUES (28, 'u028')
    INTO CASA (id, uuid_USUARIO) VALUES (29, NULL)
    INTO CASA (id, uuid_USUARIO) VALUES (30, NULL)
SELECT * FROM dual;

INSERT ALL
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (26, 'TEST123', 'u026')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (27, 'TEST456', 'u027')
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (28, 'TEST789', NULL)
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (29, 'TEST012', NULL)
    INTO VEHICULO (id, nombre, uuid_USUARIO) VALUES (30, 'TEST345', NULL)
SELECT * FROM dual;

INSERT ALL
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u026', 26)
    INTO USUARIO_TELEFONO (uuid_USUARIO, id_TELEFONO) VALUES ('u027', 27)
SELECT * FROM dual;

