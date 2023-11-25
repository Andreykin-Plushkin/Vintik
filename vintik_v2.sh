#!/bin/bash


#---------------Config---------------
name_of_program="./s21_cat"             # Путь до вашей программы
name_of_system_program="cat"            # Путь до рабочей программы
file_with_test_params="tests.txt"       # Путь до файла с набором тестов
path_to_save_logs="test_logs"           # Путь до папки, в которой все результаты будут сохраняться
#------------------------------------

echo "            _     _ "
echo "           (')-=-(') "
echo '         __(   "   )__ '
echo "        / _/'-----'\_ \ 		Vintik Debugger"
echo "     ___\\\\ \\\\     // //___ 		version: 0.2"
echo "     >____)/_\---/_\(____< 		Author: Anix (s21 : lizziech)"

echo "----------------------------------------------------------------------"


COUNTER=0
FAIL=0
SUCCESS=0
COUNT_OF_NEW_MISTAKE=0
COUNT_OF_FIXED_MISTAKE=0


if [ ! -d "${path_to_save_logs}" ]; then
        mkdir $path_to_save_logs
fi

testing() {

    if [ -d "${path_to_save_logs}/failed_tests" ]; then
        rm -rf "${path_to_save_logs}/failed_tests"
    fi

    if [ ! -d "${path_to_save_logs}/failed_tests" ]; then
        mkdir "${path_to_save_logs}/failed_tests"
    fi
    
    if [ -f "${path_to_save_logs}/list_of_fail_args.log" ]; then
        cp "${path_to_save_logs}/list_of_fail_args.log" "${path_to_save_logs}/list_of_fail_args_old.log"
        rm "${path_to_save_logs}/list_of_fail_args.log"
    fi
    
    touch "${path_to_save_logs}/list_of_fail_args.log"

    while IFS= read -r line
    do
    
        $name_of_system_program $line > "${path_to_save_logs}/test_sys_${name_of_system_program}.log"
        $name_of_program $line > "${path_to_save_logs}/test_your_${name_of_system_program}.log"
        
        DIFF_RES="$(diff -s ${path_to_save_logs}/test_sys_${name_of_system_program}.log ${path_to_save_logs}/test_your_${name_of_system_program}.log)"
        
        (( COUNTER++ ))
        
        if [ "$DIFF_RES" == "Files ${path_to_save_logs}/test_sys_${name_of_system_program}.log and ${path_to_save_logs}/test_your_${name_of_system_program}.log are identical" ]
        then
            (( SUCCESS++ ))
        else
            
            echo " ${COUNTER} FAIL ${line}"
            
            echo "${line}" >> "${path_to_save_logs}/list_of_fail_args.log"
        
            echo "ARGS [$line]" > "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            echo "System_program_${name_of_system_program}" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            echo "------------------OUTPUT System------------------" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            $name_of_system_program $line >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            echo "------------------OUTPUT System------------------" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            echo "" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            
            echo "Your_program_${name_of_system_program}" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            echo "------------------OUTPUT Your------------------" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            $name_of_program $line >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            echo "------------------OUTPUT Your------------------" >> "${path_to_save_logs}/failed_tests/fail_test_${COUNTER}.log"
            
            (( FAIL++ ))
        fi
        
    done < $file_with_test_params
    
    rm "${path_to_save_logs}/test_sys_${name_of_system_program}.log" "${path_to_save_logs}/test_your_${name_of_system_program}.log"
    
    if [ -f "${path_to_save_logs}/list_of_fail_args_old.log" ]
    then

            if [ -f "${path_to_save_logs}/need_correct.log" ]; then
                rm "${path_to_save_logs}/need_correct.log"
            fi

            if [ -f "${path_to_save_logs}/new_mistake.log" ]; then
                rm "${path_to_save_logs}/new_mistake.log"
            fi

            if [ -f "${path_to_save_logs}/fixed_mistake.log" ]; then
                rm "${path_to_save_logs}/fixed_mistake.log"
            fi
            
            touch "${path_to_save_logs}/need_correct.log"
            touch "${path_to_save_logs}/new_mistake.log"
            touch "${path_to_save_logs}/fixed_mistake.log"
            
            while IFS= read -r line
            do
                
                NEW_MISTAKE=1
            
                while IFS= read -r line_new
                do
                   
                   if [[ "$line" == "$line_new" ]]; then
                        echo "${line}" >> "${path_to_save_logs}/need_correct.log"
                        NEW_MISTAKE=0
                   fi
                    
                done < "${path_to_save_logs}/list_of_fail_args_old.log"
                
                if [ "$NEW_MISTAKE" -eq 1 ]; then
                    echo "You made new mistake! [$line]"
                    echo "${line}" >> "${path_to_save_logs}/new_mistake.log"
                    (( COUNT_OF_NEW_MISTAKE++ ))
                fi
                
            done < "${path_to_save_logs}/list_of_fail_args.log"
            
            
            while IFS= read -r line
            do
                
                FIXED_MISTAKE=1
            
                while IFS= read -r line_new
                do
                   
                   if [[ "$line" == "$line_new" ]]; then
                        FIXED_MISTAKE=0
                   fi
                    
                done < "${path_to_save_logs}/list_of_fail_args.log"
                
                
                if [ "$FIXED_MISTAKE" -eq 1 ]; then
                    echo "You fixed mistake! [$line]"
                    echo "${line}" >> "${path_to_save_logs}/fixed_mistake.log"
                    (( COUNT_OF_FIXED_MISTAKE++ ))
                fi
                
            done < "${path_to_save_logs}/list_of_fail_args_old.log"
            
    else
            mv "${path_to_save_logs}/list_of_fail_args.log" "${path_to_save_logs}/list_of_fail_args_old.log"

    fi
    
    
}

