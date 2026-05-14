with open('code.txt', 'r') as asm:
	with open('program.hex', 'w+') as fout:
		for command in asm:
			opcode = "0" * 32
			code = command.split(" ")
			if code[0] == "ldi":
				opcode = f"{1:08b}" + "0" * 4 + f"{int(code[1][1:]):04b}" + f"{int(code[2]):08b}"
			elif code[0] == "mov":
				opcode = f"{2:08b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2][1:]):04b}" + "0" * 8
			elif code[0] == "add":
				opcode = f"{3:08b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2][1:]):04b}" + "0" * 8
			elif code[0] == "sub":
				opcode = f"{5:08b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2][1:]):04b}" + "0" * 8
			elif code[0] == "neg":
				opcode = f"{4:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + "0" * 8
			elif code[0] == "inc":
				opcode = f"{6:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + "0" * 8
			elif code[0] == "dec":
				opcode = f"{7:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + "0" * 8
			elif code[0] == "jmp":
				opcode = f"{8:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2]):08b}"
			elif code[0] == "brne":
				opcode = f"{9:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2]):08b}"
			elif code[0] == "breq":
				opcode = f"{10:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2]):08b}"
			elif code[0] == "lds":
				opcode = f"{11:08b}" + f"{0:04b}" + f"{int(code[1][1:]):04b}" + f"{int(code[2]):08b}"
			elif code[0] == "sts":
				opcode = f"{12:08b}" + f"{0:04b}" + f"{int(code[2][1:]):04b}" + f"{int(code[1]):08b}"
			fout.write(opcode + "\n")
