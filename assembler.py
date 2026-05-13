with open('code.txt', 'r') as asm:
	with open('program.hex', 'w+') as fout:
		for command in asm:
			opcode = "0" * 32
			code = command.split(" ")
			if code[0] == "ldi":
