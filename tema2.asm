extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

convert_from_hex:

        push ebp
        mov ebp, esp
        push ebx
        push ecx
        push edx
        
        mov ecx, 0
        mov edx, 0
        
        mov eax, 0
        mov ecx, [ebp + 8]
        
        cmp cl, 97
        jl add_to_eax
        mov bl, 10
        sub cl, 97
        add bl, cl 
        mov cl, bl
        jmp do_the_add
        
add_to_eax:
        sub ecx, "0"

do_the_add:
        add eax, ecx
        
        mov edx, [ebp + 12]
        
        cmp dl, 97
        jl add_to_eax2
        mov bl, 10
        sub dl, 97
        add bl, dl
        mov dl, bl
        jmp do_the_add2
        
add_to_eax2:
        sub edx, "0"
        
do_the_add2:
        shl edx, 4
        add eax, edx
        
        pop edx
        pop ecx
        pop ebx
        leave
        ret

xor_strings:
        ; TODO TASK 1
        
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]
        mov ecx, 0
        
parse_string:
        mov al, [esi + ecx]
        mov bl, [edi + ecx]
        
        cmp al, 0
        je done
        xor al, bl
        mov [esi + ecx], al
        inc ecx
        jmp parse_string
 
done:       
        leave
        ret

rolling_xor:
        ; TODO TASK 2
        
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8]
        mov ecx, 1
        mov al, 0
        
decrypt:
        xor al, [esi + ecx - 1]
        mov bl, [esi + ecx]
        cmp bl, 0
        je end_of_string
        xor bl, al
        mov [esi + ecx], bl
        inc ecx
        jmp decrypt
        
        
end_of_string:        
        leave
        ret

xor_hex_strings:
        ; TODO TASK 3
        
        push ebp
        mov ebp, esp
        
        
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]
        mov ecx, 0
        mov edx, 0
        
parse_hex_string:
        mov al, [esi + ecx]
        
        cmp al, "."
        je done_hex
        
        mov bl, [esi + ecx + 1]
        push edx
        
        push eax
        push ebx
        call convert_from_hex
        add esp, 8
        
        mov ebx, eax
        push ebx
        
        mov al, [edi + ecx]
        mov bl, [edi + ecx + 1]
        
        push eax
        push ebx
        call convert_from_hex
        add esp, 8
        
        mov edx, eax
        pop ebx
        
        xor bl, dl
        
        pop edx
        mov [esi + edx], bl
        add ecx, 2
        inc edx
        
        cmp edx, [ebp + 16]
        jl parse_hex_string
 
done_hex:       
        mov byte [esi + edx], 0
        leave
        ret

base32decode:
        ; TODO TASK 4
        
        push ebp
        mov ebp, esp
        
        mov esi, [ebp + 8]
        
        push esi
        call strlen
        pop esi
        
        mov edx, eax
        mov eax, 0
        mov ebx, 0
        mov ecx, 0
        
parse_str:
        mov al, byte [esi + ecx]
        
        cmp al, "A"
        jl convert_number
        
convert_letter:
        sub al, "A"
        jmp end_convert

convert_number:
        sub al, "0"
        add al, 24
        
end_convert:
        shl ebx, 5
        add ebx, eax
       
        mov esp, ebp
        pop ebp
        ret

bruteforce_singlebyte_xor:
        ; TODO TASK 5
        ret

decode_vigenere:
        ; TODO TASK 6
        
        push ebp
        mov ebp, esp
        sub esp, 4
        
        mov esi, [ebp + 8]
        mov edi, [ebp + 12]
        
        push edi
        call strlen
        pop edi
        
        mov [ebp - 4], eax
        
        mov eax, 0
        mov ecx, 0
        mov edx, 0
        
parse_encoded_string:
        mov al, [esi + ecx]
        cmp al, 0
        je end_parse
        mov bl, [edi + edx]
        sub bl, "a"
        sub al, bl
        cmp al, "a"
        jge continue_parsing
        push ecx
        mov cl, 96
        sub cl, al
        mov al, 122
        sub al, cl
        pop ecx
        
continue_parsing:        
        mov [esi + ecx], al
        inc ecx
        inc edx
        cmp edx, [ebp - 8]
        jl parse_encoded_string
        mov edx, 0
        jmp parse_encoded_string
        
end_parse:
        mov esp, ebp
        pop ebp
        ret

