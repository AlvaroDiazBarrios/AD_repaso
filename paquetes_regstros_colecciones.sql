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

---Boletín 7---

--1
--
/*Creamos la cabecera del paquete*/
create or replace package gest_emple as

 procedure nuevoEmple (
   v_empNo emple.emp_no%type,
   v_apellido emple.apellido%type,
   v_oficio emple.oficio%type,
   v_dir emple.dir%type,
   v_fechaAlt emple.fecha_alt%type,
   v_salario emple.salario%type,
   v_comision emple.comision%type,
   v_deptNo emple.dept_no%type
  );

 procedure borrarEmple (
   v_empNo emple.emp_no%type
 );

 procedure modificarOficio (
   v_empNo emple.emp_no%type,
   v_oficio emple.oficio%type
 );

 procedure modificarDept (
   v_empNo emple.emp_no%type,
   v_dept emple.dept_no%type
 );

 procedure modificarDir (
  v_empNo emple.emp_no%type,
  v_dir emple.dir%type
 );

 procedure modificarSalario (
  v_empNo emple.emp_no%type,
  v_salario emple.salario%type
 );

 procedure modificarComision (
  v_empNo emple.emp_no%type,
  v_comision emple.comision%type
 );

 procedure visualizarDatos(
  v_empNo emple.emp_no%type
 );

 procedure visualizarDatos(
  v_apellido emple.apellido%type
 );

 function buscarPorNombre(
  v_apellido emple.apellido%type
 ) return emple.emp_no%type;

 procedure subidaPct (
  pct number
 );

 procedure subidaImp(
  imp number
 );

end gest_emple;

