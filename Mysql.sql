#CREATE DATABASE MBASE; #Crear base de datos (ejecutar las consultas en dicha base)
#USE MBASE;
#OPERACIONES CON TABLAS

#Borrar tabla, si no existe no da error, de normal seria DROP TABLE X
DROP TABLE IF EXISTS USUARIO_TELEFONO;
DROP TABLE IF EXISTS CASA;
DROP TABLE IF EXISTS VEHICULO;
DROP TABLE IF EXISTS TELEFONO;
DROP TABLE IF EXISTS USUARIO;

#Crear tabla con esas propiedades
CREATE TABLE USUARIO(uuid INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(127) NOT NULL, apellido VARCHAR(255), fecha DATE DEFAULT '2020-12-31', numero DECIMAL(5, 2), calificacion INT DEFAULT 1, activo BOOLEAN DEFAULT TRUE, creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE TELEFONO(id INT, prefijo VARCHAR(5), numero VARCHAR(9), fecha DATE, activo INT DEFAULT 0, CHECK (activo IN (0, 1)));
CREATE TABLE USUARIO_TELEFONO(uuid_USUARIO INT, id_TELEFONO INT); #Esta tabla sale de una relacion n:m
CREATE TABLE CASA(id INT AUTO_INCREMENT PRIMARY KEY, uuid_USUARIO INT); #Esta tabla tendra una clave ajena a la pk de otra tabla
CREATE TABLE VEHICULO(id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(9), uuid_USUARIO INT, CONSTRAINT fk_VEHICULO_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid)); #Se pueden hacer las restricciones directamente en la tabla, pero no se recomienda

#Para hacer atributos autoincrementales hay que ver como se hace en cada gestor de base de datos ya que no hay un estandar

#Agregar la restriccion de clave primaria a esa tabla (puede estar compuesta de varias propiedades)
#Tipos de constraint: UNIQUE uk_, PRIMARY KEY pk_, FOREIGN KEY fk_, CHECK ck_
ALTER TABLE TELEFONO ADD CONSTRAINT pk_TELEFONO PRIMARY KEY (id);
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT pk_USUARIO_TELEFONO PRIMARY KEY (uuid_USUARIO, id_TELEFONO);


#Agregar la restriccion de clave unica a esa tabla a una propiedad (puede estar compuesta de varias propiedades)
ALTER TABLE USUARIO ADD CONSTRAINT uk_USUARIO_numero UNIQUE (numero);

#Agregar la restriccion de clave ajena a esa tabla con una clave primaria de otra (puede estar compuesta de varias propiedades)
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT fk_USUARIO_TELEFONO_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid);
ALTER TABLE USUARIO_TELEFONO ADD CONSTRAINT fk_USUARIO_TELEFONO_id_TELEFONO FOREIGN KEY (id_TELEFONO) REFERENCES TELEFONO(id);
ALTER TABLE CASA ADD CONSTRAINT fk_CASA_uuid_USUARIO FOREIGN KEY (uuid_USUARIO) REFERENCES USUARIO(uuid);

#Manejar otro tipo de restricciones sobre ciertas propiedades
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_calificacion CHECK ((calificacion<=100) AND (calificacion > 0)); #Todas estas condiciones tambien pueden ser usadas en consultas con registros
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_apellido CHECK ((apellido) IN ('una opcion', 'otra opcion'));
ALTER TABLE USUARIO ADD CONSTRAINT ck_USUARIO_numero CHECK ((numero) BETWEEN 1 AND 100);
ALTER TABLE USUARIO DROP CONSTRAINT ck_USUARIO_calificacion;

#Agnadir o eliminar propiedades en tablas
ALTER TABLE USUARIO ADD correo VARCHAR(255);
ALTER TABLE USUARIO DROP COLUMN correo;


COMMIT; #Guarda los resultados de haber modificado una base de datos
ROLLBACK; #Devuelve la base de datos al estado del ultimo commit

