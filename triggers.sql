-- p1 #312

--creamos la tabla de auditaremple
create table auditaremple(
 col1 varchar2(200)
);

--creamos el trigger
create or replace trigger t1
after update on emple
for each row
begin
 if :new.salario > :old.salario * 1.05 then
  insert into auditaremple values ('cambio realizado el: ' || sysdate
   || ' al empleado: ' || :old.apellido || ' salario anterior: ' || :old.salario
   || ' nuevo salario: ' || :new.salario);
 end if;
end t1;

drop trigger t1;

---Boletín 4---

--1
create or replace trigger t1
after delete on depart
for each row
begin
 delete from emple
 where dept_no = :old.dept_no;
end t1;

drop trigger t1;

--2
create or replace trigger t2
after update on depart
for each row
begin
 update emple
 set dept_no = :new.dept_no
 where dept_no = :old.dept_no;
end;

drop trigger t2;
--3
create or replace trigger t3
before insert or update on emple
for each row
declare
 existe number;
begin
 if inserting then
  select count(*) into existe from depart
  where dept_no = :new.dept_no;

  if existe == 0 then
   raise_application_error(-20001, 'El departamento no existe');
  end if;

  insert into emple values (:new.emp_no, :new.apellido, :new.oficio, :new.dir, :new.fecha_alt, :new.salario, :new.comision, :new.dept_no);

 else
  select count(*) into existe from depart
  where dept_no = :old.dept_no;

  if existe == 0 then
   raise_application_error(-20001, 'El departamento no existe');
  end if;

  update emple
  set dept_no = :new.dept_no
  where dept_no = :old.dept_no;

 end if;
end t3;

drop trigger t3;

--4
create or replace trigger t4
before update of salario on emple
for each row
begin
 if :new.salario > :old.salario * 1.20 then
  raise_application_error(-20001, 'Excedido del 20%');
 end if;
end t4;

drop trigger t4;
--5
create or replace trigger t5
before update of apellido, emp_no, salario on emple
for each row
begin
 if updating('apellido') or updating('emp_no') or (:new.salario > :old.salario * 1.20) then
  raise_application_error(-20001, 'Modificación no permitida');
 end if;
end t5;

drop trigger t5;

--6
create or replace trigger t6
before insert on emple
for each row
begin
 :new.comision = :new.salario * 0.01;
end t6;

drop trigger t6;

--7
create or replace trigger t7
after insert or delete on personal
for each row
begin
 if inserting then
  if :new.funcion = 'PROFESOR' then
   insert into profesores(cod_centro, dni, apellidos) values (:new.cod_centro, :new.dni, :new.apellidos);
  end if;
 else
  if :old.funcion = 'PROFESOR' then
   delete from profesores
   where dni = :old.dni;
  end if;
 end if;
end t7;

drop trigger t7;

--8
create table libros(
 isbn number primary key,
 genero varchar2(15),
 titulo varchar2(50),
 autor varchar2(50)
);

create table estadisticas(
 genero varchar2(15),
 total_libros number
);

create or replace trigger t8
after insert or update or delete on libros
for each row
declare
 e_genero number;
begin
 select count(*) into e_genero from estadisticas
 where genero = :new.genero;

 if e_genero = 0 then
  insert into estadisticas values (:new.genero, 0);
 end if;

 if inserting then
  update estadisticas
  set total_libros = total_libros + 1
  where genero = :new.genero;
 end if;

 if updating then
  update estadisticas
  set total_libros = total_libros + 1
  where genero = :new.genero;

  update estadisticas
  set total_libros = total_libros - 1
  where genero = :old.genero;
 end if;

 if deleting then
  update estadisticas
  set total_libros = total_libros - 1
  where genero = :old.genero;
 end if;
end t8;

---Boletín 5---

--1
create or replace trigger t1
after insert or update of dept_no on emple
declare
 cursor c1 is
  select dept_no from depart;
 n_emple number;
begin

 for v1 in c1 loop
  select count(*) into n_emple from emple
  where dept_no = v1.dept_no;

  if n_emple > 7 then
   raise_application_error(-20001, 'Ya hay 7 empleados en el departamento '|| v1.dept_no);
  end if;
 end loop;
end t1;

drop trigger t1;

--2
create or replace trigger  t2
after insert or update on emple
declare
 cursor c1 is
  select dept_no from depart;
 sum_salario number;
begin
 for v1 in c1 loop
  select sum(salario) into sum_salario from emple
  where dept_no = v1.dept_no;

  if sum_salario > 1500000 then
   raise_application_error(-20001, 'La suma de salarios en el departamento '|| :new.dept_no
    ||' supera 1500000 euros');
  end if;
 end loop;
end t2;

drop trigger t2;

--3
create or replace trigger t3
after insert or update on emple
declare
 cursor c1 is
  select dir from emple;
 emp_aCargo number;
begin
 for v1 in c1 loop
  select count(*) into emp_aCargo from emple
  where dir = v1.dir;

  if emp_aCargo >= 5 then
   raise_application_error(-20001, 'Ese jefe ya tiene 5 empleados a su cargo');
  end if;
 end loop;
end t3;

drop trigger t3;