/*Creamos el cuerpo del paquete*/
create or replace package body gest_emple as

 procedure nuevoEmple (
   v_empNo emple.emp_no%type,
   v_apellido emple.apellido%type,
   v_oficio emple.oficio%type,
   v_dir emple.dir%type,
   v_fechaAlt emple.fecha_alt%type,
   v_salario emple.salario%type,
   v_comision emple.comision%type,
   v_deptNo emple.dept_no%type
  ) as
   e_dept number;
   e_dir  number;
  begin
   select count(*) into e_dept from depart
   where dept_no = v_deptNo;

   select count(*) into e_dir from emple
   where emp_no = v_dir;

   if e_dept = 0 then
    raise_application_error(-20001, 'El departamento no existe');
   elsif e_dir = 0 then
    raise_application_error(-20001, 'El director no existe');
   end if;

   insert into emple values(
    v_empNo,
    v_apellido,
    v_oficio,
    v_dir,
    v_fechaAlt,
    v_salario,
    v_comision,
    v_deptNo
   );
 end nuevoEmple;

 procedure borrarEmple (
  v_empNo emple.emp_no%type
 ) as
  v_dir emple.dir%type;
 begin
  select dir into v_dir from emple
  where emp_no = v_empNo;

  update emple
  set dir = v_dir
  where dir = v_empNo;

  delete from emple
  where emp_no = v_empNo;

 end borrarEmple;

 procedure modificarOficio(
  v_empNo emple.emp_no%type,
  v_oficio emple.oficio%type
 ) as
 begin
  update emple
  set oficio = v_oficio
  where emp_no = v_empNo;
 end modificarOficio;

 procedure modificarDept (
  v_empNo emple.emp_no%type,
  v_dept emple.dept_no%type
 ) as
  e_dept depart.dept_no%type;
 begin
  select count(*) into e_dept from depart
  where dept_no = v_dept;

  if e_dept = 0 then
   raise_application_error(-20001, 'El departamento no existe');
  end if;

  update emple
  set dept_no = v_dept
  where emp_no = v_empNo;
 end modificarDept;

 procedure modificarDir(
  v_empNo emple.emp_no%type,
  v_dir emple.dir%type
 ) as
  e_dir emple.dir%type;
 begin
  select count(*) into e_dir from emple
  where emp_no = v_dir;

  if e_dir = 0 then
   raise_application_error(-20001, 'El director no existe');
  end if;

  update emple
  set dir = v_dir
  where emp_no = v_empNo;
 end modificarDir;

 procedure modificarSalario (
  v_empNo emple.emp_no%type,
  v_salario emple.salario%type
 ) as
 begin
  update emple
  set salario = v_salario
  where emp_no = v_empNo;
 end modificarSalario;

 procedure modificarComision (
  v_empNo emple.emp_no%type,
  v_comision emple.comision%type
 ) as
 begin
  update emple
  set comision = v_comision
  where emp_no = v_empNo;
 end modificarComision;

 procedure visualizarDatos (
  v_empNo emple.emp_no%type
 ) as
  datos emple%rowtype;
 begin
  select * into datos from emple
  where emp_no = v_empNo;

  dbms_output.put_line('Apellido: ' || datos.apellido ||
  ' Oficio: ' || datos.oficio ||
  ' Dir: ' || datos.dir ||
  ' Fecha Alt: ' || datos.fecha_alt ||
  ' Salario: ' || datos.salario ||
  ' Comision: ' || datos.comision ||
  ' Departamento: ' || datos.dept_no);
 end visualizarDatos;

 procedure visualizarDatos (
  v_apellido emple.apellido%type
 ) as
  datos emple%rowtype;
 begin
  select * into datos from emple
  where apellido = v_apellido;

  dbms_output.put_line('Nº: ' || datos.emp_no ||
  ' Oficio: ' || datos.oficio ||
  ' Dir: ' || datos.dir ||
  ' Fecha Alt: ' || datos.fecha_alt ||
  ' Salario: ' || datos.salario ||
  ' Comision: ' || datos.comision ||
  ' Departamento: ' || datos.dept_no);
 end visualizarDatos;

 function buscarPorNombre (
  v_apellido emple.apellido%type
 ) return emple.emp_no%type as
  dato emple.emp_no%type;
 begin
  select emp_no into dato from emple
  where apellido = v_apellido;

  return dato;

 end buscarPorNombre;

 procedure subidaPct (
  pct number
 ) as
 begin

  if pct > 0.25 then
   raise_application_error(-20001, 'Porcentaje mayor a 0.25');
  end if;

  update emple
  set salario = salario + (salario * pct);
 end subidaPct;

 procedure subidaImp(
  imp number
 ) as
  salarioMedio number;
 begin
  select avg(salario) * 0.25into salarioMedio from emple;

  if salarioMedio < imp then
   raise_application_error(-20001, 'El importe supera el 0.25 del salario medio');
  end if;

  update emple
  set salario = salario + imp;
 end subidaImp;
end gest_emple;

--2
create or replace package pq_provincias as

 function provincia (v_mat provincias.mat%type) return provincias.prov%type;
 function matricula (v_prov provincias.prov%type) return provincias.mat%type;
 function codigoPost (v_prov provincias.prov%type) return provincias.cp%type;
 procedure borrarProv;

end pq_provincia;

create or replace package body pq_provincias as
 cursor c1 is
  select * from provincias;
 type tb_provincias is table of provincias%rowtype;
 v_provincias tb_provincias := tb_provincias();
 i number;

 function provincia (v_mat provincias.mat%type) return provincias.prov%type as
 dato provincias.prov%type;
 begin
  select prov into dato from provincias
  where mat = v_mat;

  return dato;
 end provincia;

 function matricula (v_prov provincias.prov%type) return provincias.mat%type as
 dato provincias.mat%type;
 begin
  select mat into dato from provincias
  where prov = v_prov;
  return dato;
 end matricula;

 function codigoPost (v_prov provincias.prov%type) return provincias.cp%type as
 dato provincias.cp%type;
 begin
  select cp into dato from provincias
  where prov = v_prov;
  return dato;
 end codigoPost;

 procedure borrarProv as
 begin
  v_provincias.delete;
 end borrarProv;

 begin
  i := 1;
  for v1 in c1 loop
   v_provincias.extend;
   v_provincias(i) := v1;
   i := i + 1;
  end loop;
end pq_provincias;
