
#!/bin/bash


#---------------Config---------------
name_of_program="./s21_grep"             # Путь до вашей программы
name_of_system_program="grep"            # Путь до рабочей программы
file_with_test_params="tests.txt"       # Путь до файла с набором тестов
path_to_save_logs="test_logs"           # Путь до папки, в которой все результаты будут сохраняться
check_leaks=1
#------------------------------------

echo "\033[0;32m            _     _  \033[0m"
echo "\033[0;32m           (')-=-(')  \033[0m"
echo '\033[0;32m         __(   "   )__  \033[0m'
echo "\033[0;32m        / _/'-----'\_ \         \033[0m   Vintik Debugger"
echo "\033[0;32m     ___\\\\ \\\\        /  /___         \033[0mversion: 0.2.2"
echo "\033[0;32m     >____)/_\---/_\(____<         \033[1;93mAuthor\033[0m: Anix (s21 : lizziech)"

echo "----------------------------------------------------------------------"


COUNTER=0
FAIL=0
SUCCESS=0
COUNT_OF_NEW_MISTAKE=0
COUNT_OF_FIXED_MISTAKE=0
COUNT_OF_LEAKS=0


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
    
if [ ! -d "${path_to_save_logs}/failed_tests/memory_leaks" ]; then
    mkdir "${path_to_save_logs}/failed_tests/memory_leaks"
else
    rm -rf "${path_to_save_logs}/failed_tests/memory_leaks"
    mkdir "${path_to_save_logs}/failed_tests/memory_leaks"
fi

    while IFS= read -r line
    do
    
        $name_of_system_program $line > "${path_to_save_logs}/test_sys_${name_of_system_program}.log"
        $name_of_program $line > "${path_to_save_logs}/test_your_${name_of_system_program}.log"
        
        DIFF_RES="$(diff -s ${path_to_save_logs}/test_sys_${name_of_system_program}.log ${path_to_save_logs}/test_your_${name_of_system_program}.log)"
        
        (( COUNTER++ ))
        
        if [ "$DIFF_RES" == "Files ${path_to_save_logs}/test_sys_${name_of_system_program}.log and ${path_to_save_logs}/test_your_${name_of_system_program}.log are identical" ]
        then
            if [[ $check_leaks == 1 ]]; then
                leaks -atExit -- "${name_of_system_program}" $line > "${path_to_save_logs}/mem.log"
                LEAK="$(grep -c '0 leaks for 0 total leaked bytes' $path_to_save_logs/mem.log)"
                if [[ "$LEAK" = "1" ]]; then
                    (( SUCCESS++ ))
                else
                    echo "Test: \033[92mOK\033[0m Memory leak: \033[1;91mERROR\033[0m [${line}]"
                    
                    cp "${path_to_save_logs}/mem.log" "${path_to_save_logs}/failed_tests/memory_leaks/memory_leak_test_${COUNTER}.log"
                    
                    echo "${line}" >> "${path_to_save_logs}/list_of_fail_args.log"
                    (( COUNT_OF_LEAKS++ ))
                    (( FAIL++ ))
                fi
            else
                (( SUCCESS++ ))
            fi
            
        else
            
            echo " ${COUNTER} \033[1;91mFAIL\033[0m ${line}"
            
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
    rm "${path_to_save_logs}/mem.log"
    
    if [ -f "${path_to_save_logs}/list_of_fail_args_old.log" ]
    then
            NUMBER_OF_TEST_WITH_NEW_MISTAKE=0
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
                   (( NUMBER_OF_TEST_WITH_NEW_MISTAKE++ ))
                   if [[ "$line" == "$line_new" ]]; then
                        echo "${line}" >> "${path_to_save_logs}/need_correct.log"
                        NEW_MISTAKE=0
                   fi
                    
                done < "${path_to_save_logs}/list_of_fail_args_old.log"
                
                if [ "$NEW_MISTAKE" -eq 1 ]; then
                    echo " ${NUMBER_OF_TEST_WITH_NEW_MISTAKE} \033[1;91mYou made new mistake!\033[0m [$line]"
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
                    echo "\033[92mYou fixed mistake!\033[0m [$line]"
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
   echo "<h1>Vintik v0.2.2</h1>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<h2>Created by Anix (s21 : lizziech)</h2>" >> "${path_to_save_logs}/statistics/index.html"
   echo "<div id=\"stat\" style=\"width: 1500px; height: 600px;\"></div>" >> "${path_to_save_logs}/statistics/index.html"
   echo "</body" >> "${path_to_save_logs}/statistics/index.html"
   echo "</html>" >> "${path_to_save_logs}/statistics/index.html"
  
  

}


testing 0
create_web_page 0

echo ""
echo "--------------------RESULTS--------------------"

if [[ $SUCCESS > 0 ]]; then
    echo "  -> \033[92mSUCCESS $SUCCESS\033[0m"
fi

if [[ $FAIL > 0 ]]; then
    echo "  -> \033[1;91mFAIL ${FAIL}\033[0m"
else
    echo "\033[102mВсе тесты пройдены!\033[0m"
fi

if [[ $COUNT_OF_LEAKS > 0 ]]; then
 echo "  ->\033[1;91m Нужно исправить ${COUNT_OF_LEAKS} утечек!\033[0m"
fi

echo "Quantity tests: ${COUNTER}"
echo "-----------------------------------------------"
echo ""

if [[ $COUNT_OF_FIXED_MISTAKE > 0 ]]; then
 echo "\033[92m[+] Пофиксили ${COUNT_OF_FIXED_MISTAKE} ошибок\033[0m"
fi

if [[ $COUNT_OF_NEW_MISTAKE > 0 ]]; then
 echo "\033[1;91m[-] Появилось ${COUNT_OF_NEW_MISTAKE} ошибок\033[0m"
fi



echo " \033[1;91m[!] Не забудьте проверить стиль\033[0m"
echo " \033[1;93m[+] А также откройте файл ${path_to_save_logs}/statistics/index.html  <3\033[0m"
