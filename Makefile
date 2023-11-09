# Run!
filename := caesar_cipher

# binary generated needs two argument
# data: string to be shifted
# shifter: move count from its original number
# Ex: caesar_cipher('a', 1) = 'b'
# 'a' = 65 in ASCII
# 'b' = 66 in ASCII

start: $(filename)
	target/$(filename) $(data) $(shifter)

# Create binary file
caesar_cipher: $(filename).o
	ld target/$(filename).o -o target/$(filename)

# Create object file
caesar_cipher.o: 
	mkdir -p target/
	as $(filename).s -o target/$(filename).o

# This one to clean up build files
clean:
	rm target/$(filename).o target/$(filename)