--4
create or replace trigger t4
after insert or update of salario on emple
declare
 cursor c1 is
  select dir, emp_no from emple;
 salario_jefe number;
 salario_emple number;
begin
 for v1 in c1 loop
  select salario into salario_jefe from emple
  where emp_no = v1.dir;

  select salario into salario_emple from emple
  where emp_no = v1.emp_no;

  if salario_emple > salario_jefe then
   raise_application_error(-20001, 'No puede cobrar mas un empleado que su jefe');
  end if;
 end loop;
end t4;

drop trigger t4;

--5
create or replace trigger t5
after insert or update of dept_no on emple
declare
 cursor c1 is
  select dir, emp_no from emple;
 dept_jefe emple.dept_no%type;
 dept_emple emple.dept_no%type;
begin
 for v1 in c1 loop
  select dept_no into dept_jefe from emple
  where emp_no = v1.dir;

  select dept_no into dept_emple from emple
  where emp_no = v1.emp_no;

  if dept_emple != dept_jefe then
   raise_application_error(-20001, 'Empleado y Jefe no pueden pertenecer a departamentos distintos');
  end if;
 end loop;
end t5;

drop trigger t5;

---Boletín 6---

--1
--Vista
create view v1 as
 select apenom, nombre, nota from alumnos, asignaturas, notas
 where alumnos.dni = notas.dni and asignaturas.cod = notas.cod;

--1_1
create or replace trigger t1_1
instead of insert on v1
for each row
declare
 cod_asig asignaturas.cod%type;
 dni_alum alumnos.dni%type;
begin
 select dni into dni_alum from alumnos
 where apenom = :new.apenom;

 select cod into cod_asig from asignaturas
 where nombre = :new.nombre;

 insert into notas values (dni_alum, cod_asig, :new.nota);
end t1_1;

drop trigger t1_1;

--1_2
create or replace trigger t1_2
instead of update on v1
for each row
declare
 cod_asig asignaturas.cod%type;
 dni_alum alumnos.dni%type;
begin
 select dni into dni_alum from alumnos
 where apenom = :new.apenom;

 select cod into cod_asig from asignaturas
 where nombre = :new.nombre;

 update notas
 set nota = :new.nota
 where dni = dni_alum and cod = cod_asig;
end t1_2;

drop trigger t_2;

--1_3
create or replace trigger t1_3
instead of delete on v1
for each row
declare
 cod_asig asignaturas.cod%type;
 dni_alum alumnos.dni%type;
begin
 select dni into dni_alum from alumnos
 where apenom = :old.apenom;

 select cod into cod_asig from asignaturas
 where nombre = :old.nombre;

 delete from notas
 where dni = dni_alum and cod = cod_asig;
end t1_3;

drop trigger t1_3;

--1_4
create or replace trigger t1_4
instead of delete on v1
declare
 dni_alum alumnos.dni%type;
begin
 select dni into dni_alum from alumnos
 where apenom = :old.apenom;

 delete from notas
 where dni = dni_alum;
end t1_4;

drop trigger t1_4;

drop view v1;

--2
--Vista
create or replace view v2 (empleado, departamento, director) as
 select e.apellido, d.dnombre, e1.apellido from emple e, depart d, emple e1
 where e1.emp_no (+)= e.dir and e.dept_no = d.dept_no;

--2_1
create or replace trigger t2_1
instead of insert on v2
for each row
declare
 num_dept depart.dept_no%type;
 num_emple emple.emp_no%type;
 num_dir emple.dir%type;
begin
 select max(emp_no) + 1 into num_emple from emple;

 select dept_no into num_dept from depart
 where dnombre = :new.departamento;

 select emp_no into num_dir from emple
 where apellido = :new.director;

 insert into emple(emp_no, apellido, dir, dept_no)
 values (num_emple, :new.empleado, num_dir, num_dept);
end t2_1;

drop trigger t2_1;

--2_2
create or replace trigger t2_2
instead of update on v2
declare
 num_dept depart.dept_no%type;
 num_emple emple.emp_no%type;
begin
 select emp_no into num_emple from emple
 where apellido = :new.empleado;

 select dept_no into num_dept from depart
 where dnombre = :new.departamento;

 update emple
 set dept_no = num_dept
 where emp_no = num_emple;
end t2_2;

drop trigger t2_2;

--2_3
create or replace trigger t2_3
instead of update on v2
declare
 num_emple emple.emp_no%type;
 num_dir emple.dir%type;
begin
 select emp_no into num_emple from emple
 where apellido = :new.empleado;

 select emp_no into num_dir from emple
 where apellido = :new.director;

 update emple
 set dir = num_dir
 where emp_no = num_emple;
end t2_3;

drop trigger t2_3;

--2_4
create or replace trigger t2_4
instead of delete on v2
declare
    num_emple emple.emp_no%type;
    es_jefe number;
begin
 select emp_no into num_emple from emple
 where apellido = :old.empleado;

 select count(*) into es_jefe from emple
 where dir = num_emple;

 if es_jefe > 0 then
    update emple
    set dir = null
    where dir = num_emple;
 end if;

 delete from emple
 where emp_no = num_emple;
end t2_4;
