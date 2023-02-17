--1
create table auditoria(
 dato varchar2(50)
);

create or replace package pk1 as
 i number;
end pk1;

create or replace trigger t1
before insert or update or delete on emple
begin
 pk1.i := 0;
end t1;

create or replace trigger t2
after insert or update or delete on emple
for each row
begin
 pk1.i := pk1.i + 1;
end t2;

create or replace trigger t3
after insert or update or delete on emple
begin
 if inserting then
  insert into auditoria values('Se han insertado ' || pk1.i ||' filas.');
 elsif updating then
  insert into auditoria values('Se han actualizado ' || pk1.i ||' filas.');
 else
  insert into auditoria values('Se han borrado ' || pk1.i ||' filas.');
 end if;
end t3;

--2
create or replace package pk2 as
 type t_emple is table of emple.emp_no%type index by binary_integer;
 tb_emp t_emple;
end pk2;

create or replace trigger t1
before delete on emple
begin
 pk2.tb_emp.delete;
end t1;

create or replace trigger t2
after delete on emple
for each row
begin
 pk2.tb_emp(:old.emp_no) := :old.emp_no;
end t2;

create or replace trigger t3
after delete on emple
begin
 for i in pk2.tb_emp.first..pk2.tb_emp.last loop
  update emple
  set dir = null
  where dir = pk2.tb_emp(i);
 end loop;
end t3;

--3
create or replace package pk3 as
 type ejer3 is record (
  nuevo emple.dept_no%type,
  viejo emple.dept_no%type
 );
 type t_emple is table of ejer3 index by binary_integer;
 tb_emp t_emple;
 i number;
end pk3;

create or replace trigger t3_1
before update on depart
begin
 pk3.tb_emp.delete;
 pk3.i := 1;
end t3_1;

create or replace trigger t3_2
after update on depart
for each row
begin
 pk3.tb_emp(pk3.i).nuevo := :new.dept_no;
 pk3.tb_emp(pk3.i).viejo := :old.dept_no;
 pk3.i := pk3.i + 1;
end t3_2;

create or replace trigger t3_3
after update on depart
begin
 for j in pk3.tb_emp.first..pk3.tb_emp.last loop
  update emple
  set dept_no = pk3.tb_emp(j).nuevo
  where dept_no = pk3.tb_emp(j).viejo;
 end loop;
end t3_3;

--4
alter table depart
add media_salario number;

create or replace package pk4 as
 type t_salario is table of emple.dept_no%type index by binary_integer;
 tb_sal t_salario;
 i number;
end pk4;

create or replace trigger t1
before insert or update or delete on emple
begin
 pk4.tb_sal.delete;
 pk4.i := 1;
end t1;

create or replace trigger t2
after insert or update or delete on emple
for each row
begin
 if deleting then
  pk4.tb_sal(pk4.i) := :old.dept_no;
 else
  pk4.tb_sal(pk4.i) := :new.dept_no;
 end if;

 pk4.i := pk4.i + 1;
end t2;

create or replace trigger t3
after insert or update or delete on emple
declare
 med number;
begin
 for j in pk4.tb_sal.first..pk4.tb_sal.last loop
  select avg(salario) into med from emple
  where dept_no = pk4.tb_sal(j);

  update depart
  set media_salario = med
  where dept_no = pk4.tb_sal(j);
 end loop;
end t3;
