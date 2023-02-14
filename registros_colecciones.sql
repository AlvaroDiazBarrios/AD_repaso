--p3 #327
declare
 cursor c_depar is
  select dnombre, count(emp_no) numemple from depart, emple
  where depart.dept_no = emple.dept_no group by depart.dept_no, dnombre;

 /*Definimos el tipo compatible con el cursor*/
 type tr_depto is record(
  nombredept depart.dnombre%type,
  numemple integer
 );

 /*Definimos una tabla anidada basada en el tipo anterior*/
 type ta_depto is table of tr_depto;

 /*Declaramos e inicializamos una variable de la tabla*/
 va_departamentos ta_depto := ta_depto();


 /*Declaramos una variable para usarla como índice*/
 n integer := 0;
begin
 /*Cargar valores en la variable*/
 for vc in c_depar loop
  n := c_depar%rowcount;
  va_departamentos.extend;
  va_departamentos(n) := vc;
 end loop;

 /*Mostrar los datos de la variable*/
 for i in 1..n loop
  dbms_output.put_line(' * Dnombre: '|| va_departamentos(i).nombredept ||
   ' * NºEmpleados: '|| va_departamentos(i).numemple);
 end loop;
end;