INSERT INTO TELEFONO (id , numero, fecha) VALUES (0, '123456789', STR_TO_DATE('21/03/2022', '%d/%m/%Y')); #Aagnadir un entry a la tabla, STR_TO_DATE se puede reemplazar por CURRENT_TIMESTAMPCURRENT_TIMESTAMP para poner la fecha actual
INSERT INTO TELEFONO (id , prefijo, numero) VALUES (2, '+34', '123412344'), (3, '+34', '123412344'), (4, '+34', '123412344'); #Insertar muchos registros a la vez
UPDATE TELEFONO SET numero = '398458643', prefijo = '+20' WHERE id = 1 AND (prefijo = '+33' OR prefijo = '+34'); #Actualizar el contenido de una tabla donde se cumpla cierta condicion
DELETE FROM TELEFONO WHERE id = 1; #Elminar un entry especifico segun una condicion (IMPORTANTE PONER EL FROM PARA NO BORRAR LA TABLA)
SET FOREIGN_KEY_CHECKS = 0; #Aplica el CASCADE a los borrados
TRUNCATE TABLE TELEFONO; #Borra todos los entrys de una tabla pero no la tabla

#Orden de ejecucion de los calculos: FROM > WHERE > GROUP BY > HAVING  SELECT > ORDER BY
SELECT * FROM TELEFONO; #Devuelve todos los entrys de la tabla con todas las columnas
SELECT * FROM TELEFONO WHERE prefijo = '+52'; #Devuelve todos los entrys de la tabla en base a ciertas condiciones (similar a update, AND y OR tambien funcionarian) (< > >= <= != <>)
SELECT numero * 10 FROM USUARIO WHERE numero = 2 * (numero - 1); #Se pueden hacer operaciones en cualquier parte del select con los datos (+ - / * POWER(a, b) MOD(a, b) SQRT(x)...)
SELECT CONCAT(nombre || ' asdf') FROM USUARIO; #Para concatenar varchars
SELECT * FROM TELEFONO WHERE prefijo IN ('+52', '+34'); #Devuelve los entrys donde x valor sea igual a alguno de esos valores 
SELECT * FROM TELEFONO WHERE cast(numero AS INTEGER) BETWEEN 0 AND 5; #Devuelve los entrys donde ese valor DECIMALo este entre esos dos numeros, como en este caso era INT se paso a INTEGER
SELECT * FROM TELEFONO WHERE prefijo IS NOT NULL; #Filtra para ver solo los que no son nulos, tambien se puede hacer solo con los nulos
SELECT * FROM USUARIO WHERE nombre LIKE 'd_t%'; #Expresiones regulares, % es cualquier cantidad de caracteres y _ es cualquier caracter
SELECT * FROM USUARIO WHERE UPPER(nombre) = 'a'; #Lower convierte cualquier cosa en mayusculas, tambien esta upper. Tambien se podria hacer = LOWER('ASDF')
SELECT nombre, apellido AS ape FROM USUARIO; #Muestra solo las columnas especificadas, tambien se le pueden cambiar el nombre a las columnas
SELECT * FROM USUARIO ORDER BY nombre DESC, apellido; #Ordenar de menor a mayor o alfabeticamente los registros, si ese valor es igual se evaluara el siguiente, DESC hace que sea descendente en este caso o ASC ascendente, se puede reemplazar el nombre de la propiedad por su numero
SELECT * FROM USUARIO ORDER BY nombre FETCH FIRST 3 ROWS ONLY; #Muestra los x primeros registros solo, depende de la version esto se podria reemplazar por LIMIT x , o por SELECT TOP x * FROM...
SELECT DISTINCT nombre FROM USUARIO; #Evita mostar resultadtos repetidos en esa propiedad
SELECT * FROM USUARIO WHERE EXTRACT(MONTH FROM fecha)=1; #Filtrar campos de una fecha

