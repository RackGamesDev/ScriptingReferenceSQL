--Los scripts de PLSQL solo son admitidos en OracleDB y Postgres, asi es como funcionan en OracleDB (simplemente codigo ejecutable en un .sql)

--SET SERVEROUTPUT ON; --Este parametro debe estar activo


--Esto es un bloque anonimo, un bloque de codigo que solo se puede ejecutar desde algun editor (no se guarda en la base de datos)
DECLARE 
	--Aqui se declaran las variables, con una sintaxis similar a la de sql
	v_texto VARCHAR2(50);
	v_cadena char(10) := 'asdf'; --Otro tipo de texto
	--v_siono BOOLEAN := TRUE; --Booleano
	v_numero NUMBER(4) DEFAULT 14; --Valores por defecto
	v_constante CONSTANT NUMBER := 10.33; --Declarar constantes
	e_unerror EXCEPTION; --Declarar un error personalizado
	
	v_otro_numero v_numero%TYPE; --Copiarle el tipo a otra variable
	v_registro_USUARIO USUARIO%ROWTYPE; --Tipo que almacena el registro entero de una tabla (similar a un struct), en este caso es un registro de una tabla especifica
	v_nombre_USUARIO USUARIO.nombre%TYPE; --Copiando el tipo de una propiedad de una tabla
	v_numero_USUARIO USUARIO.numero%TYPE;

	--v_opcion NUMBER:=&"introducir_numero"; --En algunos casos se puede hacer asi para pedirlo en una ventana
	TYPE r_usuarioBasico IS RECORD (uuid USUARIO.uuid%TYPE, nombre USUARIO.nombre%TYPE); --"variable" que almacena un conjunto de campos (no sus valores)
	v_registroBasico_USUARIO r_usuarioBasico; --Declarando una variable similar a un registro usando el RECORD ("registro" vacio con esos campos)
	CURSOR c_usuario IS SELECT USUARIO.nombre FROM USUARIO; --Declarar un CURSOR con una consulta SELECT para recorrer sus datos
	CURSOR c_usuario_filtro(p_minimo NUMBER) IS SELECT USUARIO.nombre FROM USUARIO WHERE USUARIO.numero > p_minimo; --CURSOR que es llamado con parametros
	
	TYPE tabla_texto IS TABLE OF VARCHAR2(50); --Crear un nuevo tipo para tablas de x tipo
	v_tabla_textos tabla_texto := tabla_texto('uno', 'dos', 'tres'); --Declarar una variable de esta tabla (empiezan por el 1) (cantidad fija)
	TYPE varray_texto IS VARRAY(4) OF VARCHAR2(50); --Igual que lo anterior pero con una cantidad maxima
	v_varray_textos varray_texto := varray_texto('aa', 'bb', 'cc', 'dd'); --Funciona exactamente igual
	TYPE array_integer_texto IS TABLE OF VARCHAR(50) INDEX BY PLS_INTEGER; --Creando un tipo de ARRAY infinito de x tipo
	v_array_asociativo array_integer_texto;
	
	--Declarar bloques de codigo ejecutables dentro de otro, esto debe ir al final del BEGIN
	--Declarar una funcion, los parametros IN son de entrada y el OUT es la salida, puede no tener parametros de entrada
	PROCEDURE PR_CONCATENAR(p_texto1 IN VARCHAR2, p_texto2 IN VARCHAR2, p_resultado OUT VARCHAR2) IS
	BEGIN
		p_resultado := p_texto1 || p_texto2; --Establecer un dato en el valor OUT es igual que RETURN
	END PR_CONCATENAR;
	--Similar a lo anterior pero usando una funcion, los parametros de entrada son opcionales
	FUNCTION FN_CONCATENAR2(p_texto1 VARCHAR2, p_texto2 VARCHAR2) RETURN VARCHAR2 IS
	BEGIN
		RETURN p_texto1 || p_texto2;
	END FN_CONCATENAR2;
	--Procedure simple sin alteracion de nada ni return
	PROCEDURE PR_DECIR(p_texto IN varchar2) IS
	BEGIN
		dbms_output.put_line(p_texto); --Podria estar usando cualquier variable declarada aqui
	END PR_DECIR;