main:
        push ebp
        mov ebp, esp
        sub esp, 2300

        ; test argc
        mov eax, [ebp + 8]
        cmp eax, 2
        jne exit_bad_arg

        ; get task no
        mov ebx, [ebp + 12]
        mov eax, [ebx + 4]
        xor ebx, ebx
        mov bl, [eax]
        sub ebx, '0'
        push ebx

        ; verify if task no is in range
        cmp ebx, 1
        jb exit_bad_arg
        cmp ebx, 6
        ja exit_bad_arg

        ; create the filename
        lea ecx, [filename + 7]
        add bl, '0'
        mov byte [ecx], bl

        ; fd = open("./input{i}.dat", O_RDONLY):
        mov eax, 5
        mov ebx, filename
        xor ecx, ecx
        xor edx, edx
        int 0x80
        cmp eax, 0
        jl exit_no_input

        ; read(fd, ebp - 2300, inputlen):
        mov ebx, eax
        mov eax, 3
        lea ecx, [ebp-2300]
        mov edx, [inputlen]
        int 0x80
        cmp eax, 0
        jl exit_cannot_read

        ; close(fd):
        mov eax, 6
        int 0x80

        ; all input{i}.dat contents are now in ecx (address on stack)
        pop eax
        cmp eax, 1
        je task1
        cmp eax, 2
        je task2
        cmp eax, 3
        je task3
        cmp eax, 4
        je task4
        cmp eax, 5
        je task5
        cmp eax, 6
        je task6
        jmp task_done

task1:
        ; TASK 1: Simple XOR between two byte streams

        ; TODO TASK 1: find the address for the string and the key
        ; TODO TASK 1: call the xor_strings function
        
        push ecx
        call strlen
        pop ecx
        
        mov esi, ecx
        inc eax
        add ecx, eax
        mov edi, ecx
        
        push edi
        push esi
        call xor_strings
        pop ecx
        add esp, 4

        push ecx
        call puts                   ;print resulting string
        add esp, 4

        jmp task_done

task2:
        ; TASK 2: Rolling XOR

        ; TODO TASK 2: call the rolling_xor function
        
        push ecx
        call rolling_xor
        pop ecx

        push ecx
        call puts
        add esp, 4

        jmp task_done

task3:
        ; TASK 3: XORing strings represented as hex strings

        ; TODO TASK 1: find the addresses of both strings
        ; TODO TASK 1: call the xor_hex_strings function
        
        push ecx
        call strlen
        pop ecx
        
        mov esi, ecx
        inc eax
        add ecx, eax
        mov edi, ecx
        
        dec eax
        shr eax, 1
        push eax
        push edi
        push esi
        call xor_hex_strings
        pop ecx
        add esp, 4

        push ecx                     ;print resulting string
        call puts
        add esp, 4

        jmp task_done

task4:
        ; TASK 4: decoding a base32-encoded string

        ; TODO TASK 4: call the base32decode function
        
        push ecx
        call base32decode
        pop ecx
	
        push ecx
        call puts                    ;print resulting string
        pop ecx
	
        jmp task_done

task5:
        ; TASK 5: Find the single-byte key used in a XOR encoding

        ; TODO TASK 5: call the bruteforce_singlebyte_xor function

        push ecx                    ;print resulting string
        call puts
        pop ecx

        push eax                    ;eax = key value
        push fmtstr
        call printf                 ;print key value
        add esp, 8

        jmp task_done

task6:
        ; TASK 6: decode Vignere cipher

        ; TODO TASK 6: find the addresses for the input string and key
        ; TODO TASK 6: call the decode_vigenere function

        push ecx
        call strlen
        pop ecx

        add eax, ecx
        inc eax

        push eax
        push ecx                   ;ecx = address of input string 
        call decode_vigenere
        pop ecx
        add esp, 4

        push ecx
        call puts
        add esp, 4

task_done:
        xor eax, eax
        jmp exit

exit_bad_arg:
        mov ebx, [ebp + 12]
        mov ecx , [ebx]
        push ecx
        push usage
        call printf
        add esp, 8
        jmp exit

exit_no_input:
        push filename
        push error_no_file
        call printf
        add esp, 8
        jmp exit

exit_cannot_read:
        push filename
        push error_cannot_read
        call printf
        add esp, 8
        jmp exit

exit:
        mov esp, ebp
        pop ebp
        ret