SELECT COUNT(*) AS cantidad FROM USUARIO; #Devuelve la cantidad de registros
SELECT COUNT(CASE WHEN nombre = 'hola' THEN 1 ELSE NULL END) FROM USUARIO; #Contar solo si se cumple la condicion
SELECT COUNT(*) AS "la cantidad" FROM USUARIO; #Para poner mas de una palabra en el nombre
SELECT COUNT(DISTINCT nombre) AS "nombres distintos" FROM USUARIO; #Usando el DISTINCT en una funcion
SELECT MAX(numero) FROM USUARIO; #Devuelve el que tenga el mayor valor, para el menor esta MIN
SELECT AVG(numero) FROM USUARIO; #Devuelve la media de ese valor en todos los registros seleccionados
SELECT SUM(numero) FROM USUARIO; #Devuelve el total de sumar todos esos valores
SELECT REGEXP_SUBSTR(numero, '^\d{3}') FROM TELEFONO; #Recorta el varchar para crear uno nuevo con solo los caracteres que cumplan ese regex, en este caso coge solo los 3 primeros numeros
SELECT * FROM TELEFONO WHERE REGEXP_SUBSTR(numero, '^\d{3}') = '123'; #Tambien se puede usar para filtrar
SELECT numero * 10 AS "numero por diez" FROM USUARIO; #Se puede operar con los valores a mostrar
SELECT ABS(numero) FROM USUARIO; #Siempre devuelve numeros positivos
SELECT ROUND(numero, 2) FROM USUARIO; #Redondea un numero para arriba o para abajo, el 2 es la cantidad de decimales que se salvan
SELECT LENGTH(nombre) FROM USUARIO; #Devuelve la longitud de un varchar, dependiendo del sistema gestor esto puede ser LEN

SELECT COUNT(*) AS cantidad, nombre FROM USUARIO GROUP BY nombre; #Altera funciones como COUNT, AVG, SUM, etc... para agruparlas segun el valor de un campo, en este caso muestra la cantidad de usuarios con cada nombre
SELECT COUNT(*) AS cantidad, nombre, apellido FROM USUARIO GROUP BY nombre, apellido; #Si hay varias propiedades para agrupar, se haran grupos por todas las combinaciones posibles
SELECT COUNT(*) AS cantidad, nombre FROM USUARIO GROUP BY nombre HAVING COUNT(*) > 3; #Lo mismo que antes pero poniendo un filtro, en este caso devolveria solo las que cumplan esa condicion
SELECT COUNT(*) AS distintos FROM (SELECT COUNT(DISTINCT uuid) FROM USUARIO GROUP BY nombre) AS sub1; #Devolveria la cantidad de propiedades distintas metiendo una consulta en otra
SELECT * FROM USUARIO WHERE nombre IN (SELECT nombre FROM USUARIO); #Poniendo una subconsulta en un IN
SELECT * FROM USUARIO WHERE nombre IN (SELECT DISTINCT apellido FROM USUARIO); #Otro ejemplo de subconsulta
SELECT * FROM USUARIO WHERE EXISTS (SELECT * FROM USUARIO WHERE nombre = 'Jua'); #Comprueba que esa subconsulta no este vacia
SELECT * FROM USUARIO WHERE numero > ANY (SELECT numero FROM USUARIO); #Compara si la condicion se cumple por cualquiera de los valores de un conjunto de valores o subconsulta
SELECT * FROM USUARIO WHERE numero > ALL (SELECT numero FROM USUARIO); #Compara si la condicion se cumple con todos los valores de un conjunto de valores o subconsulta

