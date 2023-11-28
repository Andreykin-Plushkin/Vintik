
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
echo "        / _/'-----'\_ \         Vintik Debugger"
echo "     ___\\\\ \\\\     // //___         version: 0.1 для сдачи проектов"
echo "     >____)/_\---/_\(____<         Author: Anix (s21 : lizziech)"

echo "----------------------------------------------------------------------"


COUNTER=0
FAIL=0
SUCCESS=0

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
            echo "${COUNTER} SUCCESS [ ${line} ]"
            (( SUCCESS++ ))
        else
            echo " ${COUNTER} FAIL [ ${line} ]"
            (( FAIL++ ))
        fi
        
    done < $file_with_test_params
    
    rm "${path_to_save_logs}/test_sys_${name_of_system_program}.log" "${path_to_save_logs}/test_your_${name_of_system_program}.log"
    rm -rf "${path_to_save_logs}"
    
}

testing 0

echo ""
echo "--------------------RESULTS--------------------"
echo "  -> SUCCESS $SUCCESS"
echo "  -> FAIL ${FAIL}"
echo "Quantity tests: ${COUNTER}"
echo "-----------------------------------------------"