BEGIN
	--Aqui se escribe el codigo
	dbms_output.put_line('asdfasfd'); --Imprimir por pantalla
	v_texto := 'asdf'; --Cambiar el valor de variables
	dbms_output.put_line('texto' || v_texto); --Usar variables (se usa || para concatenar, en algunas versiones solo se pueden imprimir varchars)
	dbms_output.put_line('a' || CHR(13) || 'b'); --Salto de linea
	v_numero := LENGTH(v_texto); --Saber la longitud de un texto
	v_numero := 4 + v_numero / 2 * 5 - 1 MOD 2; --Operaciones numericas
	dbms_output.put_line(TO_CHAR(SYSDATE + 10, 'DD/MM/YYYY')); --Operando con fechas (SYSDATE es la actual)
	--RAISE INVALID_NUMBER; --Lanzar aposta una excepcion, lo cual provoca un salto al bloque EXCEPTION
	--RAISE er_unerror; --Lanzar una excepcion personalizada

	--Ejemplo de if basico
	IF v_numero > 2 THEN --Comparaciones: < > =
		dbms_output.put_line('si');                                                                            
	ELSIF NOT v_numero < 0 AND (v_texto = 'aa' OR v_texto = 'b') THEN --Usando operaciones booleanas AND OR NOT
		dbms_output.put_line('sino');                                                                          
	ELSE                                                                                                       
		dbms_output.put_line('no');                                                                           
	END IF;                                                                                                    
                                                                                                               
	CASE v_numero --Switch basico                                                                              
		WHEN 1 THEN                                                                                            
			dbms_output.put_line('si es 1');                                                                   
		WHEN 2 THEN                                                                                            
			dbms_output.put_line('si es 2');                                                                   
		ELSE                                                                                                   
			dbms_output.put_line('ninguno');                                                                   
	END CASE;                                                                                                  
	                              
	FOR v_numero IN 0..10 LOOP --Itera de x a y usando una variable, se podria usar REVERSE 1..10 para la inversa
		dbms_output.put_line(v_numero);
		CONTINUE; --Pasa a la siguiente vuelta del bucle
		EXIT; --Sale del bucle    
	END LOOP; --El bucle no cambia la variable original
                                  
	WHILE v_numero < 20 LOOP --Bucle while basico
		dbms_output.put_line(v_numero);
		v_numero := v_numero + 1; 
	END LOOP;
	
	LOOP --Bucle do while basico
		v_numero := v_numero + 1;
		EXIT WHEN v_numero > 30; --Condicion de salida
	END LOOP;
	
	SAVEPOINT deshacer1; --Guardar un punto al que hacer ROLLBACK
	SELECT * INTO v_registro_USUARIO FROM USUARIO WHERE USUARIO.uuid = 'u001'; --Guardar un solo registro de un resultado de una consulta en una variable ROWTYPE (todos los campos)
	dbms_output.put_line(v_registro_USUARIO.nombre); --La variable tendra como propiedades los campos conseguidos con la consulta
	SELECT nombre INTO v_nombre_USUARIO FROM USUARIO WHERE USUARIO.uuid = 'u002'; --Guardando una sola columna de un solo registro
	dbms_output.put_line(v_nombre_USUARIO); --Se guardo el dato de la columna y registro seleccionada
	SELECT COUNT(*) INTO v_numero FROM USUARIO; --Guardando un resultado de otro tipo de dato (numero en este caso)
	dbms_output.put_line(v_numero);
	SELECT nombre, numero INTO v_nombre_USUARIO, v_numero_USUARIO FROM USUARIO WHERE USUARIO.uuid = 'u003'; --Guardando varios valores a la vez
	INSERT INTO USUARIO (uuid, nombre, numero) VALUES ('u999', v_nombre_USUARIO, v_numero_USUARIO * 15); --Alteracion de datos con valores del script
	DELETE FROM USUARIO WHERE USUARIO.uuid = 'u999' RETURNING nombre, numero INTO v_nombre_USUARIO, v_numero_USUARIO; --Rescatar datos de una consulta que no sea SELECT
	--COMMIT;
	ROLLBACK TO deshacer1; --Volver los datos al punto en el que estaba en ese SAVEPOINT
	
	OPEN c_usuario; --Abrir un CURSOR ya declarado con su consulta
	LOOP
		FETCH c_usuario INTO v_nombre_USUARIO; --Guardar el siguiente registro del CURSOR, segun la consulta y la variable destino se podria guardar el registro entero o los datos por esparado
		dbms_output.put_line(v_nombre_USUARIO);
		dbms_output.put_line(c_usuario%ROWCOUNT); --El numero de registro por el que va, usado para iterar
		EXIT WHEN c_usuario%NOTFOUND; --Salir cuando el CURSOR llegue al final del resultado
	END LOOP;
	CLOSE c_usuario; --Cerrar el CURSOR cuando se termine de usar
	--Otra manera de hacer lo anterior
	OPEN c_usuario;
	WHILE c_usuario%FOUND LOOP
		FETCH c_usuario INTO v_nombre_USUARIO;
		dbms_output.put_line(v_nombre_USUARIO); 
	END LOOP;
	CLOSE c_usuario;
	--Otra manera de hacer lo anterior
	FOR v_e IN c_usuario LOOP --La variable iteradora contendria el registro entero
		dbms_output.put_line(v_e.nombre);
	END LOOP;
	--Otra manera de hacer lo anterior, sin usar el cursor (siempre devuelve un registro)
	FOR v_registro_USUARIO IN (SELECT * FROM USUARIO) LOOP
		dbms_output.put_line(v_registro_USUARIO.nombre);
	END LOOP;
	OPEN c_usuario_filtro(4); --Usar un CURSOR que pide parametros
	CLOSE c_usuario_filtro;
	
	v_tabla_textos(2) := 'aaa'; --Accediendo a las posiciones de una variable tipo tabla personalizada (empieza por el 1)
	dbms_output.put_line(v_tabla_textos(1));
	FOR v_i IN v_tabla_textos.FIRST .. v_tabla_textos.LAST LOOP --Iterando usando .FIRST y .LAST, que devuelven el primer y ultimo indice
		dbms_output.put_line(v_tabla_textos(v_i));
	END LOOP;
	v_tabla_textos := tabla_texto('cuatro', 'cinco', 'seis', 'siete'); --Reasignar la variable (la unica forma de cambiar su cantidad)
	--Se puede hacer lo mismo con los varray
	v_array_asociativo(1) := 'aaa'; v_array_asociativo(-2) := 'bbb'; v_array_asociativo(77) := 'ccc'; --Este ARRAY es infinito, se pueden poner datos en cualquier posicion
	dbms_output.put_line(v_array_asociativo(-2)); --Hay que tener cuidado ya que esa posicion podria estar vacia
	
	PR_CONCATENAR('AAA', 'BBB', v_texto); --Llamando al PROCEDURE de la cabecera, el resultado se vuelca en esa variable
	dbms_output.put_line(v_texto);
	dbms_output.put_line(FN_CONCATENAR2('AAA', 'BBB')); --Usando el FUNCTION que usa un RETURN
	PR_DECIR('asdf'); --Usando el PROCEDURE simple
	