#Cuando los campos de las tablas sean iguales se usan las uniones, que agregan registros de otras tablas/consultas (unir vertical)
SELECT uuid FROM USUARIO UNION SELECT uuid_USUARIO FROM CASA; #Une los registros de dos selects no repetidos (or) (ABC + BCD = ABCD)
SELECT uuid FROM USUARIO UNION ALL SELECT uuid_USUARIO FROM CASA; #Une los registros de dos selects (or) (ABC + BCD = ABCBCD)
SELECT uuid FROM USUARIO INTERSECT SELECT uuid_USUARIO FROM CASA; #Muestra los registros en comun entre dos selects (and) (ABC + BCD = BC)
SELECT uuid FROM USUARIO EXCEPT SELECT uuid_USUARIO FROM CASA; #Muestra los registros de una consulta que no se encuentran en la otra (and not) (ABC + BCD = AD)
SELECT uuid FROM USUARIO EXCEPT SELECT uuid_USUARIO FROM CASA UNION (SELECT uuid_USUARIO FROM CASA EXCEPT SELECT uuid FROM USUARIO); #Muestra los registros que no tienen en comun ambas consultas (opuesto a intersect)

#Cuando los campos de las tablas no sean iguales se usa el JOIN, que agrega columnas nuevas de otras tablas/consultas (unir horizontal)
#SELECT * FROM USUARIO,TELEFONO; #Devuelve todas las combinaciones posibles con los registros de ambas tablas, NO RECOMENDADO
SELECT USUARIO.nombre, CASA.id FROM USUARIO, CASA WHERE CASA.uuid_USUARIO = USUARIO.uuid; #Seleccionando datos de dos tablas ya que estas tienen una relacion
#Lo anterior era sacar datos de dos tablas, con los JOIN se pueden unir dos tablas para conseguir una nueva (INNER JOIN = JOIN)
SELECT * FROM USUARIO JOIN CASA ON CASA.uuid_USUARIO = USUARIO.uuid WHERE USUARIO.nombre = 'hola'; #El join genera una tabla a partir de las otras 2, esta nueva tabla se puede volver a ampliar con otro join
#Esquema de JOIN, donde A = USUARIO y B = CASA (imagen)
SELECT * FROM USUARIO INNER JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; #Los registros enlazados entre A y B (excluyendo los no enlazados) (tambien llamado JOIN asecas)
SELECT * FROM USUARIO LEFT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; #Todos los registros de A y los enlazados de B
SELECT * FROM USUARIO LEFT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO WHERE CASA.uuid_USUARIO IS NULL; #Todos los registros de A que no esten enlazados a registros de B
#No funcional directamente aqui: #SELECT * FROM USUARIO FULL OUTER JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; #Todos los registros de A y B
#No funcional directamente aqui: #SELECT * FROM USUARIO FULL OUTER JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO WHERE USUARIO.uuid IS NULL OR CASA.uuid_USUARIO IS NULL; #Todos los registros de A y B que no esten enlazados (contrario de INNER JOIN)
SELECT * FROM USUARIO RIGHT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO WHERE CASA.uuid_USUARIO IS NULL; #Todos los registros de B que no esten enlazados a registros de A
SELECT * FROM USUARIO RIGHT JOIN CASA ON USUARIO.uuid = CASA.uuid_USUARIO; #Todos los registros de B y los enlazados de A



#VISTAS
#Las vistas son consultas select guardadas en un nombre (solo si la consulta no es el resultado de varias tablas)
DROP VIEW VISTA; DROP VIEW VISTA2; #Eliminar una vista
CREATE OR REPLACE VIEW VISTA AS (SELECT nombre, uuid, LENGTH(nombre) AS longitud FROM USUARIO); #Crear una vista, los nombres de las columnas de la tabla de la consulta deben tener nombre
SELECT * FROM VISTA; #Usando la vista (que seria como re-ejecutar la consulta)
INSERT INTO VISTA (nombre) VALUES ('Leo'); #Si la vista NO se compone de dos tablas (resultado de join) se pueden agregar datos a la tabla a la que hace referencia (a las columnas nuevas no)
CREATE OR REPLACE VIEW VISTA2 AS (SELECT uuid, nombre, LENGTH(nombre) AS longitud FROM USUARIO WHERE nombre = 'ASDF') WITH CHECK OPTION; #Solo se podran introducir datos a esta vista si se cumple las condiciones de la subconsulta, si no hay condiciones se vuelve de solo lectura
