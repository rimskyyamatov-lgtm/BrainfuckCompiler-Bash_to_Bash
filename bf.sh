#!/bin/bash
echo '#!/bin/bash'
echo 'ptr=0'
echo 'declare -a mem'
echo 'for ((i=0;i<30000;i++));do mem[i]=0;done'
indent=""
last=""
count=0
flush() {
    case "$last" in
        "+") echo "${indent}((mem[ptr]+=$count))" ;;
        "-") echo "${indent}((mem[ptr]-=$count))" ;;
        ">") echo "${indent}((ptr+=$count))" ;;
        "<") echo "${indent}((ptr-=$count))" ;;
    esac
}
while IFS= read -r -n1 c; do
    case "$c" in
        "+"|"-"|">"|"<")
            if [ "$c" = "$last" ]; then
                count=$((count+1))
                continue
            else
                if [ "$count" -gt 0 ]; then
                    flush
                fi
                last="$c"
                count=1
                continue
            fi
        ;;
    esac
    if [ "$count" -gt 0 ]; then
        flush
        count=0
    fi
    case "$c" in
        ".")
            echo "${indent}printf \"\\\\\$(printf '%03o' \${mem[ptr]})\""
        ;;
        ",")
            echo "${indent}read -n1 c; mem[ptr]=\$(printf \"%d\" \"'\$c\")"
        ;;
        "[")
            echo "${indent}while ((mem[ptr])); do"
            indent="$indent    "
        ;;
        "]")
            indent="${indent:4}"
            echo "${indent}done"
        ;;
    esac
done < "$1"
if [ "$count" -gt 0 ]; then
    flush
fi
