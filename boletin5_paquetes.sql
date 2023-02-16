--1
create or replace package pk1 as
 type t_deptNo is table of depart.dept_no%type index by binary_integer;
 tb_deptNo t_deptNo;
end pk1;

create or replace trigger t1
before insert or update on emple
begin
 pk1.v_deptNo.delete;
end t1;

create or replace trigger t2
after insert or update on emple
for each row
begin
 pk1.tb_deptNo(:new.dept_no) := :new.dept_no;
end t2;

create or replace trigger t3
after insert or update on emple
declare
 numero_Emple number;
begin
 for v in pk1.tb_deptNo.first..pk1.tb_deptNo.last loop
  select count(*) into numero_Emple from emple
  where dept_no = pk1.tb_deptNo(v);
 
  if numero_Emple > 7 then
   raise_application_error(-20001, 'El departamento no puede tener más de 7 empleados');
  end if;
 end loop;
end t3;

--2
create or replace package pk2 as
 type t_deptNo is table of depart.dept_no%type index by binary_integer;
 tb_deptNo t_deptNo;
end pk2;

create or replace trigger t1
before insert or update on emple
begin
 pk2. tb_deptNo.delete;
end t1;

create or replace trigger t2
after insert or update on emple
for each row
begin
 pk2.tb_deptNo(:new.dept_no) := :new.dept_no;
end t2;

create or replace trigger t3
after insert or update on emple
declare
 sum_salario number;
begin
 for v in pk2.tb_deptNo.first..pk2.tb_deptNo.last loop
  select sum(salario) into sum_salario from emple
  where dept_no = pk2.tb_deptNo(v);
  
  if sum_salario > 1500000 then
   raise_application_error(-20001, 'El departamento no puede tener una suma salarial mayor a 1500000');
  end if;
 end loop;
end t3;

--3
create or replace package pk3 as
 type t_dir is table of emple.emp_no%type index by binary_integer;
 tb_dir t_dir;
end pk3;

create or replace trigger t1
before insert or update on emple
begin
 pk3.tb_dir.delete;
end t1;

create or replace trigger t2
after insert or update on emple
for each row
begin
 pk3.tb_dir(:new.dir) := :new.dir;
end t2;

create or replace trigger t3
after insert or update on emple
declare
 numero_Emple number;
begin
 for v in pk3.tb_dir.first..pk3.tb_dir.last loop
  select count(*) into numero_Emple from emple
  where dir = pk3.tb_dir(v);
 
  if numero_Emple > 5 then
   raise_application_error(-20001, 'El jefe ya tiene 5 empleados a su cargo');
  end if;
 end loop;
end t3;

--4
create or replace package pk4 as
 type t_emple is table of emple%rowtype index by binary_integer;
 tb_emple t_emple;
 i number;
end pk4;

create or replace trigger t1
before insert or update on emple
begin  
 pk4.tb_emple.delete;
 pk4.i := 1;
end t1;

create or replace trigger t2
after insert or update on emple
for each row
begin
 if inserting then
	pk4.tb_emple(pk4.i).dir := :new.dir;
 else
  pk4.tb_emple(pk4.i).dir := :old.dir;
 end if;
 pk4.tb_emple(pk4.i).salario := :new.salario;
 pk4.i := pk4.i + 1;
end t2;

create or replace trigger t3
after insert or update on emple
declare
 v_salario emple.salario%type;
begin
 for v in pk4.tb_emple.first.. pk4.tb_emple.last loop
  select salario into v_salario from emple
  where emp_no = pk4.tb_emple(v).dir;
 
  if v_salario < pk4.tb_emple(v).salario then
   raise_application_error(-20001, 'El empleado no puede tener más salario que el jefe');
  end if;
 end loop;
end t3;

--5
create or replace package pk5 as
 type t_emple is table of emple%rowtype index by binary_integer;
 tb_emp t_emple;
 i number;
end pk5;

create or replace trigger t1
before insert or update on emple
begin
 pk5.tb_emp.delete;
 pk5.i := 1;
end t1;

create or replace trigger t2
after insert or update on emple
for each row
begin
 if inserting then
  pk5.tb_emp(pk5.i).dir := :new.dir;
 else
  pk5.tb_emp(pk5.i).dir := :old.dir;
 end if;
 
 pk5.tb_emp(pk5.i).dept_no := :new.dept_no;
 pk5.i := pk5.i + 1;
end t2;

create or replace trigger t3
after insert or update on emple
declare
 v_dept emple.dept_no%type;
begin
 for v in pk5.tb_emp.first..pk5.tb_emp.last loop
  select dept_no into v_dept from emple
  where emp_no = pk5.tb_emp(v).dir;
 
  if v_dept <> pk5.tb_emp(v).dept_no then
   raise_application_error(-20001, 'El empleado y el jefe no pueden pertenecer a departamentos distintos');
  end if;
 end loop;
end t3;