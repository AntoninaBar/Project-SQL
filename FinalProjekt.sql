/* Final Project*/

/*Необхідно виконати наступні запити:
1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.
2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників
3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік
4. Покажіть відділи в яких зараз працює більше 15000 співробітників.
5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище
6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.
7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу*/


/*Покажіть середню зарплату співробітників за кожен рік, до 2005 року.*/

SELECT YEAR(salaries.from_date) AS report_year, ROUND(AVG(salaries.salary),0) AS avg_salary 
FROM salaries
GROUP BY report_year
HAVING report_year BETWEEN MIN(YEAR(salaries.from_date)) AND 2005
ORDER BY report_year;

/*Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників*/

SELECT departments.dept_name AS departments, ROUND(AVG(salaries.salary),0) AS avg_salary  
FROM salaries
JOIN dept_emp ON dept_emp.emp_no = salaries.emp_no AND (CURRENT_DATE() BETWEEN salaries.from_date AND salaries.to_date) AND  (CURRENT_DATE() BETWEEN dept_emp.from_date AND dept_emp.to_date)
JOIN departments ON departments.dept_no = dept_emp.dept_no
GROUP BY departments
ORDER BY avg_salary DESC;

/*Покажіть середню зарплату співробітників по кожному відділу за кожний рік*/

SELECT  departments.dept_name AS departments, YEAR(salaries.from_date) AS report_year, ROUND(AVG(salaries.salary),0) AS avg_salary  
FROM salaries
JOIN dept_emp ON dept_emp.emp_no = salaries.emp_no
JOIN departments ON departments.dept_no = dept_emp.dept_no
GROUP BY departments, report_year 
ORDER BY departments, report_year;

/*Покажіть відділи в яких зараз працює більше 15000 співробітників.*/

SELECT departments.dept_name AS departments, COUNT(dept_emp.emp_no) AS count_emp 
FROM dept_emp
JOIN departments ON departments.dept_no = dept_emp.dept_no AND (CURRENT_DATE() BETWEEN dept_emp.from_date AND dept_emp.to_date)
GROUP BY departments
HAVING count_emp  > 15000
ORDER BY count_emp ASC;

/*Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище*/

SELECT employees.emp_no, employees.last_name, departments.dept_name AS departments, employees.hire_date
FROM employees
JOIN dept_emp ON dept_emp.emp_no = employees.emp_no AND (CURRENT_DATE() BETWEEN dept_emp.from_date AND dept_emp.to_date)
JOIN departments ON departments.dept_no = dept_emp.dept_no
WHERE employees.hire_date IN (SELECT min(hire_date) FROM employees 
                              JOIN dept_emp ON dept_emp.emp_no = employees.emp_no AND (CURRENT_DATE() BETWEEN dept_emp.from_date AND dept_emp.to_date));


/*Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.*/

WITH
Salary_emp AS (SELECT salaries.emp_no, departments.dept_name AS departments, salaries.salary
               FROM salaries
               JOIN dept_emp ON dept_emp.emp_no = salaries.emp_no AND (CURRENT_DATE() BETWEEN dept_emp.from_date AND dept_emp.to_date)
               JOIN departments ON departments.dept_no = dept_emp.dept_no
               WHERE (CURRENT_DATE() BETWEEN salaries.from_date AND salaries.to_date)),
Avg_salary_to_departments AS (SELECT departments.dept_name AS departments, ROUND(avg(salaries.salary),0) AS avg_salary 
						      FROM salaries 
                              JOIN dept_emp ON dept_emp.emp_no = salaries.emp_no AND (CURRENT_DATE() BETWEEN dept_emp.from_date AND dept_emp.to_date)
                              JOIN departments ON departments.dept_no = dept_emp.dept_no
                              WHERE (CURRENT_DATE() BETWEEN salaries.from_date AND salaries.to_date)
                              GROUP BY departments),
Diff_salary AS (SELECT salary_emp.emp_no, salary_emp.salary - avg_salary_to_departments.avg_salary AS salary_difference
                FROM salary_emp
                JOIN avg_salary_to_departments ON salary_emp.departments = avg_salary_to_departments.departments)
                
SELECT * FROM diff_salary
ORDER BY salary_difference DESC
LIMIT 10;

/*Для кожного відділу покажіть другого по порядку менеджера.
Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу*/

WITH
Manager_rank AS (SELECT departments.dept_name AS departments, CONCAT(employees.first_name,' ',employees.last_name) AS manager, employees.hire_date, dept_manager.from_date, ROW_NUMBER() OVER (PARTITION BY dept_manager.dept_no ORDER BY dept_manager.from_date ASC) AS rn
				 FROM employees
				 JOIN dept_manager ON dept_manager.emp_no = employees.emp_no 
				 JOIN departments ON departments.dept_no = dept_manager.dept_no)
SELECT departments, manager, hire_date, from_date FROM Manager_rank
WHERE rn = 2;