create_web_page() { # Создание веб-страницы для вывода удобной статистики

    if [ ! -d "${path_to_save_logs}/statistics" ]; then
        mkdir "${path_to_save_logs}/statistics"
        touch "${path_to_save_logs}/statistics/index.html"
        touch "${path_to_save_logs}/statistics/stats.txt"
    else 
        rm "${path_to_save_logs}/statistics/index.html"
    fi

   echo "${FAIL} ${SUCCESS} ${COUNT_OF_NEW_MISTAKE} ${COUNT_OF_FIXED_MISTAKE}" >> "${path_to_save_logs}/statistics/stats.txt"

   echo "<!DOCTYPE html>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<html>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<head>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<meta charset='utf-8'>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<script src='https://www.google.com/jsapi'></script>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<title>Vintik</title>" >> "${path_to_save_logs}/statistics/index.html"
   #echo "<meta http-equiv='refresh' content='5'>" >> "${path_to_save_logs}/statistics/index.html"
   echo "</head>" >> "${path_to_save_logs}/statistics/index.html"   
   echo "<body>" >> "${path_to_save_logs}/statistics/index.html"

   echo "<script>" >> "${path_to_save_logs}/statistics/index.html"
   echo "google.load(\"visualization\", \"1\", {packages:[\"corechart\"]});" >> "${path_to_save_logs}/statistics/index.html"
   echo "google.setOnLoadCallback(drawChart);" >> "${path_to_save_logs}/statistics/index.html"
   echo "function drawChart() {" >> "${path_to_save_logs}/statistics/index.html"
   echo "var data = google.visualization.arrayToDataTable([" >> "${path_to_save_logs}/statistics/index.html"
   echo "['Номер теста','Успешные тесты','Провальные тесты','Исправлено','Новые ошибки']," >> "${path_to_save_logs}/statistics/index.html"

   NUMBER_OF_TEST=1

   while read quantity_fail quantity_success count_of_new_mistake count_of_fixed_mistake; do

    echo "[${NUMBER_OF_TEST}, ${quantity_success}, ${quantity_fail}, ${count_of_fixed_mistake}, ${count_of_new_mistake}]," >> "${path_to_save_logs}/statistics/index.html"
    (( NUMBER_OF_TEST++ ))

   done < "${path_to_save_logs}/statistics/stats.txt"

   echo "[0,0,0,0,0]]);" >> "${path_to_save_logs}/statistics/index.html"
    

    echo "var chart = new google.visualization.ColumnChart(document.getElementById(\"stat\"));" >> "${path_to_save_logs}/statistics/index.html"
    echo "chart.draw(data);}" >> "${path_to_save_logs}/statistics/index.html"
    
   
  

   echo "</script>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<h1>Vintik v0.2</h1>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<h2>Created by Anix (s21 : lizziech)</h2>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<div id=\"stat\" style=\"width: 1500px; height: 600px;\"></div>" >> "${path_to_save_logs}/statistics/index.html"
   echo "</body" >> "${path_to_save_logs}/statistics/index.html" 
   echo "</html>" >> "${path_to_save_logs}/statistics/index.html" 
  
  

}


testing 0
create_web_page 0

echo ""
echo "--------------------RESULTS--------------------"
echo "  -> SUCCESS $SUCCESS"
echo "  -> FAIL ${FAIL}"
echo "Quantity tests: ${COUNTER}"
echo "-----------------------------------------------"
echo ""
echo " [!] Не забудьте проверить стиль и утечки!"
echo " [+] А также откройте файл ${path_to_save_logs}/statistics/index.html  <3"