EXCEPTION --Aqui se administran los errores
	WHEN INVALID_NUMBER THEN --Capturar un error concreto
		dbms_output.put_line('Error especifico');
	WHEN unerror THEN
		dbms_output.put_line('Error personalizado');
		RAISE_APPLICATION_ERROR(-20001, 'Mensaje de error para el programa');
	WHEN OTHERS THEN --Capturar otro error (propios del sistema de base de datos)
		dbms_output.put_line('Otro error');
END;


--Un metodo (procedure) que se guarda en la base de datos para ejecutar algo (los parametros son todos opcionales), no devuelve nada sino que recibe unos parametros IN y vuelca el resultado en las OUT
CREATE OR REPLACE PROCEDURE PR_BLOQUE(p_entrada IN VARCHAR2, p_salida OUT VARCHAR2) IS 
	--Variables
BEGIN 
	--Codigo, si se altera una variable OUT funcionara a modo de cursor (la original tambien se modificara)
END PR_BLOQUE;
ALTER PROCEDURE PR_BLOQUE COMPILE;
--Ejemplo de ejecucion: PR_BLOQUE(v_texto, v_nuevo_texto);

--Una funcion que se guarda en la base de datos para devolver un dato (los parametros son todos opcionales)
CREATE OR REPLACE FUNCTION FN_FUNCION(p_texto VARCHAR2) RETURN VARCHAR2 IS 
	--Variables
BEGIN 
	--Codigo
	RETURN p_texto || ' y ya'; --Devolver un valor del mismo tipo especificado
END FN_FUNCION;
ALTER FUNCTION FN_FUNCION COMPILE;
SELECT FN_FUNCION(nombre) FROM USUARIO; --Ejecutar la funcion, ya que devuelve un valor
--Ejemplo de ejecucion: v_texto := FN_FUNCION("aa");


--Los triggers son bloques que se guardan en la base de datos y se ejecutan automaticamente cuando x tipo de consulta se hace
CREATE OR REPLACE TRIGGER TR_DETECTAR_ACTUALIZAR_USUARIO
	BEFORE UPDATE ON USUARIO --Este se ejecutaria antes de se haga la operacion UPDATE en la tabla USUARIO, si fuese AFTER se ejecutaria despues
	FOR EACH ROW WHEN (OLD.numero > 0 AND NEW.numero > 0) --Condicion para que se dispare o no (omitible a partir del WHEN)
	--Si se hubiese puesto FOR EACH STATEMENT solo se ejecutaria una vez sin importar el numero de registros afectados, pero no se tendria acceso a :OLD ni :NEW
DECLARE 
	--Variables
BEGIN 
	--Codigo, en la mayoria de casos no se puede editar la tabla que se esta monitorizando
	dbms_output.put_line('El usuario ' || :OLD.nombre || ' ahora es ' || :NEW.nombre); --:OLD haria referencia al registro borrado y :NEW al nuevo
	--RAISE er_unerror; --Si el trigger es de tipo BEFORE, lanzar un error impidira la consulta
END;
ALTER TRIGGER TR_DETECTAR_ACTUALIZAR_USUARIO COMPILE;

CREATE OR REPLACE TRIGGER TR_BORRAR_CREAR_USUARIO
	BEFORE INSERT OR DELETE OR UPDATE ON USUARIO FOR EACH ROW --Este TRIGGER se ejecuta en varias operaciones, si fuese BEFORE DDL/DML ON USUARIO... Detectaria cualquier operacion de modificacion
BEGIN
	IF INSERTING THEN --Saber que tipo de operacion lanzo el TRIGGER
		dbms_output.put_line('Se inserto el usuario ' || :NEW.nombre);
	ELSIF DELETING THEN
		dbms_output.put_line('Se borro el usuario ' || :OLD.nombre);
	ELSIF UPDATING('NOMBRE') THEN
		dbms_output.put_line('Se actualizo el nombre de ' || :OLD.nombre || ', que ahora es ' || :NEW.nombre);
	END IF;
END;
ALTER TRIGGER TR_BORRAR_CREAR_USUARIO COMPILE;

UPDATE USUARIO SET nombre = 'nuevo' WHERE uuid = 'u002';



--Borrar todo lo declarado anteriormente (no recomendado si se va a usar despues)
DROP FUNCTION FN_FUNCION;
DROP PROCEDURE PR_BLOQUE;
DROP TRIGGER TR_DETECTAR_ACTUALIZAR_USUARIO;


--Crear una secuencia que devolvera un numero cada vez que se llame (util para simular multi-incrementales)
CREATE SEQUENCE SC_SECUENCIA START WITH 1 INCREMENT BY 1 MAXVALUE 999999 NOCACHE NOCYCLE;
SELECT SC_SECUENCIA.NEXTVAL FROM USUARIO; --Usar el siguiente valor, para ver el valor actual usar secuencia.CURRVAL. Esto es util para especificar la clave primaria en algunos casos

